local composer = require("composer")
local widget = require("widget")
local scene = composer.newScene()

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

---------------------------------------------------------------------------------

-- "scene:create()"
function scene:create(event)

   local sceneGroup = self.view

   --Back Button (return to main menu):
   local function goBack()
      composer.gotoScene("home");
   end
   local options = {
      x = 0,
      y = 50,
      width = 100,
      height = 50,
      label = "Back",
      labelColor = {default = {1,1,0}, over = {0,0,0}},
      onPress = goBack,
      shape = "roundedRect",
      fillColor = {default = {0,0,0,0.1}, over = {1,1,0}},
      strokeColor = {default = {1,1,0}, over = {1,1,0}},
      strokeWidth = 2
   }
   local backButton = widget.newButton(options);
   sceneGroup:insert(backButton);

   --Header:
   local settingsHeader = display.newText("Settings", display.contentCenterX, display.contentCenterY / 2,
      native.systemFontBold, 50);
   settingsHeader:setFillColor(1, 1, 0);
   sceneGroup:insert(settingsHeader);

   --Checkbox Functions:
   local function toggleMusic()
   end
   local function toggleSoundEffects()
   end

   --Background Music Checkbox:
   local musicCheckbox = widget.newSwitch({
      x = display.contentCenterX - 100,
      y = display.contentCenterY,
      style = "checkbox",
      onPress = toggleMusic
   })
   sceneGroup:insert(musicCheckbox)

   --Sound Effects Checkbox:
   local soundEffectCheckbox = widget.newSwitch({
      x = display.contentCenterX - 100,
      y = display.contentCenterY + 50,
      style = "checkbox",
      onPress = toggleSoundEffects
   })
   sceneGroup:insert(soundEffectCheckbox)

   --Checkbox Labels:
   local musicLabel = display.newText("Background Music", display.contentCenterX + 50, display.contentCenterY, native.systemFont, 30);
   local soundEffectLabel = display.newText("Sound Effects", display.contentCenterX + 50, display.contentCenterY + 50, native.systemFont, 30);
   musicLabel:setFillColor(1,1,0);
   soundEffectLabel:setFillColor(1,1,0);
   sceneGroup:insert(musicLabel);
   sceneGroup:insert(soundEffectLabel);
end

-- "scene:show()"
function scene:show(event)

   local sceneGroup = self.view
   local phase = event.phase

   if (phase == "will") then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif (phase == "did") then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
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