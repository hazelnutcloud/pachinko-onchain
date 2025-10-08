import { browser } from '$app/environment';
import {
	createWalletClient,
	publicActions,
	type Hex,
	type Client,
	type PublicRpcSchema,
	type PublicActions,
	type WalletActions,
	webSocket,
	type WebSocketTransport
} from 'viem';
import { generatePrivateKey, privateKeyToAccount, type PrivateKeyAccount } from 'viem/accounts';
import { riseTestnet } from 'viem/chains';

export class Wallet {
	signer: PrivateKeyAccount | undefined = $state.raw();
	client:
		| Client<
				WebSocketTransport,
				typeof riseTestnet,
				PrivateKeyAccount,
				PublicRpcSchema,
				PublicActions & WalletActions
		  >
		| undefined = $state.raw();

	constructor() {
		if (!browser) return;

		const storedPk = localStorage.getItem('account');

		if (storedPk) {
			this.signer = privateKeyToAccount(storedPk as Hex);
		} else {
			const randomPk = generatePrivateKey();
			const randomAccount = privateKeyToAccount(randomPk);
			this.signer = randomAccount;
			localStorage.setItem('account', randomPk);
		}

		this.client = createWalletClient({
			account: this.signer,
			chain: riseTestnet,
			transport: webSocket('wss://indexing.testnet.riselabs.xyz/ws')
		}).extend(publicActions);
	}

	async getBalance() {
		if (!this.client || !this.signer) return 0n;

		return await this.client.getBalance({
			address: this.signer.address
		});
	}

	async getNonce() {
		if (!this.client || !this.signer) return 0n;

		return await this.client.getTransactionCount({
			address: this.signer.address
		});
	}
}
