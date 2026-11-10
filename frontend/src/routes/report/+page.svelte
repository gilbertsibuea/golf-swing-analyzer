<script lang="ts">
	import { onMount } from 'svelte';
	import { ChevronDown, ChevronUp } from 'lucide';
	import DetailedMetrics from '$lib/components/DetailedMetrics.svelte';
	import Icon from '$lib/components/Icon.svelte';
	import NextSwingFocus from '$lib/components/NextSwingFocus.svelte';
	import SpiderChart from '$lib/components/SpiderChart.svelte';
	import { getAnnotatedVideoUrl, loadReport } from '$lib/api';
	import type { SwingAnalysis } from '$lib/types';
	import { CLUB_LABELS, SHOT_LABELS } from '$lib/types';

	let report = $state<SwingAnalysis | null>(null);
	let ready = $state(false);
	let videoError = $state(false);
	let videoRetry = $state(0);
	let showNotesInfo = $state(false);
	let showMetricsDetail = $state(false);

	const videoUrl = $derived.by(() => {
		if (!report?.annotated_video_url) return null;
		return getAnnotatedVideoUrl(report.annotated_video_url);
	});

	const hasNotesExtras = $derived(Boolean(report?.validation || report?.trim?.applied));

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

		<!-- Analysis notes (recommendation only; extras behind More info) -->
		<div class="card mb-5 w-full min-w-0 sm:mb-6">
			<p class="label">Analysis notes</p>
			<p class="mt-3 text-sm leading-relaxed text-offwhite">{report.recommendation}</p>

			{#if hasNotesExtras}
				<button
					type="button"
					class="btn-secondary mt-4 text-xs"
					aria-expanded={showNotesInfo}
					onclick={() => (showNotesInfo = !showNotesInfo)}
				>
					{showNotesInfo ? 'Less info' : 'More info'}
					<Icon icon={showNotesInfo ? ChevronUp : ChevronDown} size={14} />
				</button>

				{#if showNotesInfo}
					{#if report.validation}
						<div class="mt-4 border-t border-border pt-4">
							<p class="label mb-2">Video quality</p>
							<div class="flex flex-wrap gap-4 text-xs text-muted">
								<span>Sharpness: {report.validation.sharpness.toFixed(0)}</span>
								<span
									>Joint visibility: {(report.validation.visible_keypoint_ratio * 100).toFixed(
										0
									)}%</span
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
									Video is under 45 fps — tempo and rotation metrics are less accurate. Re-record
									at 60 fps for better results.
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
				{/if}
			{/if}
		</div>

		<!-- Next swing focus -->
		<NextSwingFocus {report} />

		<!-- Video (80%) + metric scores (20%) -->
		<div
			class="mb-5 grid w-full min-w-0 gap-5 sm:mb-6 lg:grid-cols-[minmax(0,4fr)_minmax(0,1fr)]"
		>
			<div class="card min-w-0">
				<p class="label mb-4">Pose tracking video</p>

				{#if videoUrl}
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
					</p>
				{:else}
					<div
						class="flex min-h-48 items-center justify-center border border-border bg-obsidian px-4 text-center text-sm text-muted"
					>
						Tracking video is not available for this session.
					</div>
				{/if}
			</div>

			<div class="card flex min-w-0 flex-col">
				<p class="label mb-4">Detailed metrics</p>
				<DetailedMetrics metrics={report.metrics} variant="scores" compact />
			</div>
		</div>

		<!-- Metric deep-dive below video + scores -->
		<div class="mb-5 w-full min-w-0 sm:mb-6">
			<button
				type="button"
				class="btn-secondary text-xs"
				aria-expanded={showMetricsDetail}
				onclick={() => (showMetricsDetail = !showMetricsDetail)}
			>
				{showMetricsDetail ? 'Less info' : 'More info'}
				<Icon icon={showMetricsDetail ? ChevronUp : ChevronDown} size={14} />
			</button>

			{#if showMetricsDetail}
				<div class="mt-4">
					<DetailedMetrics metrics={report.metrics} variant="detail" />
				</div>
			{/if}
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
