-- a few functions for the rpg part of the game

local utilities = require "functions.Utilities" -- for RNG generation and rounding

local rpg = {}
local rpg_mt = { __index = rpg }	-- metatable
 
-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------
 
-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------
 
function rpg.new()	-- constructor
local newRpg = {}
return setmetatable( newRpg, rpg_mt )
end
 
-------------------------------------------------
-- ABILITY CHECKS
-------------------------------------------------
function rpg:ValorCheck(defender, attack)
    
    if defender["buffValor"] and attack ~= 0 then
        attack = utilities:Round(attack / 2)
    end    
    
    return attack
end

function rpg:ReflectiveShieldCheck(attacker, attack, text)
    local refDamage = 0 
    refDamage = utilities:Round(attack * .25)
    
    attacker["currentHp"] = attacker["currentHp"] - refDamage
    
    text = text.." "..attacker["name"].." takes "..refDamage.." Reflected damage."
    
    return text
end

-- restore an elem res back to its original state.
-- passed in string determines whether setting back an imbue or elem res ability
function rpg:ImbueElemResRestore(attacker, affliction)
    if affliction == "Imbued" then
        if attacker["lightning"] == 2 and attacker["baseLightning"] ~= 2 then
            attacker["lightning"] = attacker["baseLightning"]
        end
        
        if attacker["poison"] == 2 and attacker["basePoison"] ~= 2 then
            attacker["poison"] = attacker["basePoison"]
        end
                
        if attacker["ice"] == 2 and attacker["baseIce"] ~= 2 then
            attacker["ice"] = attacker["baseIce"]
        end
                        
        if attacker["disease"] == 2 and attacker["baseDisease"] ~= 2 then
            attacker["disease"] = attacker["baseDisease"]
        end
                                
        if attacker["earth"] == 2 and attacker["baseEarth"] ~= 2 then
            attacker["earth"] = attacker["baseEarth"]
        end
                                        
        if attacker["fire"] == 2 and attacker["baseFire"] ~= 2 then
            attacker["fire"] = attacker["baseFire"]
        end
    elseif affliction == "Elementally Resistant" then                                      
        if attacker["lightning"] == 0 and attacker["baseLightning"] ~= 0 then
            attacker["lightning"] = attacker["baseLightning"]
        end
        
        if attacker["poison"] == 0 and attacker["basePoison"] ~= 0 then
            attacker["poison"] = attacker["basePoison"]
        end
                
        if attacker["ice"] == 0 and attacker["baseIce"] ~= 0 then
            attacker["ice"] = attacker["baseIce"]
        end
                        
        if attacker["disease"] == 0 and attacker["baseDisease"] ~= 0 then
            attacker["disease"] = attacker["baseDisease"]
        end
                                
        if attacker["earth"] == 0 and attacker["baseEarth"] ~= 0 then
            attacker["earth"] = attacker["baseEarth"]
        end
                                        
        if attacker["fire"] == 0 and attacker["baseFire"] ~= 0 then
            attacker["fire"] = attacker["baseFire"]
        end        
    end
    
end
-------------------------------------------------
 
return rpg