local composer = require ("composer")
local GLOB = require "globals"
local controls = require("controls.Controls")
local background = require("controls.Background")
local widget = require "widget"
local utilities = require "functions.Utilities"
local general = require "functions.General"
local json = require "json"
local scene = composer.newScene()

-- remove previous screen
composer.removeScene( "screens.Barter")
--composer.removeScene("screens.Inventory")
--composer.removeHidden()

--todo:
-- need to look into cleaning up previous scenes

-- local forward references here
local merchLblGroup1
local merchLblGroup2
local merchBtnGroup1
local merchBtnGroup2
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

local timeLabel
local dayLabel
local closedLabel
local cashLabel
local statGroup
local floorBG

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
            merchLblGroup1[i].text = name 
        elseif i > 4 then -- second set of boxes (5-8)
            local index = i - 4 -- subtract 4 from i for numbers 5-8 since they are indexed in the group as 1-4
            merchLblGroup2[index].text = name 
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

-- event listener that is fired when the shop has opened and will be called each tick of the timer
-- this will update timer count data and determine if a transaction will take place. barter screen is called from here
local OpenShop = function(event)
    -- determine what type of transaction, if any, will take place
    -- if no transaction, resume timer
    -- if no items to sell, don't try to sell
    -- if buying, determine if buying single item or collection
    -- if selling, determine if selling display item or special request   
    
    
    GLOB.currentShopIterations = event.count -- get current tick of timer
    timer.pause(GLOB.shopTimer) -- pause the timer while action is taken
    

    -- determine type of transaction
    local trans = utilities:RNG(4)
       
    -- for testing   
    --trans = 4
    
    -- todo: additional options could be put here, such as vending machine sale
    if trans == 1 then -- no customer, resume timer or close shop if timer is done
        if not scene:ResumeShop() then
            -- close the shop. when the final tick of the timer has no transaction, special conditions must be taken
            -- there were problems accessing the scene's controls after going through this function. kludged solution is call gotoScene for this screen
            -- this will reload the current page with the labels properly updated
            -- todo: could bring up another screen or something to show user store is closed again to make this more seamless            
            composer.gotoScene("screens.Shop")
        end
    elseif trans == 2 then -- customer offering an item
        GLOB.transactionType = "buy"
        composer.gotoScene("screens.Barter")
    elseif trans == 3 then  -- customer wishes to buy an item
        -- check to make sure player has items to sell. if not, resume shop or close it
        local goodsToSell = false
        
        for k,v in pairs(GLOB.merch) do -- run through mech displays to make sure at least 1 item is available for sale. if one is found, break the loop
            if v ~= "" then
                goodsToSell = true
                break
            end            
        end
        
        if goodsToSell then -- there's something to sell
            GLOB.transactionType = "sell"
            composer.gotoScene("screens.Barter")               
        else        -- there's no items to sell. try to resume shop or close shop
            if not scene:ResumeShop() then
                composer.gotoScene("screens.Shop")
            end   
            print("nothing to sell")
        end
    
    elseif trans == 4 then -- customer buys a vending item
        
        -- first make sure there is at least 1 item in the vending machine
        local stocked = false
        local soldItem = {}
        local soldName = ""
        local soldPrice = 0
        
        for k,v in pairs(GLOB.vending) do
            if v ~= "" then
                stocked = true
                break
            end
        end
        
        if stocked and GLOB.stats["level"] >= 5 then
            
            -- choose an item to sell
            soldItem = scene:ChooseVendingItem()
            
            -- construct item's name. might not need
            soldName = general:BuildName(soldItem)

            -- set the price
            soldPrice = general:CalculateBasePrice(soldItem)            
            
            -- get paid
            GLOB.stats["cash"] = GLOB.stats["cash"] + soldPrice
            
            
            if GLOB.inventory[pickItem]["Qty"] > 1 then
                GLOB.inventory[pickItem]["Qty"] = GLOB.inventory[pickItem]["Qty"] - 1 -- more than one in inventory, reduce quantity
            else
                GLOB.inventory[pickItem] = nil -- item removed from player inventory  
            end

            -- also remove item from display case
            -- todo: optional flags to skip this if picking item a different way. it may not hurt anything to leave this in since it will only remove the item if it's on display and skip it otherwise
            for k,v in pairs (GLOB.vending) do    
                if v["ItemID"] == soldItem["ItemID"] and v["Mod"] == soldItem["Mod"] then
                    GLOB.vending[k] = ""
                end        
            end 
            
            print("Sold "..soldName)
        else
            print("no vending item to sell") 
       
        end        
        
        -- refresh visual elements if shop will now be closed
        if not scene:ResumeShop() then
            composer.gotoScene("screens.Shop")
        end
    end 
end   

function scene:ChooseVendingItem()
    local isOnDisplay = false
    local keys = {}
    local pickKey = 0
    local count = 1
    local newItem = {}
    
    -- inventory may have holes in numeric index, so first create a table of the numeric indexes that do exist
    for k,v in pairs (GLOB.inventory) do
        keys[count] = k -- the value of k is the actual numeric index value of the item
        count = count + 1
    end  
    
    while not isOnDisplay do    
        pickKey = utilities:RNG(#keys) or 0   -- choose a random key
        pickItem = keys[pickKey]  -- get the index value of that key
        newItem = GLOB.inventory[pickItem] or {} -- now get the item at that index value  
    
        -- find the item in vending. if it's not there pick a different item until one is found
        for k,v in pairs (GLOB.vending) do    
            if v["ItemID"] == newItem["ItemID"] and v["Mod"] == newItem["Mod"] then
                isOnDisplay = true
                break
            end        
        end        
    end   		

    return newItem  
end

-- either restart the timer or close the shop and nil out the timer + listener, then advance the time period 1 unit
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
    
    merchBtnGroup2 = display.newGroup()
    merchBtnGroup2.x = GLOB.width - 80
    merchBtnGroup2.y = 75 
    
    merchLblGroup2 = display.newGroup()
    merchLblGroup2.x = GLOB.width - 80
    merchLblGroup2.y = 75         
    
    local merchWidth = 75
    local merchHeight = 75
    local merchX = merchWidth / 2
    local merchY = merchHeight / 2 + 5
    
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
        onEvent = function(event)
            if ( "ended" == event.phase ) then
                GLOB.pickDisplay = true
                GLOB.merchSlot = "1"
                GLOB.vendingSlot = ""
                composer.gotoScene("screens.Inventory")
            end 
        end                 
    }

    local merchButton1 = widget.newButton(merchOptions)   
    
    merchOptions["x"] = merchWidth * 2
    merchOptions["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            GLOB.pickDisplay = true
            GLOB.merchSlot = "2"
            GLOB.vendingSlot = ""
            composer.gotoScene("screens.Inventory")
        end 
    end   
    
    local merchButton2 = widget.newButton(merchOptions)
    
    merchOptions["x"] = merchWidth * 3
    merchOptions["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            GLOB.pickDisplay = true
            GLOB.merchSlot = "3"
            GLOB.vendingSlot = ""
            composer.gotoScene("screens.Inventory")
        end 
    end   
    
    local merchButton3 = widget.newButton(merchOptions)    
    
    merchOptions["x"] = merchWidth * 4
    merchOptions["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            GLOB.pickDisplay = true
            GLOB.merchSlot = "4"
            GLOB.vendingSlot = ""
            composer.gotoScene("screens.Inventory")
        end 
    end   
    
    local merchButton4 = widget.newButton(merchOptions)        
    
    local labelOptions = {
        text = "+",
        x = merchWidth + 2,
        y = merchY + 5,
        width = merchWidth - 5,
        height = merchHeight,
        font = native.systemFont,
        fontSize = 12,
        align = "center"    
    }    
    
    merchLabel1 = display.newText(labelOptions) -- item description
    merchLabel1:setFillColor(0,0,0)        
    
    labelOptions["x"] = merchWidth * 2 + 2
    merchLabel2 = display.newText(labelOptions) -- item description
    merchLabel2:setFillColor(0,0,0)     
    
    labelOptions["x"] = merchWidth * 3 + 2
    merchLabel3 = display.newText(labelOptions) -- item description
    merchLabel3:setFillColor(0,0,0)  
    
    labelOptions["x"] = merchWidth * 4 + 2
    merchLabel4 = display.newText(labelOptions) -- item description
    merchLabel4:setFillColor(0,0,0)      
    
    -- end first set of display cases
    
    -- start second set of display cases

    merchOptions["x"] = merchWidth / 2
    merchOptions["y"] = merchHeight
    merchOptions["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            GLOB.pickDisplay = true
            GLOB.merchSlot = "5"
            GLOB.vendingSlot = ""
            composer.gotoScene("screens.Inventory")
        end 
    end       
    
    local merchButton5 = widget.newButton(merchOptions)

    merchOptions["y"] = merchHeight * 2
    merchOptions["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            GLOB.pickDisplay = true
            GLOB.merchSlot = "6"
            GLOB.vendingSlot = ""
            composer.gotoScene("screens.Inventory")
        end 
    end       
    
    local merchButton6 = widget.newButton(merchOptions)
    
    merchOptions["y"] = merchHeight * 3
    merchOptions["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            GLOB.pickDisplay = true
            GLOB.merchSlot = "7"
            GLOB.vendingSlot = ""
            composer.gotoScene("screens.Inventory")
        end 
    end       
    
    local merchButton7 = widget.newButton(merchOptions)
    
    merchOptions["y"] = merchHeight * 4
    merchOptions["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            GLOB.pickDisplay = true
            GLOB.merchSlot = "8"
            GLOB.vendingSlot = ""
            composer.gotoScene("screens.Inventory")
        end 
    end       
    
    local merchButton8 = widget.newButton(merchOptions)      
    
    labelOptions["x"] = merchWidth / 2 + 2
    labelOptions["y"] = merchHeight + 5
    merchLabel5 = display.newText(labelOptions) -- item description
    merchLabel5:setFillColor(0,0,0)        
    
    labelOptions["y"] = merchHeight * 2 + 5
    merchLabel6 = display.newText(labelOptions) -- item description
    merchLabel6:setFillColor(0,0,0)     
    
    labelOptions["y"] = merchHeight * 3 + 5
    merchLabel7 = display.newText(labelOptions) -- item description
    merchLabel7:setFillColor(0,0,0)  
    
    labelOptions["y"] = merchHeight * 4 + 5
    merchLabel8 = display.newText(labelOptions) -- item description
    merchLabel8:setFillColor(0,0,0)       
    
    -- end second set of display cases
    
    -- add merch buttons and labels to merch groups and merch groups to scene group
    merchBtnGroup1:insert(merchButton1)
    merchBtnGroup1:insert(merchButton2)
    merchBtnGroup1:insert(merchButton3)
    merchBtnGroup1:insert(merchButton4)
    merchLblGroup1:insert(merchLabel1)
    merchLblGroup1:insert(merchLabel2)
    merchLblGroup1:insert(merchLabel3)
    merchLblGroup1:insert(merchLabel4)
    merchBtnGroup2:insert(merchButton5)
    merchBtnGroup2:insert(merchButton6)
    merchBtnGroup2:insert(merchButton7)
    merchBtnGroup2:insert(merchButton8)
    merchLblGroup2:insert(merchLabel5)
    merchLblGroup2:insert(merchLabel6)
    merchLblGroup2:insert(merchLabel7)
    merchLblGroup2:insert(merchLabel8)
    sceneGroup:insert(merchBtnGroup1)
    sceneGroup:insert(merchBtnGroup2)
    sceneGroup:insert(merchLblGroup1)
    sceneGroup:insert(merchLblGroup2)

    --------------------
    -- END DISPLAY CASES
    --------------------

    --------------------
    -- VENDING MACHINE
    --------------------
    
    vendingBtnGroup = display.newGroup()
    vendingBtnGroup.x = 400
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
    sceneGroup:insert(vendingBtnGroup)
    sceneGroup:insert(vendingLblGroup)  
    
    --------------------
    -- END VENDING MACHINE
    --------------------    
    
    -- hide vending until player reaches level 5
    if GLOB.stats["level"] < 5 then
        vendingBtnGroup.isVisible = false
        vendingLblGroup.isVisible = false
    end
    
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
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4,
        labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
        onEvent = function(event)
            if ( "ended" == event.phase ) then
                GLOB.transactionType = "sell"
                composer.gotoScene("screens.Barter")
            end 
        end                 
    }

    local sellButton = widget.newButton(options)     
    --sellButton:setEnabled(false)
    
    -- options for buy button
    options["label"] = "Open Shop"
    options["y"] = GLOB.height - 125
    options["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            
            -- disable on screen buttons while shop is open
            openShopButton:setEnabled(false)
            merchBtnGroup1[1]:setEnabled(false)
            merchBtnGroup1[2]:setEnabled(false)
            merchBtnGroup1[3]:setEnabled(false)
            merchBtnGroup1[4]:setEnabled(false)
            merchBtnGroup2[1]:setEnabled(false)
            merchBtnGroup2[2]:setEnabled(false)
            merchBtnGroup2[3]:setEnabled(false)
            merchBtnGroup2[4]:setEnabled(false)
            vendingBtnGroup[1]:setEnabled(false)
            vendingBtnGroup[2]:setEnabled(false)
            vendingBtnGroup[3]:setEnabled(false)
            vendingBtnGroup[4]:setEnabled(false)
            vendingBtnGroup[5]:setEnabled(false)
            vendingBtnGroup[6]:setEnabled(false)
            inventoryButton:setEnabled(false)
            craftingButton:setEnabled(false)
            saveButton:setEnabled(false)            
            
            -- determine how many ticks(possible customers for the shop's open duration).
            GLOB.currentShopIterations = 0
            local level = GLOB.stats["level"]
            local minTrans = GLOB.levels[level]["minTrans"]
            local maxTrans = GLOB.levels[level]["maxTrans"]
            closedLabel.text = "Shop Open"
            closedLabel:setFillColor(0,255/255,0)
            floorBG.bg:setFillColor(206/255,169/255,74/255)
            GLOB.shopIterations = utilities:RNG(maxTrans, minTrans) --randomize based on player level
            GLOB.shopIsOpen = true
            GLOB.shopTimer = timer.performWithDelay(1000, OpenShop, GLOB.shopIterations)
        end 
    end  
    
    openShopButton = widget.newButton(options)    
        
    -- options for buy button
    options["label"] = "Buy"
    options["x"] = 225
    options["y"] = GLOB.height - 50
    options["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            GLOB.transactionType = "buy"
            composer.gotoScene("screens.Barter")
        end 
    end  
    
    local buyButton = widget.newButton(options)
   -- buyButton:setEnabled(false)
    
    -- options for inventory
    options["label"] = "Inventory"
    options["x"] = 350
    options["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            composer.gotoScene("screens.Inventory")
        end 
    end      
    
    inventoryButton = widget.newButton(options)    
    
    -- options for inventory
    options["label"] = "Crafting"
    options["x"] = 475
    options["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            composer.gotoScene("screens.Crafting")
        end 
    end      
    
    craftingButton = widget.newButton(options)       
    
    -- options for save button. the attached event will encode the save data into a string and then be written to a json file
    options["label"] = "Save"
    options["x"] = 600
    options["onEvent"] = function(event)
        if ( "ended" == event.phase ) then
            local saveGame = {}
            saveGame["inventory"] = GLOB.inventory
            saveGame["stats"] = GLOB.stats
            saveGame["merch"] = GLOB.merch
            saveGame["vending"] = GLOB.vending
            local saveStr = json.encode(saveGame)
            if utilities:saveGame("shop.json", saveStr) then -- true is returned if successful
                print("game saved")
            end
        end 
    end      
    
    saveButton = widget.newButton(options)
    
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
    
    
    -- add controls to group
    sceneGroup:insert(floorBG.bg)
    sceneGroup:insert(sellButton)
    sceneGroup:insert(openShopButton)
    sceneGroup:insert(buyButton)
    sceneGroup:insert(saveButton)
    sceneGroup:insert(craftingButton)
    sceneGroup:insert(inventoryButton)    
    sceneGroup:insert(statGroup)
    statGroup:insert(cashLabel)
    statGroup:insert(dayLabel)
    statGroup:insert(timeLabel)
    statGroup:insert(levelLabel)
    statGroup:insert(xpLabel) 
    statGroup:insert(closedLabel)
    
    floorBG.bg:toBack()
    
    scene:UpdateTimeOutput()
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
            openShopButton:setEnabled(true)
            merchBtnGroup1[1]:setEnabled(true)
            merchBtnGroup1[2]:setEnabled(true)
            merchBtnGroup1[3]:setEnabled(true)
            merchBtnGroup1[4]:setEnabled(true)
            merchBtnGroup2[1]:setEnabled(true)
            merchBtnGroup2[2]:setEnabled(true)
            merchBtnGroup2[3]:setEnabled(true)
            merchBtnGroup2[4]:setEnabled(true)
            vendingBtnGroup[1]:setEnabled(true)
            vendingBtnGroup[2]:setEnabled(true)
            vendingBtnGroup[3]:setEnabled(true)
            vendingBtnGroup[4]:setEnabled(true)
            vendingBtnGroup[5]:setEnabled(true)
            vendingBtnGroup[6]:setEnabled(true)            
            inventoryButton:setEnabled(true)
            craftingButton:setEnabled(true)
            saveButton:setEnabled(true) 
            closedLabel.text = "Shop Closed" -- screen indicator
            closedLabel:setFillColor(255/255,0,0)
            floorBG.bg:setFillColor(0,0,0)
        else
            openShopButton:setEnabled(false)
            merchBtnGroup1[1]:setEnabled(false)
            merchBtnGroup1[2]:setEnabled(false)
            merchBtnGroup1[3]:setEnabled(false)
            merchBtnGroup1[4]:setEnabled(false)
            merchBtnGroup2[1]:setEnabled(false)
            merchBtnGroup2[2]:setEnabled(false)
            merchBtnGroup2[3]:setEnabled(false)
            merchBtnGroup2[4]:setEnabled(false)
            vendingBtnGroup[1]:setEnabled(false)
            vendingBtnGroup[2]:setEnabled(false)
            vendingBtnGroup[3]:setEnabled(false)
            vendingBtnGroup[4]:setEnabled(false)
            vendingBtnGroup[5]:setEnabled(false)
            vendingBtnGroup[6]:setEnabled(false)            
            inventoryButton:setEnabled(false)
            craftingButton:setEnabled(false)
            saveButton:setEnabled(false)   
            closedLabel.text = "Shop Open" -- screen indicator
            closedLabel:setFillColor(0,255/255,0)   
            floorBG.bg:setFillColor(206/255,169/255,74/255)
        end
        cashLabel.text = "Cash: "..GLOB.stats["cash"]
        scene:UpdateMerch()
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