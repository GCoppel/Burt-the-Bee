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

    --TITLE:
    local gameOver = display.newText("GAME OVER", display.contentCenterX, display.contentCenterY/2 + 50, native.systemFontBold, 50);
    gameOver:setFillColor(1,1,0);
    sceneGroup:insert(gameOver);

    --SCENE TRANSITIONERS:
    local options -- used by buttons

    local function buttonPress(event)
       if (event.target.buttonNum == 2) then
            composer.gotoScene("play", {
                effect= "fade",
                time = 500
            });
       else
            composer.gotoScene("home");
       end
    end

    --HOME BUTTON:
    options = {
        x = display.contentCenterX - 150,
        y = display.contentCenterY + 50,
        width = 100,
        height = 50,
        label = "Home",
        labelColor = {default = {1,1,0}, over = {0,0,0}},
        -- ◼ default: color
        -- ◼ over: color changes to this when you press the button
        onPress = buttonPress,
        -- ◼ See also onPress,  onRelease
        shape = "roundedRect",
        fillColor = {default = {0,0,0,0.1}, over = {1,1,0}},
        strokeColor = {default = {1,1,0}, over = {1,1,0}},
        strokeWidth = 2
    }
    local homeButton = widget.newButton(options);
    homeButton.buttonNum = 1;
    sceneGroup:insert(homeButton);

    --PLAY BUTTON:
    options = {
        x = display.contentCenterX + 150,
        y = display.contentCenterY + 50,
        width = 100,
        height = 50,
        label = "Play Again",
        labelColor = {default = {1,1,0}, over = {0,0,0}},
        -- ◼ default: color
        -- ◼ over: color changes to this when you press the button
        onPress = buttonPress,
        -- ◼ See also onPress,  onRelease
        shape = "roundedRect",
        fillColor = {default = {0,0,0,0.1}, over = {1,1,0}},
        strokeColor = {default = {1,1,0}, over = {1,1,0}},
        strokeWidth = 2
    }
    local playButton = widget.newButton(options);
    playButton.buttonNum = 2;
    sceneGroup:insert(playButton);

end

-- "scene:show()"
function scene:show(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif (phase == "did") then
        display.setDefault("background", 0,0,0); --Set background to a skyblue color
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
