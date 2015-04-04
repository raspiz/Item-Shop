local composer = require ("composer")
local GLOB = require "globals"
local button = require("controls.Button")
local widget = require "widget"
local utilities = require "functions.Utilities"
local json = require "json"
local scene = composer.newScene()

--todo:
-- need to look into cleaning up previous scenes
--composer.removeScene("screens.BattleScreen") -- moved this to scene:show so it executes each time the scene is loaded

-- local forward references here
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.

function scene:create(event)
    local sceneGroup = self.view
    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.    

    local logoImg = display.newImage( "images/logo.png" )
    logoImg.x = display.contentWidth / 2
    logoImg.y = 150

    -- options for the continue button
    local options = {
        label = "Continue",
        emboss = false,
        shape = "roundedRect",
        x = GLOB.middleX,
        y = 300,
        width = 100,
        height = 50,
        font = native.systemFont,
        fontSize = 16,        
        cornerRadius = 2,
        fillColor = { default={ .1, 0, .9, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ .3, .3, .3, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4,
        labelColor = { default={ .9, .9, .9, 1 }, over={ .9, .9, .9, 1 } },
        onEvent = function(event)
            if ( "ended" == event.phase ) then
                -- load the json file in as a string
                local jsonStr = utilities:loadFile("shop.json", system.DocumentsDirectory)
                
                -- if jsonStr is nil, then there is no save file present and this button will function like new game
                if jsonStr then -- only true if a save file exists
                    local saveGame = json.decode(jsonStr) -- decode the save data into this table, then copy the data into the tables that are used during the game
                    GLOB.inventory = saveGame["inventory"]
                    GLOB.stats = saveGame["stats"]
                    GLOB.merch = saveGame["merch"]
                    GLOB.vending = saveGame["vending"]
                end
                
                composer.gotoScene("screens.Shop")
            end 
        end                 
    }

    local continueButton = widget.newButton(options) 
    
    -- options for new game button
    options["label"] = "New Game"
    options["y"] = 375
    options["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            -- todo add default values to appropriate tables to setup a new game
            GLOB.stats = {["cash"] = 1000, ["level"] = 1, ["xp"] = 0, ["tier"] = 1, ["day"] = 1, ["time"] = 1, ["missedRent"] = 0}
            composer.gotoScene("screens.Shop")
        end 
    end  
    
    local newGameButton = widget.newButton(options)
    
    -- tutorial button
    -- launches into a gameplay tutorial
    options["label"] = "Tutorial"
    options["y"] = 450
    options["onEvent"] = function(event)
        if ( "ended" == event.phase ) then            
            composer.gotoScene("screens.Tutorial")
        end 
    end  
    
    local tutorialButton = widget.newButton(options)
    
    -- credits  button
    -- launches into a brief credits/info list
    options["label"] = "Credits"
    options["y"] = 525
    options["onEvent"] = function(event)
        if ( "ended" == event.phase ) then            
            composer.gotoScene("screens.Credits")
        end 
    end  
    
    local creditsButton = widget.newButton(options)    
    
    -- add controls to group
    sceneGroup:insert(continueButton)
    sceneGroup:insert(newGameButton)
    sceneGroup:insert(tutorialButton)
    sceneGroup:insert(creditsButton)
    sceneGroup:insert(logoImg)
    
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    
    if phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif phase == "did" then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
        composer.removeScene("screens.BattleScreen") 
        composer.removeScene("screens.Tutorial") 
        composer.removeScene("screens.Shop") 
        composer.removeScene("screens.GameOver") 
        print("shop scene started")
    end
end

function scene:hide(event)
    
    local sceneGroup = self.view
    local phase = event.phase
    
    if phase == "will" then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.        
    elseif phase == "did" then
          -- Called immediately after scene goes off screen.      
    end
end

function scene:destroy(event)
    local sceneGroup = self.view
    

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.    
end

-- listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene