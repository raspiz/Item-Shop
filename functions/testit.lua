-- Collection of useful functions that can be used anywhere in the program

-- the line below caused a problem because the load function is used in globals.lua
--local GLOB = require "globals"

local testIt = {}
local testIt_mt = { __index = testIt }	-- metatable
 
-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------
 
-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------
 
function testIt.new()	-- constructor
local newTestIt = {}
return setmetatable( newTestIt, testIt_mt )
end
 
-------------------------------------------------
function testIt:MakeLabels(myScene)
    ---------------------
    -- BEGIN LABELS --
    ---------------------
    
    --todo: make the x and y coordinates for labels set at their top left point rather than center

    ------------------
    -- PC LABELS
    ------------------
    local options = {
        label = "Attack",
        emboss = false,
        shape = "roundedRect",
        x = 100, --buttonOrigLoc,
        y = 0,
        width = 100,
        height = 30,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4,
        labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
        font = native.systemFont,
        fontSize = 14             
    }

    attackButton = widget.newButton(options)    
    ---------------------
    -- END LABELS --
    ---------------------    

    -- hide all the affliction images. can comment these all out to make sure they are in correct positions
    --scene:HideAfflictionImages("pc")
    --scene:HideAfflictionImages("pcPet")
    --scene:HideAfflictionImages("npc")
    --scene:HideAfflictionImages("npcPet")
end
-------------------------------------------------
 
return testIt