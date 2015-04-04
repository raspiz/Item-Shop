-- An overlay that will show the outcome of a transaction

local composer = require "composer"
local GLOB = require "globals"
local utilities = require "functions.Utilities"
local widget = require "widget"
local background = require "controls.Background"
local button = require "controls.Button"
local scene = composer.newScene()

local outcomeLabel

-- clear previous scene. (may not want)

-- todo: put how much xp was gained and details of transaction on this screen

function scene:create(event)
    local sceneGroup = self.view
    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.    
    
    -- semi transparent background
    local overlayBackground = background.new(0,0, 2100,1280)
    overlayBackground.bg:setFillColor(0,0,0,0.8)
   
    local labelHeight = GLOB.height - 75
   
    local textOptions = {
        text = "",
        x = GLOB.middleX,
        y = (GLOB.height - 75)/ 2 + 10,
        width = 400,
        height = labelHeight,
        font = native.systemFont,
        fontSize = 20,
        align = "center"    
    }    
    
    outcomeLabel = display.newText(textOptions) -- item description
    outcomeLabel:setFillColor(1,1,1)
    
    local function DoneButtonEvent(event)
        composer.hideOverlay() 
        composer.gotoScene("screens.Shop")    
    end
    
    local options = {
        label = "Done",
        emboss = false,
        shape = "roundedRect",
        id = "BtnOK",
        x = GLOB.middleX,
        y = GLOB.middleY + 275,
        width = 100,
        height = 50,
        cornerRadius = 2,
        fillColor = { default={ .1, 0, .9, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ .3, .3, .3, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4,
        labelColor = { default={ .9, .9, .9, 1 }, over={ .9, .9, .9, 1 } },  
        onRelease = DoneButtonEvent
    }
    
    local BtnOK = widget.newButton(options)
    --BtnOK:addEventListener("touch", function()  end)
    
    sceneGroup:insert(overlayBackground.bg) 
    sceneGroup:insert(outcomeLabel)
    sceneGroup:insert(BtnOK)  
    
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent
    
    if phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        outcomeLabel.text = parent:GetOutcomeText()        
    elseif phase == "did" then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.  
    end
end

function scene:hide(event)
    
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent
    if phase == "will" then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc. 
        --parent:ShowOverlay()
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


