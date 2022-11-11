local composer = require("composer")
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


    --Pause Overlay:
    local pauseOverlay = display.newRect(0, 0, 10000, 10000);
    pauseOverlay:setFillColor(0, 0, 0, 0.5);
    sceneGroup:insert(pauseOverlay);

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
        labelColor = { default = { 1, 1, 0 }, over = { 0, 0, 0 } },
        onPress = goBack,
        shape = "roundedRect",
        fillColor = { default = { 0, 0, 0, 0.1 }, over = { 1, 1, 0 } },
        strokeColor = { default = { 1, 1, 0 }, over = { 1, 1, 0 } },
        strokeWidth = 2
    }
    local pauseButton = widget.newButton(options);
    sceneGroup:insert(pauseButton);

    --Unpause Label:
    local unpauseLabel = display.newText("Paused", display.contentCenterX, display.contentCenterY - 25, native.systemFontBold, 50);
    unpauseLabel:setFillColor(1,1,0);
    sceneGroup:insert(unpauseLabel);

    --Unpause:
    local function unpause()
        composer.hideOverlay("fade", 50)
        physics.start();
        timer.resumeAll();
    end
    options = {
        x = display.contentCenterX,
        y = display.contentCenterY + 50,
        width = 250,
        height = 75,
        label = "Unpause",
        labelColor = { default = { 1, 1, 0 }, over = { 0, 0, 0 } },
        onPress = unpause,
        shape = "roundedRect",
        fillColor = { default = { 0, 0, 0, 0.1 }, over = { 1, 1, 0 } },
        strokeColor = { default = { 1, 1, 0 }, over = { 1, 1, 0 } },
        strokeWidth = 2
    }
    local unpauseButton = widget.newButton(options);
    sceneGroup:insert(unpauseButton);

end

-- "scene:show()"
function scene:show(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif (phase == "did") then
        
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
