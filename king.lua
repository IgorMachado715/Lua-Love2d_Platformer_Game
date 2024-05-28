local King = {}
King.__index = King
local Player = require("player")

local ActiveKings = {}

function King.removeAll()
   for i, v in ipairs(ActiveKings) do
      v.physics.body:destroy()
   end

   ActiveKings = {}
end

function King.new(x, y)
   local instance = setmetatable({}, King)
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

   instance.state = "idle"

   instance.health = {current = 5, max = 5}

   instance.color = {
      red = 1,
      green = 1,
      blue = 1,
      speed = 3,
   }

   instance.alive = true

   instance.animation = {timer = 0, rate = 0.1}
   instance.animation.idle = {total = 8, current = 1, img = King.idleAnim}
   instance.animation.draw = instance.animation.idle.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.4, instance.height * 0.75)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)

   table.insert(ActiveKings, instance)
   return instance
end

function King.loadAssets()
 
   King.idleAnim = {}
   for i = 1, 8 do
      King.idleAnim[i] = love.graphics.newImage("assets/king/idle/" .. i .. ".png")
   end


   King.width = King.idleAnim[1]:getWidth()
   King.height = King.idleAnim[1]:getHeight()

end

function King:update(dt)
   if not self.alive then
      return
   end

   self:syncPhysics()
   self:animate(dt)
end

function King:animate(dt)
   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function King:setNewFrame()
   local anim = self.animation[self.state]
   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end
   self.animation.draw = anim.img[anim.current]
end

function King:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel * self.speedMod, 100)
end

function King:draw()
   if not self.alive then
      return
   end

   local scaleX = 1
   if self.xVel < 0 then
      scaleX = -1
   end
   love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, self.r, scaleX, 1, self.width / 2, self.height / 2)
end

function King.updateAll(dt)
   for i, instance in ipairs(ActiveKings) do
      instance:update(dt)
   end
end

function King.drawAll()
   for i, instance in ipairs(ActiveKings) do
      instance:draw()
   end
end

function King:takeDamage(amount)
   self:tintRed()
   if self.health.current - amount > 0 then
      self.health.current = self.health.current - amount
   else
      self.health.current = 0
      self:die()
   end
   print("King health: " .. self.health.current)
end

function King:die()
   print("King died")
   self.alive = false
   for i, instance in ipairs(ActiveKings) do
      if instance == self then
         table.remove(ActiveKings, i)
         break
      end
   end
end

function King:tintRed()
   self.color.green = 0
   self.color.blue = 0
end

function King:setState()
   if self.alive == false then
      self.state = "die"
   else
      self.state = "idle"
   end
end

function King.beginContact(a, b, collision)
   for i, instance in ipairs(ActiveKings) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
      if a == Player.physics.fixture or b == Player.physics.fixture then
            --Player:takeDamage(instance.damage)--
         end
      end
   end
end

function King.beginContactDamaged(a, b, collision)
   for i, instance in ipairs(ActiveKings) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
      if a == Player.physics.fixture or b == Player.physics.fixture and Player.state == "attack" then
            --instance:takeDamage(Player.damage) --
         end
      end
   end
end

return King
