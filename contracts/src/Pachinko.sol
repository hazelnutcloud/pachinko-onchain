// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {LibPhysics2D} from "./LibPhysics2D.sol";
import {Ownable} from "solady/auth/Ownable.sol";

contract Pachinko is Ownable {
    using LibPhysics2D for LibPhysics2D.World;

    error GameAlreadyStarted();
    error GameNotStarted();
    error InvalidBallPosition();
    error MapNotInitialized();

    event GameStarted(address indexed player, int256 ballX, int256 ballY);
    event GameEnded(address indexed player, int256 ballX, int256 ballY);
    event GameTicked(address indexed player, int256 ballX, int256 ballY);

    struct PlayerGame {
        LibPhysics2D.World world;
        bool isPlaying;
    }

    uint256 internal constant TIMESTEP = 20e15; // 20 milliseconds i.e. 50 hz

    LibPhysics2D.World internal map;
    int256 internal mapWidth;
    int256 internal mapHeight;
    bool internal isMapInitialized;

    mapping(address => PlayerGame) internal playerGames;

    constructor() {
        _initializeOwner(msg.sender);
    }

    function setMap(
        LibPhysics2D.RigidBody[] calldata bodies,
        int256 width,
        int256 height
    ) external onlyOwner {
        map.setBodies(bodies);
        mapWidth = width;
        mapHeight = height;
        isMapInitialized = true;
    }

    function startGame(int256 ballPosition) external {
        PlayerGame storage game = playerGames[msg.sender];

        if (game.isPlaying) {
            revert GameAlreadyStarted();
        }
        if (!isMapInitialized) {
            revert MapNotInitialized();
        }
        if (ballPosition < 0 || ballPosition > mapWidth) {
            revert InvalidBallPosition();
        }

        int256 initialY = 105e17;

        game.world.addCircleRigidBody(
            ballPosition,
            initialY,
            25e17,
            1e18,
            5e17,
            false
        );

        game.isPlaying = true;

        emit GameStarted(msg.sender, ballPosition, initialY);
    }

    function stepGame() external {
        PlayerGame storage game = playerGames[msg.sender];

        if (!game.isPlaying) {
            revert GameNotStarted();
        }

        game.world.step(map, TIMESTEP);

        LibPhysics2D.RigidBody storage ball = game.world.bodies[0];

        emit GameTicked(msg.sender, ball.position.x, ball.position.y);

        if (ball.position.y >= mapHeight) {
            game.isPlaying = false;
            game.world.removeRigidBody(0);
            emit GameEnded(msg.sender, ball.position.x, ball.position.y);
        }
    }

    function resetGame() external {
        PlayerGame storage game = playerGames[msg.sender];

        if (!game.isPlaying) {
            revert GameNotStarted();
        }

        game.world.removeRigidBody(0);
        game.isPlaying = false;

        emit GameEnded(msg.sender, 0, 0);
    }

    function getPlayerGameStatus(
        address player
    ) external view returns (bool isPlaying, int256 ballX, int256 ballY) {
        PlayerGame storage game = playerGames[player];

        isPlaying = game.isPlaying;
        ballX = game.world.bodies[0].position.x;
        ballY = game.world.bodies[0].position.y;
    }
}
