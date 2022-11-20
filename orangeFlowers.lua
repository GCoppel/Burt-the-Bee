-----------------------------------------------------------------------------------------
-- Used to create the Orange Flowers class for Burt the Bee
--		Inherits from Flowers class
-----------------------------------------------------------------------------------------

local Flowers = require("flowers")

local orangeFlowers = Flowers:new({xPos=600, yPos=300, velocity = -100, mult = 1.25})

--Used to spawn an orange flower on screen
function orangeFlowers:spawn(imageSheet, frame)
	local randomHeight = math.random(5, 25)
	self.shape = display.newImage(imageSheet, frame)
 	self.shape.tag = self.tag;
 	self.shape.x = self.xPos;
 	self.shape.y = self.yPos - randomHeight;
 	physics.addBody(self.shape, "kinematic", {shape = {-50,-50, 50,-50, 0,50}}); 
end

--Used to add multiplier to points(?????)
function orangeFlowers:multiplyPoints() 
	multiplier = self.mult
end

return orangeFlowers