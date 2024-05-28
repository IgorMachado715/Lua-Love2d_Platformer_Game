

local Princess = {}
Princess.__index = Princess
local Player = require("player")

local ActivePrincesses = {}

function Princess.removeAll()
   for i,v in ipairs(ActivePrincesses) do
      v.physics.body:destroy()
   end

   ActivePrincesses = {}
end

function Princess.new(x,y)
   local instance = setmetatable({}, Princess)
   instance.x = x
   instance.y = y
   instance.offsetY = -8
   instance.r = 0

   instance.speed = 100
   instance.speedMod = 1
   instance.xVel = instance.speed

   instance.rageCounter = 0
   instance.rageTrigger = 3

   instance.damage = 1

   instance.state = "walk"

   instance.animation = {timer = 0, rate = 0.1}
   instance.animation.run = {total = 7, current = 1, img = Princess.runAnim}
   instance.animation.walk = {total = 7, current = 1, img = Princess.walkAnim}
   instance.animation.draw = instance.animation.walk.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.4, instance.height * 0.75)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)
   table.insert(ActivePrincesses, instance)
end

function Princess.loadAssets()
   Princess.runAnim = {}
   for i=1,7 do
      Princess.runAnim[i] = love.graphics.newImage("assets/Princess/run/"..i..".png")
   end

   Princess.walkAnim = {}
   for i=1,7 do
      Princess.walkAnim[i] = love.graphics.newImage("assets/Princess/walk/"..i..".png")
   end

   Princess.width = Princess.runAnim[1]:getWidth()
   Princess.height = Princess.runAnim[1]:getHeight()
end

function Princess:update(dt)
   self:syncPhysics()
   self:animate(dt)
end

function Princess:incrementRage()
   self.rageCounter = self.rageCounter + 1
   if self.rageCounter > self.rageTrigger then
      self.state = "run"
      self.speedMod = 3
      self.rageCounter = 0
   else
      self.state = "walk"
      self.speedMod = 1
   end
end

function Princess:flipDirection()
   self.xVel = -self.xVel
end

function Princess:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function Princess:setNewFrame()
   local anim = self.animation[self.state]
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function Princess:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel * self.speedMod, 100)
end

function Princess:draw()
   local scaleX = 1
   if self.xVel < 0 then
      scaleX = -1
   end
   love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, self.r, scaleX, 1, self.width / 2, self.height / 2)
end

function Princess.updateAll(dt)
   for i,instance in ipairs(ActivePrincesses) do
      instance:update(dt)
   end
end

function Princess.drawAll()
   for i,instance in ipairs(ActivePrincesses) do
      instance:draw()
   end
end

function Princess.beginContact(a, b, collision)
   for i,instance in ipairs(ActivePrincesses) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            gameWon()
         end
        --instance:incrementRage()--
        -- instance:flipDirection()--
      end
   end
end

function gameWon()
   gameState = "won"
 end
 


return Princess