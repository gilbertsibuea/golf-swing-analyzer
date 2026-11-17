<script lang="ts">
	import '../app.css';
	import Navbar from '$lib/components/Navbar.svelte';

	let { children } = $props();
</script>

<svelte:head>
	<title>CADDYX</title>
	<meta name="description" content="CADDYX — swing metrics from your video. Upload a clip, set the club, get scored metrics." />
</svelte:head>

<div class="flex min-h-screen w-full flex-col overflow-x-hidden">
	<Navbar />
	<main class="w-full min-w-0 flex-1">
		{@render children()}
	</main>
	<footer class="w-full border-t border-border py-5">
		<div class="container-page">
			<p class="text-xs uppercase tracking-wide text-disabled sm:tracking-widest">
				CADDYX &mdash;
				<a
					href="https://www.linkedin.com/in/gilbertsibuea"
					target="_blank"
					rel="noopener noreferrer"
					class="transition hover:text-muted"
				>
					Gilbert Sibuea
				</a>
			</p>
		</div>
	</footer>
</div>
