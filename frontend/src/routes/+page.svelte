<section class="relative overflow-hidden border-b border-border">
	<!-- Hero background: golfer figure, right-aligned -->
	<div class="pointer-events-none absolute inset-0" aria-hidden="true">
		<img
			src="/hero/golfer.jpeg"
			alt=""
			class="absolute inset-0 h-full w-full object-cover object-[75%_center] sm:object-right"
			fetchpriority="high"
		/>
		<div
			class="absolute inset-0 bg-gradient-to-r from-obsidian from-35% via-obsidian/90 via-55% to-obsidian/25 to-100% sm:from-40% sm:via-obsidian/75 sm:to-transparent"
		></div>
		<div class="absolute inset-0 bg-gradient-to-t from-obsidian via-transparent to-obsidian/50"></div>
	</div>

	<div class="container-page relative z-10 py-12 sm:py-16 lg:min-h-[32rem] lg:py-24">
		<div class="grid w-full min-w-0 items-end gap-10 lg:grid-cols-12 lg:gap-16">
			<div class="min-w-0 lg:col-span-7">
				<p class="label mb-4">Swing Analysis</p>
				<h1 class="page-title leading-none">
					Ukur.<br />
					Analisis.<br />
					<span class="text-highlight">Perbaiki.</span>
				</h1>
				<p class="mt-6 max-w-md text-sm leading-relaxed text-muted">
					Alat analisis performa swing golf berbasis pose detection. Upload video, konfigurasi
					club, dan dapatkan metrik terukur beserta rekomendasi perbaikan.
				</p>

				<div class="mt-8 sm:mt-10">
					<a href="/analyze" class="cta-swing group">
						<span class="cta-swing__scene" aria-hidden="true">
							<img src="/hero/golf-hit.gif" alt="" class="cta-swing__gif" width="72" height="72" />
						</span>
						<span class="cta-swing__label">
							<span class="cta-swing__title">Analisis Swing</span>
							<span class="cta-swing__hint">Upload video</span>
						</span>
					</a>
				</div>
			</div>
		</div>
	</div>
</section>

<section class="relative overflow-hidden border-t border-border">
	<div class="pointer-events-none absolute inset-0" aria-hidden="true">
		<img
			src="/process/driving-range.jpeg"
			alt=""
			class="absolute inset-0 h-full w-full object-cover object-center"
			loading="lazy"
		/>
		<div class="absolute inset-0 bg-obsidian/35"></div>
		<div class="absolute inset-0 bg-gradient-to-b from-obsidian/50 via-transparent to-obsidian/40"></div>
	</div>

	<div class="container-page relative z-10 py-12 sm:py-16">
		<p class="label mb-6 sm:mb-8">Proses</p>
		<div class="grid w-full min-w-0 gap-px border border-border bg-border sm:grid-cols-3">
			{#each [
				{
					step: '01',
					title: 'Rekam',
					desc: 'Video 3–8 detik dari samping. Kamera setinggi pinggang, jarak 2–3 meter.'
				},
				{
					step: '02',
					title: 'Konfigurasi',
					desc: 'Pilih club dan jenis pukulan agar analisis sesuai konteks swing Anda.'
				},
				{
					step: '03',
					title: 'Review',
					desc: 'Lihat skor, metrik detail, dan rekomendasi perbaikan yang dapat ditindaklanjuti.'
				}
			] as item}
				<div class="min-w-0 bg-graphite p-5 sm:p-6">
					<p class="font-display text-2xl font-bold text-border">{item.step}</p>
					<h3 class="mt-3 font-display text-sm font-semibold uppercase tracking-wide text-offwhite">
						{item.title}
					</h3>
					<p class="mt-2 text-sm leading-relaxed text-muted">{item.desc}</p>
				</div>
			{/each}
		</div>
	</div>
</section>

<section class="container-page pb-12 sm:pb-20">
	<div
		class="flex w-full min-w-0 flex-col items-start justify-between gap-5 border border-border bg-graphite p-5 sm:flex-row sm:items-center sm:gap-6 sm:p-6"
	>
		<div class="min-w-0">
			<p class="label">Siap Mulai</p>
			<p class="font-display text-base font-semibold text-offwhite sm:text-lg">
				Baca panduan rekaman sebelum sesi pertama.
			</p>
		</div>
		<a href="/analyze" class="btn-primary w-full shrink-0 sm:w-auto">Mulai Sesi</a>
	</div>
</section>

<style>
	.cta-swing {
		position: relative;
		display: inline-flex;
		align-items: center;
		gap: 1rem;
		min-width: min(100%, 22rem);
		padding: 0.85rem 1.25rem 0.85rem 0.85rem;
		border-radius: 0.75rem;
		background: #1e7a3d;
		color: #f5f5f0;
		text-decoration: none;
		border: 1px solid rgba(245, 245, 240, 0.12);
		transition:
			transform 0.25s ease,
			background-color 0.2s ease;
	}

	.cta-swing:hover,
	.cta-swing:focus-visible {
		transform: translateY(-3px) scale(1.02);
		background: #186433;
		outline: none;
	}

	.cta-swing:active {
		transform: translateY(-1px) scale(1.01);
		background: #14532d;
	}

	.cta-swing__scene {
		position: relative;
		z-index: 1;
		width: 4.25rem;
		height: 4.25rem;
		flex-shrink: 0;
		background: transparent;
		overflow: visible;
		display: grid;
		place-items: center;
	}

	.cta-swing__gif {
		width: 100%;
		height: 100%;
		object-fit: contain;
		display: block;
	}

	.cta-swing__label {
		position: relative;
		z-index: 1;
		display: flex;
		flex-direction: column;
		gap: 0.15rem;
		min-width: 0;
		flex: 1;
	}

	.cta-swing__title {
		font-family: var(--font-display, ui-sans-serif, system-ui);
		font-size: 1.15rem;
		font-weight: 700;
		letter-spacing: -0.02em;
		line-height: 1.2;
	}

	.cta-swing__hint {
		font-size: 0.7rem;
		font-weight: 500;
		letter-spacing: 0.04em;
		text-transform: uppercase;
		opacity: 0.75;
	}

	.cta-swing__arrow {
		position: relative;
		z-index: 1;
		font-size: 1.35rem;
		font-weight: 600;
		opacity: 0.85;
		transition: transform 0.25s ease;
	}

	.cta-swing:hover .cta-swing__arrow,
	.cta-swing:focus-visible .cta-swing__arrow {
		transform: translateX(4px);
	}

	@media (prefers-reduced-motion: reduce) {
		.cta-swing__gif {
			animation: none;
		}
	}
</style>
