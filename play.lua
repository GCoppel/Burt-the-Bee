local composer = require("composer")
local physics = require("physics")
local scene = composer.newScene()


local spawned; --Group of spawned objects still in memory. Is removed from memory when scene is destroyed.

local gameRunning;

-- "scene:create()"
function scene:create(event)

   spawned = display.newGroup();
   gameRunning = false; --Game doesn't run until player taps screen

   local sceneGroup = self.view

   physics.start(); --Start physics calculations
   physics.setGravity(0, 25);

   physics.pause();


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

   -- Image Sheet information
   local opt =
   {
      frames = {
         { x = 36, y = 51, width = 212, height = 360}, -- 1, Orange Flower
         { x = 265, y = 58, width = 212, height = 360}, -- 2, Purple Flower
         { x = 503, y = 49, width = 212, height = 360}, -- 3, Pink Flower
         { x = 800, y = 95, width = 85, height = 77}, -- 4, Honeycomb bonus
         { x = 798, y = 238, width = 87, height = 74}, -- 5, Heart/life bonus
         { x = 921, y = 37, width = 183, height = 122}, -- 6, Burt Frame 1
         { x = 1107, y = 29, width = 183, height = 122}, -- 7, Burt Frame 2
         { x = 1294, y = 37, width = 183, height = 122}, -- 8, Burt Frame 3
         { x = 953, y = 253, width = 183, height = 179}, -- 9, Hornet Frame 1
         { x = 1158, y = 229, width = 183, height = 179}, -- 10, Hornet Frame 2
         { x = 1366, y = 224, width = 183, height = 179}, -- 11, Hornet Frame 3
         { x = 45, y = 478, width = 655, height = 222}, -- 12, Grass
      }
   }
   local sheet = graphics.newImageSheet( "Burt The Bee Sprites.png", opt);

   -- Sprite animation information
   -- TO DO

   local Burt = display.newRect(display.contentCenterX - 500, display.contentCenterY, 45, 30);
   Burt:setFillColor(1, 1, 0);
   sceneGroup:insert(Burt);

   physics.addBody(Burt, "dynamic", { bounce = -1 });

   local ceiling = display.newRect(display.contentCenterX, 0, 2000, 1);
   ceiling:setFillColor(0, 0, 0, 0);
   sceneGroup:insert(ceiling);
   physics.addBody(ceiling, "static");

   local tapToStartText = display.newText(
      "Tap to Start", display.contentCenterX, display.contentCenterY, native.systemFont, 25);
      tapToStartText:setFillColor(0,0,0, 0.5);
      sceneGroup:insert(tapToStartText);

   local function groundCollision()
      print("ground hit, dead");
   end

   local ground = display.newRect(display.contentCenterX, display.contentHeight, 1000, 10);
   ground:setFillColor(0, 1, 0);
   sceneGroup:insert(ground);
   physics.addBody(ground, "static");
   ground:addEventListener("collision", groundCollision)

   function flyUp()
      if (gameRunning == false) then -- Start game
         transition.to(tapToStartText, {alpha = 0, time = 500}); --Hide "Tap to Start" message
         transition.to(Burt, {x = display.contentCenterX - 100, time = 5000, transition=easing.outExpo}); --Bring Burt on screen
         physics.start();
         gameRunning = true;

         --Add Pause Button:
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
         transition.from(pauseButton, {alpha = 0, time = 1000}); --Fade in Pause Button
      end
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
            if (object.x < -50) then
               objectIndex = indexOf(objects, object);
               table.remove(objects, objectIndex);
               object:removeSelf();
            end
         end
      end

      local function spawnObject()
         if (gameRunning == true) then
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
