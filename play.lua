local composer = require("composer")
local physics = require("physics")
local scene = composer.newScene()

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

---------------------------------------------------------------------------------

local spawnGroup = display.newGroup();

-- "scene:create()"
function scene:create(event)

   local sceneGroup = self.view

   physics.start(); --Start physics calculations
   physics.setGravity(0,25);

   --Pause:
   local function Pause()
      physics.pause();
      timer.pauseAll();
      composer.showOverlay("pause", {
         effect = "fade",
         time = 500,
         isModal = true
      });
   end

   local options = {
      x = 500,
      y = 50,
      width = 100,
      height = 50,
      label = "Pause",
      labelColor = { default = { 1, 1, 0 }, over = { 0, 0, 0 } },
      onPress = Pause,
      shape = "roundedRect",
      fillColor = { default = { 0, 0, 0, 0.1 }, over = { 1, 1, 0 } },
      strokeColor = { default = { 1, 1, 0 }, over = { 1, 1, 0 } },
      strokeWidth = 2
   }
   local pauseButton = widget.newButton(options);
   sceneGroup:insert(pauseButton);

   local Burt = display.newRect(display.contentCenterX - 100, display.contentCenterY, 45, 30);
   Burt:setFillColor(1, 1, 0);
   sceneGroup:insert(Burt);

   physics.addBody(Burt, "dynamic", {bounce = -1});

   local ceiling = display.newRect(display.contentCenterX, 0, 1000, 1);
   ceiling:setFillColor(0,0,0,0);
   sceneGroup:insert(ceiling);
   physics.addBody(ceiling, "static");

   local function groundCollision()
      print("ground hit, dead");
   end

   local ground = display.newRect(display.contentCenterX, display.contentHeight, 1000, 10);
   ground:setFillColor(0,1,0);
   sceneGroup:insert(ground);
   physics.addBody(ground, "static");
   ground:addEventListener("collision", groundCollision)

   local function flyUp()
      Burt:setLinearVelocity(0,-250);
   end

   Runtime:addEventListener("tap", flyUp);

   local function setRotation()
      local xv, yv = Burt:getLinearVelocity();
      if (yv > 150) then
         Burt:setLinearVelocity(0,150);
      end
      Burt.rotation = yv /25;
   end

   timer.performWithDelay(10,setRotation,0);

end

-- "scene:show()"
function scene:show(event)

   local sceneGroup = self.view
   local phase = event.phase

   if (phase == "will") then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif (phase == "did") then

      display.setDefault("background", 0, 0.9, 1); --Set background to a skyblue color

      local hornetOrLife;
      local object;

      local function deleteObject()
         object:removeSelf();
      end

      local function collisionDetected(event)
         if (event.target.type == "hornet") then
            print("dead");
         else
            print("bonus!")
         end
         event.target:removeSelf();
      end

      local function spawnObject()
         hornetOrLife = math.random(1, 2);
         local spawnHeight = math.random(50,450);
         if (hornetOrLife == 1) then
            object = display.newRect(600, spawnHeight, 45, 30);
            object:setFillColor(1, 0, 0);
            object.type = "hornet";
         else
            object = display.newCircle(600, spawnHeight, 15);
            object.type = "bonus";
         end

         physics.addBody(object, "kinematic");
         object.isSensor = true;
         object:setLinearVelocity(-125,0);

         object:addEventListener("collision", collisionDetected)
      end

      timer.performWithDelay(
         2500 + math.random(1500),
         spawnObject,
         0
      )
   end
end

-- "scene:hide()"
function scene:hide(event)

   local sceneGroup = self.view
   local phase = event.phase

   if (phase == "will") then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif (phase == "did") then
      -- Called immediately after scene goes off screen.
   end
end

-- "scene:destroy()"
function scene:destroy(event)

   local sceneGroup = self.view

   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

---------------------------------------------------------------------------------

return scene
