<script lang="ts">
	import '../app.css';
	import favicon from '$lib/assets/favicon.svg';
	import WalletProvider from '$lib/providers/wallet-provider.svelte';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
</svelte:head>

<WalletProvider>
	{@render children?.()}
</WalletProvider>
