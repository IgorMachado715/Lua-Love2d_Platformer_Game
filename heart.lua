

local Heart = {}
Heart.__index = Heart
local ActiveHearts = {}
local Player = require("player")

function Heart.new(x,y)
   local instance = setmetatable({}, Heart)
   instance.x = x
   instance.y = y
   instance.img = love.graphics.newImage("assets/heart.png")
   instance.width = instance.img:getWidth()
   instance.height = instance.img:getHeight()
   instance.scaleX = 1
   instance.randomTimeOffset = math.random(0, 100)
   instance.toBeRemoved = false

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.fixture:setSensor(true)
   table.insert(ActiveHearts, instance)
end

function Heart:remove()
   for i,instance in ipairs(ActiveHearts) do
      if instance == self then
         Player:incrementHealth()
         self.physics.body:destroy()
         table.remove(ActiveHearts, i)
      end
   end
end

function Heart.removeAll()
   for i,v in ipairs(ActiveHearts) do
      v.physics.body:destroy()
   end

   ActiveHearts = {}
end


function Heart:update(dt)
   self:spin(dt)
   self:checkRemove()
end

function Heart:checkRemove()
   if self.toBeRemoved then
      self:remove()
   end
end

function Heart:spin(dt)
   self.scaleX = math.sin(love.timer.getTime() * 2 + self.randomTimeOffset)
end

function Heart:draw()
   love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Heart.updateAll(dt)
   for i,instance in ipairs(ActiveHearts) do
      instance:update(dt)
   end
end

function Heart.drawAll()
   for i,instance in ipairs(ActiveHearts) do
      instance:draw()
   end
end

function Heart.beginContact(a, b, collision)
   for i,instance in ipairs(ActiveHearts) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            instance.toBeRemoved = true
            return true
         end
      end
   end
end

return Heart
