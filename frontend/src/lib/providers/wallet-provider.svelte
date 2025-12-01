<script module lang="ts">
	// export const [getWalletContext, setWalletContext] = createContext<Wallet>()
</script>

<script>
	import { Wallet } from '$lib/wallet.svelte';
	import { setContext } from 'svelte';
	// import { createContext } from 'svelte';

	const { children } = $props();

	const wallet = new Wallet();

	setContext('wallet', wallet);
</script>

{@render children()}
