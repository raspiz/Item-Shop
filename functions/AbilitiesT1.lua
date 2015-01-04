-- Collection of functions to be used in the RPG part of the game

local utilities = require "functions.Utilities" -- for RNG generation and rounding
local rpg = require "functions.RPG"

local abilitiesT1 = {}
local abilitiesT1_mt = { __index = abilitiesT1 }	-- metatable
 
-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------
 
-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------
 
function abilitiesT1.new()	-- constructor
local newAbilitiesT1 = {}
return setmetatable( newAbilitiesT1, abilitiesT1_mt )
end
 
------------------------------------------------- 
-- ABILITY FUNCTIONS
------------------------------------------------- 
 
--[[ 
-- basic template for functions
function abilitiesT1:Shell(attacker, defender)
    local textOutput = ""
    
    
    
    return textOutput
end
--]] 
 
function abilitiesT1:Cleave(attacker, defender)
    local textOutput = ""
    local roll = utilities:RNG(3)
    local attack = (attacker["str"] * roll) - defender["def"]
    attack = rpg:ValorCheck(defender, attack)

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
    
    return textOutput, attack
end
    
function abilitiesT1:Berserk(attacker, defender)
    local textOutput = ""
    local attack = (attacker["str"] * 2) - defender["def"]  
    attack = rpg:ValorCheck(defender, attack)

    if attack < 0 then
        attack = 0
    end        

    defender["currentHp"] = defender["currentHp"] - attack 

    if attack > 0 then            
        textOutput = attacker["name"].." goes Berserk, doing "..attack.." damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Berserk does "..attack.." damage to "..defender["name"].."."
    end    
    
    return textOutput, attack
end
    
function abilitiesT1:TestOfWill(attacker, defender)
    local textOutput = ""
    local attack = attacker["str"] - defender["will"] 
    attack = rpg:ValorCheck(defender, attack)

    if attack < 0 then
        attack = 0
    end        

    defender["currentHp"] = defender["currentHp"] - attack 

    if attack > 0 then            
        textOutput = attacker["name"].." uses a Test of Will, doing "..attack.." damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Test of Will does "..attack.." damage to "..defender["name"].."."
    end  
    
    return textOutput, attack
end 
 
function abilitiesT1:Backstab(attacker, defender)
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
    
    attack = rpg:ValorCheck(defender, attack)

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
    
    return textOutput, attack
end

function abilitiesT1:BeatDown(attacker, defender)
    local textOutput = ""
    
    local roll = utilities:RNG(2)
    local attack = 0

    if roll == 2 then
        attack = (attacker["str"] * 3) - defender["def"]
        attack = rpg:ValorCheck(defender, attack)
        
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
    
    return textOutput, attack
end

function abilitiesT1:DRUTurnOne(attacker, defender, matchup, move, nextTurnDmgTable)
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

function abilitiesT1:Fireball(attacker, defender)
    local textOutput = ""    
    local attack = (attacker["int"] * 2 * defender["fire"]) - defender["will"]
    

    -- set the damage to 0 if it's less than 0, otherwise round it
    if attack < 0 then
        attack = 0
    else
        attack = utilities:Round(attack)
        attack = rpg:ValorCheck(defender, attack)
    end

    defender["currentHp"] = defender["currentHp"] - attack

    if defender["fire"] ~= 0 then            
        textOutput = attacker["name"].." conjures a Fireball, doing "..attack.." fire damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].." conjures a Fireball, but "..defender["name"].." is resistant to fire."
    end      
    
    return textOutput, attack
end

function abilitiesT1:Shockwave(attacker, defender)
    local textOutput = ""    
    local roll = utilities:RNG(3)
    local attack = (attacker["int"] * roll * defender["lightning"]) - defender["will"]

    -- set the damage to 0 if it's less than 0, otherwise round it
    if attack < 0 then
        attack = 0
    else
        attack = utilities:Round(attack)
        attack = rpg:ValorCheck(defender, attack)
    end

    defender["currentHp"] = defender["currentHp"] - attack

    if roll == 3 and attack > 0 then
        textOutput = attacker["name"].." releases a mighty Shockwave, doing "..attack.." lightning damage to "..defender["name"].."."          
    elseif defender["lightning"] == 0 then  
        textOutput = attacker["name"].." releases a Shockwave, but "..defender["name"].." is resistant to lightning."            
    else
        textOutput = attacker["name"].." releases a Shockwave, doing "..attack.." lightning damage to "..defender["name"].."." 
    end      
    
    return textOutput, attack
end

function abilitiesT1:Venom(attacker, defender)
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

function abilitiesT1:Leech(attacker, defender)
    local textOutput = ""    
    local roll = utilities:RNG(3)
    local attack = roll * defender["disease"] * attacker["level"]
    attack = utilities:Round(attack)

    if defender["disease"] ~= 0 then
        
        if defender["currentHp"] < attack then
            attack = defender["currentHp"]
        end            
        
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

function abilitiesT1:IceStorm(attacker, defender)
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
            attack = rpg:ValorCheck(defender, attack)
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
    
    return textOutput, attack
end

function abilitiesT1:RockWall(attacker, defender)
    local textOutput = ""    
    local attack = (attacker["int"] + attacker["level"]) * defender["earth"]
    attack = utilities:Round(attack)
    attack = rpg:ValorCheck(defender, attack)

    defender["currentHp"] = defender["currentHp"] - attack

    if defender["earth"] ~= 0 then            
        textOutput = attacker["name"].." creates a Rock Wall, doing "..attack.." earth damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].." creates a Rock Wall, but "..defender["name"].." is resistant to earth."
    end      
    
    return textOutput, attack
end

function abilitiesT1:Heal(attacker)
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

function abilitiesT1:Cleanse(attacker)
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
    attacker["debuffImbue"] = false
    attacker["tickDebuffImbue"] = 0
    rpg:ImbueElemResRestore(attacker, "Imbued") 
    attacker["statusHamstring"] = false
    attacker["tickStatusHamstring"] = 0
    attacker["dotHemorrhage"] = false
    attacker["dotHemorrhageDmg"] = 0    
    attacker["tickDotHemorrhage"] = 0
    attacker["dotIncinerate"] = false
    attacker["dotIncinerateDmg"] = 0        
    attacker["tickDotIncinerate"] = 0
    
    return textOutput
end

function abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, affliction)
    local textOutput = ""    
    local stat = ""
    local halfStat = 0

    -- todo consider whether to start the tick count at 0 or 1. at 0 they get 3 full turns of debuff applied to them
    if affliction == "Cramp" then
        stat = "strength"
        if defender["baseStr"] > 0 then
            halfStat = defender["baseStr"] / 2
        else
            halfStat = 0
        end
        defender["str"] = utilities:Round(halfStat)
        defender["debuffCramp"] = true
        defender["tickDebuffCramp"] = 0               
    elseif affliction == "Cripple" then
        stat = "defense"
        if defender["baseDef"] > 0 then
            halfStat = defender["baseDef"] / 2
        else
            halfStat = 0
        end
        defender["def"] = utilities:Round(halfStat)
        defender["debuffCripple"] = true
        defender["tickDebuffCripple"] = 0            
    elseif affliction == "Mind Break" then
        stat = "intelligence"
        if defender["baseInt"] > 0 then
            halfStat = defender["baseInt"] / 2
        else
            halfStat = 0
        end
        defender["int"] = utilities:Round(halfStat)
        defender["debuffMindBreak"] = true
        defender["tickDebuffMindBreak"] = 1              
    else
        stat = "will"
        if defender["baseWill"] > 0 then
            halfStat = defender["baseWill"] / 2
        else
            halfStat = 0
        end
        defender["will"] = utilities:Round(halfStat)
        defender["debuffDelude"] = true
        defender["tickDebuffDelude"] = 0                 
    end

    textOutput = attacker["name"].." is able to "..affliction.." "..defender["name"]..", lowering their "..stat.."."    

    return textOutput
end

function abilitiesT1:ForbiddenRitual(attacker, defender)
    local textOutput = ""
    local roll = utilities:RNG(3)
    local attack = 0
        
    if roll ~= 1 then
        attack = defender["currentHp"] / 2
        attack = utilities:Round(attack)

        -- prevent defender from being killed if currentHp is 1
        if defender["currentHp"] == 1 then
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

function abilitiesT1:Cannibalize(attacker, defender)
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
    
    return textOutput, canniDef
end

function abilitiesT1:MindOverMatter(attacker, defender)
    local textOutput = ""
    local attack = attacker["int"] - defender["def"] 
    attack = rpg:ValorCheck(defender, attack)

    if attack < 0 then
        attack = 0
    end        

    defender["currentHp"] = defender["currentHp"] - attack 

    if attack > 0 then            
        textOutput = attacker["name"].." projects Mind Over Matter, doing "..attack.." damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Mind Over Matter does "..attack.." damage to "..defender["name"].."."
    end          
    
    return textOutput, attack
end

function abilitiesT1:Blast(attacker, defender)
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
    
    attack = rpg:ValorCheck(defender, attack)

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
    
    return textOutput, attack
end

function abilitiesT1:FinalCountdownTurnOne(attacker, defender, matchup, nextTurnDmgTable)
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

function abilitiesT1:SilenceLullBlind(attacker, defender, affliction)
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

function abilitiesT1:MirrorMania(attacker, defender, pet)
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
        pet["baseLightning"] = defender["baseLightning"]
        pet["basePoison"] = defender["basePoison"]
        pet["baseIce"] = defender["baseIce"]
        pet["baseDisease"] = defender["baseDisease"]
        pet["baseEarth"] = defender["baseEarth"]
        pet["baseFire"] = defender["baseFire"]
        
	pet["lightning"] = pet["baseLightning"]
        pet["poison"] = pet["basePoison"]
        pet["ice"] = pet["baseIce"]
        pet["disease"] = pet["baseDisease"]
        pet["earth"] = pet["baseEarth"]
        pet["fire"] = pet["baseFire"]        

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

function abilitiesT1:UndeadMinion(attacker, pet)
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

        pet["baseLightning"] = 1
        pet["basePoison"] = 1
        pet["baseIce"] = 1
        pet["baseDisease"] = 1
        pet["baseEarth"] = 1
        pet["baseFire"] = 1
        
	pet["lightning"] = pet["baseLightning"]
        pet["poison"] = pet["basePoison"]
        pet["ice"] = pet["baseIce"]
        pet["disease"] = pet["baseDisease"]
        pet["earth"] = pet["baseEarth"]
        pet["fire"] = pet["baseFire"]    

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

        if attacker["level"] >= 11 then
            pet["abil7"] = 32
            pet["abil8"] = 33 
        else
            pet["abil7"] = nil
            pet["abil8"] = nil            
        end
        
        if attacker["level"] >= 13 then
            pet["abil9"] = 48
        else
            pet["abil9"] = nil
        end

        if attacker["level"] >= 15 then
            pet["abil10"] = 35
        else
            pet["abil10"] = nil
        end
        
        if attacker["level"] >= 17 then
            pet["abil11"] = 34
        else
            pet["abil11"] = nil
        end
        
        if attacker["level"] >= 19 then
            pet["abil12"] = 31
        else
            pet["abil12"] = nil
        end   

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

function abilitiesT1:AssistedSuicide(attacker, defender)
    local textOutput = ""
    local roll = utilities:RNG(4)
    local attack = 0

    if roll ~= 1 then
        roll = utilities:RNG(6)
        attack = defender["str"] + defender["level"] + roll - defender["def"]
        attack = rpg:ValorCheck(defender, attack)
        
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
 
return abilitiesT1