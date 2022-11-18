-----------------------------------------------------------------------------------------
-- Used to create the Flowers class for Burt the Bee
--
-----------------------------------------------------------------------------------------

local Flower = {tag="flower", xPos=600, yPos=300, velocity = -100, mult = 1.25};

-- Constructor
function Flower:new(o)
	o = o or {}; 
  	setmetatable(o, self);
  	self.__index = self;
  	return o;
end

--Used to spawn the flower on screen  as an
function Flower:spawn()
	self.shape = display.newRect(self.xPos, self.yPos, 30, 90)
 	self.shape.tag = self.tag;
 	self.shape:setFillColor (1, 0, 0);
 	physics.addBody(self.shape, "kinematic"); 
end

--Used to move flower across screen
function Flower:move()
	self.shape:setLinearVelocity(self.velocity, 0)
end

--Used to add multiplier to points(?????)
function Flower:multiplyPoints() 
	multiplier = self.mult
end

return Flower