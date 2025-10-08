// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

/// @notice A 2D physics engine library with support for rectangular and circular bodies
/// @author Physics-Onchain
library LibPhysics2D {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    error BodyDoesNotExist();
    error CannotModifyStaticBody();
    error InvalidMass();
    error InvalidDimensions();
    error InvalidRadius();
    error InvalidRestitution();
    error MassRatioTooExtreme();
    error InvalidTimestep();
    error TooManyBodies();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    int256 internal constant WAD = 1e18;
    int256 internal constant GRAVITY = 981e16;
    int256 internal constant MAX_MASS_RATIO = 1000 * WAD;
    uint256 internal constant MAX_TIMESTEP = 100e15; // 0.1 seconds in WAD units
    uint256 internal constant MAX_BODIES = 100;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STRUCTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    struct World {
        RigidBody[] bodies;
    }

    struct Vector2 {
        int256 x;
        int256 y;
    }

    struct AABB {
        Vector2 min;
        Vector2 max;
    }

    struct Circle {
        int256 radius;
    }

    enum ShapeType {
        Rectangle,
        Circle
    }

    struct RigidBody {
        Vector2 position;
        Vector2 velocity;
        Vector2 acceleration;
        ShapeType shapeType;
        bytes colliderData;
        int256 mass;
        int256 restitution;
        bool isStatic;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       WORLD MANAGEMENT                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function getBodyCount(World storage world) internal view returns (uint256) {
        return world.bodies.length;
    }

    function addRectRigidBody(
        World storage world,
        int256 x,
        int256 y,
        int256 width,
        int256 height,
        int256 mass,
        int256 restitution,
        bool isStatic
    ) internal returns (uint256) {
        if (world.bodies.length >= MAX_BODIES) revert TooManyBodies();
        RigidBody memory body;
        body = initRectBody(body, x, y, width, height, mass, restitution, isStatic);
        world.bodies.push(body);
        return world.bodies.length - 1;
    }

    function addCircleRigidBody(
        World storage world,
        int256 x,
        int256 y,
        int256 radius,
        int256 mass,
        int256 restitution,
        bool isStatic
    ) internal returns (uint256) {
        if (world.bodies.length >= MAX_BODIES) revert TooManyBodies();
        RigidBody memory body;
        body = initCircleBody(body, x, y, radius, mass, restitution, isStatic);
        world.bodies.push(body);
        return world.bodies.length - 1;
    }

    /// @notice Removes a rigid body from the world using swap-and-pop for storage reclamation
    /// @dev WARNING: This changes the ID of the last body to the removed body's ID
    /// The last body in the array takes the place of the removed body
    /// @return movedBodyId The ID of the body that was moved (type(uint256).max if no swap occurred)
    function removeRigidBody(World storage world, uint256 id) internal returns (uint256 movedBodyId) {
        if (id >= world.bodies.length) revert BodyDoesNotExist();

        uint256 lastIndex = world.bodies.length - 1;

        if (id != lastIndex) {
            world.bodies[id] = world.bodies[lastIndex];
            movedBodyId = lastIndex;
        } else {
            movedBodyId = type(uint256).max;
        }

        world.bodies.pop();
    }

    function step(World storage world, uint256 timestep) internal {
        if (timestep == 0) return;
        if (timestep > MAX_TIMESTEP) revert InvalidTimestep();
        if (timestep > uint256(type(int256).max)) revert InvalidTimestep();

        // casting to 'int256' is safe because timestep is validated above
        // forge-lint: disable-next-line(unsafe-typecast)
        int256 dt = int256(timestep);

        uint256 bodyCount = world.bodies.length;

        // 1. Apply gravity to all non-static bodies
        for (uint256 i = 0; i < bodyCount; i++) {
            if (!world.bodies[i].isStatic) {
                world.bodies[i] = applyGravity(world.bodies[i]);
            }
        }

        // 2. Integrate velocity (v = v + a * dt)
        for (uint256 i = 0; i < bodyCount; i++) {
            if (!world.bodies[i].isStatic) {
                world.bodies[i] = integrateVelocity(world.bodies[i], dt);
            }
        }

        // 3. Integrate position (p = p + v * dt) BEFORE collision resolution
        for (uint256 i = 0; i < bodyCount; i++) {
            if (!world.bodies[i].isStatic) {
                world.bodies[i] = integratePosition(world.bodies[i], dt);
            }
        }

        // 4. Detect and resolve collisions
        for (uint256 i = 0; i < bodyCount; i++) {
            for (uint256 j = i + 1; j < bodyCount; j++) {
                (RigidBody memory b1, RigidBody memory b2, bool collided) =
                    resolveCollision(world.bodies[i], world.bodies[j]);

                if (collided) {
                    world.bodies[i] = b1;
                    world.bodies[j] = b2;
                }
            }
        }

        // 5. Reset accelerations
        for (uint256 i = 0; i < bodyCount; i++) {
            if (!world.bodies[i].isStatic) {
                world.bodies[i] = resetAcceleration(world.bodies[i]);
            }
        }
    }

    function step(World storage world, World storage map, uint256 timestep) internal {
        if (timestep == 0) return;
        if (timestep > MAX_TIMESTEP) revert InvalidTimestep();
        if (timestep > uint256(type(int256).max)) revert InvalidTimestep();

        // casting to 'int256' is safe because timestep is validated above
        // forge-lint: disable-next-line(unsafe-typecast)
        int256 dt = int256(timestep);

        uint256 bodyCount = world.bodies.length;
        uint256 mapBodyCount = map.bodies.length;

        // 1. Apply gravity to all non-static bodies
        for (uint256 i = 0; i < bodyCount; i++) {
            if (!world.bodies[i].isStatic) {
                world.bodies[i] = applyGravity(world.bodies[i]);
            }
        }

        // 2. Integrate velocity (v = v + a * dt)
        for (uint256 i = 0; i < bodyCount; i++) {
            if (!world.bodies[i].isStatic) {
                world.bodies[i] = integrateVelocity(world.bodies[i], dt);
            }
        }

        // 3. Integrate position (p = p + v * dt) BEFORE collision resolution
        for (uint256 i = 0; i < bodyCount; i++) {
            if (!world.bodies[i].isStatic) {
                world.bodies[i] = integratePosition(world.bodies[i], dt);
            }
        }

        // 4. Detect and resolve collisions
        for (uint256 i = 0; i < bodyCount; i++) {
            for (uint256 j = i + 1; j < bodyCount; j++) {
                (RigidBody memory b1, RigidBody memory b2, bool collided) =
                    resolveCollision(world.bodies[i], world.bodies[j]);

                if (collided) {
                    world.bodies[i] = b1;
                    world.bodies[j] = b2;
                }
            }
        }

        //5. Detect and resolve map collisions
        for (uint256 i = 0; i < bodyCount; i++) {
            // skip if world body is static
            if (world.bodies[i].isStatic) continue;

            for (uint256 j = 0; j < mapBodyCount; j++) {
                // skip if map body is not static
                if (!map.bodies[j].isStatic) continue;

                (RigidBody memory b1,, bool collided) = resolveCollision(world.bodies[i], map.bodies[j]);

                if (collided) {
                    world.bodies[i] = b1;
                }
            }
        }

        // 5. Reset accelerations
        for (uint256 i = 0; i < bodyCount; i++) {
            if (!world.bodies[i].isStatic) {
                world.bodies[i] = resetAcceleration(world.bodies[i]);
            }
        }
    }

    function applyForceToBody(World storage world, uint256 id, int256 fx, int256 fy) internal {
        if (id >= world.bodies.length) revert BodyDoesNotExist();
        world.bodies[id] = applyForce(world.bodies[id], fx, fy);
    }

    function setBodyVelocity(World storage world, uint256 id, int256 vx, int256 vy) internal {
        if (id >= world.bodies.length) revert BodyDoesNotExist();
        world.bodies[id] = setVelocity(world.bodies[id], vx, vy);
    }

    function getBody(World storage world, uint256 id) internal view returns (RigidBody memory) {
        if (id >= world.bodies.length) revert BodyDoesNotExist();
        return world.bodies[id];
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     BODY INITIALIZATION                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function initRectBody(
        RigidBody memory body,
        int256 x,
        int256 y,
        int256 width,
        int256 height,
        int256 mass,
        int256 restitution,
        bool isStatic
    ) internal pure returns (RigidBody memory) {
        if (width <= 0 || height <= 0) revert InvalidDimensions();
        if (mass <= 0) revert InvalidMass();
        if (restitution < 0 || restitution > WAD) revert InvalidRestitution();

        body.position = Vector2(x, y);
        body.velocity = Vector2(0, 0);
        body.acceleration = Vector2(0, 0);
        body.shapeType = ShapeType.Rectangle;

        AABB memory bounds = AABB(Vector2(x - width / 2, y - height / 2), Vector2(x + width / 2, y + height / 2));
        body.colliderData = abi.encode(bounds);

        body.mass = mass;
        body.restitution = restitution;
        body.isStatic = isStatic;
        return body;
    }

    function initCircleBody(
        RigidBody memory body,
        int256 x,
        int256 y,
        int256 radius,
        int256 mass,
        int256 restitution,
        bool isStatic
    ) internal pure returns (RigidBody memory) {
        if (radius <= 0) revert InvalidRadius();
        if (mass <= 0) revert InvalidMass();
        if (restitution < 0 || restitution > WAD) revert InvalidRestitution();

        body.position = Vector2(x, y);
        body.velocity = Vector2(0, 0);
        body.acceleration = Vector2(0, 0);
        body.shapeType = ShapeType.Circle;

        Circle memory circle = Circle(radius);
        body.colliderData = abi.encode(circle);

        body.mass = mass;
        body.restitution = restitution;
        body.isStatic = isStatic;
        return body;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      FORCE APPLICATION                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function applyForce(RigidBody memory body, int256 fx, int256 fy) internal pure returns (RigidBody memory) {
        if (body.isStatic) revert CannotModifyStaticBody();
        if (body.mass == 0) revert InvalidMass();

        body.acceleration.x += FixedPointMathLib.rawSDivWad(fx, body.mass);
        body.acceleration.y += FixedPointMathLib.rawSDivWad(fy, body.mass);

        return body;
    }

    function setVelocity(RigidBody memory body, int256 vx, int256 vy) internal pure returns (RigidBody memory) {
        if (body.isStatic) revert CannotModifyStaticBody();

        body.velocity.x = vx;
        body.velocity.y = vy;

        return body;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    PHYSICS INTEGRATION                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function applyGravity(RigidBody memory body) internal pure returns (RigidBody memory) {
        if (!body.isStatic) {
            body.acceleration.y += GRAVITY;
        }
        return body;
    }

    function integrateVelocity(RigidBody memory body, int256 dt) internal pure returns (RigidBody memory) {
        if (body.isStatic) return body;

        body.velocity.x += FixedPointMathLib.rawSMulWad(body.acceleration.x, dt);
        body.velocity.y += FixedPointMathLib.rawSMulWad(body.acceleration.y, dt);
        return body;
    }

    function integratePosition(RigidBody memory body, int256 dt) internal pure returns (RigidBody memory) {
        if (body.isStatic) return body;

        int256 dx = FixedPointMathLib.rawSMulWad(body.velocity.x, dt);
        int256 dy = FixedPointMathLib.rawSMulWad(body.velocity.y, dt);

        body.position.x += dx;
        body.position.y += dy;

        if (body.shapeType == ShapeType.Rectangle) {
            AABB memory bounds = abi.decode(body.colliderData, (AABB));
            int256 width = bounds.max.x - bounds.min.x;
            int256 height = bounds.max.y - bounds.min.y;

            bounds.min.x = body.position.x - width / 2;
            bounds.min.y = body.position.y - height / 2;
            bounds.max.x = body.position.x + width / 2;
            bounds.max.y = body.position.y + height / 2;

            body.colliderData = abi.encode(bounds);
        }

        return body;
    }

    function resetAcceleration(RigidBody memory body) internal pure returns (RigidBody memory) {
        if (body.isStatic) return body;

        body.acceleration.x = 0;
        body.acceleration.y = 0;
        return body;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    COLLISION DETECTION                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function checkAABBCollision(AABB memory a, AABB memory b) internal pure returns (bool) {
        return (a.min.x <= b.max.x && a.max.x >= b.min.x && a.min.y <= b.max.y && a.max.y >= b.min.y);
    }

    function checkCircleCollision(Vector2 memory pos1, int256 radius1, Vector2 memory pos2, int256 radius2)
        internal
        pure
        returns (bool)
    {
        int256 dx = pos2.x - pos1.x;
        int256 dy = pos2.y - pos1.y;
        int256 distSquared = FixedPointMathLib.rawSMulWad(dx, dx) + FixedPointMathLib.rawSMulWad(dy, dy);
        int256 radiusSum = radius1 + radius2;
        int256 radiusSumSquared = FixedPointMathLib.rawSMulWad(radiusSum, radiusSum);
        return distSquared <= radiusSumSquared;
    }

    function checkCollision(RigidBody memory b1, RigidBody memory b2) internal pure returns (bool) {
        AABB memory bounds1 = getBounds(b1);
        AABB memory bounds2 = getBounds(b2);

        if (!checkAABBCollision(bounds1, bounds2)) {
            return false;
        }

        if (b1.shapeType == ShapeType.Circle && b2.shapeType == ShapeType.Circle) {
            Circle memory c1 = abi.decode(b1.colliderData, (Circle));
            Circle memory c2 = abi.decode(b2.colliderData, (Circle));
            return checkCircleCollision(b1.position, c1.radius, b2.position, c2.radius);
        }

        if (b1.shapeType == ShapeType.Rectangle && b2.shapeType == ShapeType.Rectangle) {
            return true;
        }

        if (b1.shapeType == ShapeType.Circle) {
            Circle memory c1 = abi.decode(b1.colliderData, (Circle));
            return checkCircleRectCollision(b1.position, c1.radius, bounds2);
        } else {
            Circle memory c2 = abi.decode(b2.colliderData, (Circle));
            return checkCircleRectCollision(b2.position, c2.radius, bounds1);
        }
    }

    function checkCircleRectCollision(Vector2 memory circlePos, int256 radius, AABB memory rect)
        internal
        pure
        returns (bool)
    {
        int256 closestX = FixedPointMathLib.clamp(circlePos.x, rect.min.x, rect.max.x);
        int256 closestY = FixedPointMathLib.clamp(circlePos.y, rect.min.y, rect.max.y);

        int256 dx = circlePos.x - closestX;
        int256 dy = circlePos.y - closestY;

        int256 distSquared = FixedPointMathLib.rawSMulWad(dx, dx) + FixedPointMathLib.rawSMulWad(dy, dy);
        int256 radiusSquared = FixedPointMathLib.rawSMulWad(radius, radius);

        return distSquared <= radiusSquared;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                    COLLISION RESOLUTION                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function resolveCollision(RigidBody memory b1, RigidBody memory b2)
        internal
        pure
        returns (RigidBody memory, RigidBody memory, bool)
    {
        if (b1.isStatic && b2.isStatic) {
            return (b1, b2, true);
        }

        if (!checkCollision(b1, b2)) {
            return (b1, b2, false);
        }

        if (b1.shapeType == ShapeType.Circle && b2.shapeType == ShapeType.Circle) {
            return resolveCircleCircleCollision(b1, b2);
        }

        if (b1.shapeType == ShapeType.Rectangle && b2.shapeType == ShapeType.Rectangle) {
            return resolveAABBCollision(b1, b2);
        }

        if (b1.shapeType == ShapeType.Circle) {
            return resolveCircleRectCollision(b1, b2);
        } else {
            (b2, b1,) = resolveCircleRectCollision(b2, b1);
            return (b1, b2, true);
        }
    }

    function resolveAABBCollision(RigidBody memory b1, RigidBody memory b2)
        internal
        pure
        returns (RigidBody memory, RigidBody memory, bool)
    {
        AABB memory bounds1 = abi.decode(b1.colliderData, (AABB));
        AABB memory bounds2 = abi.decode(b2.colliderData, (AABB));

        (Vector2 memory normal, int256 penetration) =
            calculateAABBCollisionData(bounds1, bounds2, b1.position, b2.position);

        separateBodies(b1, b2, normal, penetration);
        updateBoundsAfterCollision(b1);
        updateBoundsAfterCollision(b2);

        int256 e = (b1.restitution + b2.restitution) / 2;

        if (!b1.isStatic && !b2.isStatic) {
            checkMassRatio(b1.mass, b2.mass);

            int256 relVelX = b2.velocity.x - b1.velocity.x;
            int256 relVelY = b2.velocity.y - b1.velocity.y;

            int256 velAlongNormal =
                FixedPointMathLib.rawSMulWad(relVelX, normal.x) + FixedPointMathLib.rawSMulWad(relVelY, normal.y);

            if (velAlongNormal > 0) return (b1, b2, true);

            int256 j = FixedPointMathLib.rawSMulWad(-(WAD + e), velAlongNormal);
            j = FixedPointMathLib.rawSDivWad(
                j, FixedPointMathLib.rawSDivWad(WAD, b1.mass) + FixedPointMathLib.rawSDivWad(WAD, b2.mass)
            );

            int256 impulseX = FixedPointMathLib.rawSMulWad(j, normal.x);
            int256 impulseY = FixedPointMathLib.rawSMulWad(j, normal.y);

            b1.velocity.x -= FixedPointMathLib.rawSDivWad(impulseX, b1.mass);
            b1.velocity.y -= FixedPointMathLib.rawSDivWad(impulseY, b1.mass);
            b2.velocity.x += FixedPointMathLib.rawSDivWad(impulseX, b2.mass);
            b2.velocity.y += FixedPointMathLib.rawSDivWad(impulseY, b2.mass);
        } else if (!b1.isStatic) {
            int256 velDotNormal =
                FixedPointMathLib.rawSMulWad(b1.velocity.x, normal.x)
                + FixedPointMathLib.rawSMulWad(b1.velocity.y, normal.y);
            b1.velocity.x -= FixedPointMathLib.rawSMulWad(FixedPointMathLib.rawSMulWad(velDotNormal, normal.x), WAD + e);
            b1.velocity.y -= FixedPointMathLib.rawSMulWad(FixedPointMathLib.rawSMulWad(velDotNormal, normal.y), WAD + e);
        } else {
            int256 velDotNormal =
                FixedPointMathLib.rawSMulWad(b2.velocity.x, normal.x)
                + FixedPointMathLib.rawSMulWad(b2.velocity.y, normal.y);
            b2.velocity.x -= FixedPointMathLib.rawSMulWad(FixedPointMathLib.rawSMulWad(velDotNormal, normal.x), WAD + e);
            b2.velocity.y -= FixedPointMathLib.rawSMulWad(FixedPointMathLib.rawSMulWad(velDotNormal, normal.y), WAD + e);
        }

        return (b1, b2, true);
    }

    function resolveCircleCircleCollision(RigidBody memory b1, RigidBody memory b2)
        internal
        pure
        returns (RigidBody memory, RigidBody memory, bool)
    {
        Circle memory c1 = abi.decode(b1.colliderData, (Circle));
        Circle memory c2 = abi.decode(b2.colliderData, (Circle));

        int256 dx = b2.position.x - b1.position.x;
        int256 dy = b2.position.y - b1.position.y;
        int256 distSquared = FixedPointMathLib.rawSMulWad(dx, dx) + FixedPointMathLib.rawSMulWad(dy, dy);
        int256 dist = sqrt(distSquared);

        if (dist == 0) return (b1, b2, true);

        Vector2 memory normal = Vector2(FixedPointMathLib.rawSDivWad(dx, dist), FixedPointMathLib.rawSDivWad(dy, dist));

        int256 penetration = c1.radius + c2.radius - dist;

        separateBodies(b1, b2, normal, penetration);

        int256 e = (b1.restitution + b2.restitution) / 2;

        if (!b1.isStatic && !b2.isStatic) {
            checkMassRatio(b1.mass, b2.mass);

            int256 relVelX = b2.velocity.x - b1.velocity.x;
            int256 relVelY = b2.velocity.y - b1.velocity.y;

            int256 velAlongNormal =
                FixedPointMathLib.rawSMulWad(relVelX, normal.x) + FixedPointMathLib.rawSMulWad(relVelY, normal.y);

            if (velAlongNormal > 0) return (b1, b2, true);

            int256 j = FixedPointMathLib.rawSMulWad(-(WAD + e), velAlongNormal);
            j = FixedPointMathLib.rawSDivWad(
                j, FixedPointMathLib.rawSDivWad(WAD, b1.mass) + FixedPointMathLib.rawSDivWad(WAD, b2.mass)
            );

            int256 impulseX = FixedPointMathLib.rawSMulWad(j, normal.x);
            int256 impulseY = FixedPointMathLib.rawSMulWad(j, normal.y);

            b1.velocity.x -= FixedPointMathLib.rawSDivWad(impulseX, b1.mass);
            b1.velocity.y -= FixedPointMathLib.rawSDivWad(impulseY, b1.mass);
            b2.velocity.x += FixedPointMathLib.rawSDivWad(impulseX, b2.mass);
            b2.velocity.y += FixedPointMathLib.rawSDivWad(impulseY, b2.mass);
        } else if (!b1.isStatic) {
            int256 velDotNormal =
                FixedPointMathLib.rawSMulWad(b1.velocity.x, normal.x)
                + FixedPointMathLib.rawSMulWad(b1.velocity.y, normal.y);
            b1.velocity.x -= FixedPointMathLib.rawSMulWad(FixedPointMathLib.rawSMulWad(velDotNormal, normal.x), WAD + e);
            b1.velocity.y -= FixedPointMathLib.rawSMulWad(FixedPointMathLib.rawSMulWad(velDotNormal, normal.y), WAD + e);
        } else {
            int256 velDotNormal =
                FixedPointMathLib.rawSMulWad(b2.velocity.x, normal.x)
                + FixedPointMathLib.rawSMulWad(b2.velocity.y, normal.y);
            b2.velocity.x -= FixedPointMathLib.rawSMulWad(FixedPointMathLib.rawSMulWad(velDotNormal, normal.x), WAD + e);
            b2.velocity.y -= FixedPointMathLib.rawSMulWad(FixedPointMathLib.rawSMulWad(velDotNormal, normal.y), WAD + e);
        }

        return (b1, b2, true);
    }

    function resolveCircleRectCollision(RigidBody memory circle, RigidBody memory rect)
        internal
        pure
        returns (RigidBody memory, RigidBody memory, bool)
    {
        Circle memory c = abi.decode(circle.colliderData, (Circle));
        AABB memory bounds = abi.decode(rect.colliderData, (AABB));

        int256 closestX = FixedPointMathLib.clamp(circle.position.x, bounds.min.x, bounds.max.x);
        int256 closestY = FixedPointMathLib.clamp(circle.position.y, bounds.min.y, bounds.max.y);

        int256 dx = circle.position.x - closestX;
        int256 dy = circle.position.y - closestY;

        int256 distSquared = FixedPointMathLib.rawSMulWad(dx, dx) + FixedPointMathLib.rawSMulWad(dy, dy);
        int256 dist = sqrt(distSquared);

        if (dist == 0) {
            dx = WAD;
            dy = 0;
            dist = WAD;
        }

        Vector2 memory normal = Vector2(FixedPointMathLib.rawSDivWad(dx, dist), FixedPointMathLib.rawSDivWad(dy, dist));

        int256 penetration = c.radius - dist;

        separateCircleRect(circle, rect, normal, penetration);
        updateBoundsAfterCollision(circle);
        updateBoundsAfterCollision(rect);

        int256 e = (circle.restitution + rect.restitution) / 2;

        if (!circle.isStatic && !rect.isStatic) {
            checkMassRatio(circle.mass, rect.mass);

            int256 relVelX = circle.velocity.x - rect.velocity.x;
            int256 relVelY = circle.velocity.y - rect.velocity.y;

            int256 velAlongNormal =
                FixedPointMathLib.rawSMulWad(relVelX, normal.x) + FixedPointMathLib.rawSMulWad(relVelY, normal.y);

            if (velAlongNormal > 0) return (circle, rect, true);

            int256 j = FixedPointMathLib.rawSMulWad(-(WAD + e), velAlongNormal);
            j = FixedPointMathLib.rawSDivWad(
                j, FixedPointMathLib.rawSDivWad(WAD, circle.mass) + FixedPointMathLib.rawSDivWad(WAD, rect.mass)
            );

            int256 impulseX = FixedPointMathLib.rawSMulWad(j, normal.x);
            int256 impulseY = FixedPointMathLib.rawSMulWad(j, normal.y);

            circle.velocity.x -= FixedPointMathLib.rawSDivWad(impulseX, circle.mass);
            circle.velocity.y -= FixedPointMathLib.rawSDivWad(impulseY, circle.mass);
            rect.velocity.x += FixedPointMathLib.rawSDivWad(impulseX, rect.mass);
            rect.velocity.y += FixedPointMathLib.rawSDivWad(impulseY, rect.mass);
        } else if (!circle.isStatic) {
            int256 velDotNormal =
                FixedPointMathLib.rawSMulWad(circle.velocity.x, normal.x)
                + FixedPointMathLib.rawSMulWad(circle.velocity.y, normal.y);
            circle.velocity
            .x -= FixedPointMathLib.rawSMulWad(FixedPointMathLib.rawSMulWad(velDotNormal, normal.x), WAD + e);
            circle.velocity
            .y -= FixedPointMathLib.rawSMulWad(FixedPointMathLib.rawSMulWad(velDotNormal, normal.y), WAD + e);
        } else {
            int256 velDotNormal =
                FixedPointMathLib.rawSMulWad(rect.velocity.x, normal.x)
                + FixedPointMathLib.rawSMulWad(rect.velocity.y, normal.y);
            rect.velocity
            .x -= FixedPointMathLib.rawSMulWad(FixedPointMathLib.rawSMulWad(velDotNormal, normal.x), WAD + e);
            rect.velocity
            .y -= FixedPointMathLib.rawSMulWad(FixedPointMathLib.rawSMulWad(velDotNormal, normal.y), WAD + e);
        }

        return (circle, rect, true);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     HELPER FUNCTIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function calculateAABBCollisionData(AABB memory a, AABB memory b, Vector2 memory posA, Vector2 memory posB)
        internal
        pure
        returns (Vector2 memory normal, int256 penetration)
    {
        int256 overlapX = FixedPointMathLib.min(a.max.x - b.min.x, b.max.x - a.min.x);
        int256 overlapY = FixedPointMathLib.min(a.max.y - b.min.y, b.max.y - a.min.y);

        if (overlapX < overlapY) {
            penetration = overlapX;
            normal.x = (posA.x < posB.x) ? WAD : -WAD;
            normal.y = 0;
        } else {
            penetration = overlapY;
            normal.x = 0;
            normal.y = (posA.y < posB.y) ? WAD : -WAD;
        }
    }

    function sqrt(int256 x) internal pure returns (int256) {
        if (x <= 0) return 0;
        // casting to 'uint256' is safe because x > 0 is verified above
        // forge-lint: disable-next-line(unsafe-typecast)
        return int256(FixedPointMathLib.sqrt(uint256(x)));
    }

    function getBounds(RigidBody memory body) internal pure returns (AABB memory) {
        if (body.shapeType == ShapeType.Rectangle) {
            return abi.decode(body.colliderData, (AABB));
        } else {
            Circle memory c = abi.decode(body.colliderData, (Circle));
            return AABB(
                Vector2(body.position.x - c.radius, body.position.y - c.radius),
                Vector2(body.position.x + c.radius, body.position.y + c.radius)
            );
        }
    }

    function separateBodies(RigidBody memory b1, RigidBody memory b2, Vector2 memory normal, int256 penetration)
        internal
        pure
    {
        if (!b1.isStatic && !b2.isStatic) {
            int256 halfPen = penetration / 2;
            b1.position.x -= FixedPointMathLib.rawSMulWad(normal.x, halfPen);
            b1.position.y -= FixedPointMathLib.rawSMulWad(normal.y, halfPen);
            b2.position.x += FixedPointMathLib.rawSMulWad(normal.x, halfPen);
            b2.position.y += FixedPointMathLib.rawSMulWad(normal.y, halfPen);
        } else if (!b1.isStatic) {
            b1.position.x -= FixedPointMathLib.rawSMulWad(normal.x, penetration);
            b1.position.y -= FixedPointMathLib.rawSMulWad(normal.y, penetration);
        } else {
            b2.position.x += FixedPointMathLib.rawSMulWad(normal.x, penetration);
            b2.position.y += FixedPointMathLib.rawSMulWad(normal.y, penetration);
        }
    }

    function updateBoundsAfterCollision(RigidBody memory body) internal pure {
        if (body.shapeType == ShapeType.Rectangle) {
            AABB memory bounds = abi.decode(body.colliderData, (AABB));
            int256 width = bounds.max.x - bounds.min.x;
            int256 height = bounds.max.y - bounds.min.y;

            bounds.min.x = body.position.x - width / 2;
            bounds.min.y = body.position.y - height / 2;
            bounds.max.x = body.position.x + width / 2;
            bounds.max.y = body.position.y + height / 2;

            body.colliderData = abi.encode(bounds);
        }
    }

    function separateCircleRect(
        RigidBody memory circle,
        RigidBody memory rect,
        Vector2 memory normal,
        int256 penetration
    ) internal pure {
        if (!circle.isStatic && !rect.isStatic) {
            int256 halfPen = penetration / 2;
            circle.position.x += FixedPointMathLib.rawSMulWad(normal.x, halfPen);
            circle.position.y += FixedPointMathLib.rawSMulWad(normal.y, halfPen);
            rect.position.x -= FixedPointMathLib.rawSMulWad(normal.x, halfPen);
            rect.position.y -= FixedPointMathLib.rawSMulWad(normal.y, halfPen);
        } else if (!circle.isStatic) {
            circle.position.x += FixedPointMathLib.rawSMulWad(normal.x, penetration);
            circle.position.y += FixedPointMathLib.rawSMulWad(normal.y, penetration);
        } else {
            rect.position.x -= FixedPointMathLib.rawSMulWad(normal.x, penetration);
            rect.position.y -= FixedPointMathLib.rawSMulWad(normal.y, penetration);
        }
    }

    function checkMassRatio(int256 mass1, int256 mass2) internal pure {
        int256 ratio =
            mass1 > mass2 ? FixedPointMathLib.rawSDivWad(mass1, mass2) : FixedPointMathLib.rawSDivWad(mass2, mass1);
        if (ratio > MAX_MASS_RATIO) revert MassRatioTooExtreme();
    }
}
