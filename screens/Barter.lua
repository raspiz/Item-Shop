local composer = require "composer"
local GLOB = require "globals"
local utilities = require "functions.Utilities"
local general = require "functions.General"
local widget = require "widget"
local background = require "controls.Background"
local button = require "controls.Button"
local scene = composer.newScene()

-- clear previous scene.
composer.removeScene( "screens.Shop")

-- forward declarations of controls that need accessed outside of scene:create
local onesOutput
local tensOutput
local hundredsOutput
local thousandsOutput
local markupOutput
local customerMood
local customerResponse
local outcomeText
local submitButton
local refuseButton

-- item and customer data needed throughout
-- todo add restrictions for what tier can be offered or anything else that might restrict the item picked(like if customer wants a specific type of item)
-- todo if i want to add a way to sell more than one item at a time, do it the way buying works with a table of all items
local customer = {}
local turns  = 0
local pickItem = 0 -- this will be the actual index value that the inventory uses to later remove the item. only needed when selling
local item = {} -- table of item data
local itemName = ""
local itemPrice = 0
local collection = false -- set to true when buying multiple items
local itemCollection = {} -- table of items when buying a quantity of items

-- choose a customer from available table. determine how many turns of bartering will take place based on this
-- customer will also be used in determining min and max price ranges accepted
function scene:ChooseCustomer()
    local pickCustomer = utilities:RNG(#GLOB.customers) or 0
    customer = GLOB.customers[pickCustomer] or {} -- choose a customer
    turns = customer["Turns"] + utilities:RNG(1, -1) -- randomize number of bartering turns  +/- 1
end



-- called when GLOB.transactionType = "sell"
function scene:ChooseSellItem()
    -- this could be made better. currently just picks an item, then sees if it's on display. if it's not keep looking
    -- could be reversed. pick merch item, then find it in inv. only caveat is index value in inv would need to be found
    
    -- todo: choose any item in inventory. may want to readd later as an optional sell type

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
    
        -- find the item in merch. if it's not there pick a different item until one is found
        for k,v in pairs (GLOB.merch) do    
            if v["ItemID"] == newItem["ItemID"] and v["Mod"] == newItem["Mod"] then
                isOnDisplay = true
                break
            end        
        end        
    end    
    
    return newItem
end

-- pick an item from all items. first a main cat will be randomly picked, then an item in that cat will be chosen
function scene:ChooseBuyItem()
  
    -- todo: decide if lower tiered items should appear less often. elemental guards and wards are tiered 1 and 3. this could cause them to not appear often if restrictions added. could make utility items appear for all tiers since they aren't crafted
    local goodItem = false
    local newItem = {}
    local mainCat = ""
    local pickCat = 0

    -- make table of main cats and pick a random one
    local mainCatTab = {[1] = "Weapons",[2] = "Body Armor",[3] = "Head Armor",[4] = "Feet Armor",[5] = "Accessory Armor",[6] = "Off Hand Item",[7] = "Goods",[8] = "Treasure",[9] = "Foods",[10] = "Resources",[11] = "Ingredients",[12] = "Alchemy",[13] =  "Template" }
    pickCat = utilities:RNG(#mainCatTab) or 0

    -- for testing
    --pickCat = 11

    while not goodItem do        
        pickItem = utilities:RNG(#GLOB.items) or 0
        newItem = GLOB.items[pickItem] or {} -- choose the item            
        
        -- can comment this if statement out to allow all items for testing
        if newItem["MCatID"] == pickCat and newItem["Tier"] <= GLOB.stats["tier"] then -- make sure the item tier is appropriate for the player, otherwise pick another one
            goodItem = true
        end        
    end
    
    --[[      
    -- while loop test to pick only certain items. for testing purposes. just comment out above block and uncomment this one
    local testFlag = false        
    
    while not testFlag do    
        pickItem = utilities:RNG(#GLOB.items) or 0
        newItem = GLOB.items[pickItem] or {} -- choose the item
        if newItem["Name"] == "Scroll of" then
            testFlag = true
        end
    end
     --]]   
    
    return newItem
end

-- total up player's offer and return it
function scene:TotalOffer()        
    local totalOffer = 0
    totalOffer = totalOffer + onesOutput.text
    totalOffer = totalOffer + (tensOutput.text * 10)
    totalOffer = totalOffer + (hundredsOutput.text * 100)
    totalOffer = totalOffer + (thousandsOutput.text * 1000)

    return totalOffer
end

function scene:GetOutcomeText()
    return outcomeText
end

-- check to see if player's offer is within customer's acceptable range
function scene:MakeDeal()    
    -- todo need to load in customer data, market hotness or coldness, and adjust price range accepted
    
    local sale = false
    local xpGain = 0
    
    if turns > 0 then        
        local basePrice = itemPrice  
        -- total up player's offer
        local offer = scene:TotalOffer()
        local minPrice = 0
        local maxPrice = 0
        local walkPrice = 0        
        
        if GLOB.transactionType == "sell" then
            minPrice = utilities:RNG(customer["MinPay"] + 5, customer["MinPay"] - 5) * basePrice * 0.01 -- min price customer will accept
            maxPrice = utilities:RNG(customer["MaxPay"] + 5, customer["MaxPay"] - 5) * basePrice * 0.01  -- max price customer will accept
            walkPrice = maxPrice + (maxPrice * customer["Walk"] * 0.01) -- price that will upset customer. costs 2 turns when it exceeds this value                
        else    -- buying
            minPrice = utilities:RNG(customer["MinSell"] + 5, customer["MinSell"] - 5) * basePrice * 0.01 -- min price customer will accept
            maxPrice = utilities:RNG(customer["MaxSell"] + 5, customer["MaxSell"] - 5) * basePrice * 0.01  -- max price customer will accept
            walkPrice = minPrice - (minPrice * customer["Walk"] * 0.01) -- price that will upset customer. costs 2 turns when it exceeds this value              
        end
        
        if GLOB.transactionType == "sell" then
            if offer >= walkPrice then -- customer offended by high offer
                customerResponse.text = GLOB.mood["walk"] 
                turns = turns - 2
            elseif
                offer > maxPrice then
                customerResponse.text = GLOB.mood["toomuch"] 
                turns = turns - 1            
            elseif offer >= minPrice and offer <= maxPrice then -- goldilocks zone
                customerResponse.text = GLOB.mood["goldilocks"]
                turns = 0
                sale = true 
                xpGain = 15
            elseif offer < minPrice then
                customerResponse.text = GLOB.mood["toolittle"]
                turns = 0
                sale = true
                xpGain = 10
            end            
        else -- buying
            if offer <= walkPrice then -- customer offended by high offer
                customerResponse.text = GLOB.mood["walk"] 
                turns = turns - 2
            elseif offer < minPrice then
                customerResponse.text = GLOB.mood["toomuch"] 
                turns = turns - 1            
            elseif offer >= minPrice and offer <= maxPrice then -- goldilocks zone
                customerResponse.text = GLOB.mood["goldilocks"]
                turns = 0
                sale = true 
                xpGain = 15
            elseif offer > maxPrice then
                customerResponse.text = GLOB.mood["toolittle"]
                turns = 0
                sale = true
                xpGain = 10
            end                
        end

        if not sale and turns <= 0 then
            turns = 0
        end

        if sale then -- a deal was made
            -- remove the item from inventory if selling, add it if buying. update cash
            if GLOB.transactionType == "sell" then
                if GLOB.inventory[pickItem]["Qty"] > 1 then
                    GLOB.inventory[pickItem]["Qty"] = GLOB.inventory[pickItem]["Qty"] - 1 -- more than one in inventory, reduce quantity
                else
                    GLOB.inventory[pickItem] = nil -- item removed from player inventory  
                end
                
                -- also remove item from display case
                -- todo: optional flags to skip this if picking item a different way. it may not hurt anything to leave this in since it will only remove the item if it's on display and skip it otherwise
                for k,v in pairs (GLOB.merch) do    
                    if v["ItemID"] == item["ItemID"] and v["Mod"] == item["Mod"] then
                        GLOB.merch[k] = ""
                    end        
                end
            else -- bought an item
                -- check if the item exists in inventory, if it does, increase quantity                
                for i = 1, #itemCollection do                    
                    local incQty = false

                    -- see if the item exists in inventory already. must match ItemID and Mod. if so increase Qty and break loop
                    for k,v in pairs(GLOB.inventory) do
                        if v["ItemID"] == itemCollection[i]["ItemID"] and v["Mod"] == itemCollection[i]["Mod"] then
                            v["Qty"] = v["Qty"] + 1
                            incQty = true
                            break
                        end                    
                    end

                    -- if it's a new item just add to inv
                    if not incQty then
                        itemCollection[i]["Qty"] = 1
                        GLOB.inventory[#GLOB.inventory + 1] = itemCollection[i] -- add the item to the end of the player inventory table
                    end
                end
                
                offer = - offer -- make the value a negative to be removed from player cash
            end
            
            local transDetails = ""
            local xpMessage = "You have gained "..xpGain.." XP"
            
            if GLOB.transactionType == "sell" then                
                transDetails = "You have sold\n"..itemName.."\nfor "..(offer)
            else
                transDetails = "You have bought\n"
                for i = 1, #itemCollection do
                    local collName = ""
                    
                    collName = general:BuildName(itemCollection[i])
                    transDetails = transDetails.." "..collName.."\n"
                end
                                    
                transDetails = transDetails.."for "..(-offer).." Gold"
            end
            
            outcomeText = GLOB.mood["sale"].."\n"..xpMessage.."\n"..transDetails
            
            GLOB.stats["cash"] = GLOB.stats["cash"] + offer -- add the cost of the sale or purchase onto cash. if purchasing it will be a negative value
            general:GainExperience(xpGain) -- add experience and possibly level up  
            submitButton:removeSelf()
            submitButton = nil
            scene:ShowOverlay()            
        elseif turns == 0 then -- the customer has left without making a deal
            submitButton:removeSelf()
            submitButton = nil        
            outcomeText = GLOB.mood["nodeal"]
            scene:ShowOverlay()            
        else  -- bartering isn't over, update customer's mood output
            customerMood.text = GLOB.mood[turns] 
        end 
    else
        submitButton:removeSelf()
        submitButton = nil   
        refuseButton:removeSelf()
        refuseButton = nil        
        outcomeText = GLOB.mood["nodeal"]
        scene:ShowOverlay()   
    end
end

function scene:NoDeal()
    submitButton:removeSelf()
    submitButton = nil     
    refuseButton:removeSelf()
    refuseButton = nil
    outcomeText = GLOB.mood["nodeal"]
    scene:ShowOverlay()  
end

-- change the player's offered value after pressing the up or down button
-- special conditions are included for different places to deal with numbers rolling over
-- if additional larger number values are added later, these will all need looked at and adjusted
function scene:ChangeValue()
    local btnID = self.target.id -- string name of the button pressed      
    local changeString = ""
    local changeValue = 0 
    local totalOffer = scene:TotalOffer() -- get the current value before changing anything since the number is pieced together
      
    -- get some data that will be needed for the rest of the function
    -- a default changeValue of 1 or -1 will be set. this may change depending on what button was pressed and what values will roll over
    if btnID:match("Up") then
        changeValue = 1
        changeString = "Up"
    else
        changeValue = -1
        changeString = "Down"
    end    
    
    -- determine which place is being changed. special cases for ones place and highest value place
    if btnID == "BtnOnes"..changeString then 
        if changeString == "Down" and onesOutput.text == "0" and hundredsOutput.text ~= "0" then
            changeValue = -1 end 
        elseif changeString == "Down" and onesOutput.text == "0" then 
            if tensOutput.text == "0" then -- roll back to 9
                changeValue = 9
        end
                

    elseif btnID == "BtnTens"..changeString then        
        if changeString == "Down" and tensOutput.text == "0" then -- case for decrementing at 0
            if hundredsOutput.text == "0" then -- if hundreds place is 0, roll back to a 9. ignores thousands place
                changeValue = 90
            else    -- else the hundreds place will also roll back
                changeValue = -10
            end            
        else
            changeValue = changeValue * 10        
        end    
    elseif btnID == "BtnHundreds"..changeString then
        if changeString == "Down" and hundredsOutput.text == "0" then  -- case for decrementing at 0
            if thousandsOutput.text == "0" then -- if thousands place is 0, roll back to a 9
                changeValue = 900
            else    -- else the thousands place will also roll back
                changeValue = -100    
            end 
        elseif changeString == "Up" and thousandsOutput.text == "9" and hundredsOutput.text == "9" then -- keeps thousands place from incrementing from 9 to 10, instead it will become 0. this would need moved up to thousands place if bigger numbers allowed
            changeValue = changeValue * -9900
        else
            changeValue = changeValue * 100   
        end        
    elseif btnID == "BtnThousands"..changeString then
        if changeString == "Down" and thousandsOutput.text == "0" then
            changeValue = 9000
        elseif changeString == "Up" and thousandsOutput.text == "9" then -- special case for thousands place to roll back over to 0. if i add larger numbers, this will need to be moved to highest place value
            changeValue = -9000
        else
            changeValue = changeValue * 1000    
        end        
    end
    
    totalOffer = totalOffer + changeValue 
    
    -- prevent offering more money that player has
    if GLOB.transactionType == "buy" and totalOffer > GLOB.stats["cash"] then
        totalOffer = GLOB.stats["cash"]
    end
        
    
    scene:OutputOffer(totalOffer) 
    markupOutput.text = utilities:Round(totalOffer / itemPrice * 100).."% of base price" -- display new markup %
end

function scene:OutputOffer(newOffer)
    local thousands = 0
    local hundreds = 0
    local tens = 0       
    
    thousands =  newOffer / 1000
    if thousands < 1 then 
        thousands = 0
    else
        thousands = math.floor(thousands)
    end            
    thousandsOutput.text = thousands
    newOffer = newOffer - (thousands * 1000)
    hundreds = newOffer / 100
    if hundreds < 1 then 
        hundreds = 0  
    else
        hundreds = math.floor(hundreds)
    end            
    hundredsOutput.text = hundreds
    newOffer = newOffer - (hundreds * 100)
    tens = newOffer / 10
    if tens < 1 then 
        tens = 0
    else
        tens = math.floor(tens)
    end            
    tensOutput.text = tens
    newOffer = newOffer - (tens * 10)     
    newOffer = math.floor(newOffer)
    
    if newOffer < 0 then
        newOffer = 0
    end
    
    onesOutput.text = newOffer

    newOffer = newOffer + onesOutput.text
    newOffer = newOffer + (tensOutput.text * 10)
    newOffer = newOffer + (hundredsOutput.text * 100)
    newOffer = newOffer + (thousandsOutput.text * 1000)
end


-- display initial offer of base price. 50% for buying, 115% for selling
function scene:SetInitialOffer()
    -- total up player's offer    
    local initialOffer = itemPrice
    
    if GLOB.transactionType == "sell" then
        initialOffer = initialOffer + (initialOffer * 0.15) 
    else
        initialOffer = initialOffer - (initialOffer * 0.5)   
        
        -- prevent offering more money that player has
        if initialOffer > GLOB.stats["cash"] then
            if GLOB.stats["cash"] < 0 then
                initialOffer = 0
            else
                initialOffer = GLOB.stats["cash"]
            end
        end        
    end


    
    scene:OutputOffer(initialOffer)

    markupOutput.text = utilities:Round(initialOffer / itemPrice * 100).."% of base price" -- display new markup %  
    customerMood.text = GLOB.mood[turns] -- output customer mood
end

function scene:ShowOverlay()
    local options = {
        isModal = true,
        -- add any other parameters here
    }  
    composer.showOverlay("screens.EndTransaction", options)
end



function scene:create(event)
    local sceneGroup = self.view    

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.    
    
    scene:ChooseCustomer() -- pick a customer for the transaction

    local setupText = {}
    
    if GLOB.transactionType == "sell" then -- choose an item from player inventory 
        item = scene:ChooseSellItem()

        -- construct item's name
        itemName = general:BuildName(item)

        -- set the price
        itemPrice = general:CalculateBasePrice(item)
        
        -- strings for output text labels
        setupText[1] = "sale"
        setupText[2] = "What are you willing to "..GLOB.transactionType.." this for?"
    else -- buy. choose an item from all possible items. determine if it's a collection of multiple items
        -- can decide in here whether single item or collection. 20% chance of being a collection 
        local highestPrice = 0   
        local collectionSize = 1
        local collectionChance = utilities:RNG(10, 1)
        
        -- do a count of items in inventory. if less than 5 in items and equipment, guarantee a collection for sale so that player doesn't run out of items to sell
        local itemCount = 0
        for k,v in pairs(GLOB.inventory) do
            if v["MasterCat"] ~= "Crafting" then
                itemCount = itemCount + v["Qty"]    
            end
        end        
        
        if itemCount < 10 then
            collectionChance = 10 -- can use this line to test collections
        end    
        
        if collectionChance > 8 then
            collection = true
            collectionSize = utilities:RNG(20, 5) -- determine size of collection between 5-20 inclusive
        end
        
        -- for testing
        --collectionSize = 20

        for i = 1, collectionSize do -- if not a collection, this will iterate once and the single item will get price and name set. otherwise it accumulates a total and displays name of highest priced item
            local tempPrice = 0
            local tempName = ""
            
            item = scene:ChooseBuyItem()
            
            -- add a mod. right now only applies to spells
            item["Mod"] = general:ChooseMod(item) 

            -- set the price
            tempPrice = general:CalculateBasePrice(item)    
            itemPrice = itemPrice + tempPrice -- accumulating total of all items in collection
            
            if tempPrice >= highestPrice then
                highestPrice = tempPrice
                itemName = general:BuildName(item) -- construct item's name. the highest priced item's name will be listed for the collection                   
            end   
            
            itemCollection[i] = item -- add the item to collection table even if single item
        end
        
        setupText[1] = "purchase"
        
        if collection then
            itemName = itemName.." + Collection"
            setupText[2] = "What are you willing to pay for this collection?" 
        else
            setupText[2] = "What are you willing to pay for this?" 
        end
    end    
    
    ---------------------
    --  BEGIN CONTROLS --
    ---------------------
    
    local textOptions = {
        text = "The item for "..setupText[1].." is:\n"..itemName.."\n Base price is "..itemPrice,
        x = GLOB.middleX,
        y = 100,
        width = 450,
        height = 100,
        font = native.systemFont,
        fontSize = 20,
        align = "center"    
    }    

    local itemLabel = display.newText(textOptions) -- item description
    itemLabel:setFillColor(0,0,0)
    
    textOptions["text"] = "Customer Mood:"
    textOptions["x"] = 125
    textOptions["y"] = 75
    textOptions["height"] = 50
    textOptions["width"] = 200    
    local moodLabel = display.newText(textOptions) -- customer mood label 
    moodLabel:setFillColor(0,0,0)
    
    textOptions["text"] = "The customer's mood"
    textOptions["x"] = 125
    textOptions["y"] = 125
    textOptions["height"] = 100
    textOptions["width"] = 200    
    customerMood = display.newText(textOptions) -- customer info 
    customerMood:setFillColor(0,0,0)
    
    textOptions["text"] = "Customer Response:"
    textOptions["x"] = GLOB.width - 200
    textOptions["y"] = 75
    textOptions["height"] = 50
    textOptions["width"] = 200    
    local responseLabel = display.newText(textOptions) -- customer mood label 
    responseLabel:setFillColor(0,0,0)
    
    textOptions["text"] = setupText[2]
    textOptions["x"] = GLOB.width - 200
    textOptions["y"] = 125
    textOptions["height"] = 100
    textOptions["width"] = 200    
    customerResponse = display.newText(textOptions) -- customer info 
    customerResponse:setFillColor(0,0,0)        

    local overlayBackground = background.new(0,0, 2100,1280)-- GLOB.width, GLOB.height) -- had to make this double size for some reason?
    
    if GLOB.transactionType == "sell" then
        overlayBackground.bg:setFillColor(107/255,239/255,95/255)
    elseif collection then
        overlayBackground.bg:setFillColor(249/255,228/255,64/255)
    else
        overlayBackground.bg:setFillColor(95/255,239/255,234/255)
    end    
    
    local controlsMidX = GLOB.middleX + (100/2)
    local controlsMidY = GLOB.middleY + (50/2)
    
    local options = {
        label = "Up",
        emboss = false,
        shape = "roundedRect",
        id = "BtnOnesUp",
        x = controlsMidX + 100,
        y = GLOB.middleY,
        width = 100,
        height = 50,
        cornerRadius = 2,
        fillColor = { default={ .1, 0, .9, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ .3, .3, .3, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4,
        labelColor = { default={ .9, .9, .9, 1 }, over={ .9, .9, .9, 1 } },  
        onPress = self.ChangeValue     
    }

    -- change value up buttons
    local onesButtonUp = widget.newButton(options)
    options["x"] = controlsMidX
    options["id"] = "BtnTensUp"
    local tensButtonUp = widget.newButton(options)
    options["x"] = controlsMidX - 100
    options["id"] = "BtnHundredsUp"
    local hundredsButtonUp = widget.newButton(options)
    options["x"] = controlsMidX - 200 
    options["id"] = "BtnThousandsUp"
    local thousandsButtonUp = widget.newButton(options)    
    
    -- change value down buttons
    options["x"] = controlsMidX + 100
    options["y"] = GLOB.middleY + 120
    options["label"] = "Down"
    options["id"] = "BtnOnesDown" 
    options["onPress"] = self.ChangeValue
    local onesButtonDown = widget.newButton(options)
    options["x"] = controlsMidX
    options["id"] = "BtnTensDown"
    local tensButtonDown = widget.newButton(options)
    options["x"] = controlsMidX - 100
    options["id"] = "BtnHundredsDown"
    local hundredsButtonDown = widget.newButton(options)
    options["x"] = controlsMidX - 200 
    options["id"] = "BtnThousandsDown"
    local thousandsButtonDown = widget.newButton(options)     
    
    -- labels for player offer
    textOptions["x"] = controlsMidX + 100
    textOptions["y"] = GLOB.middleY + 55
    textOptions["width"] = 100
    textOptions["height"] = 60
    textOptions["font"] = native.systemFont
    textOptions["fontSize"] = 48
    textOptions["text"] = "0"
    onesOutput = display.newText(textOptions)
    onesOutput:setFillColor(0,0,0)
    
    textOptions["x"] = controlsMidX
    tensOutput = display.newText(textOptions)    
    tensOutput:setFillColor(0,0,0)
    
    textOptions["x"] = controlsMidX - 100
    hundredsOutput = display.newText(textOptions)    
    hundredsOutput:setFillColor(0,0,0)
    
    textOptions["x"] = controlsMidX - 200
    thousandsOutput = display.newText(textOptions)    
    thousandsOutput:setFillColor(0,0,0)    
    
    -- percent markup of offer
    textOptions["x"] = GLOB.middleX
    textOptions["y"] = GLOB.middleY + 170
    textOptions["width"] = 200
    textOptions["height"] = 50
    textOptions["fontSize"] = 20
    textOptions["text"] = "% of base price"  
    markupOutput = display.newText(textOptions)    
    markupOutput:setFillColor(0,0,0)     
      
    -- submit button
    options["x"] = GLOB.middleX
    options["y"] = GLOB.middleY + 200
    options["label"] = "Offer"
    options["onRelease"] = self.MakeDeal
    options["onPress"] = nil  -- had to explicitely set to nil or else it would inherit the onPress function from up and down buttons above 
    submitButton = widget.newButton(options)
    
    -- refuse customer
    options["x"] = GLOB.middleX
    options["y"] = GLOB.middleY + 275
    options["label"] = "Refuse"
    options["onRelease"] = self.NoDeal
    options["onPress"] = nil  -- had to explicitely set to nil or else it would inherit the onPress function from up and down buttons above 
    refuseButton = widget.newButton(options)    
    
    -- cash label
    textOptions["text"] = "Gold: "..GLOB.stats["cash"]
    textOptions["x"] = 100
    textOptions["y"] = 20
    textOptions["width"] = 200
    textOptions["height"] = 30
    textOptions["align"] = "left"
    
    local cashLabel = display.newText(textOptions) -- item description
    cashLabel:setFillColor(0,0,0)        
    
    -- add controls to group
    sceneGroup:insert(overlayBackground.bg)
    sceneGroup:insert(onesButtonUp)    
    sceneGroup:insert(tensButtonUp)    
    sceneGroup:insert(hundredsButtonUp)
    sceneGroup:insert(thousandsButtonUp)
    sceneGroup:insert(onesButtonDown)
    sceneGroup:insert(tensButtonDown)
    sceneGroup:insert(hundredsButtonDown)
    sceneGroup:insert(thousandsButtonDown)
    sceneGroup:insert(onesOutput)
    sceneGroup:insert(tensOutput)
    sceneGroup:insert(hundredsOutput)
    sceneGroup:insert(thousandsOutput)
    sceneGroup:insert(submitButton)
    sceneGroup:insert(refuseButton)
    sceneGroup:insert(itemLabel)
    sceneGroup:insert(markupOutput)
    sceneGroup:insert(customerMood)
    sceneGroup:insert(moodLabel)
    sceneGroup:insert(customerResponse)
    sceneGroup:insert(responseLabel)
    sceneGroup:insert(cashLabel)
    
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase    
    
    if phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        scene:SetInitialOffer() -- display an initial offer of 100%
    elseif phase == "did" then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.    
        print("barter scene started")        
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