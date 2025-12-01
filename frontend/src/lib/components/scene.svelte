<script lang="ts">
	import { T } from '@threlte/core';
	import { OrbitControls,
	// Gizmo, Grid
	} from '@threlte/extras';

	const { ballX, ballY }: { ballX: number; ballY: number } = $props();
</script>

<T.PerspectiveCamera makeDefault position={[5.3, -5.15, 15]} fov={40} oncreate={(e) => {
  e.lookAt(5.3, -5.15, 0);
}}>
	<OrbitControls target={[5.3, -5.15, 0]}>
		<!-- <Gizmo /> -->
	</OrbitControls>
</T.PerspectiveCamera>

<T.AmbientLight intensity={0.5} />
<T.DirectionalLight position={[5, 10, 5]} intensity={0.8} />

<!-- <Grid></Grid> -->

<!-- Ball  --> --
	<T.Mesh position={[ballX * 10, -ballY * 10, 0]}>
		<T.SphereGeometry args={[0.25, 32, 32]} />
		<T.MeshStandardMaterial color="#ff6b6b" />
	</T.Mesh>

<!-- Walls -->
<T.Mesh position={[5.3, -0.15, 0]}>
	<T.BoxGeometry args={[10.6, 0.3, 0.1]} />
	<T.MeshStandardMaterial color="#666666" />
</T.Mesh>

<T.Mesh position={[0.15, -5.3, 0]}>
	<T.BoxGeometry args={[0.3, 10, 0.1]} />
	<T.MeshStandardMaterial color="#666666" />
</T.Mesh>

<T.Mesh position={[10.45, -5.3, 0]}>
	<T.BoxGeometry args={[0.3, 10, 0.1]} />
	<T.MeshStandardMaterial color="#666666" />
</T.Mesh>

<!-- Pins Row 1 -->
<T.Mesh position={[1.3, -2.72, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[3.3, -2.72, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[5.3, -2.72, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[7.3, -2.72, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[9.3, -2.72, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<!-- Pins Row 2 -->
<T.Mesh position={[2.3, -4.27, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[4.3, -4.27, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[6.3, -4.27, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[8.3, -4.27, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<!-- Pins Row 3 -->
<T.Mesh position={[1.3, -5.82, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[3.3, -5.82, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[5.3, -5.82, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[7.3, -5.82, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[9.3, -5.82, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<!-- Pins Row 4 -->
<T.Mesh position={[2.3, -7.37, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[4.3, -7.37, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[6.3, -7.37, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<T.Mesh position={[8.3, -7.37, 0]} rotation={[Math.PI / 2, 0, 0]}>
	<T.CylinderGeometry args={[0.3, 0.3, 0.1, 32]} />
	<T.MeshStandardMaterial color="#ff6b6b" />
</T.Mesh>

<!-- Score Walls -->
<T.Mesh position={[1.3, -9.55, 0]}>
	<T.BoxGeometry args={[0.3, 1.5, 0.1]} />
	<T.MeshStandardMaterial color="#4ecdc4" />
</T.Mesh>

<T.Mesh position={[3.3, -9.55, 0]}>
	<T.BoxGeometry args={[0.3, 1.5, 0.1]} />
	<T.MeshStandardMaterial color="#4ecdc4" />
</T.Mesh>

<T.Mesh position={[5.3, -9.55, 0]}>
	<T.BoxGeometry args={[0.3, 1.5, 0.1]} />
	<T.MeshStandardMaterial color="#4ecdc4" />
</T.Mesh>

<T.Mesh position={[7.3, -9.55, 0]}>
	<T.BoxGeometry args={[0.3, 1.5, 0.1]} />
	<T.MeshStandardMaterial color="#4ecdc4" />
</T.Mesh>

<T.Mesh position={[9.3, -9.55, 0]}>
	<T.BoxGeometry args={[0.3, 1.5, 0.1]} />
	<T.MeshStandardMaterial color="#4ecdc4" />
</T.Mesh>
