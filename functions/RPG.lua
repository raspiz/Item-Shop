-- Collection of functions to be used in the RPG part of the game

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
-- ABILITY FUNCTIONS
------------------------------------------------- 
 
--[[ 
-- basic template for functions
function rpg:Shell(attacker, defender)
    local textOutput = ""
    
    
    
    return textOutput
end
--]] 
 
function rpg:Cleave(attacker, defender)
    local textOutput = ""
    local roll = utilities:RNG(3)
    local attack = (attacker["str"] * roll) - defender["def"]

    if attack < 0 then
        attack = 0
    end

    defender["currentHp"] = defender["currentHp"] - attack

    if roll == 3 and attack > 0 then            
        textOutput = attacker["name"].." Cleaves with a mighty swing, doing "..attack.." damage to "..defender["name"].."."
    elseif attack > 0 then
        textOutput = attacker["name"].." Cleaves, doing "..attack.." damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Cleave does "..attack.." damage to "..defender["name"].."."            
    end
    
    return textOutput
end
    
function rpg:Berserk(attacker, defender)
    local textOutput = ""
    local attack = (attacker["str"] * 2) - defender["def"]  

    if attack < 0 then
        attack = 0
    end        

    defender["currentHp"] = defender["currentHp"] - attack 

    if attack > 0 then            
        textOutput = attacker["name"].." goes Berserk, doing "..attack.." damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Berserk does "..attack.." damage to "..defender["name"].."."
    end    
    
    return textOutput
end
    
function rpg:TestOfWill(attacker, defender)
    local textOutput = ""
    local attack = attacker["str"] - defender["will"] 

    if attack < 0 then
        attack = 0
    end        

    defender["currentHp"] = defender["currentHp"] - attack 

    if attack > 0 then            
        textOutput = attacker["name"].." uses a Test of Will, doing "..attack.." damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Test of Will does "..attack.." damage to "..defender["name"].."."
    end  
    
    return textOutput
end 
 
function rpg:Backstab(attacker, defender)
    local textOutput = ""    
    local roll = utilities:RNG(6)
    local attack = 0

    if roll == 6 then
        attack = (attacker["str"] * 3) - defender["def"]
    elseif roll == 1 then -- miss
        attack = 0
    else
        attack = (attacker["str"] * 2) - defender["def"]            
    end

    if attack < 0 then
        attack = 0
    end        

    defender["currentHp"] = defender["currentHp"] - attack

    if roll == 6 then            
        textOutput = attacker["name"].." critically Backstabs  "..defender["name"]..", doing "..attack.." damage."
    elseif roll == 1 then
        textOutput = attacker["name"].."'s Backstab misses the mark, doing "..attack.." damage to "..defender["name"].."."         
    else
        textOutput = attacker["name"].."'s Backstab does "..attack.." damage to "..defender["name"].."."           
    end    
    
    return textOutput
end

function rpg:BeatDown(attacker, defender)
    local textOutput = ""
    
    local roll = utilities:RNG(2)
    local attack = 0

    if roll == 2 then
        attack = (attacker["str"] * 3) - defender["def"]

        if attack < 0 then
            attack = 0
        end  
    end

    defender["currentHp"] = defender["currentHp"] - attack

    if roll == 2 then            
        textOutput = attacker["name"].." uses a Beat Down, doing "..attack.." damage to "..defender["name"].."."
    elseif roll == 1 then
        textOutput = attacker["name"].." tries a Beat Down but misses his mark, doing "..attack.." damage to "..defender["name"].."."       
    end    
    
    return textOutput
end

function rpg:DRUTurnOne(attacker, defender, matchup, move, nextTurnDmgTable)
    local textOutput = ""
    
    -- associate attacker with target and determine damage
    if move == "Delayed Reaction" then
        nextTurnDmgTable[matchup] = (attacker["str"] * 3) - defender["def"]
        attacker["delayedReactionReady"] = true
        textOutput = attacker["name"].." sizes up "..defender["name"].." for a "..move.."."           
    else
        nextTurnDmgTable[matchup] = (attacker["int"] * 3) - defender["will"]
        attacker["unleashReady"] = true
        textOutput = attacker["name"].." prepares to "..move.." on "..defender["name"].."."
    end   

    -- give an arbitrary value to dmg if 0 or below, so that the game shows the text when DRUTurnTwo is activated
    if nextTurnDmgTable[matchup] < 1 then
        nextTurnDmgTable[matchup] = -1
    end     
    
    return textOutput
end

function rpg:Fireball(attacker, defender)
    local textOutput = ""    
    local attack = (attacker["int"] * 2 * defender["fire"]) - defender["will"]

    -- set the damage to 0 if it's less than 0, otherwise round it
    if attack < 0 then
        attack = 0
    else
        attack = utilities:Round(attack)
    end

    defender["currentHp"] = defender["currentHp"] - attack

    if defender["fire"] ~= 0 then            
        textOutput = attacker["name"].." conjures a Fireball, doing "..attack.." fire damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].." conjures a Fireball, but "..defender["name"].." is resistant to fire."
    end      
    
    return textOutput
end

function rpg:Shockwave(attacker, defender)
    local textOutput = ""    
    local roll = utilities:RNG(3)
    local attack = (attacker["int"] * roll * defender["lightning"]) - defender["will"]

    -- set the damage to 0 if it's less than 0, otherwise round it
    if attack < 0 then
        attack = 0
    else
        attack = utilities:Round(attack)
    end

    defender["currentHp"] = defender["currentHp"] - attack

    if roll == 3 and attack > 0 then
        textOutput = attacker["name"].." releases a mighty Shockwave, doing "..attack.." lightning damage to "..defender["name"].."."          
    elseif defender["lightning"] == 0 then  
        textOutput = attacker["name"].." releases a Shockwave, but "..defender["name"].." is resistant to lightning."            
    else
        textOutput = attacker["name"].." releases a Shockwave, doing "..attack.." lightning damage to "..defender["name"].."." 
    end      
    
    return textOutput
end

function rpg:Venom(attacker, defender)
    local textOutput = ""    
    local roll = utilities:RNG(3)
    local attack = roll * defender["poison"] * attacker["level"]   
    attack = utilities:Round(attack)

    -- poison can be reapplied for new damage. this allows it to be used as an attack or to improve the poison damage
    if attack > 0 then
        defender["currentHp"] = defender["currentHp"] - attack
        defender["dotPoison"] = true
        defender["dotPoisonDmg"] = attack            
        textOutput = attacker["name"].." uses Venom on "..defender["name"]..", poisoning them for an ongoing "..attack.." damage."        
    elseif defender["poison"] == 0 then  
        textOutput = attacker["name"].." uses Venom on "..defender["name"]..", but they are resistant to poison."            
    else
        textOutput = attacker["name"].." uses Venom on "..defender["name"]..", but the poison doesn't take hold."   
    end      
    
    return textOutput
end

function rpg:Leech(attacker, defender)
    local textOutput = ""    
    local roll = utilities:RNG(3)
    local attack = roll * defender["disease"] * attacker["level"]
    attack = utilities:Round(attack)

    if defender["disease"] ~= 0 then
        defender["currentHp"] = defender["currentHp"] - attack
        attacker["currentHp"] = attacker["currentHp"] + attack

        if attacker["currentHp"] > attacker["hp"] then
            attacker["currentHp"] = attacker["hp"]
        end

        textOutput = attacker["name"].." Leeches from "..defender["name"]..", inflicting and restoring "..attack.." disease damage."           
    else
        textOutput = attacker["name"].." Leeches, but "..defender["name"].." is resistant to disease."           
    end      
    
    return textOutput
end

function rpg:IceStorm(attacker, defender)
    local textOutput = ""
    
    local roll = utilities:RNG(2)
    local attack = 0

    if roll == 2 then
        attack = (attacker["int"] * 3 * defender["ice"]) - defender["will"]

        -- set the damage to 0 if it's less than 0, otherwise round it
        if attack < 0 then
            attack = 0
        else
            attack = utilities:Round(attack)
        end

        defender["currentHp"] = defender["currentHp"] - attack
    end        

    if defender["ice"] == 0 then 
        textOutput = attacker["name"].." summons an Ice Storm, but "..defender["name"].." is resistant to ice."                        
    elseif roll == 2 then
        textOutput = attacker["name"].." summons an Ice Storm, doing "..attack.." ice damage to "..defender["name"].."."            
    else
        textOutput = attacker["name"].." tries to summon an Ice Storm, but fails."   
    end      
    
    return textOutput
end

function rpg:RockWall(attacker, defender)
    local textOutput = ""    
    local attack = (attacker["int"] + attacker["level"]) * defender["earth"]
    attack = utilities:Round(attack)

    defender["currentHp"] = defender["currentHp"] - attack

    if defender["earth"] ~= 0 then            
        textOutput = attacker["name"].." creates a Rock Wall, doing "..attack.." earth damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].." creates a Rock Wall, but "..defender["name"].." is resistant to earth."
    end      
    
    return textOutput
end

function rpg:Heal(attacker)
    local textOutput = ""    
    local attack = attacker["int"] * 3

    attacker["currentHp"] = attacker["currentHp"] + attack

    if attacker["currentHp"] > attacker["hp"] then
        attacker["currentHp"] = attacker["hp"]
    end

    if attack > 0 then            
        textOutput = attacker["name"].." Heals, restoring "..attack.." health."
    else
        textOutput = attacker["name"].." tries to Heal, but it has no effect."
    end      
    
    return textOutput
end

function rpg:Cleanse(attacker)
    local textOutput = ""
    textOutput = attacker["name"].." Cleanses, removing all negative status effects."
        
    -- remove status effects
    attacker["dotPoison"] = false
    attacker["dotPoisonDmg"] = 0       
    attacker["debuffCramp"] = false
    attacker["tickDebuffCramp"] = 0
    attacker["str"] = attacker["baseStr"]
    attacker["debuffCripple"] = false
    attacker["tickDebuffCripple"] = 0
    attacker["def"] = attacker["baseDef"]
    attacker["debuffMindBreak"] = false
    attacker["tickDebuffMindBreak"] = 0
    attacker["int"] = attacker["baseInt"]
    attacker["debuffDelude"] = false
    attacker["tickDebuffDelude"] = 0
    attacker["will"] = attacker["baseWill"]
    attacker["statusBlind"] = false
    attacker["tickStatusBlind"] = 0
    attacker["statusSilence"] = false
    attacker["tickStatusSilence"] = 0   
    attacker["statusLull"] = false
    return textOutput
end

function rpg:CrampCrippleMindBreakDelude(attacker, defender, affliction)
    local textOutput = ""    
    local stat = ""
    local halfStat = 0

    -- todo consider whether to start the tick count at 0 or 1. at 0 they get 3 full turns of debuff applied to them
    if affliction == "Cramp" then
        stat = "strength"
        halfStat = defender["baseStr"] / 2
        defender["str"] = utilities:Round(halfStat)
        defender["debuffCramp"] = true
        defender["tickDebuffCramp"] = 0               
    elseif affliction == "Cripple" then
        stat = "defense"
        halfStat = defender["baseDef"] / 2
        defender["def"] = utilities:Round(halfStat)
        defender["debuffCripple"] = true
        defender["tickDebuffCripple"] = 0            
    elseif affliction == "Mind Break" then
        stat = "intelligence"
        halfStat = defender["baseInt"] / 2
        defender["int"] = utilities:Round(halfStat)
        defender["debuffMindBreak"] = true
        defender["tickDebuffMindBreak"] = 0              
    else
        stat = "will"
        halfStat = defender["baseWill"] / 2
        defender["will"] = utilities:Round(halfStat)
        defender["debuffDelude"] = true
        defender["tickDebuffDelude"] = 0                 
    end

    textOutput = attacker["name"].." casts "..affliction..", lowering "..defender["name"].."'s "..stat.."."    

    return textOutput
end

function rpg:ForbiddenRitual(attacker, defender)
    local textOutput = ""
    local roll = utilities:RNG(3)
    local attack = 0
        
    if roll ~= 1 then
        attack = defender["currentHp"] / 2
        attack = utilities:Round(attack)

        -- prevent defender from being killed if currentHp is 1
        if defender["currentHp"] == 1 and attack == 1 then
            textOutput = attacker["name"].."'s Forbidden Ritual does no damage to "..defender["name"].."."                            
        else
            defender["currentHp"] = defender["currentHp"] - attack                
            textOutput = attacker["name"].." commits a Forbidden Ritual, doing "..attack.." damage to "..defender["name"].."."              
        end
    else
        textOutput = attacker["name"].." commits a Forbidden Ritual, but it fails."                        
    end  
    
    return textOutput
end

function rpg:Cannibalize(attacker, defender)
    local textOutput = ""
    local roll = utilities:RNG(6)
    local attack = attacker["int"] + roll
    local canniAtk = attack - attacker["will"]
    local canniDef = (attack * 2) - defender["will"]

    -- set the damage to 0 if it's less than 0, otherwise round it
    if canniAtk < 0 then
        canniAtk = 0
    end

    if canniDef < 0 then
        canniDef = 0
    end     

    attacker["currentHp"] = attacker["currentHp"] - canniAtk
    defender["currentHp"] = defender["currentHp"] - canniDef

    textOutput = attacker["name"].." Cannibalizes flesh, suffering "..canniAtk.." damage and inflicting "..canniDef.." damage to "..defender["name"].."."      
    
    return textOutput
end

function rpg:MindOverMatter(attacker, defender)
    local textOutput = ""
    local attack = attacker["int"] - defender["def"] 

    if attack < 0 then
        attack = 0
    end        

    defender["currentHp"] = defender["currentHp"] - attack 

    if attack > 0 then            
        textOutput = attacker["name"].." projects Mind Over Matter, doing "..attack.." damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Mind Over Matter does "..attack.." damage to "..defender["name"].."."
    end          
    
    return textOutput
end

function rpg:Blast(attacker, defender)
    local textOutput = ""
    local roll = utilities:RNG(6)
    local attack = 0

    if roll == 6 then
        attack = (attacker["int"] * 3) - defender["will"]
    elseif roll == 1 then -- miss
        attack = 0
    else
        attack = (attacker["int"] * 2) - defender["will"]            
    end

    if attack < 0 then
        attack = 0
    end        

    defender["currentHp"] = defender["currentHp"] - attack

    if roll == 6 then            
        textOutput = attacker["name"].." critically Blasts  "..defender["name"]..", doing "..attack.." damage."
    elseif roll == 1 then
        textOutput = attacker["name"].."'s Blast misses the mark, doing "..attack.." damage to "..defender["name"].."."           
    else
        textOutput = attacker["name"].."'s Blast does "..attack.." damage to "..defender["name"].."."            
    end    
    
    return textOutput
end

function rpg:FinalCountdownTurnOne(attacker, defender, matchup, nextTurnDmgTable)
    local textOutput = ""
    local roll = utilities:RNG(2)

    if roll == 2 then
        nextTurnDmgTable[matchup] = -1
        attacker["finalCountdownReady"] = true
        attacker["tickFinalCountdown"] = 1 -- could set this to 0 if FC is too OP            
        textOutput = attacker["name"].." begins a Final Countdown, hexing "..defender["name"].."."           
    else
        textOutput = attacker["name"].." tries to hex "..defender["name"].." with Final Countdown, but fails."
    end      
    
    return textOutput
end

function rpg:SilenceLullBlind(attacker, defender, affliction)
    local textOutput = ""
    local roll = utilities:RNG(3)

    if roll ~= 1 then
        if affliction == "Silences" then
            defender["statusSilence"] = true
            defender["tickStatusSilence"] = 0
            textOutput = attacker["name"].." "..affliction.." "..defender["name"]..", preventing them from using magical abilities."              
        elseif affliction == "Blinds" then
            defender["statusBlind"] = true
            defender["tickStatusBlind"] = 0
            textOutput = attacker["name"].." "..affliction.." "..defender["name"]..", preventing them from using physical abilities."
        else -- lull
            defender["statusLull"] = true
            textOutput = attacker["name"].." "..affliction.." "..defender["name"].." to sleep, preventing them from taking action."
        end        
    else
        textOutput = attacker["name"].." "..affliction.." "..defender["name"]..", but they avoid the attempt."
    end    
    
    return textOutput
end

function rpg:MirrorMania(attacker, defender, pet)
    local textOutput = ""
    local roll = utilities:RNG(2)

    if roll == 2 then
        pet["baseHp"] = defender["baseHp"]
        pet["baseStr"] = defender["baseStr"]
        pet["baseDef"] = defender["baseDef"]
        pet["baseAp"] = defender["baseAp"]
        pet["baseInt"] = defender["baseInt"]
        pet["baseWill"] = defender["baseWill"]

        pet["hp"] = pet["baseHp"]
        pet["str"] = pet["baseStr"]
        pet["def"] = pet["baseDef"]
        pet["ap"] = pet["baseAp"]
        pet["int"] = pet["baseInt"]
        pet["will"] = pet["baseWill"]

        -- shouldn't need these but doesn't hurt to have them
        pet["lightning"] = defender["lightning"]
        pet["poison"] = defender["poison"]
        pet["ice"] = defender["ice"]
        pet["disease"] = defender["disease"]
        pet["earth"] = defender["earth"]
        pet["fire"] = defender["fire"]

        pet["abil1"] = defender["abil1"]
        pet["abil2"] = defender["abil2"]
        pet["abil3"] = defender["abil3"]
        pet["abil4"] = defender["abil4"]
        pet["abil5"] = defender["abil5"]
        pet["abil6"] = defender["abil6"]
        pet["abil7"] = defender["abil7"]
        pet["abil8"] = defender["abil8"]
        pet["abil9"] = defender["abil9"]
        pet["abil10"] = defender["abil10"]
        pet["abil11"] = defender["abil11"]
        pet["abil12"] = defender["abil12"]       

        pet["name"] = "Shadow "..defender["name"]            
        pet["level"] = defender["level"]
        pet["currentHp"] = defender["hp"]
        pet["currentAp"] = defender["ap"]               

        -- flag and tick count for caster
        attacker["petMirrorMania"] = true
        attacker["tickPetMirrorMania"] = 1 -- can be changed to 0 if we want to allow extra turn for pet

        if attacker["type"] == "pc" then
            pet["type"] = "pcPet"              
        elseif attacker["type"] == "npc" then
            pet["type"] = "npcPet"               
        end

        textOutput = attacker["name"].." casts Mirror Mania and spawns a shadow of "..defender["name"].."."            
    else
        textOutput = attacker["name"].." casts Mirror Mania, but it fails."           
    end            
    
    return textOutput
end

function rpg:UndeadMinion(attacker, pet)
    local textOutput = ""
    local roll = utilities:RNG(2)   

    if roll == 2 then
        pet["baseHp"] = (attacker["level"] + attacker["level"] - 1) * 3
        pet["baseStr"] = attacker["level"] * 2
        pet["baseDef"] = attacker["level"] * 1
        pet["baseAp"] = attacker["level"] * 1
        pet["baseInt"] = attacker["level"] * 0
        pet["baseWill"] = attacker["level"] * 1

        pet["hp"] = pet["baseHp"]
        pet["str"] = pet["baseStr"]
        pet["def"] = pet["baseDef"]
        pet["ap"] = pet["baseAp"]
        pet["int"] = pet["baseInt"]
        pet["will"] = pet["baseWill"]

        pet["lightning"] = 1
        pet["poison"] = 1
        pet["ice"] = 1
        pet["disease"] = 1
        pet["earth"] = 1
        pet["fire"] = 1

        -- assign abilities based on level
        pet["abil1"] = 1
        pet["abil2"] = 10

        if attacker["level"] >= 3 then
            pet["abil3"] = 5
        else
            pet["abil3"] = nil
        end

        if attacker["level"] >= 5 then
            pet["abil4"] = 29
        else
            pet["abil4"] = nil
        end

        if attacker["level"] >= 7 then
            pet["abil5"] = 9
        else
            pet["abil5"] = nil
        end

        if attacker["level"] >= 9 then
            pet["abil6"] = 16
        else
            pet["abil6"] = nil
        end            

        -- todo set these up if adding higher levels
        pet["abil7"] = nil
        pet["abil8"] = nil
        pet["abil9"] = nil
        pet["abil10"] = nil
        pet["abil11"] = nil
        pet["abil12"] = nil

        pet["name"] = "Undead Minion"            
        pet["level"] = attacker["level"]
        pet["currentHp"] = pet["hp"]
        pet["currentAp"] = pet["ap"] 

        -- todo add image
        if attacker["type"] == "pc" then
            pet["type"] = "pcPet"                
        elseif attacker["type"] == "npc" then
            pet["type"] = "npcPet"               
        end

        textOutput = attacker["name"].." summons an Undead Minion to aid in battle."            
    else
        textOutput = attacker["name"].." tries to summon an Undead Minion, but fails."            
    end      
    
    return textOutput
end

function rpg:AssistedSuicide(attacker, defender)
    local textOutput = ""
    local roll = utilities:RNG(4)
    local attack = 0

    if roll ~= 1 then
        roll = utilities:RNG(6)
        attack = defender["str"] + defender["level"] + roll - defender["def"]

        if attack < 0 then
            attack = 0
        end  

        defender["currentHp"] = defender["currentHp"] - attack

        textOutput = attacker["name"].." performs Assisted Suicide on "..defender["name"].." doing "..attack.." damage."           
    else
        textOutput = attacker["name"].."'s Assisted Suicide misses the mark, doing "..attack.." damage to "..defender["name"].."."
    end    
    
    return textOutput
end

-------------------------------------------------
-- AI FUNCTIONS
------------------------------------------------- 
-- check to see if the ai has learned a passed in ability.
-- return true if they know it, false otherwise 
function rpg:CheckForAbil(attacker, abilIndex)
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
function rpg:CleanseCheck(attacker, defender)
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
function rpg:AI(attacker, defender, petOut)
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
        if rpg:CheckForAbil(attacker, 13) and (attacker["currentHp"] < atkQuartHP) then
            returnValue = 13
        -- cleanse if afflicted and afflictions is debilitating(ex if str is main stat and cramped)
        elseif rpg:CheckForAbil(attacker, 14) and rpg:CleanseCheck(attacker, defender) then
            returnValue = 14
        -- try mirror mania if hp and ap > 75%
        elseif rpg:CheckForAbil(attacker, 26) and (attacker["type"] == "npc") and (not petOut) and (attacker["currentHp"] > atkTQuartHP) and (attacker["currentAp"] > atkTQuartAP) then
            returnValue = 26
        -- try undead minion if hp and ap > 75%    
        elseif rpg:CheckForAbil(attacker, 27) and (attacker["type"] == "npc") and (not petOut) and (attacker["currentHp"] > atkTQuartHP) and (attacker["currentAp"] > atkTQuartAP) then
            returnValue = 27            
        --venom
        elseif rpg:CheckForAbil(attacker, 9) and (defender["poison"] ~= 0) and (defender["currentHp"] > defQuartHP) and (not defender["dotPoison"]) then
            returnValue = 9
        -- lull
        elseif rpg:CheckForAbil(attacker, 28) and (defender["currentHp"] > defQuartHP) and (not defender["statusLull"]) then
            returnValue = 28  
        -- silence
        elseif rpg:CheckForAbil(attacker, 25) and (defender["baseInt"] > defender["baseStr"]) and (defender["currentHp"] > defQuartHP) and (not defender["statusSilence"]) then
            returnValue = 25  
        -- blind
        elseif rpg:CheckForAbil(attacker, 30) and (defender["baseStr"] > defender["baseInt"]) and (defender["currentHp"] > defQuartHP) and (not defender["statusBlind"]) then
            returnValue = 30       
        -- cramp
        elseif rpg:CheckForAbil(attacker, 15) and (defender["baseStr"] > defender["baseInt"]) and (defender["currentHp"] > defQuartHP) and (not defender["debuffCramp"]) then
            returnValue = 15    
        -- cripple
        elseif rpg:CheckForAbil(attacker, 16) and (attacker["baseStr"] > attacker["baseInt"]) and (defender["currentHp"] > defQuartHP) and (not defender["debuffCripple"]) then
            returnValue = 16  
        -- mind break
        elseif rpg:CheckForAbil(attacker, 17) and (defender["baseInt"] > defender["baseStr"]) and (defender["currentHp"] > defQuartHP) and (not defender["debuffMindBreak"]) then
            returnValue = 17     
        -- delude
        elseif rpg:CheckForAbil(attacker, 18) and (attacker["baseInt"] > attacker["baseStr"]) and (defender["currentHp"] > defQuartHP) and (not defender["debuffDelude"]) then
            returnValue = 18  
        -- fireball
        elseif rpg:CheckForAbil(attacker, 7) and (defender["fire"] == 2) then
            returnValue = 7
        -- shockwave
        elseif rpg:CheckForAbil(attacker, 8) and (defender["lightning"] == 2) then
            returnValue = 8   
        -- leech
        elseif rpg:CheckForAbil(attacker, 10) and (defender["disease"] == 2) then
            returnValue = 10    
        -- ice storm
        elseif rpg:CheckForAbil(attacker, 11) and (defender["ice"] == 2) then
            returnValue = 11   
        -- rock wall
        elseif rpg:CheckForAbil(attacker, 12) and (defender["earth"] == 2) then
            returnValue = 12   
        -- forbidden ritual
        elseif rpg:CheckForAbil(attacker, 19) and (defender["currentHp"] > defHalfHP) and (defender["baseStr"] > defender["baseInt"]) then
            returnValue = 19    
        -- delayed reaction
        elseif rpg:CheckForAbil(attacker, 6) and (defender["currentHp"] > defHalfHP) then
            returnValue = 6   
        -- unleash
        elseif rpg:CheckForAbil(attacker, 24) and (defender["currentHp"] > defHalfHP) then
            returnValue = 24                       
        else -- pick a random abiliy unless it doesn't make sense(ex: don't heal if hp is full')
            local abilityPool = {}
            local count = 0
            
            if rpg:CheckForAbil(attacker, 1) then
                count = count + 1
                abilityPool[count] = 1
            end            
            if rpg:CheckForAbil(attacker, 2) then
                count = count + 1
                abilityPool[count] = 2
            end
            if rpg:CheckForAbil(attacker, 3) then
                count = count + 1
                abilityPool[count] = 3
            end
            if rpg:CheckForAbil(attacker, 4) then
                count = count + 1
                abilityPool[count] = 4
            end
            if rpg:CheckForAbil(attacker, 5) then
                count = count + 1
                abilityPool[count] = 5
            end
            if rpg:CheckForAbil(attacker, 6) then
                count = count + 1
                abilityPool[count] = 6 
            end
            if rpg:CheckForAbil(attacker, 7) and (defender["fire"] ~= 0) then
                count = count + 1
                abilityPool[count] = 7 
            end
            if rpg:CheckForAbil(attacker, 8) and (defender["lightning"] ~= 0) then
                count = count + 1
                abilityPool[count] = 8  
            end
            if rpg:CheckForAbil(attacker, 9) and (defender["poison"] ~= 0) and (not defender["dotPoison"]) then
                count = count + 1
                abilityPool[count] = 9
            end
            if rpg:CheckForAbil(attacker, 10) and (defender["disease"] ~= 0) then
                count = count + 1
                abilityPool[count] = 10 
            end
            if rpg:CheckForAbil(attacker, 11) and (defender["ice"] ~= 0) then
                count = count + 1
                abilityPool[count] = 11 
            end
            if rpg:CheckForAbil(attacker, 12) and (defender["earth"] ~= 0) then
                count = count + 1
                abilityPool[count] = 12                     
            end
            if rpg:CheckForAbil(attacker, 13) and (attacker["currentHp"] ~= attacker["hp"]) then
                count = count + 1
                abilityPool[count] = 13                     
            end            
            -- skipping cleanse. it should have already executed if needed
            if rpg:CheckForAbil(attacker, 15) and (not defender["debuffCramp"]) then
                count = count + 1
                abilityPool[count] = 15                     
            end   
            if rpg:CheckForAbil(attacker, 16) and (not defender["debuffCripple"]) then
                count = count + 1
                abilityPool[count] = 16                     
            end           
            if rpg:CheckForAbil(attacker, 17) and (not defender["debuffMindBreak"]) then
                count = count + 1
                abilityPool[count] = 17                    
            end           
            if rpg:CheckForAbil(attacker, 18) and (not defender["debuffDelude"]) then
                count = count + 1
                abilityPool[count] = 18                    
            end                       
            if rpg:CheckForAbil(attacker, 19) then
                count = count + 1
                abilityPool[count] = 19 
            end
            if rpg:CheckForAbil(attacker, 20) then
                count = count + 1
                abilityPool[count] = 20 
            end
            if rpg:CheckForAbil(attacker, 21) then
                count = count + 1
                abilityPool[count] = 21
            end
            if rpg:CheckForAbil(attacker, 22) then
                count = count + 1
                abilityPool[count] = 22
            end
            if rpg:CheckForAbil(attacker, 23) then
                count = count + 1
                abilityPool[count] = 23
            end
            if rpg:CheckForAbil(attacker, 24) then
                count = count + 1
                abilityPool[count] = 24
            end            
            if rpg:CheckForAbil(attacker, 25) and (not defender["statusSilence"]) then
                count = count + 1
                abilityPool[count] = 25 
            end
            if rpg:CheckForAbil(attacker, 26) and (attacker["type"] == "npc") and (not petOut) then
                count = count + 1
                abilityPool[count] = 26 
            end
            if rpg:CheckForAbil(attacker, 27) and (attacker["type"] == "npc") and (not petOut) then
                count = count + 1
                abilityPool[count] = 27 
            end
            if rpg:CheckForAbil(attacker, 28) and (not defender["statusLull"]) then
                count = count + 1
                abilityPool[count] = 28 
            end
            if rpg:CheckForAbil(attacker, 29) then
                count = count + 1
                abilityPool[count] = 29 
            end
            if rpg:CheckForAbil(attacker, 30) and (not defender["statusBlind"]) then
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
 
return rpg