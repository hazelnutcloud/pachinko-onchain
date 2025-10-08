import { riseTestnet } from 'viem/chains';

export const pachinkoContracts = {
	abi: [
		{ type: 'constructor', inputs: [], stateMutability: 'nonpayable' },
		{
			type: 'function',
			name: 'cancelOwnershipHandover',
			inputs: [],
			outputs: [],
			stateMutability: 'payable'
		},
		{
			type: 'function',
			name: 'completeOwnershipHandover',
			inputs: [{ name: 'pendingOwner', type: 'address', internalType: 'address' }],
			outputs: [],
			stateMutability: 'payable'
		},
		{
			type: 'function',
			name: 'getPlayerGameStatus',
			inputs: [{ name: 'player', type: 'address', internalType: 'address' }],
			outputs: [
				{ name: 'isPlaying', type: 'bool', internalType: 'bool' },
				{ name: 'ballX', type: 'int256', internalType: 'int256' },
				{ name: 'ballY', type: 'int256', internalType: 'int256' }
			],
			stateMutability: 'view'
		},
		{
			type: 'function',
			name: 'owner',
			inputs: [],
			outputs: [{ name: 'result', type: 'address', internalType: 'address' }],
			stateMutability: 'view'
		},
		{
			type: 'function',
			name: 'ownershipHandoverExpiresAt',
			inputs: [{ name: 'pendingOwner', type: 'address', internalType: 'address' }],
			outputs: [{ name: 'result', type: 'uint256', internalType: 'uint256' }],
			stateMutability: 'view'
		},
		{
			type: 'function',
			name: 'renounceOwnership',
			inputs: [],
			outputs: [],
			stateMutability: 'payable'
		},
		{
			type: 'function',
			name: 'requestOwnershipHandover',
			inputs: [],
			outputs: [],
			stateMutability: 'payable'
		},
		{
			type: 'function',
			name: 'resetGame',
			inputs: [],
			outputs: [],
			stateMutability: 'nonpayable'
		},
		{
			type: 'function',
			name: 'setMap',
			inputs: [
				{
					name: 'bodies',
					type: 'tuple[]',
					internalType: 'struct LibPhysics2D.RigidBody[]',
					components: [
						{
							name: 'position',
							type: 'tuple',
							internalType: 'struct LibPhysics2D.Vector2',
							components: [
								{ name: 'x', type: 'int256', internalType: 'int256' },
								{ name: 'y', type: 'int256', internalType: 'int256' }
							]
						},
						{
							name: 'velocity',
							type: 'tuple',
							internalType: 'struct LibPhysics2D.Vector2',
							components: [
								{ name: 'x', type: 'int256', internalType: 'int256' },
								{ name: 'y', type: 'int256', internalType: 'int256' }
							]
						},
						{
							name: 'acceleration',
							type: 'tuple',
							internalType: 'struct LibPhysics2D.Vector2',
							components: [
								{ name: 'x', type: 'int256', internalType: 'int256' },
								{ name: 'y', type: 'int256', internalType: 'int256' }
							]
						},
						{
							name: 'shapeType',
							type: 'uint8',
							internalType: 'enum LibPhysics2D.ShapeType'
						},
						{
							name: 'colliderData',
							type: 'bytes',
							internalType: 'bytes'
						},
						{ name: 'mass', type: 'int256', internalType: 'int256' },
						{
							name: 'restitution',
							type: 'int256',
							internalType: 'int256'
						},
						{ name: 'isStatic', type: 'bool', internalType: 'bool' }
					]
				},
				{ name: 'width', type: 'int256', internalType: 'int256' },
				{ name: 'height', type: 'int256', internalType: 'int256' }
			],
			outputs: [],
			stateMutability: 'nonpayable'
		},
		{
			type: 'function',
			name: 'startGame',
			inputs: [{ name: 'ballPosition', type: 'int256', internalType: 'int256' }],
			outputs: [],
			stateMutability: 'nonpayable'
		},
		{
			type: 'function',
			name: 'stepGame',
			inputs: [],
			outputs: [],
			stateMutability: 'nonpayable'
		},
		{
			type: 'function',
			name: 'transferOwnership',
			inputs: [{ name: 'newOwner', type: 'address', internalType: 'address' }],
			outputs: [],
			stateMutability: 'payable'
		},
		{
			type: 'event',
			name: 'GameEnded',
			inputs: [
				{
					name: 'player',
					type: 'address',
					indexed: true,
					internalType: 'address'
				},
				{
					name: 'ballX',
					type: 'int256',
					indexed: false,
					internalType: 'int256'
				},
				{
					name: 'ballY',
					type: 'int256',
					indexed: false,
					internalType: 'int256'
				}
			],
			anonymous: false
		},
		{
			type: 'event',
			name: 'GameStarted',
			inputs: [
				{
					name: 'player',
					type: 'address',
					indexed: true,
					internalType: 'address'
				},
				{
					name: 'ballX',
					type: 'int256',
					indexed: false,
					internalType: 'int256'
				},
				{
					name: 'ballY',
					type: 'int256',
					indexed: false,
					internalType: 'int256'
				}
			],
			anonymous: false
		},
		{
			type: 'event',
			name: 'GameTicked',
			inputs: [
				{
					name: 'player',
					type: 'address',
					indexed: true,
					internalType: 'address'
				},
				{
					name: 'ballX',
					type: 'int256',
					indexed: false,
					internalType: 'int256'
				},
				{
					name: 'ballY',
					type: 'int256',
					indexed: false,
					internalType: 'int256'
				}
			],
			anonymous: false
		},
		{
			type: 'event',
			name: 'OwnershipHandoverCanceled',
			inputs: [
				{
					name: 'pendingOwner',
					type: 'address',
					indexed: true,
					internalType: 'address'
				}
			],
			anonymous: false
		},
		{
			type: 'event',
			name: 'OwnershipHandoverRequested',
			inputs: [
				{
					name: 'pendingOwner',
					type: 'address',
					indexed: true,
					internalType: 'address'
				}
			],
			anonymous: false
		},
		{
			type: 'event',
			name: 'OwnershipTransferred',
			inputs: [
				{
					name: 'oldOwner',
					type: 'address',
					indexed: true,
					internalType: 'address'
				},
				{
					name: 'newOwner',
					type: 'address',
					indexed: true,
					internalType: 'address'
				}
			],
			anonymous: false
		},
		{ type: 'error', name: 'AlreadyInitialized', inputs: [] },
		{ type: 'error', name: 'BodyDoesNotExist', inputs: [] },
		{ type: 'error', name: 'GameAlreadyStarted', inputs: [] },
		{ type: 'error', name: 'GameNotStarted', inputs: [] },
		{ type: 'error', name: 'InvalidBallPosition', inputs: [] },
		{ type: 'error', name: 'InvalidMass', inputs: [] },
		{ type: 'error', name: 'InvalidRadius', inputs: [] },
		{ type: 'error', name: 'InvalidRestitution', inputs: [] },
		{ type: 'error', name: 'InvalidTimestep', inputs: [] },
		{ type: 'error', name: 'MapNotInitialized', inputs: [] },
		{ type: 'error', name: 'MassRatioTooExtreme', inputs: [] },
		{ type: 'error', name: 'NewOwnerIsZeroAddress', inputs: [] },
		{ type: 'error', name: 'NoHandoverRequest', inputs: [] },
		{ type: 'error', name: 'TooManyBodies', inputs: [] },
		{ type: 'error', name: 'Unauthorized', inputs: [] }
	],
	addresses: {
		[riseTestnet.id]: '0x3b1d19D1c3bCd3edc9a84789EFcbf585114CB9aC'
	}
} as const;
