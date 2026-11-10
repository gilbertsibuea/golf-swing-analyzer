"""Draw skeleton overlay and motion trails on video frames."""

from __future__ import annotations

from collections import deque

import cv2
import numpy as np

import config
from analyzer.keypoints import SKELETON_CONNECTIONS, TRAIL_JOINTS
from analyzer.pose import FramePose


def _draw_joint(frame: np.ndarray, x: float, y: float, conf: float) -> None:
    if conf < config.MIN_POSE_CONFIDENCE:
        return
    cv2.circle(frame, (int(x), int(y)), config.JOINT_RADIUS, config.COLOR_JOINT, -1, cv2.LINE_AA)


def draw_pose(frame: np.ndarray, pose: FramePose, trails: dict[int, deque]) -> np.ndarray:
    output = frame.copy()
    kp = pose.keypoints

    for i, j in SKELETON_CONNECTIONS:
        if kp[i, 2] < config.MIN_POSE_CONFIDENCE or kp[j, 2] < config.MIN_POSE_CONFIDENCE:
            continue
        pt1 = (int(kp[i, 0]), int(kp[i, 1]))
        pt2 = (int(kp[j, 0]), int(kp[j, 1]))
        cv2.line(output, pt1, pt2, config.COLOR_SKELETON, config.SKELETON_THICKNESS, cv2.LINE_AA)

    for idx in range(kp.shape[0]):
        _draw_joint(output, kp[idx, 0], kp[idx, 1], kp[idx, 2])
        if idx in TRAIL_JOINTS and kp[idx, 2] >= config.MIN_POSE_CONFIDENCE:
            trails[idx].append((int(kp[idx, 0]), int(kp[idx, 1])))

    for idx, points in trails.items():
        for i in range(1, len(points)):
            alpha = i / len(points)
            thickness = max(1, int(2 * alpha))
            cv2.line(output, points[i - 1], points[i], config.COLOR_TRAIL, thickness, cv2.LINE_AA)

    return output


def render_annotated_video(
    input_path: str,
    output_path: str,
    poses: list[FramePose | None],
    meta_width: int,
    meta_height: int,
    meta_fps: float,
    start_frame: int = 0,
    end_frame: int | None = None,
    slow_output_path: str | None = None,
    slowmo_factor: int = 1,
) -> None:
    """
    Draw overlays once, transcode to H.264 once.
    Optional slowmo is derived from the final H.264 via ffmpeg setpts (not OpenCV repeats).
    """
    from analyzer.video_io import (
        create_video_writer,
        generate_slowmo_video,
        iter_frames,
        transcode_for_browser,
    )

    writer = create_video_writer(output_path, meta_width, meta_height, meta_fps)
    trails: dict[int, deque] = {idx: deque(maxlen=20) for idx in TRAIL_JOINTS}

    try:
        for i, frame in enumerate(iter_frames(input_path, start_frame, end_frame)):
            pose = poses[i] if i < len(poses) else None
            if pose is not None:
                frame = draw_pose(frame, pose, trails)
            writer.write(frame)
    finally:
        writer.release()

    transcode_for_browser(output_path)

    repeats = max(1, slowmo_factor)
    if (
        config.GENERATE_SLOWMO
        and slow_output_path
        and repeats > 1
    ):
        generate_slowmo_video(output_path, slow_output_path, repeats)
