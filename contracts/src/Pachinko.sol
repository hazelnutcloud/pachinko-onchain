// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {LibPhysics2D} from "./LibPhysics2D.sol";

contract Pachinko {
    using LibPhysics2D for LibPhysics2D.World;

    LibPhysics2D.World internal world;
}
