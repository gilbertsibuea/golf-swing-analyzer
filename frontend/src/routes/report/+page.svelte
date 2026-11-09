<script lang="ts">
	import { onMount } from 'svelte';
	import DetailedMetrics from '$lib/components/DetailedMetrics.svelte';
	import NextSwingFocus from '$lib/components/NextSwingFocus.svelte';
	import SpiderChart from '$lib/components/SpiderChart.svelte';
	import { getAnnotatedVideoUrl, loadReport } from '$lib/api';
	import type { SwingAnalysis } from '$lib/types';
	import { CLUB_LABELS, SHOT_LABELS } from '$lib/types';

	let report = $state<SwingAnalysis | null>(null);
	let ready = $state(false);
	let videoError = $state(false);
	let videoRetry = $state(0);
	let videoMode = $state<'normal' | 'slow'>('normal');

	const videoUrl = $derived.by(() => {
		if (!report) return null;
		const path =
			videoMode === 'slow' && report.annotated_video_slow_url
				? report.annotated_video_slow_url
				: report.annotated_video_url;
		return path ? getAnnotatedVideoUrl(path) : null;
	});

	const slowmoFactor = $derived(report?.slowmo_factor ?? 4);

	onMount(() => {
		report = loadReport();
		ready = true;
	});

	$effect(() => {
		if (videoUrl) {
			videoError = false;
		}
	});

	function retryVideo() {
		videoError = false;
		videoRetry += 1;
	}

	function setVideoMode(mode: 'normal' | 'slow') {
		if (mode === videoMode) return;
		videoMode = mode;
		videoError = false;
		videoRetry += 1;
	}

	function formatDate(iso: string): string {
		return new Date(iso).toLocaleString('en-US', {
			day: 'numeric',
			month: 'long',
			year: 'numeric',
			hour: '2-digit',
			minute: '2-digit'
		});
	}
</script>

<section class="container-page py-8 sm:py-10">
	{#if !ready}
		<div class="flex min-h-[50vh] w-full items-center justify-center">
			<p class="text-sm text-muted">Loading report…</p>
		</div>
	{:else if !report}
		<div
			class="flex min-h-[60vh] w-full flex-col items-start justify-center border border-border bg-graphite px-5 py-12 sm:px-8 sm:py-16"
		>
			<p class="label">Report</p>
			<h1 class="mt-2 max-w-xl font-display text-2xl font-bold tracking-tight text-offwhite sm:text-3xl">
				No analysis yet
			</h1>
			<p class="mt-3 max-w-md text-sm leading-relaxed text-muted">
				Upload a swing video to generate your performance report. Results appear here after analysis
				finishes.
			</p>
			<div class="mt-8 flex w-full flex-col gap-3 sm:w-auto sm:flex-row">
				<a href="/analyze" class="btn-primary w-full sm:w-auto">Start analysis</a>
				<a href="/" class="btn-secondary w-full sm:w-auto">Back to home</a>
			</div>
		</div>
	{:else}
		<!-- Header -->
		<div
			class="mb-6 flex flex-col gap-4 border-b border-border pb-6 sm:mb-8 sm:flex-row sm:items-end sm:justify-between"
		>
			<div class="min-w-0">
				<p class="label">Session report</p>
				<h1 class="page-title">Analysis results</h1>
				<p class="mt-1 text-xs text-disabled">{formatDate(report.analyzed_at)}</p>
			</div>
			<div class="flex min-w-0 flex-wrap items-center gap-3 text-xs text-muted">
				<span>{CLUB_LABELS[report.club] ?? report.club}</span>
				<span class="text-border">|</span>
				<span>{SHOT_LABELS[report.shot_type] ?? report.shot_type}</span>
				{#if report.tuning?.profile_id}
					<span class="text-border">|</span>
					<span class="text-disabled" title="Tuning profile">Profile: {report.tuning.profile_id}</span>
				{/if}
				<span class="text-border">|</span>
				<span class="truncate">{report.filename}</span>
			</div>
		</div>

		<!-- Main analysis: Spider chart + score -->
		<div class="card mb-5 w-full min-w-0 sm:mb-6">
			<p class="label mb-6">Main analysis</p>
			<div class="grid w-full min-w-0 items-center gap-8 lg:grid-cols-2">
				<div class="flex justify-center">
					<SpiderChart summary={report.metrics.summary} size={320} />
				</div>
				<div
					class="flex flex-col items-center justify-center gap-4 border-t border-border pt-6 lg:border-l lg:border-t-0 lg:pl-8 lg:pt-0"
				>
					<div class="text-center">
						<p class="label">Overall score</p>
						<p class="font-display text-6xl font-bold tabular-nums text-offwhite">{report.score}</p>
						<p class="mt-1 text-sm text-muted">out of 100</p>
					</div>
					<div
						class="grid w-full max-w-xs grid-cols-2 gap-2 text-center text-xs sm:max-w-sm sm:grid-cols-3"
					>
						{#each [
							{ label: 'Tempo', value: report.metrics.summary.tempo },
							{ label: 'Posture', value: report.metrics.summary.posture },
							{ label: 'Rotation', value: report.metrics.summary.rotation },
							{ label: 'Balance', value: report.metrics.summary.balance },
							{ label: 'Head', value: report.metrics.summary.head_stability }
						] as item}
							<div class="border border-border bg-obsidian px-2 py-2">
								<p class="text-muted">{item.label}</p>
								<p class="font-display font-semibold text-offwhite">{item.value}</p>
							</div>
						{/each}
					</div>
				</div>
			</div>
		</div>

		<!-- Notes / Recommendation -->
		<div class="card mb-5 w-full min-w-0 sm:mb-6">
			<p class="label">Analysis notes</p>
			<p class="mt-3 text-sm leading-relaxed text-offwhite">{report.recommendation}</p>
			{#if report.validation}
				<div class="mt-4 border-t border-border pt-4">
					<p class="label mb-2">Video quality</p>
					<div class="flex flex-wrap gap-4 text-xs text-muted">
						<span>Sharpness: {report.validation.sharpness.toFixed(0)}</span>
						<span
							>Joint visibility: {(report.validation.visible_keypoint_ratio * 100).toFixed(0)}%</span
						>
						<span>{report.validation.video.fps.toFixed(0)} fps</span>
						<span
							>{report.validation.video.duration_sec}s &middot; {report.validation.video
								.frame_count} frames</span
						>
						<span>{report.metrics.frames_analyzed} frames analyzed</span>
					</div>
					{#if report.metrics.quality?.low_fps_warning}
						<p class="mt-2 text-xs text-muted">
							Video is under 45 fps — tempo and rotation metrics are less accurate. Re-record at 60
							fps for better results.
						</p>
					{/if}
				</div>
			{/if}
			{#if report.trim?.applied}
				<div class="mt-4 border-t border-border pt-4">
					<p class="label mb-2">Auto-trim swing segment</p>
					<p class="text-sm text-offwhite">
						Setup
						<span class="font-semibold text-highlight"
							>{report.trim.setup_trimmed_sec.toFixed(1)}s</span
						>
						removed &middot; analyzing
						<span class="font-semibold"
							>{report.trim.trimmed_start_sec.toFixed(1)}s – {report.trim.trimmed_end_sec.toFixed(
								1
							)}s</span
						>
						of {report.trim.original_duration_sec.toFixed(1)}s total
					</p>
					<p class="mt-2 text-xs text-muted">
						Source frames: {report.trim.source_start_frame}–{report.trim.source_end_frame}
						&middot; Address #{report.trim.address_frame_source}
						&middot; Top #{report.trim.top_frame_source}
						&middot; Impact #{report.trim.impact_frame_source}
					</p>
					<p class="mt-1 text-xs text-disabled">
						Tracking video shows the trimmed segment only — not the full upload.
					</p>
				</div>
			{/if}
			{#if report.metrics.club}
				<div class="mt-4 border-t border-border pt-4">
					<p class="label mb-2">Club tracking</p>
					<div class="flex flex-wrap gap-4 text-xs text-muted">
						<span>Track score: {report.metrics.club.tracking_score}</span>
						<span>Confidence: {(report.metrics.club.mean_confidence * 100).toFixed(0)}%</span>
						<span>Detect rate: {(report.metrics.club.detection_rate * 100).toFixed(0)}%</span>
						<span>Method: {report.metrics.club.method}</span>
						{#if report.metrics.club.shaft_lean_impact_deg != null}
							<span>Shaft lean at impact: {report.metrics.club.shaft_lean_impact_deg.toFixed(1)}°</span>
						{/if}
						{#if report.metrics.club.impact_refined}
							<span class="text-highlight">Impact refined from club tip</span>
						{/if}
					</div>
					<p class="mt-2 text-xs text-disabled">
						Red overlay (grip → clubhead) only appears when YOLO/line detection is confident enough.
						Misses on the downswing mean no fake line. Method: {report.metrics.club.method}.
						{#if !report.metrics.club.yolo_enabled}
							{' '}Install yolov8n-club.pt (see datasets/clubhead/README.md) after manual annotation.
						{:else}
							{' '}Improve the model: label frames in datasets/clubhead/to_label, then retrain.
						{/if}
					</p>
				</div>
			{/if}
		</div>

		<!-- Next swing focus -->
		<NextSwingFocus {report} />

		<!-- Annotated video -->
		{#if videoUrl}
			<div class="card mb-5 w-full min-w-0 sm:mb-6">
				<div class="mb-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
					<p class="label">Joint &amp; club tracking video</p>
					{#if report?.annotated_video_slow_url}
						<div class="flex gap-2">
							<button
								type="button"
								class="text-xs {videoMode === 'normal' ? 'btn-primary' : 'btn-secondary'}"
								onclick={() => setVideoMode('normal')}
							>
								Normal
							</button>
							<button
								type="button"
								class="text-xs {videoMode === 'slow' ? 'btn-primary' : 'btn-secondary'}"
								onclick={() => setVideoMode('slow')}
							>
								Slow motion ({slowmoFactor}x)
							</button>
						</div>
					{/if}
				</div>
				<div class="overflow-hidden border border-border bg-obsidian">
					{#if videoError}
						<div
							class="flex min-h-48 flex-col items-center justify-center gap-3 p-6 text-center text-sm text-muted"
						>
							<p>Video could not play. Make sure the backend is running, then try again.</p>
							<div class="flex flex-wrap justify-center gap-2">
								<button type="button" class="btn-secondary text-xs" onclick={retryVideo}>
									Retry playback
								</button>
								<a href={videoUrl} class="btn-secondary text-xs" target="_blank" rel="noopener">
									Open video directly
								</a>
							</div>
						</div>
					{:else}
						{#key `${videoUrl}-${videoRetry}`}
							<video
								src={videoUrl}
								controls
								playsinline
								preload="metadata"
								class="max-h-[32rem] w-full object-contain"
								onerror={() => (videoError = true)}
							></video>
						{/key}
					{/if}
				</div>
				<p class="mt-2 text-xs text-muted">
					Green = skeleton &middot; bright dots = joints &middot; white line = motion trail
					{#if videoMode === 'slow'}
						&middot; slow motion {slowmoFactor}x @ {report?.validation?.video.fps.toFixed(0) ?? '—'} fps
					{/if}
				</p>
			</div>
		{/if}

		<!-- Detailed metrics -->
		<div class="w-full min-w-0">
			<p class="label mb-3">Detailed metrics</p>
			<DetailedMetrics metrics={report.metrics} />
		</div>

		<div class="mt-6 flex w-full flex-col gap-3 sm:mt-8 sm:flex-row">
			<a
				href="/analyze?club={report.club}&shot_type={report.shot_type}"
				class="btn-primary w-full sm:w-auto"
			>
				Next swing ({CLUB_LABELS[report.club] ?? report.club})
			</a>
			<a href="/analyze" class="btn-secondary w-full sm:w-auto">Analyze another</a>
			<a href="/" class="btn-secondary w-full sm:w-auto">Home</a>
		</div>
	{/if}
</section>
