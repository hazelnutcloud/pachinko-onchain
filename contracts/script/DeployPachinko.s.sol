// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {Pachinko} from "../src/Pachinko.sol";
import {LibPhysics2D} from "../src/LibPhysics2D.sol";

contract DeployPachinko is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Pachinko pachinko = new Pachinko();

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
        mapWidth = 1060e18;
        mapHeight = 1030e18;

        // WALLS
        bodies[0] = LibPhysics2D.initRectBody(
            bodies[0],
            530e18,
            15e18,
            1060e18,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[1] = LibPhysics2D.initRectBody(
            bodies[1],
            15e18,
            530e18,
            30e18,
            1000e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[2] = LibPhysics2D.initRectBody(
            bodies[2],
            1045e18,
            530e18,
            30e18,
            1000e18,
            type(int256).max,
            5e17,
            true
        );

        // PINS
        int256 pinY;
        int256 pinX;

        // first row
        pinY = 272e18;
        pinX = 130e18;
        bodies[3] = LibPhysics2D.initCircleBody(
            bodies[3],
            pinX,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[4] = LibPhysics2D.initCircleBody(
            bodies[4],
            pinX + 200e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[5] = LibPhysics2D.initCircleBody(
            bodies[5],
            pinX + 400e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[6] = LibPhysics2D.initCircleBody(
            bodies[6],
            pinX + 600e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[7] = LibPhysics2D.initCircleBody(
            bodies[7],
            pinX + 800e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );

        // second row
        pinY = 427e18;
        pinX = 230e18;
        bodies[8] = LibPhysics2D.initCircleBody(
            bodies[8],
            pinX,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[9] = LibPhysics2D.initCircleBody(
            bodies[9],
            pinX + 200e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[10] = LibPhysics2D.initCircleBody(
            bodies[10],
            pinX + 400e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[11] = LibPhysics2D.initCircleBody(
            bodies[11],
            pinX + 600e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );

        // third row
        pinY = 582e18;
        pinX = 130e18;
        bodies[12] = LibPhysics2D.initCircleBody(
            bodies[12],
            pinX,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[13] = LibPhysics2D.initCircleBody(
            bodies[13],
            pinX + 200e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[14] = LibPhysics2D.initCircleBody(
            bodies[14],
            pinX + 400e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[15] = LibPhysics2D.initCircleBody(
            bodies[15],
            pinX + 600e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[16] = LibPhysics2D.initCircleBody(
            bodies[16],
            pinX + 800e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );

        // fourth row
        pinY = 737e18;
        pinX = 230e18;
        bodies[17] = LibPhysics2D.initCircleBody(
            bodies[17],
            pinX,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[18] = LibPhysics2D.initCircleBody(
            bodies[18],
            pinX + 200e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[19] = LibPhysics2D.initCircleBody(
            bodies[19],
            pinX + 400e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[20] = LibPhysics2D.initCircleBody(
            bodies[20],
            pinX + 600e18,
            pinY,
            30e18,
            type(int256).max,
            5e17,
            true
        );

        // score walls
        bodies[21] = LibPhysics2D.initRectBody(
            bodies[21],
            130e18,
            955e18,
            30e18,
            150e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[22] = LibPhysics2D.initRectBody(
            bodies[22],
            330e18,
            955e18,
            30e18,
            150e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[23] = LibPhysics2D.initRectBody(
            bodies[23],
            530e18,
            955e18,
            30e18,
            150e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[24] = LibPhysics2D.initRectBody(
            bodies[24],
            730e18,
            955e18,
            30e18,
            150e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[25] = LibPhysics2D.initRectBody(
            bodies[25],
            930e18,
            955e18,
            30e18,
            150e18,
            type(int256).max,
            5e17,
            true
        );
    }
}
