-- Collection of functions to be used in the RPG part of the game

local utilities = require "functions.Utilities" -- for RNG generation and rounding
local rpg = require "functions.RPG"

local abilitiesT2 = {}
local abilitiesT2_mt = { __index = abilitiesT2 }	-- metatable
 
-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------
 
-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------
 
function abilitiesT2.new()	-- constructor
local newAbilitiesT2 = {}
return setmetatable( newAbilitiesT2, abilitiesT2_mt )
end
 
------------------------------------------------- 
-- ABILITY FUNCTIONS
------------------------------------------------- 
 
--[[ 
-- basic template for functions
function abilitiesT2:Shell(attacker, defender)
    local textOutput = ""
    
    
    
    return textOutput, attack
end
--]] 
 
function abilitiesT2:ConcussiveBlow(attacker, defender)
    local textOutput = ""
    local attack = attacker["str"]
    attack = rpg:ValorCheck(defender, attack)

    if attack < 0 then
        attack = 0
    end

    defender["currentHp"] = defender["currentHp"] - attack
    
    if attack > 0 then            
        textOutput = attacker["name"].." delivers a Concussive Blow, doing "..attack.." damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Concussive Blow does "..attack.." damage to "..defender["name"].."."
    end    
    
    return textOutput, attack
end

function abilitiesT2:RecklessAssault(attacker, defender)
    local textOutput = ""
    local roll = utilities:RNG(6) + utilities:RNG(6)
    local attack = attacker["str"] + roll
    attack = rpg:ValorCheck(defender, attack)
    local raAtk = attack - attacker["def"]
    local raDef = (attack * 2) - defender["def"]
    
    -- set the damage to 0 if it's less than 0, otherwise round it
    if raAtk < 0 then
        raAtk = 0
    end

    if raDef < 0 then
        raDef = 0
    end     

    attacker["currentHp"] = attacker["currentHp"] - raAtk
    defender["currentHp"] = defender["currentHp"] - raDef

    textOutput = attacker["name"].." performs a Reckless Assault, suffering "..raAtk.." damage and inflicting "..raDef.." damage to "..defender["name"].."."      
    
    return textOutput, raDef
end

function abilitiesT2:Hemorrhage(attacker, defender)
    local textOutput = ""
    local attack = attacker["str"]  
    attack = rpg:ValorCheck(defender, attack)

    if attack > 0 then
        defender["currentHp"] = defender["currentHp"] - attack
        defender["dotHemorrhage"] = true
        defender["dotHemorrhageDmg"] = utilities:Round(attack / 2) 
        defender["tickDotHemorrhage"] = 2
        textOutput = attacker["name"].." Hemorrhages "..defender["name"]..", cutting deep and dealing "..attack.." damage."        
    else
        textOutput = attacker["name"].." Hemorrhages "..defender["name"]..", but 'tis just a flesh wound."   
    end      
    
    return textOutput
end

function abilitiesT2:Bloodlust(attacker, defender)
    local textOutput = ""
    local attack = (attacker["str"] * 3) - defender["def"]  
    attack = rpg:ValorCheck(defender, attack)

    if attack < 0 then
        attack = 0
    end        

    defender["currentHp"] = defender["currentHp"] - attack 

    if attack > 0 then            
        textOutput = attacker["name"].." gets a Bloodlust, doing "..attack.." damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Bloodlust does "..attack.." damage to "..defender["name"].."."
    end    
    
    return textOutput, attack
end

function abilitiesT2:ResistanceIsFutile(attacker, defender)
    local textOutput = ""
    local roll = utilities:RNG(3)
    local attack = (attacker["str"] * roll) - defender["will"]
    attack = rpg:ValorCheck(defender, attack)

    if attack < 0 then
        attack = 0
    end

    defender["currentHp"] = defender["currentHp"] - attack
    
    if roll == 3 and attack > 0 then            
        textOutput = attacker["name"].." declares that Resistance Is Futile, doing a critical "..attack.." damage to "..defender["name"].."."
    elseif attack > 0 then
        textOutput = attacker["name"].." declares that Resistance Is Futile, doing "..attack.." damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Resistance Is Futile does "..attack.." damage to "..defender["name"].."."            
    end 
    
    return textOutput, attack
end

function abilitiesT2:AchillesHeel(attacker, defender)
    local textOutput = ""    
    local roll = utilities:RNG(6)
    local attack = 0
       

    if roll >= 5 then
        attack = (attacker["str"] * 3) - defender["def"]
    else
        attack = (attacker["str"] * 2) - defender["def"]            
    end
    
    attack = rpg:ValorCheck(defender, attack) 

    if attack < 0 then
        attack = 0
    end        

    defender["currentHp"] = defender["currentHp"] - attack

    if roll >= 5 then            
        textOutput = attacker["name"].."'s Achilles Heel does "..attack.." critical damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Achilles Heel does "..attack.." damage to "..defender["name"].."."           
    end    
    
    return textOutput, attack
end

function abilitiesT2:Incinerate(attacker, defender)
    local textOutput = ""    
    local attack = (attacker["int"] * 2 * defender["fire"]) - defender["will"]
    local dotDmg = (attacker["int"] * defender["fire"]) - defender["will"]

    -- set the damage to 0 if it's less than 0, otherwise round it
    if attack < 0 then
        attack = 0
    else
        attack = utilities:Round(attack)
        attack = rpg:ValorCheck(defender, attack)
    end
    
    if dotDmg < 0 then
        dotDmg = 0
    else
        dotDmg = utilities:Round(dotDmg)
    end    

    defender["currentHp"] = defender["currentHp"] - attack

    if attack > 0 then
        defender["currentHp"] = defender["currentHp"] - attack
        defender["dotIncinerate"] = true
        defender["dotIncinerateDmg"] = dotDmg 
        defender["tickDotIncinerate"] = 2
        textOutput = attacker["name"].." Incinerates "..defender["name"]..", lighting them on fire and dealing "..attack.." damage."     
    elseif defender["fire"] == 0 then
        textOutput = attacker["name"].." Incinerates "..defender["name"]..", but they are resistant to fire."
    else
        textOutput = attacker["name"].." Incinerate "..defender["name"]..", but they fail to catch fire." 
    end      
    
    return textOutput, attack
end

function abilitiesT2:Electromagnet(attacker, defender)
    local textOutput = ""    
    local roll = utilities:RNG(3)
    local attack = (attacker["int"] * roll * defender["lightning"]) - defender["will"]
    local sap = 0
    
    -- set the damage to 0 if it's less than 0, otherwise round it
    if attack < 0 then
        attack = 0
    else
        attack = utilities:Round(attack)
        attack = rpg:ValorCheck(defender, attack)
    end

    defender["currentHp"] = defender["currentHp"] - attack
    
    if defender["currentAp"] < roll then
        sap = defender["currentAp"]
    else
        sap = roll
    end
    
    if defender["lightning"] == 0 then
        sap = 0
    end
    
    defender["currentAp"] = defender["currentAp"] - sap
    
    attacker["currentAp"] = attacker["currentAp"] + sap
    
    if attacker["currentAp"] > attacker["ap"] then
        attacker["currentAp"] = attacker["ap"] 
    end    

    if roll == 3 and attack > 0 then
        textOutput = attacker["name"].." conjures a powerful Electromagnet, doing "..attack.." lightning damage to "..defender["name"]..", and sapping "..sap.." AP."          
    elseif defender["lightning"] == 0 then  
        textOutput = attacker["name"].." conjures an Electromagnet, but "..defender["name"].." is resistant to lightning."            
    else
        textOutput = attacker["name"].." conjures an Electromagnet, doing "..attack.." lightning damage to "..defender["name"]..", and sapping "..sap.." AP." 
    end      
    
    return textOutput, attack
end

function abilitiesT2:Debilitate(attacker, defender)
    local textOutput = ""
    local attack = defender["poison"] * attacker["level"] * 2 
    attack = utilities:Round(attack)    

    if attack > 0 then
        defender["currentHp"] = defender["currentHp"] - attack
        defender["dotPoison"] = true
        defender["dotPoisonDmg"] = attack            
        textOutput = attacker["name"].." Debilitates "..defender["name"]..", poisoning them for an ongoing "..attack.." damage."        
    elseif defender["poison"] == 0 then  
        textOutput = attacker["name"].." Debilitates "..defender["name"]..", but they are resistant to poison."            
    else
        textOutput = attacker["name"].." Debilitates "..defender["name"]..", but the poison doesn't take hold."   
    end      
    
    return textOutput
end

function abilitiesT2:VampiricEmbrace(attacker, defender)
    local textOutput = ""    
    local roll = utilities:RNG(3)
    local attack = roll * attacker["level"]
    local dot = attack
    attack = attack * defender["disease"]
    attack = utilities:Round(attack)

    if attack > 0 then
        
        if defender["currentHp"] < attack then
            attack = defender["currentHp"]
        end            
        
        defender["currentHp"] = defender["currentHp"] - attack
        attacker["currentHp"] = attacker["currentHp"] + attack

        if attacker["currentHp"] > attacker["hp"] then
            attacker["currentHp"] = attacker["hp"]
        end        
        
        attacker["buffVampEmb"] = true
        attacker["buffVampEmbHeal"] = dot
        attacker["tickBuffVampEmb"] = 2
        
        textOutput = attacker["name"].." uses a Vampiric Embrace on "..defender["name"]..", inflicting and restoring "..attack.." disease damage.".." "..attacker["name"].." now has the taste for blood."           
    elseif defender["disease"] ~= 0 then
        textOutput = attacker["name"].." tries a Vampiric Embrace "..defender["name"]..", but fails to get hold."
    else
        textOutput = attacker["name"].." uses a Vampiric Embrace, but "..defender["name"].." is resistant to disease."           
    end      
    
    return textOutput
end

function abilitiesT2:BrainFreeze(attacker, defender)
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

function abilitiesT2:EssenceOfEarth(attacker, defender)
    local textOutput = ""    
    local attack = ((attacker["int"] * 1.5) + attacker["level"]) * defender["earth"]
    attack = utilities:Round(attack)
    attack = rpg:ValorCheck(defender, attack)

    defender["currentHp"] = defender["currentHp"] - attack

    if defender["earth"] ~= 0 then            
        textOutput = attacker["name"].." harnesses the Essence of Earth, doing "..attack.." earth damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].." harnesses the Essence of Earth, but "..defender["name"].." is resistant to earth."
    end      
    
    return textOutput, attack
end

function abilitiesT2:Replenish(attacker)
    local textOutput = ""  
    local roll = utilities:RNG(3)
    local attack = roll * attacker["level"]

    attacker["currentHp"] = attacker["currentHp"] + attack

    if attacker["currentHp"] > attacker["hp"] then
        attacker["currentHp"] = attacker["hp"]
    end

    attacker["buffReplenish"] = true
    attacker["tickBuffReplenish"] = 1
    attacker["buffReplenishHeal"] = attack
     
    textOutput = attacker["name"].." Replenishes health over time, restoring "..attack.." HP."
    
    return textOutput
end

function abilitiesT2:Hamstring(attacker, defender)
    local textOutput = ""
    local roll = utilities:RNG(2)

    if roll == 2 then
        defender["statusHamstring"] = true
        defender["tickStatusHamstring"] = 1
        textOutput = attacker["name"].." Hamstrings "..defender["name"]..", preventing them from taking action."              
    else
        textOutput = attacker["name"].." attempts to Hamstring "..defender["name"]..", but they avoid the attempt."
    end    
    
    return textOutput
end

function abilitiesT2:Haste(attacker)
    local textOutput = ""  
    local roll = utilities:RNG(3)
    
    if roll ~= 1 then
        attacker["buffHaste"] = true
        attacker["tickBuffHaste"] = 1
        attacker["buffHasteOn"] = false

        textOutput = attacker["name"].."'s Haste puts a spring in their step."        
    else
        textOutput = attacker["name"].." tries to Haste, but only ends up wasting time."  
    end
    
    return textOutput
end

function abilitiesT2:MindShatter(attacker, defender)
    local textOutput = ""
    local sap = 0
    
    if defender["currentAp"] > 0 then
        sap = utilities:Round(defender["currentAp"] / 2)
        defender["currentAp"] = defender["currentAp"] - sap    
        attacker["currentAp"] = attacker["currentAp"] + sap   
        
        if attacker["currentAp"] > attacker["ap"] then
            attacker["currentAp"] = attacker["ap"] 
        end            
        
        textOutput = attacker["name"].." uses a Mind Shatter on "..defender["name"]..", sapping "..sap.." AP."          
    else
        textOutput = attacker["name"].." tries to Mind Shatter "..defender["name"]..", but there's no AP to sap."           
    end
    
    return textOutput
end

function abilitiesT2:Valor(attacker)
    local textOutput = ""    

    attacker["buffValor"] = true
    attacker["tickBuffValor"] = 1

    textOutput = attacker["name"].." shows Valor, protecting them from incoming damage." 
    
    return textOutput
end

function abilitiesT2:ReflectiveShield(attacker)
    local textOutput = ""    

    attacker["buffRefShield"] = true
    attacker["tickBuffRefShield"] = 1

    textOutput = attacker["name"].." creates a Reflective Shield, harming those who come near." 
    
    return textOutput
end

function abilitiesT2:DarkPact(attacker, defender)
    local textOutput = ""
    local attack = (attacker["int"] * 3) - defender["will"]  
    attack = rpg:ValorCheck(defender, attack)

    if attack < 0 then
        attack = 0
    end        

    defender["currentHp"] = defender["currentHp"] - attack 

    if attack > 0 then            
        textOutput = attacker["name"].." makes a Dark Pact, doing "..attack.." damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Dark Pact does "..attack.." damage to "..defender["name"].."."
    end    
    
    return textOutput, attack
end

function abilitiesT2:MentalOverload(attacker, defender)
    local textOutput = ""
    local attack = attacker["int"]
    attack = rpg:ValorCheck(defender, attack)

    if attack < 0 then
        attack = 0
    end

    defender["currentHp"] = defender["currentHp"] - attack
    
    if attack > 0 then            
        textOutput = attacker["name"].." delivers a Mental Overload, doing "..attack.." damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Mental Overload does "..attack.." damage to "..defender["name"].."."
    end    
    
    return textOutput, attack
end

function abilitiesT2:SirenSong(attacker, defender)
    local textOutput = ""
    local attack = 0

    attack = defender["currentHp"] / 2
    attack = utilities:Round(attack)

    -- prevent defender from being killed if currentHp is 1
    if defender["currentHp"] == 1 then
        textOutput = attacker["name"].."'s Siren Song does no damage to "..defender["name"].."."                            
    else
        defender["currentHp"] = defender["currentHp"] - attack                
        textOutput = attacker["name"].."'s Siren Song entrances "..defender["name"]..", allowing them to do "..attack.." damage."              
    end
    
    return textOutput
end

function abilitiesT2:BendTheSpoon(attacker, defender)
    local textOutput = ""
    local roll = utilities:RNG(3)
    local attack = (attacker["int"] * roll) - defender["def"]
    attack = rpg:ValorCheck(defender, attack)

    if attack < 0 then
        attack = 0
    end

    defender["currentHp"] = defender["currentHp"] - attack
    
    if roll == 3 and attack > 0 then            
        textOutput = attacker["name"].." uses their mind to Bend The Spoon, doing a critical "..attack.." damage to "..defender["name"].."."
    elseif attack > 0 then
        textOutput = attacker["name"].." uses their mind to Bend The Spoon, doing "..attack.." damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Bend The Spoon does "..attack.." damage to "..defender["name"].."."            
    end 
    
    return textOutput, attack
end

function abilitiesT2:Fallout(attacker, defender)
    local textOutput = ""    
    local roll = utilities:RNG(6)
    local attack = 0
       

    if roll >= 5 then
        attack = (attacker["int"] * 3) - defender["will"]
    else
        attack = (attacker["int"] * 2) - defender["will"]            
    end
    
    attack = rpg:ValorCheck(defender, attack) 

    if attack < 0 then
        attack = 0
    end        

    defender["currentHp"] = defender["currentHp"] - attack

    if roll >= 5 then            
        textOutput = attacker["name"].."'s Fallout does "..attack.." critical damage to "..defender["name"].."."
    else
        textOutput = attacker["name"].."'s Fallout does "..attack.." damage to "..defender["name"].."."           
    end    
    
    return textOutput, attack
end

function abilitiesT2:SummonDemon(attacker, pet)
    local textOutput = ""
    local roll = utilities:RNG(2)   

    if roll == 2 then
        pet["baseHp"] = (attacker["level"] + attacker["level"] - 1) * 3
        pet["baseStr"] = attacker["level"] * 1
        pet["baseDef"] = attacker["level"] * 1
        pet["baseAp"] = attacker["level"] * 1
        pet["baseInt"] = attacker["level"] * 2
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
        pet["abil1"] = 7
        pet["abil2"] = 25

        if attacker["level"] >= 3 then
            pet["abil3"] = 22
        else
            pet["abil3"] = nil
        end

        if attacker["level"] >= 5 then
            pet["abil4"] = 9
        else
            pet["abil4"] = nil
        end

        if attacker["level"] >= 7 then
            pet["abil5"] = 24
        else
            pet["abil5"] = nil
        end

        if attacker["level"] >= 9 then
            pet["abil6"] = 18
        else
            pet["abil6"] = nil
        end            

        if attacker["level"] >= 11 then
            pet["abil7"] = 37
            pet["abil8"] = 39 
        else
            pet["abil7"] = nil
            pet["abil8"] = nil            
        end
        
        if attacker["level"] >= 13 then
            pet["abil9"] = 49
        else
            pet["abil9"] = nil
        end

        if attacker["level"] >= 15 then
            pet["abil10"] = 60
        else
            pet["abil10"] = nil
        end
        
        if attacker["level"] >= 17 then
            pet["abil11"] = 38
        else
            pet["abil11"] = nil
        end
        
        if attacker["level"] >= 19 then
            pet["abil12"] = 51
        else
            pet["abil12"] = nil
        end   

        pet["name"] = "Summoned Demon"            
        pet["level"] = attacker["level"]
        pet["currentHp"] = pet["hp"]
        pet["currentAp"] = pet["ap"] 

        -- todo add image
        if attacker["type"] == "pc" then
            pet["type"] = "pcPet"                
        elseif attacker["type"] == "npc" then
            pet["type"] = "npcPet"               
        end

        textOutput = attacker["name"].." conjures a Summoned Demon to aid in battle."            
    else
        textOutput = attacker["name"].." tries to conjure a Summoned Demon, but fails."            
    end      
    
    return textOutput
end

function abilitiesT2:ElementalResistance(attacker, element)
    local textOutput = ""    

    attacker["buffElemRes"] = true
    attacker["tickBuffElemRes"] = 1
    attacker[element] = 0

    textOutput = attacker["name"].." becomes resistant to "..element.." attacks." 
    
    return textOutput
end

function abilitiesT2:Imbue(attacker, defender, element)
    local textOutput = ""    

    defender["debuffImbue"] = true
    defender["tickDebuffImbue"] = 1
    defender[element] = 2

    textOutput = attacker["name"].." has Imbued "..defender["name"].." with "..element..", making them susceptible to "..element.." attacks." 
    
    return textOutput
end

function abilitiesT2:Polymorph(attacker, defender)
    local textOutput = ""   
    local halfStat = 0
    local roll = utilities:RNG(2)

    if roll == 2 then
        textOutput = attacker["name"].." casts Polymorph on "..defender["name"].." turning them into a small, helpless creature."
        
        if not defender["debuffCramp"] then
            if defender["baseStr"] > 0 then
                halfStat = defender["baseStr"] / 2
            else
                halfStat = 0
            end
            defender["str"] = utilities:Round(halfStat)
            defender["debuffCramp"] = true
            defender["tickDebuffCramp"] = 0   
            textOutput = textOutput.." "..defender["name"].."'s strength has been lowered."
        end

        if not defender["debuffCripple"] then
            if defender["baseDef"] > 0 then
                halfStat = defender["baseDef"] / 2
            else
                halfStat = 0
            end
            defender["def"] = utilities:Round(halfStat)
            defender["debuffCripple"] = true
            defender["tickDebuffCripple"] = 0  
            textOutput = textOutput.." "..defender["name"].."'s defense has been lowered."
        end

        if not defender["debuffMindBreak"] then
            if defender["baseInt"] > 0 then
                halfStat = defender["baseInt"] / 2
            else
                halfStat = 0
            end
            defender["int"] = utilities:Round(halfStat)
            defender["debuffMindBreak"] = true
            defender["tickDebuffMindBreak"] = 1   
            textOutput = textOutput.." "..defender["name"].."'s intelligence has been lowered."
        end

        if not defender["debuffDelude"] then
            if defender["baseWill"] > 0 then
                halfStat = defender["baseWill"] / 2
            else
                halfStat = 0
            end
            defender["will"] = utilities:Round(halfStat)
            defender["debuffDelude"] = true
            defender["tickDebuffDelude"] = 0 
            textOutput = textOutput.." "..defender["name"].."'s will has been lowered."
        end       
    else
        textOutput = attacker["name"].." casts Polymorph on "..defender["name"]..", but misses the target."
    end

    return textOutput
end
-------------------------------------------------
 
return abilitiesT2