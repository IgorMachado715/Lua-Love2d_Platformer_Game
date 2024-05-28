local Map = {}
local STI = require("sti")
local Coin = require("coin")
local Heart = require("heart")
local Spike = require("spike")
local Stone = require("stone")
local Enemy = require("enemy")
local Villain = require("villain")
local Princess = require("princess")
local King = require("king")
local Player = require("player")

function Map:load()
    self.currentLevel = 1
    World = love.physics.newWorld(0, 2000)
    World:setCallbacks(beginContact, endContact)
    self:init()
end

function Map:init()
    self.level = STI("map/" .. self.currentLevel .. ".lua", {"box2d"})
    self.level:box2d_init(World)
    self.solidLayer = self.level.layers.solid
    self.groundLayer = self.level.layers.ground
    self.entityLayer = self.level.layers.entity

    self.solidLayer.visible = false
    self.entityLayer.visible = false
    MapWidth = self.groundLayer.width * 16

    self:spawnEntities()
end

function Map:previous()
    if self.currentLevel > 1 then
        self:clean()
        self.currentLevel = self.currentLevel - 1
        self:init()
        Player:oldMapPosition()
    end
end

function Map:next()
    self:clean()
    self.currentLevel = self.currentLevel + 1
    self:init()
    Player:resetPosition()
end

function Map:clean()
    if self.level then
        self.level:box2d_removeLayer("solid")
    end
    Coin.removeAll()
    Heart.removeAll()
    Enemy.removeAll()
    Villain.removeAll()
    Princess.removeAll()
    Stone.removeAll()
    King.removeAll()
    Spike.removeAll()
end

function Map:update()
    if Player.x > MapWidth - 16 then
        self:next()
    elseif Player.x < 16 and self.currentLevel > 1 then
        self:previous()
    end
end

function Map:spawnEntities()
    for i, v in ipairs(self.entityLayer.objects) do
        if v.type == "spikes" then
            Spike.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "stone" then
            Stone.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "enemy" then
            Enemy.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "villain" then
            Villain.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "princess" then
            Princess.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "king" then
            King.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "coin" then
            Coin.new(v.x, v.y)
        elseif v.type == "heart" then
            Heart.new(v.x, v.y)
        end
    end
end

return Map
