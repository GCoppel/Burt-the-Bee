local composer = require("composer")
local json = require("json")
local scene = composer.newScene()

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

---------------------------------------------------------------------------------

local finalScoreVal = 0;
local highestScoreVal = 0;
--local hasUnlockedTrophy1 = false
local gameStats = {
    highestScore = 0,
    achievement1Unlocked = false
}
local lastSavedGameStats

-- "scene:create()"
function scene:create(event)

    local sceneGroup = self.view

    --TITLE:
    local gameOver = display.newText("GAME OVER", display.contentCenterX, display.contentCenterY - 100,
        native.systemFontBold, 50);
    gameOver:setFillColor(1, 1, 0);
    sceneGroup:insert(gameOver);

    --SCORE TEXT:
    local scoreText = display.newText("Score: ", display.contentCenterX - 40, gameOver.y + 50, native.systemFontBold, 30)
    sceneGroup:insert(scoreText)
    scoreTextNum = display.newText(finalScoreVal, display.contentCenterX + 40, scoreText.y, native.systemFontBold, 30)
    sceneGroup:insert(scoreTextNum)

    --HIGHEST SCORE TEXT:
    local highscoreText = display.newText("Highest Score: ", display.contentCenterX - 50, gameOver.y + 90, native.systemFontBold, 30)
    sceneGroup:insert(highscoreText)
    highscoreTextNum = display.newText(highestScoreVal, display.contentCenterX + 90, highscoreText.y, native.systemFontBold, 30)
    sceneGroup:insert(highscoreTextNum)

    --SCENE TRANSITIONERS:
    local options -- used by buttons

    local function buttonPress(event)
        if (event.target.buttonNum == 2) then
            composer.gotoScene("play", {
                effect = "fade",
                time = 500
            });
        else
            composer.gotoScene("home");
        end
    end

    --HOME BUTTON:
    options = {
        x = display.contentCenterX - 150,
        y = display.contentCenterY + 70,
        width = 100,
        height = 50,
        label = "Home",
        labelColor = { default = { 1, 1, 0 }, over = { 0, 0, 0 } },
        -- ◼ default: color
        -- ◼ over: color changes to this when you press the button
        onPress = buttonPress,
        -- ◼ See also onPress,  onRelease
        shape = "roundedRect",
        fillColor = { default = { 0, 0, 0, 0.1 }, over = { 1, 1, 0 } },
        strokeColor = { default = { 1, 1, 0 }, over = { 1, 1, 0 } },
        strokeWidth = 2
    }
    local homeButton = widget.newButton(options);
    homeButton.buttonNum = 1;
    sceneGroup:insert(homeButton);

    --PLAY BUTTON:
    options = {
        x = display.contentCenterX + 150,
        y = display.contentCenterY + 70,
        width = 100,
        height = 50,
        label = "Play Again",
        labelColor = { default = { 1, 1, 0 }, over = { 0, 0, 0 } },
        -- ◼ default: color
        -- ◼ over: color changes to this when you press the button
        onPress = buttonPress,
        -- ◼ See also onPress,  onRelease
        shape = "roundedRect",
        fillColor = { default = { 0, 0, 0, 0.1 }, over = { 1, 1, 0 } },
        strokeColor = { default = { 1, 1, 0 }, over = { 1, 1, 0 } },
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
        params = event.params
        finalScoreVal = params.finalScore

        local readFile;
        local readData;
        local writeFile;

        local statsLocation = system.pathForFile("stats.json", system.DocumentsDirectory);
        readFile = io.open(statsLocation, "r");
        readData = readFile:read("*a");
        io.close(readFile);
        readFile = nil;

        local statsDeserialized = json.decode(readData);
        highestScoreVal = statsDeserialized.highestScore; --Read in current highest score for onscreen output

        local achieve1unlocked = false -- Score at least 25 points
        local achieve2unlocked = false -- Score at least 100 points
        local achieve3unlocked = false -- Score at least 250 points

        if (statsDeserialized.highestScore < finalScoreVal) then --New high score! Overwrite current json stats to update
            if finalScoreVal >= 25 then achieve1unlocked = true end --Unlock new achievement
            if finalScoreVal >= 100 then achieve2unlocked = true end --Unlock new achievement
            if finalScoreVal >= 250 then achieve3unlocked = true end --Unlock new achievement

            local newStats = {
                achievement1Unlocked = achieve1unlocked,
                achievement2Unlocked = achieve2unlocked,
                achievement3Unlocked = achieve3unlocked,
                highestScore = finalScoreVal
            }

            highestScoreVal = finalScoreVal; --Update highest score for onscreen output

            local newScore = json.encode(newStats);
            writeFile = io.open(statsLocation, "w");
            writeFile:write(newScore);
            io.close(writeFile);
            writeFile = nil;
        else
            if statsDeserialized.highestScore >= 25 then achieve1unlocked = true end --Unlock new achievement
            if statsDeserialized.highestScore >= 100 then achieve2unlocked = true end --Unlock new achievement
            if statsDeserialized.highestScore >= 250 then achieve3unlocked = true end --Unlock new achievement

            local newStats = {
                achievement1Unlocked = achieve1unlocked,
                achievement2Unlocked = achieve2unlocked,
                achievement3Unlocked = achieve3unlocked,
                highestScore = statsDeserialized.highestScore
            }

            --highestScoreVal = finalScoreVal; --Update highest score for onscreen output

            local newScore = json.encode(newStats);
            writeFile = io.open(statsLocation, "w");
            writeFile:write(newScore);
            io.close(writeFile);
            writeFile = nil;    
        end

    elseif (phase == "did") then
        audio.stop(); --Stop background jazz
        composer.removeScene("play"); --Reset "play" scene
        display.setDefault("background", 0, 0, 0); --Set background to a skyblue color
        scoreTextNum.text = finalScoreVal
        highscoreTextNum.text = highestScoreVal
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
