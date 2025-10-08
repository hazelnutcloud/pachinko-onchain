<script lang="ts">
	import Scene from '$lib/components/scene.svelte';
	import { pachinkoContracts } from '$lib/contracts';
	import { walletContext } from '$lib/providers/wallet-provider.svelte';
	import { Wallet } from '$lib/wallet.svelte';
	import { Canvas } from '@threlte/core';
	import { getContext } from 'svelte';
	import {
		encodeFunctionData,
		formatEther,
		parseEther,
		type PrivateKeyAccount,
		type SignTransactionParameters
	} from 'viem';
	import { readContract } from 'viem/actions';
	import { riseTestnet } from 'viem/chains';

	const wallet: Wallet = getContext(walletContext);
	const balance = await wallet.getBalance();
	let nonce = Number(await wallet.getNonce());

	const INITIAL_BALL_X = parseEther('53');
	const INITIAL_BALL_Y = parseEther('10.5');

	const status = $derived(
		wallet.client && wallet.signer
			? await readContract(wallet.client, {
					abi: pachinkoContracts.abi,
					address: pachinkoContracts.addresses[riseTestnet.id],
					functionName: 'getPlayerGameStatus',
					args: [wallet.signer.address]
				}).catch(() => [false, INITIAL_BALL_X, INITIAL_BALL_Y] as const)
			: undefined
	);
	let isGameStarted = $derived(status?.[0] ?? false);
	let ballX = $derived(parseFloat(formatEther(status?.[1] ?? INITIAL_BALL_X)));
	let ballY = $derived(parseFloat(formatEther(status?.[2] ?? INITIAL_BALL_Y)));

	$effect(() => {
		if (!wallet.client || !wallet.signer) return;

		const unsubscribeGameTicked = wallet.client.watchContractEvent({
			abi: pachinkoContracts.abi,
			address: pachinkoContracts.addresses[riseTestnet.id],
			eventName: 'GameTicked',
			args: {
				player: wallet.signer.address
			},
			onLogs: (logs) => {
				for (const log of logs) {
					// console.log(log);
					if (!log.args.ballX || !log.args.ballY) continue;
					ballX = parseFloat(formatEther(log.args.ballX));
					ballY = parseFloat(formatEther(log.args.ballY));
				}
			}
		});

		const unsubscribeGameStarted = wallet.client.watchContractEvent({
			abi: pachinkoContracts.abi,
			address: pachinkoContracts.addresses[riseTestnet.id],
			eventName: 'GameStarted',
			args: {
				player: wallet.signer.address
			},
			onLogs: (logs) => {
				for (const log of logs) {
					console.log('GameStarted', log);
				}
			}
		});

		const unsubscribeGameEnded = wallet.client.watchContractEvent({
			abi: pachinkoContracts.abi,
			address: pachinkoContracts.addresses[riseTestnet.id],
			eventName: 'GameEnded',
			args: {
				player: wallet.signer.address
			},
			onLogs: (logs) => {
				for (const log of logs) {
					console.log('GameEnded', log);
				}
			}
		});

		console.log('subscribed');

		return () => {
			console.log('unsubscribed');
			unsubscribeGameStarted();
			unsubscribeGameEnded();
			unsubscribeGameTicked();
		};
	});

	const STEP_GAME_DATA = encodeFunctionData({
		abi: pachinkoContracts.abi,
		functionName: 'stepGame'
	});

	const getBaseTxParams = (account: PrivateKeyAccount) =>
		({
			account,
			gas: 10_000_000n,
			maxFeePerGas: 7n,
			maxPriorityFeePerGas: 7n,
			nonce: nonce++
		}) satisfies SignTransactionParameters<typeof riseTestnet, undefined>;

	let stepGameInterval: NodeJS.Timeout | undefined = $state();

	const handleStartGame = async () => {
		if (!wallet.client || !wallet.signer) return;
		console.log('starting game');

		isGameStarted = true;

		const serializedTransaction = await wallet.client.signTransaction({
			...getBaseTxParams(wallet.signer),
			chain: riseTestnet,
			data: encodeFunctionData({
				abi: pachinkoContracts.abi,
				functionName: 'startGame',
				args: [INITIAL_BALL_X]
			}),
			to: pachinkoContracts.addresses[riseTestnet.id]
		});

		const res = await wallet.client.sendRawTransactionSync({
			serializedTransaction
		});

		console.log('startGame receipt: ', res);

		stepGameInterval = setInterval(() => {
			handleStepGame();
		}, 1000 / 10);
	};

	const handleContinueGame = async () => {
		console.log('continuing game');

		stepGameInterval = setInterval(() => {
			handleStepGame();
		}, 1000 / 10);
	};

	const handleStepGame = async () => {
		if (!isGameStarted) return;
		if (!wallet.client || !wallet.signer) return;
		// console.log('stepping game');

		const serializedTransaction = await wallet.client.signTransaction({
			...getBaseTxParams(wallet.signer),
			chain: riseTestnet,
			data: STEP_GAME_DATA,
			to: pachinkoContracts.addresses[riseTestnet.id]
		});

		const res = await wallet.client.sendRawTransactionSync({
			serializedTransaction
		});

		// console.log('stepGame receipt: ', res);
	};

	const handleStopGame = () => {
		clearInterval(stepGameInterval);
		stepGameInterval = undefined;
	};

	const handleResetGame = async () => {
		handleStopGame();
		if (!wallet.client || !wallet.signer) return;
		console.log('resetting game');

		const serializedTransaction = await wallet.client.signTransaction({
			...getBaseTxParams(wallet.signer),
			chain: riseTestnet,
			data: encodeFunctionData({
				abi: pachinkoContracts.abi,
				functionName: 'resetGame'
			}),
			to: pachinkoContracts.addresses[riseTestnet.id]
		});

		const res = await wallet.client.sendRawTransactionSync({
			serializedTransaction
		});

		console.log('resetGame receipt: ', res);
	};
</script>

<div class="flex min-h-screen w-full flex-col items-center justify-center p-4">
	<div class="flex w-full max-w-xl flex-col items-center justify-center gap-2">
		<h1 class="text-xl font-bold">Pachinko Onchain</h1>

		<div class="w-full space-y-2 text-xs">
			<div>
				<div class="flex items-center gap-2">
					<p>wallet address:</p>
					<p class="font-medium">{wallet.signer?.address}</p>
				</div>
				<div class="flex items-center gap-2">
					<p>chain:</p>
					<p class="font-medium">rise testnet</p>
				</div>
				<div class="flex items-center gap-2">
					<p>balance:</p>
					<p class="font-medium">{formatEther(balance)} ETH</p>
				</div>
			</div>
			<div class="aspect-square w-full outline outline-red-500">
				<Canvas>
					<Scene {ballX} {ballY} />
				</Canvas>
			</div>
			<div class="flex w-full items-center justify-center gap-2">
				{#if stepGameInterval === undefined && isGameStarted}
					<button class="cursor-pointer rounded-sm p-1 shadow outline" onclick={handleResetGame}>
						Reset Game
					</button>
					<button class="cursor-pointer rounded-sm p-1 shadow outline" onclick={handleContinueGame}>
						Continue Game
					</button>
				{:else if !isGameStarted}
					<button class="cursor-pointer rounded-sm p-1 shadow outline" onclick={handleStartGame}>
						Start Game
					</button>
				{:else}
					<button class="cursor-pointer rounded-sm p-1 shadow outline" onclick={handleResetGame}>
						Reset Game
					</button>
					<button class="cursor-pointer rounded-sm p-1 shadow outline" onclick={handleStopGame}>
						Pause Game
					</button>
				{/if}
			</div>
		</div>
	</div>
</div>
