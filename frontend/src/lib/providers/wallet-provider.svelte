<script module lang="ts">
	export const walletContext = 'wallet' as const;
</script>

<script>
	import { Wallet } from '$lib/wallet.svelte';
	import { setContext } from 'svelte';

	const { children } = $props();

	const wallet = new Wallet();

	setContext(walletContext, wallet);
</script>

{@render children()}
