local composer = require("composer")
local scene = composer.newScene()
 
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
-- local forward references should go here
 
---------------------------------------------------------------------------------
 
-- "scene:create()"
function scene:create( event )
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

      --Creator Credits:
      local Xcenter = display.contentCenterX;
      local Ycenter = display.contentCenterY;
      local createdBy = display.newText("Created by:", Xcenter, Ycenter - 75, native.systemFontBold, 40);
      local mehganCredit = display.newText("Mehgan Cooper", Xcenter, Ycenter - 15, native.systemFont, 25);
      local georgeCredit = display.newText("George Coppel", Xcenter, Ycenter + 20, native.systemFont, 25);
      local jaydeCredit = display.newText("Jayde Holbrook", Xcenter, Ycenter + 55, native.systemFont, 25);
      createdBy:setFillColor(1,1,0);
      mehganCredit:setFillColor(1,1,0);
      georgeCredit:setFillColor(1,1,0);
      jaydeCredit:setFillColor(1,1,0);
      sceneGroup:insert(createdBy);
      sceneGroup:insert(mehganCredit);
      sceneGroup:insert(georgeCredit);
      sceneGroup:insert(jaydeCredit);
      
end
 
-- "scene:show()"
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
   end
end
 
-- "scene:hide()"
function scene:hide( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end
 
-- "scene:destroy()"
function scene:destroy( event )
 
   local sceneGroup = self.view
 
   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end
 
---------------------------------------------------------------------------------
 
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
---------------------------------------------------------------------------------
 
return scene