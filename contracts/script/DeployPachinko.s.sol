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
        mapWidth = 106e18;
        mapHeight = 103e18;

        // WALLS
        bodies[0] = LibPhysics2D.initRectBody(
            bodies[0],
            53e18,
            15e17,
            106e18,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[1] = LibPhysics2D.initRectBody(
            bodies[1],
            15e17,
            53e18,
            3e18,
            100e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[2] = LibPhysics2D.initRectBody(
            bodies[2],
            1045e17,
            53e18,
            3e18,
            100e18,
            type(int256).max,
            5e17,
            true
        );

        // PINS
        int256 pinY;
        int256 pinX;

        // first row
        pinY = 272e17;
        pinX = 13e18;
        bodies[3] = LibPhysics2D.initCircleBody(
            bodies[3],
            pinX,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[4] = LibPhysics2D.initCircleBody(
            bodies[4],
            pinX + 20e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[5] = LibPhysics2D.initCircleBody(
            bodies[5],
            pinX + 40e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[6] = LibPhysics2D.initCircleBody(
            bodies[6],
            pinX + 60e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[7] = LibPhysics2D.initCircleBody(
            bodies[7],
            pinX + 80e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );

        // second row
        pinY = 427e17;
        pinX = 23e18;
        bodies[8] = LibPhysics2D.initCircleBody(
            bodies[8],
            pinX,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[9] = LibPhysics2D.initCircleBody(
            bodies[9],
            pinX + 20e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[10] = LibPhysics2D.initCircleBody(
            bodies[10],
            pinX + 40e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[11] = LibPhysics2D.initCircleBody(
            bodies[11],
            pinX + 60e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );

        // third row
        pinY = 582e17;
        pinX = 13e18;
        bodies[12] = LibPhysics2D.initCircleBody(
            bodies[12],
            pinX,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[13] = LibPhysics2D.initCircleBody(
            bodies[13],
            pinX + 20e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[14] = LibPhysics2D.initCircleBody(
            bodies[14],
            pinX + 40e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[15] = LibPhysics2D.initCircleBody(
            bodies[15],
            pinX + 60e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[16] = LibPhysics2D.initCircleBody(
            bodies[16],
            pinX + 80e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );

        // fourth row
        pinY = 737e17;
        pinX = 23e18;
        bodies[17] = LibPhysics2D.initCircleBody(
            bodies[17],
            pinX,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[18] = LibPhysics2D.initCircleBody(
            bodies[18],
            pinX + 20e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[19] = LibPhysics2D.initCircleBody(
            bodies[19],
            pinX + 40e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[20] = LibPhysics2D.initCircleBody(
            bodies[20],
            pinX + 60e18,
            pinY,
            3e18,
            type(int256).max,
            5e17,
            true
        );

        // score walls
        bodies[21] = LibPhysics2D.initRectBody(
            bodies[21],
            13e18,
            955e17,
            3e18,
            15e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[22] = LibPhysics2D.initRectBody(
            bodies[22],
            33e18,
            955e17,
            3e18,
            15e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[23] = LibPhysics2D.initRectBody(
            bodies[23],
            53e18,
            955e17,
            3e18,
            15e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[24] = LibPhysics2D.initRectBody(
            bodies[24],
            73e18,
            955e17,
            3e18,
            15e18,
            type(int256).max,
            5e17,
            true
        );
        bodies[25] = LibPhysics2D.initRectBody(
            bodies[25],
            93e18,
            955e17,
            3e18,
            15e18,
            type(int256).max,
            5e17,
            true
        );
    }
}
