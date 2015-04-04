local composer = require ("composer")
local GLOB = require "globals"
local background = require("controls.Background")
local widget = require "widget"
local utilities = require "functions.Utilities"
local general = require "functions.General"
local json = require "json"
local scene = composer.newScene()

--todo:
-- need to look into cleaning up previous scenes

-- local forward references here
--labels
local tutorialStep = 0
local merchLabel1
local merchLabel2
local merchLabel3
local merchLabel4
local merchLabel5
local merchLabel6
local merchLabel7
local merchLabel8
local vendingLblGroup
local vendingBtnGroup
local vendingLabel1
local vendingLabel2
local vendingLabel3
local vendingLabel4
local vendingLabel5
local vendingLabel6

local openShopButton
local inventoryButton
local craftingButton
local saveButton
local nextButton

local timeLabel
local dayLabel
local closedLabel
local cashLabel
local statGroup
local floorBG

--tutorial pieces
local tutorialDisplay
local tutorialArrow

local pickItem


-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.


function scene:UpdateMerch()
    local displayItem = {}
    local name = ""  
    
    -- output text names to display boxes
    for i = 1, 8 do
        displayItem = GLOB.merch[tostring(i)]       
        
        if displayItem ~= "" then
            name = general:BuildName(displayItem)
        else
            name = "+"
        end 
        
        if i <= 4 then -- first 4 boxes
            --merchLblGroup1[i].text = name 
        end
    end 
    
    -- output text names to vending machine
    for i = 1, 6 do
        displayItem = GLOB.vending[tostring(i)]       
        
        if displayItem ~= "" then
            name = general:BuildName(displayItem)
        else
            name = "+"
        end 
        
        vendingLblGroup[i].text = name
    end        
    
end

function scene:ResumeShop()
      if GLOB.shopIsOpen and GLOB.currentShopIterations < GLOB.shopIterations then
        timer.resume(GLOB.shopTimer)
        return true
    elseif GLOB.shopIsOpen then
        GLOB.shopIsOpen = false
        GLOB.shopTimer = nil
        scene:AdvanceTime()    
        return false
    end     
end

-- increment the time period and day if applicable
function scene:AdvanceTime()
    -- advance the time period and roll over to one when incrementing from 4
    GLOB.stats["time"] = GLOB.stats["time"] % 4 + 1
    
    -- advance day if time period is now 1
    if GLOB.stats["time"] == 1 then
       GLOB.stats["day"] = GLOB.stats["day"] + 1
    end
end

-- Update the text labels for day and time. called when shop is loaded and after a period of being open
function scene:UpdateTimeOutput() 
    statGroup[2].text = "Day: "..GLOB.stats["day"] 
    
    local timePeriod = ""
    if GLOB.stats["time"] == 1 then
        timePeriod = "Morning"
    elseif GLOB.stats["time"] == 2 then
        timePeriod = "Afternoon"
    elseif GLOB.stats["time"] == 3 then
        timePeriod = "Evening"
    elseif GLOB.stats["time"] == 4 then
        timePeriod = "Night"
    end
    
    statGroup[3].text = "Time: "..timePeriod
end


function scene:create(event)
    local sceneGroup = self.view
    
    local merchWidth = 75
    local merchHeight = 75
    local merchX = merchWidth / 2
    local merchY = merchHeight / 2 + 5    
    --------------------
    -- DISPLAY CASES
    --------------------
    -- had to make labels separate from the buttons because the widget button labels do not support multiline text
    merchBtnGroup1 = display.newGroup()
    merchBtnGroup1.x = 200
    merchBtnGroup1.y = 0 
    
    merchLblGroup1 = display.newGroup()
    merchLblGroup1.x = 200
    merchLblGroup1.y = 0     
    
    local merchOptions = {
        label = "",
        emboss = false,
        shape = "rect",
        x = merchWidth,
        y = merchY,
        width = merchWidth,
        height = merchHeight,
        fontSize = 10,
        fillColor = { default={ 76/255, 233/255, 247/255, 1 }, over={ 237/255, 223/255, 26/255, 0.7 } },
        strokeColor = { default={ 107/255, 25/255, 46/255, 1 }, over={ 1, 1, 1, 1 } },
        strokeWidth = 4,
        labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },               
    }

    local merchButton1 = widget.newButton(merchOptions)   
    
    merchOptions["x"] = merchWidth * 2
    
    local merchButton2 = widget.newButton(merchOptions)
    
    merchOptions["x"] = merchWidth * 3
    
    local merchButton3 = widget.newButton(merchOptions)    
    
    merchOptions["x"] = merchWidth * 4
    
    local merchButton4 = widget.newButton(merchOptions)        
    

    -- end first set of display cases

    -- add merch buttons and labels to merch groups and merch groups to scene group
    merchBtnGroup1:insert(merchButton1);
    merchBtnGroup1:insert(merchButton2);
    merchBtnGroup1:insert(merchButton3);
    merchBtnGroup1:insert(merchButton4);


    --------------------
    -- END DISPLAY CASES
    --------------------

    --------------------
    -- VENDING MACHINE
    --------------------
    
    vendingBtnGroup = display.newGroup()
    vendingBtnGroup.x = 650
    vendingBtnGroup.y = 200 
    
    vendingLblGroup = display.newGroup()
    vendingLblGroup.x = 400
    vendingLblGroup.y = 200      
    
    local vendingWidth = 50
    local vendingHeight = 50
    local vendingX = vendingWidth / 2
    local vendingY = vendingHeight / 2 + 5    
    
    local vendingOptions = {
        label = "",
        emboss = false,
        shape = "rect",
        x = vendingWidth,
        y = vendingY,
        width = vendingWidth,
        height = vendingHeight,
        fontSize = 9,
        fillColor = { default={ 206/255, 49/255, 91/255, 1 }, over={ 237/255, 223/255, 26/255, 0.7 } },
        strokeColor = { default={ 107/255, 25/255, 46/255, 1 }, over={ 1, 1, 1, 1 } },
        strokeWidth = 4,
        labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
        onEvent = function(event)
            if ( "ended" == event.phase ) then
                GLOB.pickDisplay = true
                GLOB.vendingSlot = "1"
                GLOB.merchSlot = ""
                composer.gotoScene("screens.Inventory")
            end 
        end            
    }    
    
    local vendingButton1 = widget.newButton(vendingOptions)  

    
    vendingOptions["x"] = vendingWidth * 2
    vendingOptions["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            GLOB.pickDisplay = true
            GLOB.vendingSlot = "2"
            GLOB.merchSlot = ""
            composer.gotoScene("screens.Inventory")
        end 
    end       
    
    local vendingButton2 = widget.newButton(vendingOptions)    
    
    vendingOptions["x"] = vendingWidth * 3
    vendingOptions["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            GLOB.pickDisplay = true
            GLOB.vendingSlot = "3"
            GLOB.merchSlot = ""
            composer.gotoScene("screens.Inventory")
        end 
    end   
    
    local vendingButton3 = widget.newButton(vendingOptions)    
    
    vendingOptions["x"] = vendingWidth
    vendingOptions["y"] = vendingY + vendingHeight
    vendingOptions["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            GLOB.pickDisplay = true
            GLOB.vendingSlot = "4"
            GLOB.merchSlot = ""
            composer.gotoScene("screens.Inventory")
        end 
    end   
    
    local vendingButton4 = widget.newButton(vendingOptions)          
    
    vendingOptions["x"] = vendingWidth * 2
    vendingOptions["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            GLOB.pickDisplay = true
            GLOB.vendingSlot = "5"
            GLOB.merchSlot = ""
            composer.gotoScene("screens.Inventory")
        end 
    end   
    
    local vendingButton5 = widget.newButton(vendingOptions)    
    
    vendingOptions["x"] = vendingWidth * 3
    vendingOptions["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            GLOB.pickDisplay = true
            GLOB.vendingSlot = "6"
            GLOB.merchSlot = ""
            composer.gotoScene("screens.Inventory")
        end 
    end   
    
    local vendingButton6 = widget.newButton(vendingOptions)          
    
    local vendingLabelOptions = {
        text = "+",
        x = vendingWidth + 2,
        y = vendingY + 5,
        width = vendingWidth - 5,
        height = vendingHeight,
        font = native.systemFont,
        fontSize = 9,
        align = "center"    
    }        
    
    vendingLabel1 = display.newText(vendingLabelOptions) -- item description
    vendingLabel1:setFillColor(0,0,0)        
    
    vendingLabelOptions["x"] = vendingWidth * 2 + 2
    vendingLabel2 = display.newText(vendingLabelOptions) -- item description
    vendingLabel2:setFillColor(0,0,0)     
    
    vendingLabelOptions["x"] = vendingWidth * 3 + 2
    vendingLabel3 = display.newText(vendingLabelOptions) -- item description
    vendingLabel3:setFillColor(0,0,0)  
    
    vendingLabelOptions["x"] = vendingWidth + 2
    vendingLabelOptions["y"] = vendingY + vendingHeight + 5
    vendingLabel4 = display.newText(vendingLabelOptions) -- item description
    vendingLabel4:setFillColor(0,0,0)      
        
    vendingLabelOptions["x"] = vendingWidth * 2 + 2
    vendingLabel5 = display.newText(vendingLabelOptions) -- item description
    vendingLabel5:setFillColor(0,0,0)  
    
    vendingLabelOptions["x"] = vendingWidth * 3 + 2
    vendingLabel6 = display.newText(vendingLabelOptions) -- item description
    vendingLabel6:setFillColor(0,0,0)      
    
    vendingBtnGroup:insert(vendingButton1)
    vendingBtnGroup:insert(vendingButton2)
    vendingBtnGroup:insert(vendingButton3)
    vendingBtnGroup:insert(vendingButton4)
    vendingBtnGroup:insert(vendingButton5)
    vendingBtnGroup:insert(vendingButton6)
    vendingLblGroup:insert(vendingLabel1)
    vendingLblGroup:insert(vendingLabel2)
    vendingLblGroup:insert(vendingLabel3)
    vendingLblGroup:insert(vendingLabel4)
    vendingLblGroup:insert(vendingLabel5)
    vendingLblGroup:insert(vendingLabel6)
    sceneGroup:insert(merchBtnGroup1)
    sceneGroup:insert(vendingBtnGroup)
    sceneGroup:insert(vendingLblGroup)  
    
    --------------------
    -- END VENDING MACHINE
    --------------------    
    
    scene:UpdateMerch()    
    
    local options = {
        label = "Sell",
        emboss = false,
        shape = "roundedRect",
        x = 100,
        y = GLOB.height - 50,
        width = 100,
        height = 50,
        cornerRadius = 2,
        fillColor = { default={ .1, 0, .9, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ .3, .3, .3, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4,
        labelColor = { default={ .9, .9, .9, 1 }, over={ .9, .9, .9, 1 } },              
    }    
    
    options["label"] = "Open Shop"
    
    openShopButton = widget.newButton(options)    
    
    -- options for inventory
    options["label"] = "Inventory"
    options["x"] = 225    
    
    inventoryButton = widget.newButton(options)    
    
    -- options for inventory
    options["label"] = "Crafting"
    options["x"] = 350     
    
    craftingButton = widget.newButton(options)           
    
    -- options for save button. the attached event will encode the save data into a string and then be written to a json file
    options["label"] = "Save"
    options["x"] = 475
    
    saveButton = widget.newButton(options)
    
        --tutorial next button
    options["label"] = "Next"
    options["x"] = 775
    options["labelColor"] = { default={ .9, .9, .9 }, over={ 1, 1, 1, 0.5 } }
    options["fillColor"] =  { default={ .1, 0, .9 }, over={ .8, 0, .8, 0.5 } }
    options["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            --advance tutorial
            tutorialStep = tutorialStep + 1
            --displaycases
            if(tutorialStep == 1)then
                
                local paint = {type = "image", filename = "images/tutorialTextDisplayCases.png" }              
                tutorialDisplay.fill = paint
                tutorialArrow.isVisible = true
                local paint = {type = "image", filename = "images/tutorialArrowUp.png"}
                tutorialArrow.fill = paint
                tutorialArrow.x = merchBtnGroup1.x + 75
                tutorialArrow.y = 145
            --openshop
            elseif(tutorialStep == 2)then
             local paint = {type = "image", filename = "images/tutorialTextOpenShop.png" }              
                tutorialDisplay.fill = paint
                local paint = {type = "image", filename = "images/tutorialArrow.png"}
                tutorialArrow.fill = paint
                tutorialArrow.x = openShopButton.x
                tutorialArrow.y = 500
            --inventory
            elseif(tutorialStep == 3)then
             local paint = {type = "image", filename = "images/tutorialTextInventory.png" }              
                tutorialDisplay.fill = paint
                local paint = {type = "image", filename = "images/tutorialArrow.png"}
                tutorialArrow.fill = paint
                tutorialArrow.x = inventoryButton.x
                tutorialArrow.y = 500
             --crafting
            elseif(tutorialStep == 4)then
             local paint = {type = "image", filename = "images/tutorialTextCrafting.png" }              
                tutorialDisplay.fill = paint
                local paint = {type = "image", filename = "images/tutorialArrow.png"}
                tutorialArrow.fill = paint
                tutorialArrow.x = craftingButton.x
                tutorialArrow.y = 500
             --save
            elseif(tutorialStep == 5)then
             local paint = {type = "image", filename = "images/tutorialTextSave.png" }              
                tutorialDisplay.fill = paint
                local paint = {type = "image", filename = "images/tutorialArrow.png"}
                tutorialArrow.fill = paint
                tutorialArrow.x = saveButton.x
                tutorialArrow.y = 500
                 --inventory
            elseif(tutorialStep == 6)then
             local paint = {type = "image", filename = "images/tutorialTextVendingMachine.png" }              
                tutorialDisplay.fill = paint
                local paint = {type = "image", filename = "images/tutorialArrowRight.png"}
                tutorialArrow.fill = paint
                tutorialArrow.x = vendingBtnGroup.x - 42
                tutorialArrow.y = 250
                tutorialArrow.width = 119
                tutorialArrow.height = 32
            elseif(tutorialStep == 7)then
                local paint = {type = "image", filename = "images/tutorialTextFinish.png" } 
                nextButton:setLabel("Finish")
                tutorialArrow.isVisible = false
                tutorialDisplay.fill = paint
            elseif(tutorialStep == 8)then
                composer.gotoScene("screens.Start")
            end
        end 
    end   
        
    nextButton = widget.newButton(options) 
    
    local textWidth = 200
    local textHeight = 25
    
    local textOptions = {
        text = "Cash: "..GLOB.stats["cash"],
        x = textWidth / 2,
        y = textHeight / 2,
        width = textWidth,
        height = textHeight,
        font = native.systemFont,
        fontSize = 20,
        align = "left"    
    }    
    
    cashLabel = display.newText(textOptions) -- item description
    cashLabel:setFillColor(1,1,1)    
    
    textWidth = 50
    textOptions["y"] = textOptions["y"] + 25
    textOptions["text"] = ""    
    dayLabel = display.newText(textOptions) -- item description
    dayLabel:setFillColor(1,1,1)      
        
    textOptions["x"] = textOptions["x"] + 85
    textOptions["text"] = ""    
    timeLabel = display.newText(textOptions) -- item description
    timeLabel:setFillColor(1,1,1)       
    
    --textWidth = 50
    textOptions["x"] = 100
    textOptions["y"] = textHeight / 2 + 50
    textOptions["text"] = "Level: "..GLOB.stats["level"]    
    local levelLabel = display.newText(textOptions) -- item description
    levelLabel:setFillColor(1,1,1)      
        
    textOptions["x"] = textOptions["x"] + 85
    textOptions["text"] = "XP: "..GLOB.stats["xp"]  
    local xpLabel = display.newText(textOptions) -- item description
    xpLabel:setFillColor(1,1,1)
    
    textOptions["x"] = textOptions["x"] - 85
    textOptions["y"] = textHeight / 2 + 75
    textOptions["text"] = "Shop Closed"  
    closedLabel = display.newText(textOptions) -- item description
    closedLabel:setFillColor(255/255,0,0)
    
    statGroup = display.newGroup()
    statGroup.x = 0
    statGroup.y = 0
    
    -- background
    floorBG = background.new(0,0, 1600,960)
    floorBG.bg:setFillColor(206/255,169/255,74/255,0.8)
    
    --the tutorial opening
        --show the opening tutorial box
    tutorialDisplay = display.newRect(300,display.contentHeight/2, 474, 172)
    local paint
    local myFile = "images/tutorialTextStart.png"
            paint = {
            type = "image",
            filename = myFile}
    tutorialDisplay.fill = paint
    
    --create the arrow to show what we're describing'
    tutorialArrow = display.newRect(1, 500, 32, 119 )
    tutorialArrow.isVisible = false;
            
    --add the tutorial pieces to the screen
    sceneGroup:insert(tutorialDisplay)
    sceneGroup:insert(tutorialArrow)
    
    -- add controls to group
    sceneGroup:insert(floorBG.bg)
    sceneGroup:insert(openShopButton)
    sceneGroup:insert(saveButton)
    sceneGroup:insert(craftingButton)
    sceneGroup:insert(inventoryButton)    
    sceneGroup:insert(nextButton)
    sceneGroup:insert(statGroup)
    statGroup:insert(cashLabel)
    statGroup:insert(dayLabel)
    statGroup:insert(timeLabel)
    statGroup:insert(levelLabel)
    statGroup:insert(xpLabel) 
    statGroup:insert(closedLabel)
    
    floorBG.bg:toBack()
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
        scene:ResumeShop() -- try to resume the open shop. update text labels
        scene:UpdateTimeOutput()
        -- enable buttons that may have been disabled after opening shope
        -- these are needed here because if there were no items to sell or there wasn't a transaction and the scene was loaded again, create was not called and the buttons persist being disabled
        if not GLOB.shopIsOpen then
            closedLabel.text = "Shop Closed" -- screen indicator
            closedLabel:setFillColor(255/255,0,0)
            floorBG.bg:setFillColor(0,0,0)
        else
            closedLabel.text = "Shop Open" -- screen indicator
            closedLabel:setFillColor(0,255/255,0)   
            floorBG.bg:setFillColor(206/255,169/255,74/255)
        end
        cashLabel.text = "Cash: "..GLOB.stats["cash"]
        scene:UpdateMerch()
        print("tutorial scene started")
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