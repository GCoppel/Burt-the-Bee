-----------------------------------------------------------------------------------------
-- Used to create the Purple Flowers class for Burt the Bee
--		Inherits from Flowers class
-----------------------------------------------------------------------------------------

local Flowers = require("flowers")

local purpleFlowers = Flowers:new({xPos=600, yPos=300, velocity = -190, mult = 2.0})

--Used to spawn an orange flower on screen
function purpleFlowers:spawn(imageSheet, frame)
	local randomHeight = math.random(10, 20)
	self.shape = display.newImage(imageSheet, frame)
 	self.shape.tag = self.tag;
 	self.shape.x = self.xPos;
 	self.shape.y = self.yPos + randomHeight;
 	physics.addBody(self.shape, "kinematic"); 
end

--Used to add multiplier to points(?????)
function purpleFlowers:multiplyPoints() 
	multiplier = self.mult
end

return purpleFlowers