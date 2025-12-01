// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {Pachinko} from "../src/Pachinko.sol";
import {LibPhysics2D} from "../src/LibPhysics2D.sol";

contract UpdateMap is Script {
    function run(address pachinko) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Pachinko pachinko = Pachinko(pachinko);

        (
            LibPhysics2D.RigidBody[] memory bodies,
            int256 mapWidth,
            int256 mapHeight
        ) = getMap();

        pachinko.setMap(bodies, mapWidth, mapHeight);

        vm.stopBroadcast();
    }

    function getMap()
        internal
        pure
        returns (
            LibPhysics2D.RigidBody[] memory bodies,
            int256 mapWidth,
            int256 mapHeight
        )
    {
        bodies = new LibPhysics2D.RigidBody[](26);
        mapWidth = 106e15;
        mapHeight = 103e15;

        // WALLS
        bodies[0] = LibPhysics2D.initRectBody(
            bodies[0],
            53e15,
            15e14,
            106e15,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[1] = LibPhysics2D.initRectBody(
            bodies[1],
            15e14,
            53e15,
            3e15,
            100e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[2] = LibPhysics2D.initRectBody(
            bodies[2],
            1045e14,
            53e15,
            3e15,
            100e15,
            type(int256).max,
            5e17,
            true
        );

        // PINS
        int256 pinY;
        int256 pinX;

        // first row
        pinY = 272e14;
        pinX = 13e15;
        bodies[3] = LibPhysics2D.initCircleBody(
            bodies[3],
            pinX,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[4] = LibPhysics2D.initCircleBody(
            bodies[4],
            pinX + 2e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[5] = LibPhysics2D.initCircleBody(
            bodies[5],
            pinX + 4e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[6] = LibPhysics2D.initCircleBody(
            bodies[6],
            pinX + 6e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[7] = LibPhysics2D.initCircleBody(
            bodies[7],
            pinX + 8e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );

        // second row
        pinY = 427e14;
        pinX = 23e15;
        bodies[8] = LibPhysics2D.initCircleBody(
            bodies[8],
            pinX,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[9] = LibPhysics2D.initCircleBody(
            bodies[9],
            pinX + 2e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[10] = LibPhysics2D.initCircleBody(
            bodies[10],
            pinX + 4e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[11] = LibPhysics2D.initCircleBody(
            bodies[11],
            pinX + 6e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );

        // third row
        pinY = 582e14;
        pinX = 13e15;
        bodies[12] = LibPhysics2D.initCircleBody(
            bodies[12],
            pinX,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[13] = LibPhysics2D.initCircleBody(
            bodies[13],
            pinX + 2e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[14] = LibPhysics2D.initCircleBody(
            bodies[14],
            pinX + 4e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[15] = LibPhysics2D.initCircleBody(
            bodies[15],
            pinX + 6e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[16] = LibPhysics2D.initCircleBody(
            bodies[16],
            pinX + 8e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );

        // fourth row
        pinY = 737e14;
        pinX = 23e15;
        bodies[17] = LibPhysics2D.initCircleBody(
            bodies[17],
            pinX,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[18] = LibPhysics2D.initCircleBody(
            bodies[18],
            pinX + 2e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[19] = LibPhysics2D.initCircleBody(
            bodies[19],
            pinX + 4e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[20] = LibPhysics2D.initCircleBody(
            bodies[20],
            pinX + 6e16,
            pinY,
            3e15,
            type(int256).max,
            5e17,
            true
        );

        // score walls
        bodies[21] = LibPhysics2D.initRectBody(
            bodies[21],
            13e15,
            955e14,
            3e15,
            15e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[22] = LibPhysics2D.initRectBody(
            bodies[22],
            33e15,
            955e14,
            3e15,
            15e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[23] = LibPhysics2D.initRectBody(
            bodies[23],
            53e15,
            955e14,
            3e15,
            15e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[24] = LibPhysics2D.initRectBody(
            bodies[24],
            73e15,
            955e14,
            3e15,
            15e15,
            type(int256).max,
            5e17,
            true
        );
        bodies[25] = LibPhysics2D.initRectBody(
            bodies[25],
            93e15,
            955e14,
            3e15,
            15e15,
            type(int256).max,
            5e17,
            true
        );
    }
}
