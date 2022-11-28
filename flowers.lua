-----------------------------------------------------------------------------------------
-- Used to create the Flowers class for Burt the Bee
-----------------------------------------------------------------------------------------

local Flower = {tag="flower", xPos=0, yPos=0, velocity = 0, mult = 0.0};

-- Constructor
function Flower:new(o)
	o = o or {}; 
  	setmetatable(o, self);
  	self.__index = self;
  	return o;
end

--Used to spawn the flower on screen
function Flower:spawn()
	self.shape = display.newRect(self.xPos, self.yPos, 30, 90)
 	self.shape.tag = self.tag;
 	self.shape:setFillColor (1, 0, 0);
 	physics.addBody(self.shape, "kinematic", {shape = {-50,-25, 50,-25, 50,25, -50, 25}}); 
end

--Used to move flower across screen
function Flower:move()
	self.shape:setLinearVelocity(self.velocity, 0)
end

return Flower