local json = require "json"
local utilities = require "functions.Utilities"
--local jsonFile = require "items.json"

-- globals
-- add global vars here

local globals = {
    middleX = display.contentCenterX,
    middleY = display.contentCenterY,
    --width = display.contentWidth,
  --  height = display.contentHeight

    width = display.actualContentWidth,
    height = display.actualContentHeight,
    transactionType = "", -- a string set before moving to barter screen. this will determine if buying or selling and behavior in bartering
    pickDisplay = false, -- flag value representing whether player is picking an item for display case. for use by inventory
    vendingSlot = "",
    merchSlot = ""
}

-- keep track of state of shop when it's open. shopIteration values will be used by Shop to determine whether to resume timer when returning
local shopTimer
local shopIsOpen = false
local shopIterations = 0
local currentShopIterations = 0


-- create tables from json files
local jsonStr = utilities:loadFile("data/items.json", system.ResourceDirectory)
globals.items = json.decode(jsonStr)

jsonStr = utilities:loadFile("data/abilities.json", system.ResourceDirectory)
globals.abilities = json.decode(jsonStr)

jsonStr = utilities:loadFile("data/customers.json", system.ResourceDirectory)
globals.customers = json.decode(jsonStr)

jsonStr = utilities:loadFile("data/leveling.json", system.ResourceDirectory)
globals.levels = json.decode(jsonStr)

-- todo: might want to separate loading of tables of shop data and rpg. could make separate glob files
---------------
-- RPG TABLES
---------------
-- table for npcs
jsonStr = utilities:loadFile("data/npcs.json", system.ResourceDirectory)
globals.npcs = json.decode(jsonStr)

-- table for ability names
jsonStr = utilities:loadFile("data/abilities.json", system.ResourceDirectory)
globals.abilities = json.decode(jsonStr)

---------------
-- END RPG TABLES
---------------

-- the first items in this list are indexed by the turns remaining. the last ones are called based on player's offer
globals.mood = {    
    "The customer seems irritated", 
    "The customer seems to be in a hurry",
    "The customer is sizing you up",
    "The customer seems considerate",
    "The customer seems patient",
    "The customer seems relaxed",
    ["sale"] = "The customer has accepted the offer!",
    ["walk"] = "Is that a joke?",
    ["toomuch"] = "You've got to do better than that",
    ["toolittle"] = "Wow, what a bargain!",
    ["goldilocks"] = "That's a good deal",
    ["nodeal"] = "The customer has left angry"
}

-- these tables will be used during the game to keep track of data. this data will be used for saving and loading
-- set with default values for new game
globals.inventory = {}
globals.stats = {["cash"] = 1000, ["level"] = 1, ["xp"] = 0, ["tier"] = 1, ["day"] = 1, ["time"] = 1, ["missedRent"] = 0}
globals.merch = {["1"] = "", ["2"] = "", ["3"] = "", ["4"] = "", ["5"] = "", ["6"] = "", ["7"] = "", ["8"] = ""} -- table of items currently for sale by player
globals.vending = {["1"] = "", ["2"] = "", ["3"] = "", ["4"] = "", ["5"] = "", ["6"] = ""}

-- tables within this table will hold player specific data for saving. it is a json friendly data format that can be converted into a string for saving
-- todo: this table isn't really necessary and could be removed eventually. just make a local table of the needed tables when saving
-- inventory items will have additional columns that are not in items.json. these are mod and qty
globals.saveGame = {
    ["stats"] = {["cash"] = 0, ["level"] = 1, ["xp"] = 0, ["tier"] = 1, ["day"] = 1, ["time"] = 1, ["missedRent"] = 0},
    ["inventory"] = {},
    ["merch"] = {["1"] = "", ["2"] = "", ["3"] = "", ["4"] = "", ["5"] = "", ["6"] = "", ["7"] = "", ["8"] = ""},
    ["vending"] = {["1"] = "", ["2"] = "", ["3"] = "", ["4"] = "", ["5"] = "", ["6"] = ""}
}

globals.font =
{
    regular = native.systemFont,
    bold = native.systemFontBold,	
}

return globals