-- Collection of useful functions that are specific to the game

local GLOB = require "globals"
local utilities = require "functions.Utilities"

local general = {}
local general_mt = { __index = general }	-- metatable
 
-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------
 
-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------
 
function general.new()	-- constructor
local newGeneral = {}
return setmetatable( newGeneral, general_mt )
end
 
------------------------------------------------- 
-- Build the name of an item using pieces from its table
-- Primary + Secondary + Base Name + Mod
function general:BuildName(item)
    local mod = ""
    local primary = ""
    local secondary = ""
    local name = ""

    if item["Primary"] ~= "" then
        primary = item["Primary"].." "
    end

    if item["Secondary"] ~= "" then
        secondary = item["Secondary"].." "
    end

    if item["Mod"] ~= "" then
        mod = " "..item["Mod"]
    end        

    name = primary..secondary..item["Name"]..mod         

    return name
end
-------------------------------------------------

-- if it's a spell, pick a spell name
-- todo: this will need adjusted when restrictions on tiers offered are added or if additional mods are added
function general:ChooseMod(newItem)   
    local spellName = "" -- string of the spell name. only applies to consumable magic scrolls and compendiums
    if newItem["Tag1"] == "Spell" or newItem["Tag2"] == "Spell" then
        if newItem["Name"] == "Scroll of" then    
            local goodName = false

            while not goodName do
                local pickSpell = utilities:RNG(#GLOB.abilities) or 0
                if tonumber(GLOB.abilities[pickSpell]["Tier"]) == 1 then
                    spellName = GLOB.abilities[pickSpell]["Name"]
                    goodName = true
                end
            end    
        elseif newItem["Name"] == "Compendium of" then
            local goodName = false

            while not goodName do
                local pickSpell = utilities:RNG(#GLOB.abilities) or 0
                if tonumber(GLOB.abilities[pickSpell]["Tier"]) == 2 then
                    spellName = GLOB.abilities[pickSpell]["Name"]
                    goodName = true
                end
            end  
        end  
    end 
    
    -- will return empty string if it's not a spell
    return spellName
end
-------------------------------------------------

-- add xp to player's total. increase level and tier if needed
function general:GainExperience(newXP)    
    GLOB.stats["xp"] = GLOB.stats["xp"] + newXP    
    -- see if player leveled up   
    -- todo: make more variance in xp alloted and how much xp needed for each level
    local curLevel = GLOB.stats["level"]
    
    -- check to see if player levels up. if they do check to see if they tier up
    if GLOB.stats["xp"] >= GLOB.levels[curLevel]["xp"] and GLOB.stats["level"] < 20 then
        GLOB.stats["level"] = GLOB.stats["level"] + 1 -- level up
        
        if GLOB.stats["level"] == 6 then
            GLOB.stats["tier"] = 2
        elseif GLOB.stats["level"] == 11 then
            GLOB.stats["tier"] = 3
        elseif GLOB.stats["level"] == 16 then
            GLOB.stats["tier"] = 4
        end
    end
end
------------------------------------------------- 

-- returns flag value representing whether player is picking an item for display case. for use by inventory
function general:GetPickDisplayStatus()
    return GLOB.pickDisplay
end
------------------------------------------------- 
 
-- flip the flag
function general:SetPickDisplayStatus()
    GLOB.pickDisplay = not GLOB.pickDisplay
end
------------------------------------------------- 
 
-- returns the numeric string value of the display case being changed. for use by inventory
function general:GetMerchSlot()
    return GLOB.merchSlot
end
------------------------------------------------- 
function general:GetVendingSlot()
    return GLOB.vendingSlot
end
------------------------------------------------- 

-- determine the base price of a single item and return it
-- todo: adjust this when weapon and armor mods are added to factor in bonus value
function general:CalculateBasePrice(myItem)
    local multiplier = myItem["Multiplier"] or "" -- string to use for index of the type of multiplier (CatID or Tier)
    local calcPrice = 0

    if multiplier ~= "" then
        calcPrice = myItem["BasePrice"] * myItem[multiplier] -- multiply the base price times whatever the multiplier for that item is
    else
        calcPrice = myItem["BasePrice"]
    end        
    
    return calcPrice
end
------------------------------------------------- 
 
return general