<script lang="ts">
	import { browser } from '$app/environment';
	import { ChevronLeft, ChevronRight, RotateCcw, X } from 'lucide';
	import { onDestroy } from 'svelte';
	import Icon from '$lib/components/Icon.svelte';

	interface Step {
		target: string;
		title: string;
		body: string;
	}

	interface Props {
		open?: boolean;
		onclose?: () => void;
		/** Optional: open recording guide from last step */
		onopenGuide?: () => void;
	}

	let { open = false, onclose, onopenGuide }: Props = $props();

	const steps: Step[] = [
		{
			target: '#tour-shot-type',
			title: 'Jenis Pukulan',
			body: 'Pilih jenis pukulan: Full Swing, Chip, Pitch, atau Putt. Ini menyesuaikan fokus metrik analisis dengan jenis shot Anda.'
		},
		{
			target: '#tour-club',
			title: 'Jenis Club',
			body: 'Pilih club yang dipakai (driver, iron, wedge, putter). Analisis memakai profil berbeda per kategori club.'
		},
		{
			target: '#tour-upload',
			title: 'Upload Video',
			body: 'Seret atau pilih file video swing Anda (MP4/MOV, maks. 100 MB). Pastikan seluruh swing terlihat jelas di frame.'
		},
		{
			target: '#tour-guide',
			title: 'Panduan Rekaman',
			body: 'Butuh tips posisi kamera, pencahayaan, dan durasi? Buka Panduan Rekaman kapan saja — atau ulangi tutorial ini.'
		}
	];

	let step = $state(0);
	let hole = $state<{ top: number; left: number; width: number; height: number } | null>(null);
	let tipPos = $state<{ top: number; left: number; place: 'below' | 'above' } | null>(null);

	const isLast = $derived(step === steps.length - 1);
	const isFirst = $derived(step === 0);

	function measure() {
		if (!browser || !open) return;
		const el = document.querySelector(steps[step].target) as HTMLElement | null;
		if (!el) {
			hole = null;
			tipPos = null;
			return;
		}
		el.scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'nearest' });
		const pad = 10;
		const r = el.getBoundingClientRect();
		hole = {
			top: Math.max(8, r.top - pad),
			left: Math.max(8, r.left - pad),
			width: Math.min(window.innerWidth - 16, r.width + pad * 2),
			height: r.height + pad * 2
		};

		const tipW = Math.min(360, window.innerWidth - 24);
		const spaceBelow = window.innerHeight - (hole.top + hole.height);
		const place: 'below' | 'above' = spaceBelow < 180 && hole.top > 200 ? 'above' : 'below';
		let left = hole.left;
		left = Math.min(left, window.innerWidth - tipW - 12);
		left = Math.max(12, left);
		const top =
			place === 'below' ? hole.top + hole.height + 12 : Math.max(12, hole.top - 12 - 160);
		tipPos = { top, left, place };
	}

	function next() {
		if (step < steps.length - 1) step += 1;
		else onclose?.();
	}

	function prev() {
		if (step > 0) step -= 1;
	}

	function restart() {
		step = 0;
	}

	function skip() {
		onclose?.();
	}

	function handleKeydown(e: KeyboardEvent) {
		if (!open) return;
		if (e.key === 'Escape') skip();
		if (e.key === 'ArrowRight' || e.key === 'Enter') {
			e.preventDefault();
			if (isLast) onclose?.();
			else next();
		}
		if (e.key === 'ArrowLeft') {
			e.preventDefault();
			prev();
		}
	}

	$effect(() => {
		if (!open) return;
		step = 0;
		const t = window.setTimeout(measure, 50);
		const onScroll = () => measure();
		window.addEventListener('resize', measure);
		window.addEventListener('scroll', onScroll, true);
		return () => {
			clearTimeout(t);
			window.removeEventListener('resize', measure);
			window.removeEventListener('scroll', onScroll, true);
		};
	});

	$effect(() => {
		if (!open) return;
		void step;
		const t = window.setTimeout(measure, 80);
		return () => clearTimeout(t);
	});

	onDestroy(() => {
		hole = null;
		tipPos = null;
	});
</script>

<svelte:window onkeydown={handleKeydown} />

{#if open}
	<div class="fixed inset-0 z-[70]" role="dialog" aria-modal="true" aria-labelledby="spotlight-title">
		{#if hole}
			<!-- Spotlight cutout: dims everything outside the hole -->
			<div
				class="spotlight-hole pointer-events-none absolute rounded-lg transition-all duration-300 ease-out"
				style="top:{hole.top}px;left:{hole.left}px;width:{hole.width}px;height:{hole.height}px;"
			></div>
		{:else}
			<div class="pointer-events-none absolute inset-0 bg-obsidian/80"></div>
		{/if}

		<!-- Block page interaction while tour is open (tooltip stays above) -->
		<div class="absolute inset-0 z-[70]" aria-hidden="true"></div>

		{#if tipPos}
			<div
				class="absolute z-[72] w-[min(22.5rem,calc(100vw-1.5rem))] rounded-md border border-border bg-graphite p-4 shadow-xl transition-all duration-300"
				style="top:{tipPos.top}px;left:{tipPos.left}px;"
				role="document"
			>
				<div class="mb-3 flex items-start justify-between gap-3">
					<div class="min-w-0">
						<p class="text-[10px] font-bold uppercase tracking-widest text-highlight">
							Langkah {step + 1} / {steps.length}
						</p>
						<h2 id="spotlight-title" class="mt-1 font-display text-base font-semibold text-offwhite">
							{steps[step].title}
						</h2>
					</div>
					<button
						type="button"
						class="shrink-0 rounded-md p-1 text-muted transition hover:text-offwhite"
						aria-label="Tutup"
						onclick={skip}
					>
						<Icon icon={X} size={16} />
					</button>
				</div>

				<p class="text-sm leading-relaxed text-muted">{steps[step].body}</p>

				<div class="mt-4 flex items-center gap-1.5">
					{#each steps as _, i}
						<button
							type="button"
							class="h-1.5 rounded-full transition-all
								{i === step ? 'w-5 bg-golf' : 'w-1.5 bg-border hover:bg-muted'}"
							aria-label="Ke langkah {i + 1}"
							onclick={() => (step = i)}
						></button>
					{/each}
				</div>

				<div class="mt-4 flex flex-wrap gap-2">
					{#if !isFirst}
						<button type="button" class="btn-secondary text-xs" onclick={prev}>
							<Icon icon={ChevronLeft} size={14} />
							Kembali
						</button>
					{/if}

					{#if isLast}
						<button type="button" class="btn-secondary text-xs" onclick={restart}>
							<Icon icon={RotateCcw} size={14} />
							Ulangi
						</button>
						{#if onopenGuide}
							<button
								type="button"
								class="btn-secondary text-xs"
								onclick={() => {
									onclose?.();
									onopenGuide();
								}}
							>
								Buka Panduan
							</button>
						{/if}
						<button type="button" class="btn-primary ml-auto text-xs" onclick={() => onclose?.()}>
							Selesai
						</button>
					{:else}
						<button type="button" class="btn-ghost ml-auto text-xs" onclick={skip}>Lewati</button>
						<button type="button" class="btn-primary text-xs" onclick={next}>
							Lanjut
							<Icon icon={ChevronRight} size={14} />
						</button>
					{/if}
				</div>
			</div>
		{/if}
	</div>
{/if}

<style>
	.spotlight-hole {
		box-shadow: 0 0 0 9999px rgba(10, 12, 14, 0.78);
		outline: 2px solid rgba(30, 122, 61, 0.85);
		outline-offset: 0;
	}
</style>
