-- Collection of functions to be used in the RPG part of the game

local utilities = require "functions.Utilities" -- for RNG generation and rounding

local ai = {}
local ai_mt = { __index = ai }	-- metatable
 
-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------
 
-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------
 
function ai.new()	-- constructor
local newAi = {}
return setmetatable( newAi, ai_mt )
end
 

-------------------------------------------------
-- AI FUNCTIONS
------------------------------------------------- 
-- check to see if the ai has learned a passed in ability.
-- return true if they know it, false otherwise 
function ai:CheckForAbil(attacker, abilIndex)
    if attacker["abil1"] == abilIndex then
        return true
    elseif attacker["abil2"] == abilIndex then
        return true
    elseif attacker["abil3"] == abilIndex then
        return true
    elseif attacker["abil4"] == abilIndex then
        return true
    elseif attacker["abil5"] == abilIndex then
        return true
    elseif attacker["abil6"] == abilIndex then
        return true
    else
        return false
    end    
end
-------------------------------------------------
-- determine if attacker has any status ailments and whether it is worth curing
-- ex: if cramped and attacker's str is less than their int, 
--    they will ignore it since they are likely a caster and don't care about str as much 
function ai:CleanseCheck(attacker, defender)
    if attacker["dotPoison"] then -- always try to cure poison
        return true
    elseif attacker["statusSilence"] and (attacker["baseInt"] > attacker["baseStr"]) then -- cure silence if int > str
        return true
    elseif attacker["statusBlind"] and (attacker["baseStr"] > attacker["baseInt"]) then -- cure blind if str > int
        return true
    elseif attacker["debuffCramp"] and (attacker["baseStr"] > attacker["baseInt"]) then -- cure cramp if str > int
        return true
    elseif attacker["debuffCripple"] and (defender["baseStr"] > defender["baseInt"]) then -- cure cripple if defender's str > int
        return true
    elseif attacker["debuffMindBreak"] and (attacker["baseInt"] > attacker["baseStr"]) then -- cure mind break if int > str
        return true
    elseif attacker["debuffDelude"] and (defender["baseInt"] > defender["baseStr"]) then -- cure delude if defender's int > str
        return true
    else
        return false -- don't have any afflictions or they aren't severe
    end
end


-------------------------------------------------
-- attacker is npc or npcPet. defender is pc or pcPet
-- logic of the AI:
--  it will try to use an ability if there is ap
--      some abilities will get preference depending on the battle situation such as healing
--      else a random ability will be chosen
--  elseif it will try to meditate to restore ap if hp > 15% and ap = 0 
--  elseif it will try to meditate or attack based on a roll
--  else it will just attack as a last ditch effort
function ai:AI(attacker, defender, petOut)
    local returnValue -- return a string for the action (attack, meditate) or a number for an ability to execute   
    
    local atkQuartHP = utilities:Round(attacker["hp"] * .25) 
    local atkTQuartHP = utilities:Round(attacker["hp"] * .75)
    local atkTQuartAP = utilities:Round(attacker["ap"] * .75)
    local atkHalfHP = utilities:Round(attacker["hp"] * .5) -- didn't use this. left in here in case balance changes needed later
    local defQuartHP = utilities:Round(defender["hp"] * .25) 
    local defHalfHP = utilities:Round(defender["hp"] * .5) 
    
    -- use ability if there is ap
    -- first try to use an ability that will give an edge such as heal, debuff, status effect, pet
    if attacker["currentAp"] > 0 then
        -- try to heal if hp < 25%
        if ai:CheckForAbil(attacker, 13) and (attacker["currentHp"] < atkQuartHP) then
            returnValue = 13
        -- cleanse if afflicted and afflictions is debilitating(ex if str is main stat and cramped)
        elseif ai:CheckForAbil(attacker, 14) and ai:CleanseCheck(attacker, defender) then
            returnValue = 14
        -- try mirror mania if hp and ap > 75%
        elseif ai:CheckForAbil(attacker, 26) and (attacker["type"] == "npc") and (not petOut) and (attacker["currentHp"] > atkTQuartHP) and (attacker["currentAp"] > atkTQuartAP) then
            returnValue = 26
        -- try undead minion if hp and ap > 75%    
        elseif ai:CheckForAbil(attacker, 27) and (attacker["type"] == "npc") and (not petOut) and (attacker["currentHp"] > atkTQuartHP) and (attacker["currentAp"] > atkTQuartAP) then
            returnValue = 27            
        --venom
        elseif ai:CheckForAbil(attacker, 9) and (defender["poison"] ~= 0) and (defender["currentHp"] > defQuartHP) and (not defender["dotPoison"]) then
            returnValue = 9
        -- lull
        elseif ai:CheckForAbil(attacker, 28) and (defender["currentHp"] > defQuartHP) and (not defender["statusLull"]) then
            returnValue = 28  
        -- silence
        elseif ai:CheckForAbil(attacker, 25) and (defender["baseInt"] > defender["baseStr"]) and (defender["currentHp"] > defQuartHP) and (not defender["statusSilence"]) then
            returnValue = 25  
        -- blind
        elseif ai:CheckForAbil(attacker, 30) and (defender["baseStr"] > defender["baseInt"]) and (defender["currentHp"] > defQuartHP) and (not defender["statusBlind"]) then
            returnValue = 30       
        -- cramp
        elseif ai:CheckForAbil(attacker, 15) and (defender["baseStr"] > defender["baseInt"]) and (defender["currentHp"] > defQuartHP) and (not defender["debuffCramp"]) then
            returnValue = 15    
        -- cripple
        elseif ai:CheckForAbil(attacker, 16) and (attacker["baseStr"] > attacker["baseInt"]) and (defender["currentHp"] > defQuartHP) and (not defender["debuffCripple"]) then
            returnValue = 16  
        -- mind break
        elseif ai:CheckForAbil(attacker, 17) and (defender["baseInt"] > defender["baseStr"]) and (defender["currentHp"] > defQuartHP) and (not defender["debuffMindBreak"]) then
            returnValue = 17     
        -- delude
        elseif ai:CheckForAbil(attacker, 18) and (attacker["baseInt"] > attacker["baseStr"]) and (defender["currentHp"] > defQuartHP) and (not defender["debuffDelude"]) then
            returnValue = 18  
        -- fireball
        elseif ai:CheckForAbil(attacker, 7) and (defender["fire"] == 2) then
            returnValue = 7
        -- shockwave
        elseif ai:CheckForAbil(attacker, 8) and (defender["lightning"] == 2) then
            returnValue = 8   
        -- leech
        elseif ai:CheckForAbil(attacker, 10) and (defender["disease"] == 2) then
            returnValue = 10    
        -- ice storm
        elseif ai:CheckForAbil(attacker, 11) and (defender["ice"] == 2) then
            returnValue = 11   
        -- rock wall
        elseif ai:CheckForAbil(attacker, 12) and (defender["earth"] == 2) then
            returnValue = 12   
        -- forbidden ritual
        elseif ai:CheckForAbil(attacker, 19) and (defender["currentHp"] > defHalfHP) and (defender["baseStr"] > defender["baseInt"]) then
            returnValue = 19    
        -- delayed reaction
        elseif ai:CheckForAbil(attacker, 6) and (defender["currentHp"] > defHalfHP) then
            returnValue = 6   
        -- unleash
        elseif ai:CheckForAbil(attacker, 24) and (defender["currentHp"] > defHalfHP) then
            returnValue = 24                       
        else -- pick a random abiliy unless it doesn't make sense(ex: don't heal if hp is full')
            local abilityPool = {}
            local count = 0
            
            if ai:CheckForAbil(attacker, 1) then
                count = count + 1
                abilityPool[count] = 1
            end            
            if ai:CheckForAbil(attacker, 2) then
                count = count + 1
                abilityPool[count] = 2
            end
            if ai:CheckForAbil(attacker, 3) then
                count = count + 1
                abilityPool[count] = 3
            end
            if ai:CheckForAbil(attacker, 4) then
                count = count + 1
                abilityPool[count] = 4
            end
            if ai:CheckForAbil(attacker, 5) then
                count = count + 1
                abilityPool[count] = 5
            end
            if ai:CheckForAbil(attacker, 6) then
                count = count + 1
                abilityPool[count] = 6 
            end
            if ai:CheckForAbil(attacker, 7) and (defender["fire"] ~= 0) then
                count = count + 1
                abilityPool[count] = 7 
            end
            if ai:CheckForAbil(attacker, 8) and (defender["lightning"] ~= 0) then
                count = count + 1
                abilityPool[count] = 8  
            end
            if ai:CheckForAbil(attacker, 9) and (defender["poison"] ~= 0) and (not defender["dotPoison"]) then
                count = count + 1
                abilityPool[count] = 9
            end
            if ai:CheckForAbil(attacker, 10) and (defender["disease"] ~= 0) then
                count = count + 1
                abilityPool[count] = 10 
            end
            if ai:CheckForAbil(attacker, 11) and (defender["ice"] ~= 0) then
                count = count + 1
                abilityPool[count] = 11 
            end
            if ai:CheckForAbil(attacker, 12) and (defender["earth"] ~= 0) then
                count = count + 1
                abilityPool[count] = 12                     
            end
            if ai:CheckForAbil(attacker, 13) and (attacker["currentHp"] ~= attacker["hp"]) then
                count = count + 1
                abilityPool[count] = 13                     
            end            
            -- skipping cleanse. it should have already executed if needed
            if ai:CheckForAbil(attacker, 15) and (not defender["debuffCramp"]) then
                count = count + 1
                abilityPool[count] = 15                     
            end   
            if ai:CheckForAbil(attacker, 16) and (not defender["debuffCripple"]) then
                count = count + 1
                abilityPool[count] = 16                     
            end           
            if ai:CheckForAbil(attacker, 17) and (not defender["debuffMindBreak"]) then
                count = count + 1
                abilityPool[count] = 17                    
            end           
            if ai:CheckForAbil(attacker, 18) and (not defender["debuffDelude"]) then
                count = count + 1
                abilityPool[count] = 18                    
            end                       
            if ai:CheckForAbil(attacker, 19) then
                count = count + 1
                abilityPool[count] = 19 
            end
            if ai:CheckForAbil(attacker, 20) then
                count = count + 1
                abilityPool[count] = 20 
            end
            if ai:CheckForAbil(attacker, 21) then
                count = count + 1
                abilityPool[count] = 21
            end
            if ai:CheckForAbil(attacker, 22) then
                count = count + 1
                abilityPool[count] = 22
            end
            if ai:CheckForAbil(attacker, 23) then
                count = count + 1
                abilityPool[count] = 23
            end
            if ai:CheckForAbil(attacker, 24) then
                count = count + 1
                abilityPool[count] = 24
            end            
            if ai:CheckForAbil(attacker, 25) and (not defender["statusSilence"]) then
                count = count + 1
                abilityPool[count] = 25 
            end
            if ai:CheckForAbil(attacker, 26) and (attacker["type"] == "npc") and (not petOut) then
                count = count + 1
                abilityPool[count] = 26 
            end
            if ai:CheckForAbil(attacker, 27) and (attacker["type"] == "npc") and (not petOut) then
                count = count + 1
                abilityPool[count] = 27 
            end
            if ai:CheckForAbil(attacker, 28) and (not defender["statusLull"]) then
                count = count + 1
                abilityPool[count] = 28 
            end
            if ai:CheckForAbil(attacker, 29) then
                count = count + 1
                abilityPool[count] = 29 
            end
            if ai:CheckForAbil(attacker, 30) and (not defender["statusBlind"]) then
                count = count + 1
                abilityPool[count] = 30
            end            
            
            -- if any abilities were added to the pool, choose randomly from them and execute
            if count > 0 then
                local roll = utilities:RNG(count)
                returnValue = abilityPool[roll]
            else -- else just attack
                returnValue = "atk"
            end            
        end
    -- meditate if hp > 15% and out of ap    
    elseif attacker["currentAp"] == 0 and (attacker["currentHp"] > (attacker["hp"] * .15)) then
        returnValue = "med"    
    -- if out of ap but have low health, roll to either attack or meditate
    elseif attacker["currentAp"] == 0 then
        local roll = utilities:RNG(2)
        
        if roll == 2 then
            returnValue = "med"
        else
            returnValue = "atk"
        end   
    else -- else attack
        returnValue = "atk"        
    end
    
    return returnValue
end 

-------------------------------------------------
 
return ai