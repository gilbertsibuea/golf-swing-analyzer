<script lang="ts">
	import { page } from '$app/stores';
	import { BarChart3, Home, ScanLine } from 'lucide';
	import Icon from '$lib/components/Icon.svelte';

	const links = [
		{ href: '/', label: 'Home', icon: Home },
		{ href: '/analyze', label: 'Analyze', icon: ScanLine },
		{ href: '/report', label: 'Report', icon: BarChart3 }
	];
</script>

<header class="nav">
	<div class="nav__inner">
		<a href="/" class="nav__brand">
			<img
				src="/brand/swinglab-mark.png"
				alt="SwingLab"
				width="44"
				height="44"
				class="nav__mark"
				decoding="async"
			/>
			<span class="nav__wordmark">
				<span class="nav__swing">Swing</span><span class="nav__lab">Lab</span>
			</span>
		</a>

		<nav class="nav__links">
			{#each links as link}
				<a
					href={link.href}
					class="nav__link"
					class:nav__link--active={$page.url.pathname === link.href}
				>
					<Icon icon={link.icon} size={14} class="nav__icon" />
					<span>{link.label}</span>
				</a>
			{/each}
		</nav>
	</div>
</header>

<style>
	.nav {
		width: 100%;
		border-bottom: var(--rule-hair) solid var(--color-rule);
		background: var(--color-paper);
	}

	.nav__inner {
		width: 100%;
		max-width: var(--container);
		margin-inline: auto;
		padding: var(--space-md) var(--gutter);
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: var(--space-md);
		box-sizing: border-box;
	}

	.nav__brand {
		display: flex;
		min-width: 0;
		align-items: center;
		gap: 0.7rem;
		text-decoration: none;
		color: inherit;
	}

	.nav__brand:focus-visible {
		outline: 2px solid var(--color-focus);
		outline-offset: 3px;
	}

	.nav__mark {
		width: 2.5rem;
		height: 2.5rem;
		flex-shrink: 0;
		object-fit: contain;
		object-position: center;
	}

	.nav__wordmark {
		min-width: 0;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
		font-family: var(--font-display);
		font-size: var(--text-lg);
		font-weight: 700;
		letter-spacing: var(--tracking-display);
		line-height: 1;
	}

	.nav__swing {
		color: var(--color-ink);
	}

	.nav__lab {
		color: var(--color-accent);
	}

	.nav__links {
		display: flex;
		flex-shrink: 0;
		align-items: center;
		gap: 0.15rem;
	}

	.nav__link {
		display: flex;
		align-items: center;
		gap: 0.4rem;
		padding: 0.55rem 0.7rem;
		font-family: var(--font-body);
		font-size: var(--text-xs);
		font-weight: 500;
		color: var(--color-muted);
		text-decoration: none;
		border-bottom: 2px solid transparent;
		transition: color var(--dur-micro) var(--ease-out);
	}

	.nav__link:hover {
		color: var(--color-ink);
	}

	.nav__link:focus-visible {
		outline: 2px solid var(--color-focus);
		outline-offset: 2px;
	}

	.nav__link--active {
		color: var(--color-ink);
		border-bottom-color: var(--color-accent);
	}

	:global(.nav__icon) {
		display: none;
	}

	@media (min-width: 40rem) {
		.nav__mark {
			width: 2.75rem;
			height: 2.75rem;
		}

		:global(.nav__icon) {
			display: block;
		}
	}
</style>
