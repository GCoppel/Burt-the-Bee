-----------------------------------------------------------------------------------------
-- Used to create the Pink Flowers class for Burt the Bee
--		Inherits from Flowers class
-----------------------------------------------------------------------------------------

local Flowers = require("flowers")

local pinkFlowers = Flowers:new({xPos=600, yPos=300, velocity = -150, mult = 3})

--Used to spawn an orange flower on screen
function pinkFlowers:spawn(imageSheet, frame)
	local randomHeight = math.random(0, 20)
	self.shape = display.newImage(imageSheet, frame)
 	self.shape.tag = self.tag;
 	self.shape.x = self.xPos;
 	self.shape.y = self.yPos - randomHeight;
 	self.shape.mult = self.mult;
 	physics.addBody(self.shape, "kinematic", {shape = {-50,-30, 50,-30, 50, 0, -50, 0}}); 
end

return pinkFlowers