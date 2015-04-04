-- An overlay that will show the inventory. can be filtered to show only desired items. 
-- a tabbar is used to allow player to sort items by category
-- events can be attached to clicking items when asked to pick an item from inventory

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
local masterTabBar 
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
local countLabel
local sortValueLabel
local sortNameLabel
local sortTierLabel

local asc = false -- default to sort ascending
local sorting = "Value" -- default to sort by value
local currentID = ""

-- rectangle's origin is its center so use width and height / 2 to start it at point 0,0 on parent group
local rectWidth = 600
local rectHeight = 350
local visibleScroll = 250 -- the visible area of the scrollview
local filter = ""


-- add item labels to the scrollView. all previous items will be removed first with a call to RemoveItems.
-- items to be displayed are filtered by the passed in id and the string var filter. A new table is created of the filtered items,
-- which is then sorted by tier. Additional sort options could be added
function scene:AddItems(id)
    local itemLabel
    local itemPriceLabel
    local item = {}
    local itemName = ""
    
    scene:RemoveItems() -- first clear out any items already there    
    
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
    for k,v in pairs (GLOB.inventory) do
        if filter == "master" then
            if v["MasterCat"] == id or id == "All" then
                selectedCount = selectedCount + 1  
                selectedTable[selectedCount] = v
                          
            end
        elseif filter == "main" then
            if v["MainCat"] == id then
                selectedCount = selectedCount + 1 
                selectedTable[selectedCount] = v
                           
            end            
        elseif filter == "sub" then
            if v["SubCat"] == id then
                selectedCount = selectedCount + 1
                selectedTable[selectedCount] = v
                                 
            end
        end        
    end
    
    -- sort items based on player choice. default setting is by value ascending
    -- todo: could move this to general functions by passing in a table and returning the table. would also need to pass in asc or desc and sort type
    if sorting == "Value" then -- value ascending and descending
        if asc then
            table.sort(selectedTable, function (a,b) return (general:CalculateBasePrice(a) < general:CalculateBasePrice(b)) end)               
        else
            table.sort(selectedTable, function (a,b) return (general:CalculateBasePrice(a) > general:CalculateBasePrice(b)) end)
        end        
    elseif sorting == "A-Z" then -- name ascending and descending
        if asc then
            table.sort(selectedTable, function (a,b) return (general:BuildName(a) < general:BuildName(b)) end)            
        else
            table.sort(selectedTable, function (a,b) return (general:BuildName(a) > general:BuildName(b)) end) 
        end        
    elseif sorting == "Tier" then -- tier ascending and descending
        if asc then
            table.sort(selectedTable, function (a,b) return (a.Tier < b.Tier) end)             
        else
            table.sort(selectedTable, function (a,b) return (a.Tier > b.Tier) end) 
        end            
    end
    
    -- give an option to choose nothing if trying to choose an item for merchandise or vending display
    if general:GetPickDisplayStatus() then
        textOptions["x"] = textWidth / 2 + 50
        textOptions["text"] = "Nothing"        
        itemLabel = display.newText(textOptions) -- item description
        itemLabel:setFillColor(1,1,1) 
        
        scrollArea:insert(itemLabel)
        textOptions["y"] = textOptions["y"] + 25
        selectedCount = selectedCount + 1
            
        function itemLabel:tap(event)
            -- clear out the display spot if player chose nothing
            if general:GetMerchSlot() ~= "" then
                GLOB.merch[general:GetMerchSlot()] = "" -- clear out any item that might be in that slot
            elseif general:GetVendingSlot() ~= "" then
                GLOB.vending[general:GetVendingSlot()] = "" -- clear out any item that might be in that slot                
            end
            
            general:SetPickDisplayStatus()
            composer.gotoScene("screens.Shop")    
        end
        
        itemLabel:addEventListener("tap", itemLabel)
        
        --[[]
        itemLabel:addEventListener("tap", function() 
            -- clear out the display spot if player chose nothing
            if general:GetMerchSlot() ~= "" then
                GLOB.merch[general:GetMerchSlot()] = "" -- clear out any item that might be in that slot
            elseif general:GetVendingSlot() ~= "" then
                GLOB.vending[general:GetVendingSlot()] = "" -- clear out any item that might be in that slot                
            end
            
            --general:SetPickDisplayStatus()
            GLOB.pickDisplay = false
            composer.gotoScene("screens.Shop")
        end)--]]
    end

    local breakFlag = false -- flag used to break loop for items already on display so they aren't listed

    -- count of all items including their quantity for display at bottom of inv window
    local totalCount = 0
    
    for k,v in pairs (selectedTable) do
        itemName = ""
        item = v
        
        local itemPrice = 0
        
        itemPrice = general:CalculateBasePrice(item)           
        itemName = general:BuildName(item)
        
        if item["Qty"] > 1 then -- list quantity if greater than 1
            itemName = itemName.."...x"..item["Qty"]            
        end
        
        totalCount = totalCount + item["Qty"]
        
        -- don't include items already on display. if they have a quantity > 1, decrement listed quantity
        -- this only applies when trying to pick a display item
        if general:GetPickDisplayStatus() then
            local numListings = 0
            
            for l,w in pairs(GLOB.merch) do
                if w["ItemID"] == item["ItemID"] and w["Mod"] == item["Mod"] then
                    if item["Qty"] == 1 then -- if there's only 1 of the item and it's on display, don't show it again'
                        selectedCount = selectedCount - 1
                        totalCount = totalCount - 1
                        breakFlag = true
                        break
                    else
                        numListings = numListings + 1
                        totalCount = totalCount - 1
                        
                        if numListings >= item["Qty"] then
                            selectedCount = selectedCount - 1                            
                            breakFlag = true
                            break
                        end 
                    end                    
                end  
            end
            
            
            if not breakFlag then
                for l,w in pairs(GLOB.vending) do
                    if w["ItemID"] == item["ItemID"] and w["Mod"] == item["Mod"] then
                        if item["Qty"] == 1 then -- if there's only 1 of the item and it's on display, don't show it again'
                            selectedCount = selectedCount - 1
                            totalCount = totalCount - 1
                            breakFlag = true
                            break
                        else
                            numListings = numListings + 1
                            totalCount = totalCount - 1

                            if numListings >= item["Qty"] then
                                selectedCount = selectedCount - 1                                
                                breakFlag = true
                                break
                            end
                        end                    
                    end  
                end 
            end
            
            -- once it's checked for and decremented possible listings, get new listing quantity if applicable'
            --if not breakFlag then
                itemName = general:BuildName(item)

                if item["Qty"] > numListings + 1 then -- this will skip adding the qty if there is only 1 left not displayed
                    itemName = itemName.."...x"..(item["Qty"] - numListings)
                end
            --end            
        end 
        
        -- breakFlag prevents items from appearing multiple times
        if not breakFlag then        
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
            itemLabel:toFront()

            -- if player needs to pick an item from inventory for display, attach listener with item data
            -- when clicked the merch table and shop display text will be updated, then overlay hiden
            if general:GetPickDisplayStatus() then
                itemLabel["item"] = item

                -- this is still fucked. now it won't scroll and just invokes touch began event.
                -- todo may need to just move inventory and crafting to separate screens
                function itemLabel:tap(event) -- important note: I had to make this a touch listener because if I used tap, the tap from shop would propagate and invoke this event causing errors
                    print(event.phase)
                    --if (event.phase == "ended") then
                        local num = ""

                        if general:GetMerchSlot() ~= "" then
                            num = general:GetMerchSlot() 
                            GLOB.merch[num] = self.item
                        elseif general:GetVendingSlot() ~= "" then
                            num = general:GetVendingSlot() 
                            GLOB.vending[num] = self.item
                        end                    

                    general:SetPickDisplayStatus()
                    composer.gotoScene("screens.Shop")
                    --end
                end           

                itemLabel:addEventListener("tap", itemLabel)
            end

            textOptions["y"] = textOptions["y"] + 25
        else
            breakFlag = false
        end        
    end  
    
    -- update the scrollArea and scrollView heights and position
    local newHeight = selectedCount * 25        
    scrollArea.height = selectedCount * 50 -- for some reason i had to double this? less than 50 cuts items off but any value 50 or above shows all without extra space at bottom
    scrollView:scrollTo("top",{time = 25}) -- reset scroll position to top
    scrollView:setScrollHeight(newHeight)
    countLabel.text = "Count: "..totalCount
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
        masterTabBar:setSelected(2)
        mainTabBar1.isVisible = true
        mainTabBar1:setSelected()
    elseif id == "Items" then
        mainTabBar2.isVisible = true  
        mainTabBar2:setSelected()
    elseif id == "Crafting" then
        mainTabBar3.isVisible = true  
        mainTabBar3:setSelected()
    end
    
    currentID = id
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
        
    currentID = id    
    scene:AddItems(id)
end

-- sub cats only need to set the filter and call AddItems
function scene:SetSubFilter(id)
    filter = "sub"    
    
    currentID = id    
    scene:AddItems(id)
end

function scene:SetSort(sortType)
    if sortType == "Value" then
        if sorting == "Value" then
            asc = not asc
            if asc then
                sortValueLabel.text = "Value▲"
            else
                sortValueLabel.text = "Value▼"
            end
            
        else
            if sortValueLabel.text == "Value▲" then
                asc = true
            else
                asc = false
            end
            sorting = "Value"
            
            sortValueLabel:setFillColor(0,0,255/255)
            sortNameLabel:setFillColor(255/255,0,0)
            sortTierLabel:setFillColor(255/255,0,0)
        end
    elseif sortType == "A-Z" then
        if sorting == "A-Z" then
            asc = not asc
            if asc then
                sortNameLabel.text = "A-Z▲"
            else
                sortNameLabel.text = "A-Z▼"
            end 
        else
            if sortNameLabel.text == "A-Z▲" then
                asc = true
            else
                asc = false
            end
            sorting = "A-Z"
            
            sortNameLabel:setFillColor(0,0,255/255)
            sortValueLabel:setFillColor(255/255,0,0)
            sortTierLabel:setFillColor(255/255,0,0)   
        end
    elseif sortType == "Tier" then
        if sorting == "Tier" then
            asc = not asc
            if asc then
                sortTierLabel.text = "Tier▲"
            else
                sortTierLabel.text = "Tier▼"
            end             
        else
            if sortTierLabel.text == "Tier▲" then
                asc = true
            else
                asc = false
            end
            sorting = "Tier"
            
            sortTierLabel:setFillColor(0,0,255/255)
            sortValueLabel:setFillColor(255/255,0,0)
            sortNameLabel:setFillColor(255/255,0,0)   
        end 
    end
    
    scene:AddItems(currentID)
    
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
        },
        {
            id = "Crafting",
            label = "Crafting",
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
            width = 40, 
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
            width = 40, 
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
            width = 40, 
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
            width = 40, 
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
            width = 40, 
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
            width = 40, 
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
            width = 40, 
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
            width = 40, 
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
            width = 40, 
            height = 20,               
            size = 12,
            selected = false,
            onPress = subTabButtonEvent
        },
        {
            id = "Utility",
            label = "Utility",
            labelColor = {default={.9,.9,.9}, over={.5,.5,.5}},
            font = native.systemFont,
            defaultFile = "images/default.png",
            overFile = "images/default.png",
            width = 40, 
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
    
    masterTabBar = widget.newTabBar(masterTabOptions)
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
            --print("scroll view touched")
        elseif phase == "moved" then
            --print("scroll view moved")
        elseif phase == "ended" then
            --print("scroll view released")            
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
    
    local bottomOptions = {
        text = "Exit",
        x = 55,
        y = 340,
        width = 100,
        height = 20,
        font = native.systemFont,
        fontSize = 16,
        align = "left"    
    }    

    local exitLabel = display.newText(bottomOptions) -- item description
    exitLabel:addEventListener("tap", function() 
        if general:GetPickDisplayStatus() then -- if picking an item for display and hitting exit, flip the flag back
            general:SetPickDisplayStatus()
        end
        composer.gotoScene("screens.Shop")
    end)
    exitLabel:setFillColor(255/255,0,0)
    
    bottomOptions["x"] = 200
    countLabel = display.newText(bottomOptions) -- item description
    countLabel:setFillColor(255/255,0,0)
    
    bottomOptions["x"] = 300
    bottomOptions["width"] = 75
    bottomOptions["text"] = "Sort by:"
    local sortLabel = display.newText(bottomOptions) -- item description
    sortLabel:setFillColor(255/255,0,0)    
    
    bottomOptions["x"] = 375
    bottomOptions["text"] = "Value▲"
    sortValueLabel = display.newText(bottomOptions) -- item description
    sortValueLabel:addEventListener("tap", function() 
        scene:SetSort("Value")    
    end)    
    sortValueLabel:setFillColor(0,0,255/255)      
    
    bottomOptions["x"] = 450
    bottomOptions["text"] = "A-Z▲"
    sortNameLabel = display.newText(bottomOptions) -- item description
    sortNameLabel:addEventListener("tap", function() 
        scene:SetSort("A-Z")    
    end)        
    sortNameLabel:setFillColor(255/255,0,0)      
    
    bottomOptions["x"] = 525
    bottomOptions["text"] = "Tier▲"
    sortTierLabel = display.newText(bottomOptions) -- item description
    sortTierLabel:addEventListener("tap", function() 
        scene:SetSort("Tier")    
    end)        
    sortTierLabel:setFillColor(255/255,0,0)          
    

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
    invGroup:insert(countLabel)
    invGroup:insert(sortLabel)
    invGroup:insert(sortValueLabel)
    invGroup:insert(sortNameLabel)
    invGroup:insert(sortTierLabel)
    invGroup:insert(priceLabel)
    invGroup:insert(nameLabel)
    sceneGroup:insert(subBarMask)
    
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    

    if phase == "will" then
        --filter = "master"
        --scene:AddItems("All") -- show all items by default when loading
        
        scene:SetMasterFilter("All")
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


