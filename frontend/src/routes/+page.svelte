<section class="land-hero">
	<div class="land-hero__media" aria-hidden="true">
		<img
			src="/hero/golfer.jpeg"
			alt=""
			class="land-hero__photo"
			fetchpriority="high"
		/>
		<div class="land-hero__veil land-hero__veil--x"></div>
		<div class="land-hero__veil land-hero__veil--y"></div>
	</div>

	<div class="land-shell land-hero__copy">
		<h1>Swing metrics from your video</h1>
		<p class="lead land-hero__lead">
			Upload a clip, set the club, get scored metrics.
		</p>
		<a href="/analyze" class="land-cta">
			<span class="land-cta__scene" aria-hidden="true">
				<img src="/hero/golf-hit.gif" alt="" class="land-cta__gif" width="72" height="72" />
			</span>
			<span class="land-cta__text">Analyze Swing</span>
		</a>
	</div>
</section>

<section class="land-steps">
	<div class="land-steps__media" aria-hidden="true">
		<img
			src="/process/driving-range.jpeg"
			alt=""
			class="land-steps__photo"
			loading="lazy"
		/>
		<div class="land-steps__veil"></div>
	</div>

	<div class="land-shell land-steps__body">
		<h2>How a session runs</h2>
		<ol class="land-list">
			{#each [
				{
					step: '01',
					title: 'Record',
					desc: 'Film 3–8 seconds from the side. Camera at waist height, 2–3 meters away.'
				},
				{
					step: '02',
					title: 'Configure',
					desc: 'Select your club and shot type so the analysis matches your swing context.'
				},
				{
					step: '03',
					title: 'Review',
					desc: 'See your score, detailed metrics, and actionable improvement recommendations.'
				}
			] as item}
				<li class="land-list__row">
					<span class="land-list__num num" aria-hidden="true">{item.step}</span>
					<div class="land-list__copy">
						<h3>{item.title}</h3>
						<p>{item.desc}</p>
					</div>
				</li>
			{/each}
		</ol>
	</div>
</section>

<section class="land-close">
	<div class="land-shell land-close__row">
		<p class="land-close__text">
			Read the recording guide before your first session.
		</p>
		<a href="/analyze" class="land-btn">Start Session</a>
	</div>
</section>

<style>
	.land-shell {
		width: 100%;
		max-width: var(--container);
		margin-inline: auto;
		padding-inline: var(--gutter);
		box-sizing: border-box;
		min-width: 0;
	}

	.land-hero {
		position: relative;
		overflow: clip;
		border-bottom: var(--rule-hair) solid var(--color-rule);
		min-height: min(32rem, 78dvh);
		display: flex;
		align-items: flex-end;
	}

	.land-hero__media {
		pointer-events: none;
		position: absolute;
		inset: 0;
	}

	.land-hero__photo {
		position: absolute;
		inset: 0;
		width: 100%;
		height: 100%;
		object-fit: cover;
		object-position: 75% center;
		max-width: none;
	}

	@media (min-width: 40rem) {
		.land-hero__photo {
			object-position: right center;
		}
	}

	.land-hero__veil {
		position: absolute;
		inset: 0;
	}

	.land-hero__veil--x {
		background: linear-gradient(
			to right,
			var(--color-paper) 0%,
			color-mix(in oklab, var(--color-paper) 88%, transparent) 42%,
			color-mix(in oklab, var(--color-paper) 35%, transparent) 68%,
			transparent 100%
		);
	}

	.land-hero__veil--y {
		background: linear-gradient(
			to top,
			var(--color-paper) 0%,
			transparent 45%,
			color-mix(in oklab, var(--color-paper) 55%, transparent) 100%
		);
	}

	.land-hero__copy {
		position: relative;
		z-index: var(--z-raised);
		padding-block: var(--space-2xl) var(--space-3xl);
		animation: land-settle var(--dur-long) var(--ease-out) both;
	}

	.land-hero__copy h1 {
		max-width: 14ch;
		font-size: var(--text-display);
		font-weight: var(--display-weight);
		letter-spacing: var(--tracking-display);
		color: var(--color-ink);
		line-height: 1.02;
		text-wrap: balance;
		overflow-wrap: break-word;
		min-width: 0;
	}

	.land-hero__lead {
		margin-top: var(--space-lg);
		max-width: 34ch;
		color: var(--color-muted);
	}

	.land-cta {
		margin-top: var(--space-xl);
		display: inline-flex;
		align-items: center;
		gap: var(--space-md);
		min-width: min(100%, 18rem);
		padding: var(--space-sm) var(--space-lg) var(--space-sm) var(--space-sm);
		background: var(--color-accent);
		color: var(--color-accent-ink);
		text-decoration: none;
		border: var(--rule-hair) solid color-mix(in oklab, var(--color-ink) 12%, transparent);
		transition:
			transform var(--dur-short) var(--ease-out),
			filter var(--dur-short) var(--ease-out);
	}

	.land-cta:hover {
		transform: translateY(-2px);
		filter: brightness(1.06);
	}

	.land-cta:focus-visible {
		outline: 2px solid var(--color-focus);
		outline-offset: 3px;
	}

	.land-cta:active {
		transform: translateY(0);
		filter: brightness(0.96);
	}

	.land-cta__scene {
		width: 3.75rem;
		height: 3.75rem;
		flex-shrink: 0;
		display: grid;
		place-items: center;
		background: transparent;
	}

	.land-cta__gif {
		width: 100%;
		height: 100%;
		object-fit: contain;
		max-width: none;
	}

	.land-cta__text {
		font-family: var(--font-display);
		font-size: var(--text-lg);
		font-weight: 700;
		letter-spacing: -0.02em;
		white-space: nowrap;
	}

	.land-steps {
		position: relative;
		overflow: clip;
		border-bottom: var(--rule-hair) solid var(--color-rule);
	}

	.land-steps__media {
		pointer-events: none;
		position: absolute;
		inset: 0;
	}

	.land-steps__photo {
		position: absolute;
		inset: 0;
		width: 100%;
		height: 100%;
		object-fit: cover;
		object-position: center;
		max-width: none;
	}

	.land-steps__veil {
		position: absolute;
		inset: 0;
		background: color-mix(in oklab, var(--color-paper) 72%, transparent);
	}

	.land-steps__body {
		position: relative;
		z-index: var(--z-raised);
		padding-block: var(--section-gap-s);
	}

	.land-steps__body h2 {
		font-size: var(--text-section);
		font-weight: var(--display-weight);
		letter-spacing: var(--tracking-display);
		color: var(--color-ink);
		margin-bottom: var(--space-xl);
		max-width: 18ch;
		text-wrap: balance;
		overflow-wrap: break-word;
		min-width: 0;
	}

	.land-list {
		list-style: none;
		margin: 0;
		padding: 0;
		border-top: var(--rule-hair) solid var(--color-rule);
		background: color-mix(in oklab, var(--color-paper-2) 88%, transparent);
	}

	.land-list__row {
		display: grid;
		grid-template-columns: 3.5rem minmax(0, 1fr);
		gap: var(--space-lg);
		padding: var(--space-lg);
		border-bottom: var(--rule-hair) solid var(--color-rule);
		min-width: 0;
	}

	.land-list__num {
		font-family: var(--font-display);
		font-size: var(--text-2xl);
		font-weight: 700;
		line-height: 1;
		color: var(--color-rule-2);
		font-variant-numeric: tabular-nums;
	}

	.land-list__copy {
		min-width: 0;
	}

	.land-list__copy h3 {
		font-size: var(--text-title);
		font-weight: 600;
		letter-spacing: var(--tracking-display);
		color: var(--color-ink);
		max-width: none;
	}

	.land-list__copy p {
		margin-top: var(--space-xs);
		font-size: var(--text-sm);
		line-height: 1.55;
		color: var(--color-muted);
		max-width: 48ch;
	}

	.land-close {
		padding-block: var(--space-2xl) var(--section-gap-s);
	}

	.land-close__row {
		display: flex;
		flex-wrap: wrap;
		align-items: center;
		justify-content: space-between;
		gap: var(--space-lg);
		padding: var(--space-lg) 0;
		border-top: var(--rule-hair) solid var(--color-rule);
		border-bottom: var(--rule-hair) solid var(--color-rule);
	}

	.land-close__text {
		font-family: var(--font-display);
		font-size: var(--text-title);
		font-weight: 600;
		letter-spacing: var(--tracking-display);
		color: var(--color-ink);
		max-width: 36ch;
		min-width: 0;
	}

	.land-btn {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
		padding: 0.7rem 1.25rem;
		background: transparent;
		color: var(--color-ink);
		border: var(--rule-hair) solid var(--color-rule-2);
		font-family: var(--font-body);
		font-size: var(--text-sm);
		font-weight: 600;
		text-decoration: none;
		white-space: nowrap;
		transition: border-color var(--dur-short) var(--ease-out);
	}

	.land-btn:hover {
		border-color: var(--color-muted);
	}

	.land-btn:focus-visible {
		outline: 2px solid var(--color-focus);
		outline-offset: 3px;
	}

	.land-btn:active {
		border-color: var(--color-ink);
	}

	@keyframes land-settle {
		from {
			opacity: 0.6;
		}
		to {
			opacity: 1;
		}
	}

	@media (prefers-reduced-motion: reduce) {
		.land-hero__copy {
			animation: none;
		}

		.land-cta,
		.land-btn {
			transition: none;
		}

		.land-cta:hover,
		.land-cta:active {
			transform: none;
		}
	}

	@media (max-width: 40rem) {
		.land-close__row {
			flex-direction: column;
			align-items: stretch;
		}

		.land-btn {
			width: 100%;
		}
	}
</style>
