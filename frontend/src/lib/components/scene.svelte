<script lang="ts">
	import { T } from '@threlte/core';
	import { OrbitControls, Gizmo } from '@threlte/extras';

	const { ballX, ballY }: { ballX: number; ballY: number } = $props();

	$effect(() => {
		console.log('ballX', ballX);
		console.log('ballY', ballY);
	});

	const SCALE = 0.001;

	const toThree = (x: number, y: number) => ({
		x: x * SCALE - 0.053,
		y: -(y * SCALE - 0.0515)
	});
</script>

<T.PerspectiveCamera makeDefault position={[0, 0, 0.16]} fov={40}>
	<OrbitControls>
		<Gizmo />
	</OrbitControls>
</T.PerspectiveCamera>

<T.AmbientLight intensity={0.5} />
<T.DirectionalLight position={[5, 10, 5]} intensity={0.8} />

<!-- Ball  --> --
{#key [ballX, ballY]}
	<T.Mesh position={[toThree(ballX, ballY).x, toThree(ballX, ballY).y, 0]}>
		<T.SphereGeometry args={[0.0025, 32, 32]} />
		<T.MeshStandardMaterial color="#ff6b6b" />
	</T.Mesh>
{/key}

<!-- Walls -->
<T.Mesh position={[toThree(53, 1.5).x, toThree(53, 1.5).y, 0]}>
	<T.BoxGeometry args={[0.106, 0.003, 0.01]} />
	<T.MeshStandardMaterial color="#666666" />
</T.Mesh>

<T.Mesh position={[toThree(1.5, 53).x, toThree(1.5, 53).y, 0]}>
	<T.BoxGeometry args={[0.003, 0.1, 0.01]} />
	<T.MeshStandardMaterial color="#666666" />
</T.Mesh>

<T.Mesh position={[toThree(104.5, 53).x, toThree(104.5, 53).y, 0]}>
	<T.BoxGeometry args={[0.003, 0.1, 0.01]} />
	<T.MeshStandardMaterial color="#666666" />
</T.Mesh>

<!-- Pins Row 1 -->
<T.Mesh position={[toThree(13, 27.2).x, toThree(13, 27.2).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(33, 27.2).x, toThree(33, 27.2).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(53, 27.2).x, toThree(53, 27.2).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(73, 27.2).x, toThree(73, 27.2).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(93, 27.2).x, toThree(93, 27.2).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<!-- Pins Row 2 -->
<T.Mesh position={[toThree(23, 42.7).x, toThree(23, 42.7).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(43, 42.7).x, toThree(43, 42.7).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(63, 42.7).x, toThree(63, 42.7).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(83, 42.7).x, toThree(83, 42.7).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<!-- Pins Row 3 -->
<T.Mesh position={[toThree(13, 58.2).x, toThree(13, 58.2).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(33, 58.2).x, toThree(33, 58.2).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(53, 58.2).x, toThree(53, 58.2).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(73, 58.2).x, toThree(73, 58.2).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(93, 58.2).x, toThree(93, 58.2).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<!-- Pins Row 4 -->
<T.Mesh position={[toThree(23, 73.7).x, toThree(23, 73.7).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(43, 73.7).x, toThree(43, 73.7).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(63, 73.7).x, toThree(63, 73.7).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[toThree(83, 73.7).x, toThree(83, 73.7).y, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.003, 0.003, 0.01, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<!-- Score Walls -->
<T.Mesh position={[toThree(13, 95.5).x, toThree(13, 95.5).y, 0]}>
	<T.BoxGeometry args={[0.003, 0.015, 0.01]} />
	<T.MeshStandardMaterial color="#4ecdc4" />
</T.Mesh>

<T.Mesh position={[toThree(33, 95.5).x, toThree(33, 95.5).y, 0]}>
	<T.BoxGeometry args={[0.003, 0.015, 0.01]} />
	<T.MeshStandardMaterial color="#4ecdc4" />
</T.Mesh>

<T.Mesh position={[toThree(53, 95.5).x, toThree(53, 95.5).y, 0]}>
	<T.BoxGeometry args={[0.003, 0.015, 0.01]} />
	<T.MeshStandardMaterial color="#4ecdc4" />
</T.Mesh>

<T.Mesh position={[toThree(73, 95.5).x, toThree(73, 95.5).y, 0]}>
	<T.BoxGeometry args={[0.003, 0.015, 0.01]} />
	<T.MeshStandardMaterial color="#4ecdc4" />
</T.Mesh>

<T.Mesh position={[toThree(93, 95.5).x, toThree(93, 95.5).y, 0]}>
	<T.BoxGeometry args={[0.003, 0.015, 0.01]} />
	<T.MeshStandardMaterial color="#4ecdc4" />
</T.Mesh>
