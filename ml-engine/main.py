"""FastAPI entrypoint for the ML engine."""

from __future__ import annotations

import os
import tempfile
import threading
from pathlib import Path

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

import config
from analyzer.exceptions import AnalysisError, ValidationError

config.OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

app = FastAPI(
    title="Golf Swing Analyzer — ML Engine",
    description="Processes golf swing videos with YOLOv8-pose pose estimation.",
    version="0.2.0",
)

app.mount("/outputs", StaticFiles(directory=str(config.OUTPUT_DIR)), name="outputs")

# Lazy model load so /health responds before YOLO finishes initializing.
_lock = threading.Lock()
_pipeline = None
_model_error: str | None = None
_model_ready = False


def _get_pipeline():
    """Load YOLO + pipeline once (thread-safe)."""
    global _pipeline, _model_error, _model_ready
    if _pipeline is not None:
        return _pipeline
    with _lock:
        if _pipeline is not None:
            return _pipeline
        try:
            from ultralytics import YOLO
            from analyzer.pipeline import SwingAnalysisPipeline

            pose = Path(config.MODEL_PATH)
            if pose.is_dir():
                raise RuntimeError(
                    f"{pose} is a directory — Docker created it because the host "
                    "weight file was missing. Remove that directory and copy a real "
                    "yolov8n-pose.pt onto the host, then recreate the container."
                )
            print(f"==> Loading pose model: {config.MODEL_PATH}", flush=True)
            model = YOLO(config.MODEL_PATH)
            _pipeline = SwingAnalysisPipeline(model)
            _model_ready = True
            _model_error = None
            print("==> Pose model ready", flush=True)
            return _pipeline
        except Exception as exc:
            _model_error = str(exc)
            _model_ready = False
            raise


@app.on_event("startup")
def _warm_model_in_background() -> None:
    """Start model load after the HTTP server is listening (health can pass)."""

    def _load() -> None:
        try:
            _get_pipeline()
        except Exception as exc:
            print(f"==> Model warm-up failed: {exc}", flush=True)

    threading.Thread(target=_load, daemon=True, name="yolo-warmup").start()


@app.get("/health")
async def health_check():
    # Always 200 once uvicorn is up — compose depends_on can proceed.
    # "ready" tells you whether analyze-swing will work yet.
    return {
        "status": "ok",
        "ready": _model_ready,
        "model_error": _model_error,
    }


@app.post("/analyze-swing")
async def analyze_swing(
    video: UploadFile = File(...),
    club: str = Form("iron_7"),
    shot_type: str = Form("full_swing"),
):
    if not video.filename:
        raise HTTPException(status_code=400, detail="No file provided")

    try:
        pipeline = _get_pipeline()
    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail=f"Model not ready: {exc}",
        ) from exc

    suffix = Path(video.filename).suffix or ".mp4"
    tmp_path: str | None = None

    try:
        with tempfile.NamedTemporaryFile(
            prefix="temp_swing_", suffix=suffix, delete=False
        ) as tmp:
            tmp_path = tmp.name
            content = await video.read()
            tmp.write(content)

        result = pipeline.run(tmp_path, club=club, shot_type=shot_type)
        return pipeline.to_dict(result)

    except ValidationError as exc:
        return JSONResponse(
            status_code=422,
            content={
                "status": "error",
                "code": exc.code,
                "error": str(exc),
            },
        )
    except AnalysisError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {exc}") from exc
    finally:
        if tmp_path and os.path.exists(tmp_path):
            os.remove(tmp_path)
