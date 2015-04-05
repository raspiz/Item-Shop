-- An overlay that will show the craftable items
-- items will only appear if the player is the correct tier and items needed to craft are available in inventory
-- most of this code was copied from Inventory.lua screen, so changes to one need to reflect the other

local composer = require "composer"
local GLOB = require "globals"
local widget = require "widget"
local background = require "controls.Background"
local utilities = require "functions.Utilities"
local general = require "functions.General"
local scene = composer.newScene()

composer.removeScene( "screens.Shop")

-- forward declaration of controls that need accessed outside of scene:create
local scrollView
local subBarMask
local mainTabBar1 
local mainTabBar2
local mainTabBar3
local subTabBar1
local subTabBar2
local subTabBar3
local subTabBar4
local subTabBar5
local subTabBar6
local subTabBar7
local subTabBar8
local subTabBar9
local subTabBar10
local subTabBar11
local subTabBar12
local subTabBar13
local scrollArea

-- rectangle's origin is its center so use width and height / 2 to start it at point 0,0 on parent group
local rectWidth = 600
local rectHeight = 350
local visibleScroll = 250 -- the visible area of the scrollview
local filter = ""

local craftables = {}
local templates = {}

-- make a table of whether the player has a crafting component in the inventory
function scene:TrackResources()  
    for k,v in pairs(GLOB.inventory) do
        if v["MasterCat"] == "Crafting" then        
            if v["Name"] == "Bolt of Wool" then
                craftables["Wool"] = true
            elseif v["Name"] == "Bolt of Hemp" then
                craftables["Hemp"] = true
            elseif v["Name"] == "Bolt of Cotton" then
                craftables["Cotton"] = true
            elseif v["Name"] == "Bolt of Silk" then
                craftables["Silk"] = true
            elseif v["Name"] == "Rabbit Hide" then
                craftables["Rabbit Hide"] = true
            elseif v["Name"] == "Stag Hide" then
                craftables["Stag Hide"] = true
            elseif v["Name"] == "Troll Hide" then
                craftables["Troll Hide"] = true
            elseif v["Name"] == "Dragon Hide" then
                craftables["Dragon Hide"] = true
            elseif v["Name"] == "Pine Log" then
                craftables["Pine"] = true
            elseif v["Name"] == "Cherry Log" then
                craftables["Cherry"] = true
            elseif v["Name"] == "Oak Log" then
                craftables["Oak"] = true
            elseif v["Name"] == "Snakewood Log" then
                craftables["Snakewood"] = true
            elseif v["Name"] == "Raw Emerald" then
                craftables["Emerald"] = true
            elseif v["Name"] == "Raw Sapphire" then
                craftables["Sapphire"] = true
            elseif v["Name"] == "Raw Ruby" then
                craftables["Ruby"] = true
            elseif v["Name"] == "Raw Diamond" then
                craftables["Diamond"] = true
            elseif v["Name"] == "Basalt Block" then
                craftables["Basalt"] = true
            elseif v["Name"] == "Flint Block" then
                craftables["Flint"] = true 
            elseif v["Name"] == "Chert Block" then
                craftables["Chert"] = true
            elseif v["Name"] == "Obsidian Block" then
                craftables["Obsidian"] = true
            elseif v["Name"] == "Copper Ingot" then
                craftables["Copper"] = true
            elseif v["Name"] == "Bronze Ingot" then
                craftables["Bronze"] = true
            elseif v["Name"] == "Iron Ingot" then
                craftables["Iron"] = true
            elseif v["Name"] == "Meteor Ingot" then
                craftables["Meteor"] = true
            elseif v["Name"] == "Fish Meat" then
                craftables["Fish"] = true
            elseif v["Name"] == "Poultry Meat" then
                craftables["Poultry"] = true
            elseif v["Name"] == "Pork Meat" then
                craftables["Pork"] = true
            elseif v["Name"] == "Bear Meat" then
                craftables["Bear"] = true
            elseif v["Name"] == "Bunch of Radishes" then
                craftables["Radish"] = true
            elseif v["Name"] == "Bunch of Celery" then
                craftables["Celery"] = true
            elseif v["Name"] == "Bunch of Tomatoes" then
                craftables["Tomato"] = true
            elseif v["Name"] == "Bunch of Carrots" then
                craftables["Carrot"] = true
            elseif v["Name"] == "Bundle of Apples" then
                craftables["Apple"] = true
            elseif v["Name"] == "Bundle of Oranges" then
                craftables["Orange"] = true
            elseif v["Name"] == "Bundle of Strawberries" then
                craftables["Strawberry"] = true
            elseif v["Name"] == "Bundle of Starfruit" then
                craftables["Starfruit"] = true
            elseif v["Name"] == "Vessel of Sheep Milk" then
                craftables["Sheep Milk"] = true
            elseif v["Name"] == "Vessel of Camel Milk" then
                craftables["Camel Milk"] = true    
            elseif v["Name"] == "Vessel of Goat Milk" then
                craftables["Goat Milk"] = true        
            elseif v["Name"] == "Vessel of Auroch Milk" then
                craftables["Auroch Milk"] = true       
            elseif v["Name"] == "Cube of Corn Sugar" then
                craftables["Corn Sugar"] = true       
            elseif v["Name"] == "Cube of Sweet Potato Sugar" then
                craftables["Sweet Potato Sugar"] = true       
            elseif v["Name"] == "Cube of Cane Sugar" then
                craftables["Cane Sugar"] = true       
            elseif v["Name"] == "Cube of Beet Sugar" then
                craftables["Beet Sugar"] = true       
            elseif v["Name"] == "Sack of Rye Grain" then
                craftables["Rye"] = true       
            elseif v["Name"] == "Sack of Rice Grain" then
                craftables["Rice"] = true       
            elseif v["Name"] == "Sack of Oat Grain" then
                craftables["Oat"] = true       
            elseif v["Name"] == "Sack of Wheat Grain" then
                craftables["Wheat"] = true       
            elseif v["Name"] == "Diluted Oil of Vitriol" then
                craftables["Abrasive"] = true       
            elseif v["Name"] == "Impure Oil of Vitriol" then
                craftables["Caustic"] = true       
            elseif v["Name"] == "Pure Oil of Vitriol" then
                craftables["Corrosive"] = true       
            elseif v["Name"] == "Concentrated Oil of Vitriol" then
                craftables["Trenchant"] = true       
            elseif v["Name"] == "Earthenware Decanter" then
                craftables["Earthenware"] = true       
            elseif v["Name"] == "Stoneware Decanter" then
                craftables["Stoneware"] = true   
            elseif v["Name"] == "Porcelain Decanter" then
                craftables["Porcelain"] = true 
            elseif v["Name"] == "Bone China Decanter" then
                craftables["Bone China"] = true 
            elseif v["Name"] == "Mixed Nitrum Flammans" then
                craftables["Ebullient"] = true 
            elseif v["Name"] == "Thinned Nitrum Flammans" then
                craftables["Effusive"] = true 
            elseif v["Name"] == "Strong Nitrum Flammans" then
                craftables["Exuberant"] = true 
            elseif v["Name"] == "Uncut Nitrum Flammans" then
                craftables["Frenzied"] = true 
            elseif v["Name"] == "Old Spirit Essence" then
                craftables["Corrupted"] = true 
            elseif v["Name"] == "Antiquated Spirit Essence" then
                craftables["Depraved"] = true 
            elseif v["Name"] == "Ancient Spirit Essence" then
                craftables["Perverted"] = true 
            elseif v["Name"] == "Primordial Spirit Essence" then
                craftables["Degenerate"] = true 
            elseif v["Name"] == "Flawed Magical Jewel" then
                craftables["Exalted"] = true 
            elseif v["Name"] == "Cloudy Magical Jewel" then
                craftables["Consecrated"] = true 
            elseif v["Name"] == "Clear Magical Jewel" then
                craftables["Sacred"] = true 
            elseif v["Name"] == "Flawless Magical Jewel" then
                craftables["Divine"] = true 
            elseif v["Name"] == "Worn Inscription" then
                craftables["Sublime"] = true 
            elseif v["Name"] == "Marred Inscription" then
                craftables["Mystical"] = true 
            elseif v["Name"] == "Legible Inscription" then
                craftables["Celestial"] = true 
            elseif v["Name"] == "Embellished Inscription" then
                craftables["Miraculous"] = true 
            elseif v["MainCat"] == "Template" then
                templates[v["Name"]] = true
            end
        end
    end    
end

-- add item labels to the scrollView. all previous items will be removed first with a call to RemoveItems.
-- items to be displayed are filtered by the passed in id and the string var filter. A new table is created of the filtered items,
-- which is then sorted by tier. Additional sort options could be added
function scene:AddItems(id)
    local itemLabel
    local itemPriceLabel
    local item = {}
    local itemName = ""
    
    scene:RemoveItems() -- first clear out any items already there    
    
    
    craftables = {}
    templates = {}
    scene:TrackResources()
    
    -- make the scroll area. this is a child of scrollView, individual items will be children of this
    scrollArea = display.newContainer(rectWidth * 2, 0) -- had to double rectWidth here for some reason?
    scrollView:insert(scrollArea) 
    
    local textWidth = 600
    local textHeight = 20
    local textOptions = {
        text = "",
        x = textWidth / 2 + 5,
        y = textHeight / 2,
        width = textWidth,
        height = textHeight,
        font = native.systemFont,
        fontSize = 16,
        align = "left"    
    }    

    -- create a table of just the items we're interested in
    -- the string flag filter determines which level of the item hierarchy we're interested in (master, main, sub).
    -- id is a string value which matches the specific category name in the json file
    local selectedTable = {}
    local selectedCount = 0
    for k,v in pairs (GLOB.items) do        
        local pri = v["Primary"]
        local sec = v["Secondary"]
        local hasTemplate = true        
        
        if filter == "master" then
            if v["MasterCat"] == id or id == "All" then                
                if v["MasterCat"] == "Equipment" then
                    local tempName = "Tier "..v["Tier"].." "..v["Name"].." Template"
                    if templates[tempName] then
                        hasTemplate = true
                    else
                        hasTemplate = false
                    end                    
                end                
                
                -- only add if it's craftable, primary and secondary item is in inv, and tier is at or below player tier
                if v["Primary"] ~= "" and craftables[pri] and craftables[sec] and hasTemplate and v["Tier"] <= GLOB.stats["tier"]then
                    selectedTable[selectedCount] = v
                    selectedCount = selectedCount + 1   
                end     
            end
        elseif filter == "main" then
            if v["MainCat"] == id then                
                if v["MasterCat"] == "Equipment" then
                    local tempName = "Tier "..v["Tier"].." "..v["Name"].." Template"
                    if templates[tempName] then
                        hasTemplate = true
                    else
                        hasTemplate = false
                    end                    
                end                
                
                -- only add if it's craftable, primary and secondary item is in inv, and tier is at or below player tier
                if v["Primary"] ~= "" and craftables[pri] and craftables[sec] and hasTemplate and v["Tier"] <= GLOB.stats["tier"]then
                    selectedTable[selectedCount] = v
                    selectedCount = selectedCount + 1   
                end
            end            
        elseif filter == "sub" then
            if v["SubCat"] == id then                
                -- for equipment, make sure there is a template for it. if not do not add to list
                if v["MasterCat"] == "Equipment" then
                    local tempName = "Tier "..v["Tier"].." "..v["Name"].." Template"
                    if templates[tempName] then
                        hasTemplate = true
                    else
                        hasTemplate = false
                    end                    
                end                
                
                -- only add if it's craftable, primary and secondary item is in inv, and tier is at or below player tier
                if v["Primary"] ~= "" and craftables[pri] and craftables[sec] and hasTemplate and v["Tier"] <= GLOB.stats["tier"]then
                    selectedTable[selectedCount] = v
                    selectedCount = selectedCount + 1   
                end
               
            end
        end        
    end
    
    -- todo: fix up sort options. ideally by price but would need to figure up calculated total value for each one first. for now just sort by tier
    table.sort(selectedTable, function (a,b) return (general:CalculateBasePrice(a) > general:CalculateBasePrice(b)) end)

    for k,v in pairs (selectedTable) do
        itemName = ""
        local primary = ""
        local secondary = ""
        item = v
        
        local itemPrice = 0
        
        itemPrice = general:CalculateBasePrice(item)           
        --itemName = general:BuildName(item)
        
        if item["Primary"] ~= "" then
            primary = item["Primary"].." "
        end

        if item["Secondary"] ~= "" then
            secondary = item["Secondary"].." "
        end    

        itemName = primary..secondary..item["Name"]
                    
        textOptions["x"] = textWidth / 2 + 5
        textOptions["text"] = itemPrice
        itemPriceLabel = display.newText(textOptions) -- item description
        itemPriceLabel:setFillColor(1,1,1)         
        scrollArea:insert(itemPriceLabel)

        textOptions["x"] = textWidth / 2 + 50
        textOptions["text"] = itemName        
        itemLabel = display.newText(textOptions) -- item description
        itemLabel:setFillColor(1,1,1)

        scrollArea:insert(itemLabel)

        -- add tap event that will create the item and remove the resources used to make it
        itemLabel["item"] = item

        function itemLabel:tap(event)
            -- remove crafting components used in creation
            scene:RemoveResource(self.item["Primary"])
            scene:RemoveResource(self.item["Secondary"])
            
            --variable in ms for crafting delay
            local craftingDelay = 2700
            
            --"crafting..." text
            textOptions["x"] = 850
            textOptions["text"] = "Crafting..."
            textOptions["fontSize"] = 16
            textOptions["y"] = 150
            textOptions["height"] = 20
            craftingLabel = display.newText(textOptions)
            craftingLabel:setFillColor(0,0,0)
            --label of item that is being crafted, placed under "crafting..."
            textOptions["text"] = self.item["Primary"].." "..self.item["Secondary"].." "..self.item["Name"].." "..(self.item["Mod"] or "")
            textOptions["y"] = 180
            textOptions["width"] = 300
            textOptions["x"] = 770 - textOptions["width"]/2
            craftingItemLabel = display.newText(textOptions)
            craftingItemLabel:setFillColor(0,0,0)
            --empty label to display the result of crafting
            textOptions["text"] = ""
            textOptions["x"] = 850
            textOptions["width"] = 600
            textOptions["y"] = 210
            resultLabel = display.newText(textOptions)
            local result
            
            --function to roll success/failure of crafting             
            local function displayResult()
                local num = utilities:RNG(100,1)
                if(num  + GLOB.stats["level"] > 50) then
                resultLabel["text"] = "SUCCESS"
                result = "success"
                resultLabel:setFillColor(0,1,0)
                else
                resultLabel["text"] = "FAILURE"
                result = "failure"
                resultLabel:setFillColor(1,0,0)  
                end
            end
            
            --half of delay spent "crafting..." other half seeing success/failure, so display result after half the delay
            timer.performWithDelay(craftingDelay/2, displayResult)       


            -- remove template if it's equipment
            if self.item["MasterCat"] == "Equipment" then
                local tempName = "Tier "..self.item["Tier"].." "..self.item["Name"].." Template"

                -- remove item from merch if on display
                for k,v in pairs (GLOB.merch) do    
                    if v["Name"] == tempName then
                        GLOB.merch[k] = ""
                        break
                    end        
                end   

                -- remove item from inventory or decrement qty
                for k,v in pairs(GLOB.inventory) do
                    if v["Name"] == tempName then            
                        if v["Qty"] > 1 then
                            v["Qty"] = v["Qty"] - 1
                            break
                        else
                            GLOB.inventory[k] = nil
                            break
                        end
                    end
                end 
            end
            
            local function generateItem()
                -- add a mod
                self.item["Mod"] = general:ChooseMod(self.item)

                -- see if the item exists already
                local incQty = false

                -- see if the item exists in inventory already. must match ItemID and Mod. if so increase Qty and break loop
                for k,v in pairs(GLOB.inventory) do
                    if v["ItemID"] == self.item["ItemID"] and v["Mod"] == self.item["Mod"] then
                        v["Qty"] = v["Qty"] + 1
                        incQty = true
                        break
                    end                    
                end

                -- if it's a new item just add to inv
                if not incQty then
                    self.item["Qty"] = 1
                    GLOB.inventory[#GLOB.inventory + 1] = self.item -- add the item to the end of the player inventory table
                end 
            end
                
                if(result == "success")then
                    generateItem()
                end
            
            --refresh the item list after crafting an item, remove crafting progress/result labels
            local function DisplayCrafting()
               scene:AddItems(id)
               craftingLabel:removeSelf()
               resultLabel:removeSelf()
               craftingItemLabel:removeSelf()
            end
            
            --delay item list refreshing
          timer.performWithDelay(craftingDelay, DisplayCrafting)
           
        end           

        itemLabel:addEventListener("tap", itemLabel)


        textOptions["y"] = textOptions["y"] + 25
      
    end  
    
    -- update the scrollArea and scrollView heights and position
    local newHeight = selectedCount * 25
    scrollView:setScrollHeight(newHeight)
    scrollArea.height = selectedCount * 50 -- for some reason i had to double this?
    scrollView:scrollTo("top",{time = 25}) -- reset scroll position to top
end

function scene:RemoveResource(name)
    local removeName = ""
    
    if name == "Wool" then
        removeName = "Bolt of Wool"
    elseif name == "Hemp" then
        removeName = "Bolt of Hemp"
    elseif name == "Cotton" then
        removeName = "Bolt of Cotton"
    elseif name == "Silk" then
        removeName = "Bolt of Silk"
    elseif name == "Rabbit Hide" then
        removeName = "Rabbit Hide"
    elseif name == "Stag Hide" then
        removeName = "Stag Hide"
    elseif name == "Troll Hide" then
        removeName = "Troll Hide"
    elseif name == "Dragon Hide" then
        removeName = "Dragon Hide"
    elseif name == "Pine" then
        removeName = "Pine Log"
    elseif name == "Cherry" then
        removeName = "Cherry Log"
    elseif name == "Oak" then
        removeName = "Oak Log"
    elseif name == "Snakewood" then
        removeName = "Snakewood Log"
    elseif name == "Emerald" then
        removeName = "Raw Emerald"
    elseif name == "Sapphire" then
        removeName = "Raw Sapphire"
    elseif name == "Ruby" then
        removeName = "Raw Ruby"
    elseif name == "Diamond" then
        removeName = "Raw Diamond"
    elseif name == "Basalt" then
        removeName = "Basalt Block"
    elseif name == "Flint" then
        removeName = "Flint Block"
    elseif name == "Chert" then
        removeName = "Chert Block"
    elseif name == "Obsidian" then
        removeName = "Obsidian Block"
    elseif name == "Copper" then
        removeName = "Copper Ingot"
    elseif name == "Bronze" then
        removeName = "Bronze Ingot"
    elseif name == "Iron" then
        removeName = "Iron Ingot"
    elseif name == "Meteor" then
        removeName = "Meteor Ingot"
    elseif name == "Fish" then
        removeName = "Fish Meat"
    elseif name == "Poultry" then
        removeName = "Poultry Meat"
    elseif name == "Pork" then
        removeName = "Pork Meat"
    elseif name == "Bear" then
        removeName = "Bear Meat"
    elseif name == "Radish" then
        removeName = "Bunch of Radishes"
    elseif name == "Celery" then
        removeName = "Bunch of Celery"
    elseif name == "Tomato" then
        removeName = "Bunch of Tomatoes"
    elseif name == "Carrot" then
        removeName = "Bunch of Carrots"
    elseif name == "Apple" then
        removeName = "Bundle of Apples"
    elseif name == "Orange" then
        removeName = "Bundle of Oranges"
    elseif name == "Strawberry" then
        removeName = "Bundle of Strawberries"
    elseif name == "Starfruit" then
        removeName = "Bundle of Starfruit"
    elseif name == "Sheep Milk" then
        removeName = "Vessel of Sheep Milk"
    elseif name == "Camel Milk" then
        removeName = "Vessel of Camel Milk"
    elseif name == "Goat Milk" then
        removeName = "Vessel of Goat Milk"
    elseif name == "Auroch Milk" then
        removeName = "Vessel of Auroch Milk"    
    elseif name == "Corn Sugar" then
        removeName = "Cube of Corn Sugar" 
    elseif name == "Sweet Potato Sugar" then
        removeName = "Cube of Sweet Potato Sugar"
    elseif name == "Cane Sugar" then
        removeName = "Cube of Cane Sugar"
    elseif name == "Beet Sugar" then
        removeName = "Cube of Beet Sugar"   
    elseif name == "Rye" then
        removeName = "Sack of Rye Grain"    
    elseif name == "Rice" then
        removeName = "Sack of Rice Grain"   
    elseif name == "Oat" then
        removeName = "Sack of Oat Grain"  
    elseif name == "Wheat" then
        removeName = "Sack of Wheat Grain"
    elseif name == "Abrasive" then
        removeName = "Diluted Oil of Vitriol"  
    elseif name == "Caustic" then
        removeName = "Impure Oil of Vitriol"  
    elseif name == "Corrosive" then
        removeName = "Pure Oil of Vitriol" 
    elseif name == "Trenchant" then
        removeName = "Concentrated Oil of Vitriol"     
    elseif name == "Earthenware" then
        removeName = "Earthenware Decanter"  
    elseif name == "Stoneware" then
        removeName = "Stoneware Decanter" 
    elseif name == "Porcelain" then
        removeName = "Porcelain Decanter"
    elseif name == "Bone China" then
        removeName = "Bone China Decanter"
    elseif name == "Ebullient" then
        removeName = "Mixed Nitrum Flammans"
    elseif name == "Effusive" then
        removeName = "Thinned Nitrum Flammans"
    elseif name == "Exuberant" then
        removeName = "Strong Nitrum Flammans"
    elseif name == "Frenzied" then
        removeName = "Uncut Nitrum Flammans"
    elseif name == "Corrupted" then
        removeName = "Old Spirit Essence"
    elseif name == "Depraved" then
        removeName = "Antiquated Spirit Essence"
    elseif name == "Perverted" then
        removeName = "Ancient Spirit Essence"
    elseif name == "Degenerate" then
        removeName = "Primordial Spirit Essence"
    elseif name == "Exalted" then
        removeName = "Flawed Magical Jewel"
    elseif name == "Consecrated" then
        removeName = "Cloudy Magical Jewel"
    elseif name == "Sacred" then
        removeName = "Clear Magical Jewel"
    elseif name == "Divine" then
        removeName = "Flawless Magical Jewel"
    elseif name == "Sublime" then
        removeName = "Worn Inscription"
    elseif name == "Mystical" then
        removeName = "Marred Inscription"
    elseif name == "Celestial" then
        removeName = "Legible Inscription"
    elseif name == "Miraculous" then
        removeName = "Embellished Inscription"
    end    
    
    -- remove item from merch if on display
    for k,v in pairs (GLOB.merch) do    
        if v["Name"] == removeName then
            GLOB.merch[k] = ""
            break
        end        
    end    
    
    -- remove item from inventory
    for k,v in pairs(GLOB.inventory) do
        if v["Name"] == removeName then            
            if v["Qty"] > 1 then
                v["Qty"] = v["Qty"] - 1
                break
            else
                GLOB.inventory[k] = nil
                break
            end
        end
    end
end

-- remove all items from scroll view
function scene:RemoveItems()
    if scrollArea then -- make sure the container exists        
        scrollArea:removeSelf() -- all child items and their listeners will also be removed
        scrollArea = nil    
    end
end

-- the root categories and all items. if all is selected, no main cat tab bar is shown
function scene:SetMasterFilter(id)
    filter = "master"      
        
    mainTabBar1.isVisible = false
    mainTabBar2.isVisible = false
    mainTabBar3.isVisible = false
    subBarMask:toFront()

    if id == "Equipment" then
        mainTabBar1.isVisible = true
        mainTabBar1:setSelected()
    elseif id == "Items" then
        mainTabBar2.isVisible = true  
        mainTabBar2:setSelected()
    elseif id == "Crafting" then
        mainTabBar3.isVisible = true  
        mainTabBar3:setSelected()
    end
    
    scene:AddItems(id)
end

-- main categories. their sub categories' tab bar is shown
function scene:SetMainFilter(id)
    filter = "main"  
    
    if id == "Weapons" then
        subTabBar1:toFront()
        subTabBar1:setSelected()
    elseif id == "Body Armor" then
        subTabBar2:toFront()
        subTabBar2:setSelected()
    elseif id == "Head Armor" then
        subTabBar3:toFront()
        subTabBar3:setSelected()
    elseif id == "Feet Armor" then
        subTabBar4:toFront()
        subTabBar4:setSelected()
    elseif id == "Accessory Armor" then
        subTabBar5:toFront()
        subTabBar5:setSelected()
    elseif id == "Off Hand Item" then
        subTabBar6:toFront()
        subTabBar6:setSelected()
    elseif id == "Goods" then
        subTabBar7:toFront()
        subTabBar7:setSelected()
    elseif id == "Treasure" then
        subTabBar8:toFront()
        subTabBar8:setSelected()
    elseif id == "Foods" then
        subTabBar9:toFront()
        subTabBar9:setSelected()
    elseif id == "Resources" then
        subTabBar10:toFront()
        subTabBar10:setSelected()
    elseif id == "Ingredients" then
        subTabBar11:toFront()
        subTabBar11:setSelected()
    elseif id == "Alchemy" then
        subTabBar12:toFront()
        subTabBar12:setSelected()
    elseif id == "Template" then
        subTabBar13:toFront()
        subTabBar13:setSelected()        
    end        
    
    scene:AddItems(id)
end

-- sub cats only need to set the filter and call AddItems
function scene:SetSubFilter(id)
    filter = "sub"    
    
    scene:AddItems(id)
end

function scene:create(event)
    local sceneGroup = self.view

    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.    
    
    -- semi transparent background to block out the underlying parent screen
    local overlayBackground = background.new(0,0, 1600,960)
    overlayBackground.bg:setFillColor(0,0,0,0.8)
   
    local invGroup = display.newGroup()
    invGroup.x = 175
    invGroup.y = 50    

    -- this rectange will be the main background of inventory
    local invBG = display.newRect(rectWidth / 2, rectHeight / 2, rectWidth, rectHeight)
    invBG:setFillColor(.5,.5,.5)

    ------------------
    -- TAB BAR STUFF
    ------------------ 

    ------------------
    -- TAB BAR LISTENERS
    ------------------ 

    local function masterTabButtonEvent(event)
        print(event.target._id)       
        scene:SetMasterFilter(event.target._id) 
    end
    
    local function mainTabButtonEvent(event)
        print(event.target._id)              
        scene:SetMainFilter(event.target._id) 
    end    
    
    local function subTabButtonEvent(event)
        print(event.target._id)              
        scene:SetSubFilter(event.target._id) 
    end         
    
    --------------------
    -- MASTER TAB BUTTONS
    --------------------
    
    local masterTabButtons = {
        {
            id = "All",
            label = "All",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 16,
            selected = true,
            onPress = masterTabButtonEvent
        },
        {
            id = "Equipment",
            label = "Equipment",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont, 
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 16,
            selected = false,
            onPress = masterTabButtonEvent -- or onEvent
        },
        {
            id = "Items",
            label = "Items",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 16,
            selected = false,
            onPress = masterTabButtonEvent -- or onEvent
        }     
    }
    
    --------------------
    -- MAIN TAB BUTTONS
    --------------------    
    
    local mainTabButtons1 = {
        {
            id = "Weapons",
            label = "Weapons",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 14,
            selected = false,
            onPress = mainTabButtonEvent
        },
        {
            id = "Body Armor",
            label = "Body Armor",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,   
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 14,
            selected = false,
            onPress = mainTabButtonEvent
        },
        {
            id = "Head Armor",
            label = "Head Armor",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 14,
            selected = false,
            onPress = mainTabButtonEvent
        },
        {
            id = "Feet Armor",
            label = "Feet Armor",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 14,
            selected = false,
            onPress = mainTabButtonEvent
        },
        {
            id = "Accessory Armor",
            label = "Accessories",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 14,
            selected = false,
            onPress = mainTabButtonEvent
        },
        {
            id = "Off Hand Item",
            label = "Off Hand",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 14,
            selected = false,
            onPress = mainTabButtonEvent
        }        
    }   
    
    local mainTabButtons2 = {
        {
            id = "Goods",
            label = "Goods",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 14,
            selected = false,
            onPress = mainTabButtonEvent
        },
        {
            id = "Treasure",
            label = "Treasure",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont, 
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 14,
            selected = false,
            onPress = mainTabButtonEvent
        },
        {
            id = "Foods",
            label = "Foods",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 14,
            selected = false,
            onPress = mainTabButtonEvent
        }       
    }        
    
    local mainTabButtons3 = {
        {
            id = "Resources",
            label = "Resources",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 14,
            selected = false,
            onPress = mainTabButtonEvent
        },
        {
            id = "Ingredients",
            label = "Ingredients",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,  
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 14,
            selected = false,
            onPress = mainTabButtonEvent
        },
        {
            id = "Alchemy",
            label = "Alchemy",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 14,
            selected = false,
            onPress = mainTabButtonEvent
        },
        {
            id = "Template",
            label = "Template",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 14,
            selected = false,
            onPress = mainTabButtonEvent
        }     
    }         
    
    --------------------
    -- SUB TAB BUTTONS
    --------------------    
    
    local subTabButtons1 = {
        {
            id = "Sword",
            label = "Sword",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Club",
            label = "Club",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont, 
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Fist Wraps",
            label = "Fist Wraps",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Staff",
            label = "Staff",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Dagger",
            label = "Dagger",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Whip",
            label = "Whip",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        }        
    }       

    local subTabButtons2 = {
        {
            id = "Robe",
            label = "Robe",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Coat",
            label = "Coat",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,   
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Mail",
            label = "Mail",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Chain Mail",
            label = "Chain Mail",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Tunic",
            label = "Tunic",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Cuirass",
            label = "Cuirass",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        }        
    }    
    
    local subTabButtons3 = {
        {
            id = "Kettle Helm",
            label = "Kettle Helm",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Rawhide Cap",
            label = "Rawhide Cap",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont, 
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Barbute",
            label = "Barbute",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Headband",
            label = "Headband",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Crown",
            label = "Crown",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Hood",
            label = "Hood",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        }        
    }         
    
    local subTabButtons4 = {
        {
            id = "Slippers",
            label = "Slippers",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Kneehigh Boots",
            label = "Kneehigh Boots",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,   
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Clogs",
            label = "Clogs",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Plated Boots",
            label = "Plated Boots",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Buckled Boots",
            label = "Buckled Boots",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Sandals",
            label = "Sandals",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        }        
    }         

    local subTabButtons5 = {
        {
            id = "Skull Ring",
            label = "Skull Ring",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Stone Armband",
            label = "Stone Armband",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,   
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Shiny Gorget",
            label = "Shiny Gorget",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Hypnotic Necklace",
            label = "Necklace",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Dazzling Earring",
            label = "Dazzling Earring",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Foppish Bracelet",
            label = "Bracelet",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        }        
    }     
    
    local subTabButtons6 = {
        {
            id = "Holy Idol",
            label = "Holy Idol",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Evil Idol",
            label = "Evil Idol",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,  
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Earthly Idol",
            label = "Earthly Idol",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Lute",
            label = "Lute",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Shield",
            label = "Shield",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Tome",
            label = "Tome",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        }        
    }        
    
    local subTabButtons7 = {
        {
            id = "Vial of Acid",
            label = "Vial",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Quikfire",
            label = "Quikfire",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,  
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Shining Force",
            label = "S. Force",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Blighted Vigor",
            label = "B. Vigor",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Minion Summon",
            label = "Minion",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Demon Summon",
            label = "Demon",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Phoenix Summon",
            label = "Phoenix",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Scroll of",
            label = "Scroll",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Compendium of",
            label = "Compendium",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        }        
    }       
    
    local subTabButtons8 = {
        {
            id = "Ornate Vase",
            label = "Ornate Vase",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Wooden Trinket",
            label = "Wooden Trinket",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,   
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Bone Carving",
            label = "Bone Carving",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Gaudy Chalice",
            label = "Gaudy Chalice",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Goddess Statue",
            label = "Goddess Statue",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Animistic Figurine",
            label = "Animistic Figurine",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        }        
    }        
    
    local subTabButtons9 = {
        {
            id = "Snack",
            label = "Snack",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Meal",
            label = "Meal",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont, 
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Treat",
            label = "Treat",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Dessert",
            label = "Dessert",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Smoothie",
            label = "Smoothie",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Soda",
            label = "Soda",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        }        
    }     
    
    local subTabButtons10 = {
        {
            id = "Textile",
            label = "Textile",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Leather",
            label = "Leather",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,   
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Wood",
            label = "Wood",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Gem",
            label = "Gem",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Stone",
            label = "Stone",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Metal",
            label = "Metal",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        }        
    }           
    
    local subTabButtons11 = {
        {
            id = "Meat",
            label = "Meat",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Veggie",
            label = "Veggie",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,  
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Fruit",
            label = "Fruit",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Cream",
            label = "Cream",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Sugar",
            label = "Sugar",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Grain",
            label = "Grain",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        }        
    }         
    
    local subTabButtons12 = {
        {
            id = "Oil of Vitriol",
            label = "Oil of Vitriol",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Decanter",
            label = "Decanter",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,   
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Nitrum Flammans",
            label = "Nitrum Flammans",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Spirit Essence",
            label = "Spirit Essence",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Magical Jewel",
            label = "Magical Jewel",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Inscription",
            label = "Inscription",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        }        
    }          
    
    local subTabButtons13 = {
        {
            id = "Tier 1 Template",
            label = "Tier 1 Template",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Tier 2 Template",
            label = "Tier 2 Template",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,  
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Tier 3 Template",
            label = "Tier 3 Template",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Tier 4 Template",
            label = "Tier 4 Template",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 50,
            height = 20,            
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        }      
    }           

    --------------------
    -- TAB OPTIONS
    --------------------

    local masterTabOptions = {
        id = "tabbar",
        left = 175,
        top = 50,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = masterTabButtons
    }
    
    local mainTabOptions1 = {
        id = "tabbar",
        left = 175,
        top = 70,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = mainTabButtons1
    }    
    
    local mainTabOptions2 = {
        id = "tabbar",
        left = 175,
        top = 70,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = mainTabButtons2
    }       
    
    local mainTabOptions3 = {
        id = "tabbar",
        left = 175,
        top = 70,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = mainTabButtons3
    }         
    
    local subTabOptions1 = {
        id = "tabbar",
        left = 175,
        top = 90,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = subTabButtons1
    }       
    
    local subTabOptions2 = {
        id = "tabbar",
        left = 175,
        top = 90,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = subTabButtons2
    }    
    
    local subTabOptions3 = {
        id = "tabbar",
        left = 175,
        top = 90,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = subTabButtons3
    }       
    
    local subTabOptions4 = {
        id = "tabbar",
        left = 175,
        top = 90,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = subTabButtons4
    }       
    
    local subTabOptions5 = {
        id = "tabbar",
        left = 175,
        top = 90,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = subTabButtons5
    }       
    
    local subTabOptions6 = {
        id = "tabbar",
        left = 175,
        top = 90,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = subTabButtons6
    }       
    
    local subTabOptions7 = {
        id = "tabbar",
        left = 175,
        top = 90,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 30,
        tabSelectedFrameHeight = 10,        
        buttons = subTabButtons7
    }       
    
    local subTabOptions8 = {
        id = "tabbar",
        left = 175,
        top = 90,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = subTabButtons8
    }       
    
    local subTabOptions9 = {
        id = "tabbar",
        left = 175,
        top = 90,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = subTabButtons9
    }       
    
    local subTabOptions10 = {
        id = "tabbar",
        left = 175,
        top = 90,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = subTabButtons10
    }       
    
    local subTabOptions11 = {
        id = "tabbar",
        left = 175,
        top = 90,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = subTabButtons11
    }       
    
    local subTabOptions12 = {
        id = "tabbar",
        left = 175,
        top = 90,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = subTabButtons12
    }       
    
    local subTabOptions13 = {
        id = "tabbar",
        left = 175,
        top = 90,
        width = 600,
        height = 20,
        backgroundFile = "images/default.png",
        tabSelectedLeftFile = "images/default.png",
        tabSelectedRightFile = "images/default.png",
        tabSelectedMiddleFile = "images/default.png",
        tabSelectedFrameWidth = 40,
        tabSelectedFrameHeight = 10,        
        buttons = subTabButtons13
    }           
    
    --------------------
    -- CREATE TAB BARS
    --------------------    
    
    local masterTabBar = widget.newTabBar(masterTabOptions)
    mainTabBar1 = widget.newTabBar(mainTabOptions1)
    mainTabBar2 = widget.newTabBar(mainTabOptions2)
    mainTabBar3 = widget.newTabBar(mainTabOptions3)
    subTabBar1 = widget.newTabBar(subTabOptions1)
    subTabBar2 = widget.newTabBar(subTabOptions2)
    subTabBar3 = widget.newTabBar(subTabOptions3)
    subTabBar4 = widget.newTabBar(subTabOptions4)
    subTabBar5 = widget.newTabBar(subTabOptions5)
    subTabBar6 = widget.newTabBar(subTabOptions6)
    subTabBar7 = widget.newTabBar(subTabOptions7)
    subTabBar8 = widget.newTabBar(subTabOptions8)
    subTabBar9 = widget.newTabBar(subTabOptions9)
    subTabBar10 = widget.newTabBar(subTabOptions10)
    subTabBar11 = widget.newTabBar(subTabOptions11)
    subTabBar12 = widget.newTabBar(subTabOptions12)
    subTabBar13 = widget.newTabBar(subTabOptions13)
    mainTabBar1.isVisible = false
    mainTabBar2.isVisible = false
    mainTabBar3.isVisible = false
    
    -- this will go over sub cats when they aren't needed to be shown'
    subBarMask = display.newRect(rectWidth / 2 + 175, 100, rectWidth, 20)
    subBarMask:setFillColor(.5,.5,.5)
    subBarMask:addEventListener("touch", function() return true end) -- i put a listener here to absorb touches so that the hidden tab bars are not pressed      
    
    ------------------
    -- END TAB BAR STUFF
    ------------------     

    ------------------
    -- SCROLL VIEW STUFF
    ------------------    
    local function scrollListener(event)
        local phase = event.phase
        if phase == "began" then 
            print("scroll view touched")
        elseif phase == "moved" then
            print("scroll view moved")
        elseif phase == "ended" then
            print("scroll view released")            
        end
        
        if event.limitReached then
            if event.direction == "up" then                
                print("reached top")
            elseif event.direction == "down" then                
                print("reached bottom")
            elseif event.direction == "left" then                
                print("reached left")
            elseif event.direction == "right" then                
                print("reached right")                
            end
        end
        
        return true
    end
    
    local newScrollHeight = 0
    
    scrollView = widget.newScrollView
    {
        left = 0,
        top = 80,
        width = 600,
        height = visibleScroll,
        scrollWidth = rectWidth,
        scrollHeight = newScrollHeight, -- adjust this
        horizontalScrollDisabled = true,
        isBounceEnabled = false,
        listener = scrollListener,
        hideScrollBar = false,
        backgroundColor = {.5,.5,.5},
        friction = 0
    }
    
    -- might not need this rect but it's not hurting anything
    local scrollBG = display.newRect(rectWidth / 2, visibleScroll / 2, rectWidth, rectHeight)
    scrollBG:setFillColor(.5,.5,.5)
    scrollView:insert(scrollBG)   

    ------------------
    -- END SCROLL VIEW STUFF
    ------------------  

    ------------------
    -- BOTTOM BUTTONS
    ------------------  
    
    local exitOptions = {
        text = "Exit",
        x = 55,
        y = 340,
        width = 100,
        height = 20,
        font = native.systemFont,
        fontSize = 16,
        align = "left"    
    }    

    local exitLabel = display.newText(exitOptions) -- item description
    exitLabel:addEventListener("tap", function() 
        if general:GetPickDisplayStatus() then -- if picking an item for display and hitting exit, flip the flag back
            general:SetPickDisplayStatus()
        end
        composer.gotoScene("screens.Shop")
    end)
    exitLabel:setFillColor(255/255,0,0)

    ------------------
    -- END BOTTOM BUTTONS
    ------------------  

    ------------------
    -- ITEM DESCRIPTORS
    ------------------  
    local descriptionOptions = {
        text = "Value",
        x = 30,
        y = 70,
        width = 50,
        height = 20,
        font = native.systemFont,
        fontSize = 16,
        align = "left"    
    }    
    
    local priceLabel = display.newText(descriptionOptions)
    
    
    descriptionOptions["x"] = 75
    descriptionOptions["width"] = 50
    descriptionOptions["text"] = "Name"
    local nameLabel = display.newText(descriptionOptions) -- item description
    
    
    
    nameLabel:setFillColor(1,1,1)

    ------------------
    -- END ITEM DESCRIPTORS
    ------------------ 
    
    sceneGroup:insert(overlayBackground.bg)
    sceneGroup:insert(invGroup) -- add inv background to main group
    invGroup:insert(invBG) -- add group to inv background. additional background controls are added to the invGroup
    sceneGroup:insert(masterTabBar) -- for some reason this will not work correctly if attached to invGroup, so i attached it to the sceneGroup
    sceneGroup:insert(mainTabBar1)
    sceneGroup:insert(mainTabBar2)
    sceneGroup:insert(mainTabBar3)
    sceneGroup:insert(subTabBar1)
    sceneGroup:insert(subTabBar2)
    sceneGroup:insert(subTabBar3)
    sceneGroup:insert(subTabBar4)
    sceneGroup:insert(subTabBar5)
    sceneGroup:insert(subTabBar6)
    sceneGroup:insert(subTabBar7)
    sceneGroup:insert(subTabBar8)
    sceneGroup:insert(subTabBar9)
    sceneGroup:insert(subTabBar10)
    sceneGroup:insert(subTabBar11)
    sceneGroup:insert(subTabBar12)
    sceneGroup:insert(subTabBar13)
    invGroup:insert(scrollView)
    invGroup:insert(exitLabel)
    invGroup:insert(priceLabel)
    invGroup:insert(nameLabel)
    sceneGroup:insert(subBarMask)
    
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase    

    if phase == "will" then
        filter = "master"
        scene:AddItems("All") -- show all items by default when loading
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


