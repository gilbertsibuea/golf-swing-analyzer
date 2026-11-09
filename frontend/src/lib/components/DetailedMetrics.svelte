<script lang="ts">
	import type { SwingMetrics } from '$lib/types';

	interface Props {
		metrics: SwingMetrics;
	}

	let { metrics }: Props = $props();

	const summaryItems = $derived([
		{ label: 'Tempo', value: metrics.summary.tempo },
		{ label: 'Posture', value: metrics.summary.posture },
		{ label: 'Rotation', value: metrics.summary.rotation },
		{ label: 'Balance', value: metrics.summary.balance },
		{ label: 'Head', value: metrics.summary.head_stability }
	]);

	function barColor(value: number): string {
		if (value >= 85) return 'bg-highlight';
		if (value >= 70) return 'bg-golf';
		if (value >= 55) return 'bg-warning';
		return 'bg-error';
	}

	function pct(n: number): string {
		return `${(n * 100).toFixed(0)}%`;
	}
</script>

<!-- Summary scores -->
<div class="grid gap-px border border-border bg-border sm:grid-cols-2 lg:grid-cols-5">
	{#each summaryItems as item}
		<div class="bg-graphite p-4">
			<p class="label">{item.label}</p>
			<p class="metric-value text-2xl">{item.value}</p>
			<div class="mt-2 h-px w-full bg-border">
				<div class="h-px {barColor(item.value)}" style="width: {item.value}%"></div>
			</div>
		</div>
	{/each}
</div>

{#if metrics.quality}
	<p class="mt-3 text-xs text-disabled">
		Pose detection quality: {pct(metrics.quality.detection_quality)}
		{#if metrics.arms?.handedness}
			&middot; {metrics.arms.handedness === 'right' ? 'Right-handed' : 'Left-handed'}
		{/if}
	</p>
{/if}

<!-- Biomechanics core -->
{#if metrics.biomechanics || metrics.posture}
	<div class="mt-5 grid gap-5 lg:grid-cols-2">
		<div class="card">
			<p class="label">Posture — spine angle</p>
			<dl class="space-y-2 text-sm">
				<div class="flex justify-between gap-4">
					<dt class="text-muted">Address</dt>
					<dd class="text-offwhite">
						{(metrics.posture?.spine_angle_address_deg ?? metrics.biomechanics?.spine_angle_address_deg ?? 0).toFixed(1)}°
					</dd>
				</div>
				<div class="flex justify-between gap-4">
					<dt class="text-muted">Impact</dt>
					<dd class="text-offwhite">
						{(metrics.posture?.spine_angle_impact_deg ?? metrics.biomechanics?.spine_angle_impact_deg ?? 0).toFixed(1)}°
					</dd>
				</div>
				<div class="flex justify-between gap-4">
					<dt class="text-muted">Retention (Δ)</dt>
					<dd class="text-offwhite">
						{(metrics.posture?.spine_angle_retention_deg ?? metrics.biomechanics?.spine_angle_retention_deg ?? 0).toFixed(1)}°
					</dd>
				</div>
			</dl>
		</div>

		<div class="card">
			<p class="label">Rotation — X-factor</p>
			<dl class="space-y-2 text-sm">
				<div class="flex justify-between gap-4">
					<dt class="text-muted">Shoulder turn</dt>
					<dd class="text-offwhite">
						{(metrics.rotation?.shoulder_rotation_max_deg ?? metrics.biomechanics?.shoulder_rotation_max_deg ?? 0).toFixed(1)}°
					</dd>
				</div>
				<div class="flex justify-between gap-4">
					<dt class="text-muted">Hip turn</dt>
					<dd class="text-offwhite">
						{(metrics.rotation?.hip_rotation_max_deg ?? metrics.biomechanics?.hip_rotation_max_deg ?? 0).toFixed(1)}°
					</dd>
				</div>
				<div class="flex justify-between gap-4">
					<dt class="text-muted">X-factor</dt>
					<dd class="font-display font-semibold text-offwhite">
						{(metrics.rotation?.x_factor_deg ?? metrics.biomechanics?.x_factor_deg ?? 0).toFixed(1)}°
					</dd>
				</div>
			</dl>
		</div>
	</div>
{/if}

<!-- Tempo & Balance -->
{#if metrics.tempo || metrics.balance}
	<div class="mt-5 grid gap-5 lg:grid-cols-2">
		<div class="card">
			<p class="label">Tempo</p>
			<dl class="space-y-2 text-sm">
				<div class="flex justify-between gap-4">
					<dt class="text-muted">Backswing : downswing ratio</dt>
					<dd class="font-display font-semibold text-offwhite">
						{(metrics.tempo?.ratio ?? metrics.biomechanics?.tempo_ratio ?? 0).toFixed(2)} : 1
					</dd>
				</div>
				<div class="flex justify-between gap-4">
					<dt class="text-muted">Backswing</dt>
					<dd class="text-offwhite">
						{metrics.tempo?.backswing_frames ?? metrics.biomechanics?.backswing_frames ?? 0} frames
					</dd>
				</div>
				<div class="flex justify-between gap-4">
					<dt class="text-muted">Phases (frames)</dt>
					<dd class="text-offwhite">
						Addr {metrics.tempo?.address_frame ?? metrics.biomechanics?.address_frame ?? 0}
						&middot; Top {metrics.tempo?.top_frame ?? metrics.biomechanics?.top_frame ?? 0}
						&middot; Imp {metrics.tempo?.impact_frame ?? metrics.biomechanics?.impact_frame ?? 0}
					</dd>
				</div>
			</dl>
		</div>

		<div class="card">
			<p class="label">Balance — sway</p>
			<dl class="space-y-2 text-sm">
				<div class="flex justify-between gap-4">
					<dt class="text-muted">Sway (normalized)</dt>
					<dd class="text-offwhite">
						{(metrics.balance?.sway_normalized ?? metrics.biomechanics?.hip_sway_normalized ?? 0).toFixed(3)}
					</dd>
				</div>
				<div class="flex justify-between gap-4">
					<dt class="text-muted">Lead arm (impact)</dt>
					<dd class="text-offwhite">
						{(metrics.arms?.lead_arm_straightness_impact_deg ?? metrics.biomechanics?.lead_arm_straightness_impact_deg ?? 0).toFixed(1)}°
					</dd>
				</div>
			</dl>
		</div>
	</div>
{/if}

<!-- Head -->
<div class="card mt-5">
	<p class="label">Head</p>
	<div class="grid gap-4 sm:grid-cols-3">
		<div>
			<p class="text-xs text-muted">Stability</p>
			<p class="font-display text-lg font-semibold">{metrics.head.stability_score}</p>
		</div>
		<div>
			<p class="text-xs text-muted">Normalized movement</p>
			<p class="font-display text-lg font-semibold">
				{(metrics.head.movement_normalized ?? metrics.biomechanics?.head_movement_normalized ?? 0).toFixed(3)}
			</p>
		</div>
		<div>
			<p class="text-xs text-muted">Ref. shoulder width</p>
			<p class="font-display text-lg font-semibold">
				{(metrics.head.reference_shoulder_width_px ?? metrics.biomechanics?.address_shoulder_width_px ?? 0).toFixed(0)} px
			</p>
		</div>
	</div>
</div>

<!-- Joint distances -->
<div class="card mt-5">
	<p class="label">Joint distances (px)</p>
	<div class="grid gap-2 sm:grid-cols-2 lg:grid-cols-3">
		{#each Object.entries(metrics.joint_distances) as [name, stat]}
			<div class="flex justify-between gap-2 border-b border-border py-2 text-xs">
				<span class="text-muted">{name.replaceAll('_', ' ')}</span>
				<span class="text-offwhite">{stat.avg.toFixed(1)}</span>
			</div>
		{/each}
	</div>
</div>

<!-- Joint angles -->
<div class="card mt-5">
	<p class="label">Joint angles (°)</p>
	<div class="grid gap-2 sm:grid-cols-2">
		{#each Object.entries(metrics.joint_angles) as [name, stat]}
			<div class="flex justify-between gap-2 border-b border-border py-2 text-xs">
				<span class="text-muted">{name.replaceAll('_', ' ')}</span>
				<span class="text-offwhite">{stat.avg.toFixed(1)}°</span>
			</div>
		{/each}
	</div>
</div>

<p class="mt-3 text-xs text-disabled">
	{metrics.frames_analyzed} frames analyzed
</p>
