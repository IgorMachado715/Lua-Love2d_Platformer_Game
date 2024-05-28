local Player = require("player")
local Coin = require("coin")
local Heart = require("heart")
local GUI = require("gui")
local Spike = require("spike")
local Stone = require("stone")
local Camera = require("camera")
local Enemy = require("enemy")
local Villain = require("villain")
local Map = require("map")
local Princess = require("princess")
local King = require("king")

local gameState = "playing"  

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    Enemy.loadAssets()
    Villain.loadAssets()
    Princess.loadAssets()
    King.loadAssets()
    Map:load()
    background = love.graphics.newImage("assets/background3.png")
    GUI:load()
    Player:load()
end

function love.update(dt)
    if gameState == "playing" then
        World:update(dt)
        Player:update(dt)
        Coin.updateAll(dt)
        Heart.updateAll(dt)
        Spike.updateAll(dt)
        Stone.updateAll(dt)
        Enemy.updateAll(dt)
        King.updateAll(dt)
        Villain.updateAll(dt)
        Princess.updateAll(dt)
        GUI:update(dt)
        Camera:setPosition(Player.x, 0)
        Map:update(dt)
    end
end

function love.draw()
    love.graphics.draw(background)
    Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)

    Camera:apply()
    Player:draw()
    Enemy.drawAll()
    Villain.drawAll()
    Princess.drawAll()
    King.drawAll()
    Coin.drawAll()
    Heart.drawAll()
    Spike.drawAll()
    Stone.drawAll()
    Camera:clear()

    GUI:draw()

    if gameState == "won" then
        love.graphics.printf("You Win! Press Space to Restart", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    end
end

function love.keypressed(key)
    if gameState == "playing" then
        Player:jump(key)
        Player:handleAttack(dt, ActiveEnemies) 
    elseif gameState == "won" and key == 'space' then
        restartGame()
    end
end

function beginContact(a, b, collision)
    if Coin.beginContact(a, b, collision) then return end
    if Heart.beginContact(a, b, collision) then return end
    if Spike.beginContact(a, b, collision) then return end
    Enemy.beginContact(a, b, collision)
    Enemy.beginContactDamaged(a, b, collision)
    Villain.beginContact(a, b, collision)
    Villain.beginContactDamaged(a, b, collision)
    King.beginContact(a, b, collision)
    King.beginContactDamaged(a, b, collision)
    Princess.beginContact(a, b, collision)
    Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
    Player:endContact(a, b, collision)
end

function gameWon()
    gameState = "won"
end

function restartGame()
    gameState = "playing"
    Map:clean()
    Map.currentLevel = 1
    Map:init()
end
