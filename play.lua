local composer = require("composer")
local physics = require("physics")
local json = require("json");
local orangeFlowers = require("orangeFlowers")
local pinkFlowers = require("pinkFlowers")
local purpleFlowers = require("purpleFlowers")
local scene = composer.newScene()


--Loading in sound effects and background music:
local backgroundMusic = audio.loadStream("GameplayMusic.mp3");
local bonusEffect = audio.loadSound("Bonus");
local hitEffect = audio.loadSound("Hit");
local extraLifeEffect = audio.loadSound("ExtraLife");


local spawned; --Group of spawned objects still in memory. Is removed from memory when scene is destroyed.
local spawnedHornets = {}; --Table of all hornets that spawn

--Variables used to make the game work
local gameRunning;
local lives = 1;
local score = 0;
local multiplier = 1;

local distanceToKeeper = 100; --Starting gap of 100

local settingsDeserialized; --Stores deserialized JSON data for audio settings

-- "scene:create()"
function scene:create(event)

   spawned = display.newGroup();
   gameRunning = false; --Game doesn't run until player taps screen

   local sceneGroup = self.view

   physics.start(); --Start physics calculations
   physics.setGravity(0, 25);

   physics.pause();

   -- Image Sheets information
   opt =
   {
      frames = {
         { x = 21, y = 16, width = 111, height = 182 }, -- 1, Orange Flower
         { x = 137, y = 23, width = 111, height = 182 }, -- 2, Purple Flower
         { x = 255, y = 19, width = 111, height = 182 }, -- 3, Pink Flower
         { x = 30, y = 235, width = 322, height = 104 } -- 4, Grass
      }
   }
   sheet = graphics.newImageSheet("Various Sprites.png", opt);

   opt2 =
   {
      frames = {
         { x = 57, y = 226, width = 2298, height = 1212 }, -- beekeeper
      }
   }
   sheet2 = graphics.newImageSheet("beekeeper.png", opt2);

   opt3 = {
      frames = {
         { x = 55, y = 5, width = 57, height = 58 }, -- 1, Hornet Frame 1
         { x = 117, y = 5, width = 57, height = 58 }, -- 2, Hornet Frame 2
         { x = 181, y = 3, width = 57, height = 58 }, -- 3, Hornet Frame 3
         { x = 9, y = 9, width = 25, height = 21 }, -- 4, Honeycomb bonus
         { x = 7, y = 49, width = 27, height = 23 } -- 5, Heart/life bonus
      }
   }
   sheet3 = graphics.newImageSheet("Hornet_Sprites.png", opt3)

   opt4 = {
      frames = {
         { x = 11, y = 12, width = 53, height = 38 }, -- 1, Burt Frame 1
         { x = 63, y = 12, width = 52, height = 35 }, -- 2, Burt Frame 2
         { x = 116, y = 13, width = 54, height = 37 } -- 3, Burt Frame 3
      }
   }
   sheet4 = graphics.newImageSheet("Burt The Bee.png", opt4)

   -- Sprite animation information
   sequenceData = {
      { name = "Burt", frames = { 1, 2, 3 }, sheet = sheet4, time = 900, loopCount = 0 },
      { name = "Hornet", frames = { 1, 2, 3 }, sheet = sheet3, time = 900, loopCount = 0 },
      { name = "HornetPause", frames = { 1 }, sheet = sheet3, time = 900, loopCount = 0 }
   }

   --Load in audio settings from JSON:
   local readFile;
   local readData;

   local settingsLocation = system.pathForFile("settings.json", system.DocumentsDirectory);
   readFile = io.open(settingsLocation, "r");
   readData = readFile:read("*a");
   io.close(readFile);
   readFile = nil;

   settingsDeserialized = json.decode(readData); --Stores deserialized JSON data


   local function deleteGrass(obj)
      display.remove(obj)
      obj = nil
   end

   local function createGrass()
      local grass = display.newImage(sheet, 4)
      grass.x = 800
      grass.y = 300
      sceneGroup:insert(grass)
      transition.to(grass, { x = -600, time = 10000, onComplete = deleteGrass })
   end

   Burt = display.newSprite(sheet4, sequenceData)
   Burt.x = -display.contentWidth;
   Burt.y = display.contentCenterY;
   Burt:setSequence("Burt")
   Burt:play()
   sceneGroup:insert(Burt);
   local burtOutline = graphics.newOutline(2, sheet4, 1)
   physics.addBody(Burt, "dynamic", {outline = burtOutline})

   local ceiling = display.newRect(display.contentCenterX, 0, 2000, 1);
   ceiling:setFillColor(0, 0, 0, 0);
   sceneGroup:insert(ceiling);
   physics.addBody(ceiling, "static");

   local tapToStartText = display.newText(
      "Tap to Start", display.contentCenterX, display.contentCenterY, native.systemFont, 25);
   tapToStartText:setFillColor(0, 0, 0, 0.5);
   sceneGroup:insert(tapToStartText);

   local function groundCollision()
      print("ground hit, dead");
      checkLives()
   end

   function checkLives()
      if (lives == 1) then
         lives = lives - 1
         --timerGroup:removeSelf()
         composer.gotoScene("gameOver", {
            params = {
               finalScore = score;
            }
         })
      else
         lives = lives - 1
      end
   end

   local ground = display.newRect(display.contentCenterX, display.contentHeight, 1000, 10);
   ground:setFillColor(0, 1, 0);
   sceneGroup:insert(ground);
   physics.addBody(ground, "static");
   ground:addEventListener("collision", groundCollision)

   --Pause:
   -- BUG: Sometimes unpausing does not bring back both timer functions
   local function Pause()
      physics.pause();
      timer.pauseAll();
      transition.pauseAll();
      Burt:pause();
      for _, object in ipairs(spawnedHornets) do
         object:setSequence("HornetPause")
      end
      composer.showOverlay("pause", {
         effect = "fade",
         time = 500,
         isModal = true
      });
   end

   -- timer display and funtion
   -- create timer group to be removed at game over
   local timerGroup = display.newGroup();
   timerGroup.x = 250;
   timerGroup.alpha = 0;
   local barH = 50;
   local bar = display.newRect(115, 50, 100, barH);
   bar:setFillColor(0, 0, 0, 0.1); --Clear
   bar.strokeWidth = 2;
   bar:setStrokeColor(1, 1, 0);
   timerGroup:insert(bar);
   local timeText = display.newText("Score:", 100, 50, native.systemFont, 20);
   timeText:setFillColor(1, 1, 0);
   timerGroup:insert(timeText);
   local timeVal = display.newText(score, timeText.x + timeText.width - 10, 50, native.systemFont, 20);
   timeVal:setFillColor(1, 1, 0);
   timerGroup:insert(timeVal);
   sceneGroup:insert(timerGroup);

   function flyUp()
      if (gameRunning == false) then -- Start game (only runs once)
         transition.to(tapToStartText, { alpha = 0, time = 500 }); --Hide "Tap to Start" message
         transition.to(Burt, { x = display.contentCenterX - 100, time = 5000, transition = easing.outExpo }); --Bring Burt on screen
         physics.start();
         gameRunning = true;

         --Start background music:
         if (settingsDeserialized.enableMusic == true) then
            audio.play(backgroundMusic, { loopCount = -1 });
         end

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
         transition.to(timerGroup, { alpha = 1, time = 1000 }); --Fade in Pause Button
         transition.from(pauseButton, { alpha = 0, time = 1000 }); --Fade in Pause Button
         timer.performWithDelay(2265, createGrass, 0) --Start generating grass

         --Timer keeping track of score and beekeeper gap:
         local updateEverySecond = timer.performWithDelay(
            1000,
            function()
               -- increase score by one every second with timer:
               score = score + (1 * multiplier);
               timeVal.text = score;
            end,
            0
         )
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

      --RESET GAME VARIABLES
      spawnedHornets = {}

      -- Called when the scene is still off screen (but is about to come on screen).
   elseif (phase == "did") then
      local hornetOrLife;
      local bonusOrLife;
      local object;

      -- display arm
      local arm = display.newImage(sheet2, 1);
      arm.x = -10;
      arm.y = 170;
      arm.xScale = 0.10;
      arm.yScale = 0.10;
      arm.rotation = 20;
      sceneGroup:insert(arm);

      -- move arm up and down
      local function moveArm()
         transition.to(arm, { y = 20 })
         if (arm.y == 20) then
            transition.to(arm, { y = 170 })
         end
      end

      -- timer to repeat movement of arm
      timer.performWithDelay(700, moveArm, 0)


      local objects = {}; --Contains spawned objects. Used for checking for offscreen objects that can be removed from memory
      local objectIndex; --Location of target object in "objects" table

      ---------------------------------------------------------------------
      -- ENEMY AND BONUS GENERATION

      --Function to find the index of a value in a table:
      function indexOf(table, value)
         for index, val in ipairs(table) do
            if value == val then
               return index
            end
         end
      end

      --Function to determine what action needs carried out based on the object collided
      local function collisionDetected(event)
         if (event.target.type == "hornet") then
            if (settingsDeserialized.enableEffects == true) then audio.play(hitEffect); end
            checkLives();
         elseif (event.target.type == "arm") then
            checkLives();

         elseif (event.target.type == "life") then
            if (settingsDeserialized.enableEffects == true) then audio.play(extraLifeEffect); end
            lives = lives + 1;
         else --Bonus honeycomb
            if (settingsDeserialized.enableEffects == true) then audio.play(bonusEffect); end
            score = score + 5; --Bonus collected, add 5 to score
         end

         --Remove collision object from table of objects and then from memory
         objectIndex = indexOf(objects, event.target);
         table.remove(objects, objectIndex);
         if (event.target.type == "hornet") then
            objectIndex = indexOf(spawnedHornets, object);
            table.remove(spawnedHornets, objectIndex);
         end
         event.target:removeSelf();
      end

      --Removes offscreen hornets and bonus items from memory
      local function cleanup()
         for _, object in ipairs(objects) do
            if (object.x < -50) then
               objectIndex = indexOf(objects, object);
               table.remove(objects, objectIndex);
               if (object.type == "hornet") then
                  objectIndex = indexOf(spawnedHornets, object);
                  table.remove(spawnedHornets, objectIndex);
               end
               object:removeSelf();
            end
         end
      end

      --Spawn an enemy or bonus item randomly
      local function spawnObject()
         if (gameRunning == true) then --Only start spawning once game has begun
            hornetOrLife = math.random(1, 3); --1 in 3 chance of a bonus
            bonusOrLife = math.random(1, 4); --1 in 4 chance of extra life, bonus points otherwise
            local spawnHeight = math.random(50, 250);
            local objectOutline
            if (hornetOrLife == 1) then --Spawn bonus
               if (bonusOrLife == 1) then
                  object = display.newImage(sheet3, 5)
                  objectOutline = graphics.newOutline(2, sheet3, 5)
                  object.x = 600
                  object.y = spawnHeight
                  object.type = "life";
               else
                  object = display.newImage(sheet3, 4)
                  objectOutline = graphics.newOutline(2, sheet3, 4)
                  object.x = 600
                  object.y = spawnHeight
                  object.type = "bonus";
               end
            else --Spawn hornet
               object = display.newSprite(sheet, sequenceData)
               objectOutline = graphics.newOutline(2, sheet3, 1)
               object:setSequence("Hornet")
               object.x = 600
               object.y = spawnHeight
               object.scaleX = 0.3
               object.scaleY = 0.3
               object:play()
               object.type = "hornet";
               table.insert(spawnedHornets, object)
            end

            --Make enemies and bonuses smaller and easier to avoid:
            --object.xScale = 0.75;
            --object.yScale = 0.75;

            physics.addBody(object, "kinematic", { outline = objectOutline });
            object.isSensor = true;
            object:setLinearVelocity(-125, 0);

            object:addEventListener("collision", collisionDetected)

            spawned:insert(object);
            table.insert(objects, object);

            cleanup();
         end
      end

      -- Once we get distance/score working, I am thinking of basing the spawn on that with a cap of course
      timer.performWithDelay(
         2500 + math.random(1500),
         spawnObject,
         0
      )

      ---------------------------------------------------------------------
      -- FLOWER GENERATION
      local function flowerCollisionDetected(event)
         if (event.phase == "began") then
            multiplier = event.target.mult
         end
         if (event.phase == "ended") then
            multiplier = 1
         end
      end

      local function flowerGeneration()
         if (gameRunning) then
            local randomFlower = math.random(1, 3)
            local objFlower;
            if (randomFlower == 1) then
               objFlower = orangeFlowers:new()
            end
            if (randomFlower == 2) then
               objFlower = purpleFlowers:new()
            end
            if (randomFlower == 3) then
               objFlower = pinkFlowers:new()
            end
            objFlower:spawn(sheet, randomFlower);
            objFlower.shape:addEventListener("collision", flowerCollisionDetected)
            objFlower:move();

            spawned:insert(objFlower.shape);
            table.insert(objects, objFlower.shape);

            cleanup();
         end
      end

      timer.performWithDelay(3000, flowerGeneration, 0)
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
      timer.cancelAll();
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
