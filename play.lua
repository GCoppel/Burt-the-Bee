local composer = require("composer")
local physics = require("physics")
local scene = composer.newScene()

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

---------------------------------------------------------------------------------

local spawned; --Group of spawned objects still in memory. Is removed from memory when scene is destroyed. 

-- "scene:create()"
function scene:create(event)

   spawned = display.newGroup();

   local sceneGroup = self.view

   --local function startPhysics()
   physics.start(); --Start physics calculations
   physics.setGravity(0, 25);
   --Runtime:removeEventListener("tap", startPhysics);
   -- end
   -- Runtime:addEventListener("tap", startPhysics);


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

   physics.addBody(Burt, "dynamic", { bounce = -1 });

   local ceiling = display.newRect(display.contentCenterX, 0, 1000, 1);
   ceiling:setFillColor(0, 0, 0, 0);
   sceneGroup:insert(ceiling);
   physics.addBody(ceiling, "static");

   local function groundCollision()
      print("ground hit, dead");
   end

   local ground = display.newRect(display.contentCenterX, display.contentHeight, 1000, 10);
   ground:setFillColor(0, 1, 0);
   sceneGroup:insert(ground);
   physics.addBody(ground, "static");
   ground:addEventListener("collision", groundCollision)

   function flyUp()
      Burt:setLinearVelocity(0, -250);
   end

   Runtime:addEventListener("tap", flyUp);

   local function setRotation()
      local xv, yv = Burt:getLinearVelocity();
      if (yv > 150) then
         Burt:setLinearVelocity(0, 150);
      end
      Burt.rotation = yv / 25;
   end

   timer.performWithDelay(10, setRotation, 0);

end

-- "scene:show()"
function scene:show(event)

   local sceneGroup = self.view
   local phase = event.phase

   if (phase == "will") then
      display.setDefault("background", 0, 0.9, 1); --Set background to a skyblue color
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif (phase == "did") then

      local hornetOrLife;
      local object;

      local objects = {}; --Contains spawned objects. Used for checking for offscreen objects that can be removed from memory
      local objectIndex; --Location of target object in "objects" table

      --Function to find the index of a value in a table:
      function indexOf(table, value)
         for index, val in ipairs(table) do
            if value == val then
               return index
            end
         end
      end

      local function collisionDetected(event)
         if (event.target.type == "hornet") then
            print("dead");
         else
            print("bonus!")
         end
         --Remove collision object from table of objects and then from memory
         objectIndex = indexOf(objects, event.target);
         table.remove(objects, objectIndex);
         event.target:removeSelf();
      end

      --Removes offscreen hornets and bonus items from memory
      local function cleanup()
         for _, object in ipairs(objects) do
            print(object.type,object.x);
            if (object.x < -50) then
               objectIndex = indexOf(objects, object);
               table.remove(objects, objectIndex);
               object:removeSelf();
            end
         end
      end

      local function spawnObject()
         hornetOrLife = math.random(1, 2);
         local spawnHeight = math.random(50, 450);
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
         object:setLinearVelocity(-125, 0);

         object:addEventListener("collision", collisionDetected)

         spawned:insert(object);
         table.insert(objects, object);

         cleanup();
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

   Runtime:removeEventListener("tap", flyUp);
   spawned:removeSelf();

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
