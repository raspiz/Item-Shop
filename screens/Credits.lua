local composer = require ("composer")
local GLOB = require "globals"
local widget = require "widget"
local scene = composer.newScene()

-- local forward references here
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.

function scene:create(event)
    local sceneGroup = self.view
    
    local textOptions = 
    {
        text = "Programming & Design: Aaron Whitmer",     
        x = display.contentWidth / 2,
        y = 300,
        width = 400,
        font = native.systemFontBold,   
        fontSize = 18,
        align = "center"
    }

    local creditsAaron = display.newText( textOptions )
    creditsAaron:setFillColor( 0, 0, 1 )

    textOptions["text"] = "Tutorial Scenario: Corbin Troup"
    textOptions["y"] = 350
    
    local creditsCorbin = display.newText( textOptions )
    creditsCorbin:setFillColor( 0, 1, 0 )
    
    textOptions["text"] = "Graphics: Eric McDonald"
    textOptions["y"] = 400
    
    local creditsEric = display.newText( textOptions )
    creditsEric:setFillColor( 1, 0, 0 ) 
    
    textOptions["text"] = "Ye Olde Item Shop"
    textOptions["y"] = 200
    
    local creditsGame = display.newText( textOptions )
    creditsGame:setFillColor( 155/255, 133/255, 66/255 )  
    
    textOptions["text"] = "2015 Clarion Golden Eagles"
    textOptions["y"] = 220
    
    local creditsTeam = display.newText( textOptions )
    creditsTeam:setFillColor( 155/255, 133/255, 66/255 )       
    
    sceneGroup:insert(creditsAaron)
    sceneGroup:insert(creditsCorbin)
    sceneGroup:insert(creditsEric)
    sceneGroup:insert(creditsGame)
    sceneGroup:insert(creditsTeam)
    
    local options = {
        label = "Return",
        emboss = false,
        shape = "roundedRect",
        x = GLOB.middleX,
        y = display.contentHeight - 100,
        width = 100,
        height = 50,
        cornerRadius = 2,
        fillColor = { default={ .1, 0, .9, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ .3, .3, .3, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4,
        labelColor = { default={ .9, .9, .9, 1 }, over={ .9, .9, .9, 1 } },
        onEvent = function(event)
            if ( "ended" == event.phase ) then
                composer.gotoScene("screens.Start")
            end 
        end                 
    }

    local returnButton = widget.newButton(options) 

    sceneGroup:insert(returnButton)

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.    
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

