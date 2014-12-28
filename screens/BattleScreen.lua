local composer = require ("composer")
local GLOB = require "globals"
local controls = require("controls.Controls")
local button = require("controls.Button")
local widget = require "widget"
local utilities = require "functions.Utilities"
local json = require "json"
local scene = composer.newScene()
--todo:

-- local forward references here
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.

---------------------
--  BEGIN FORWARD VARIABLE DECLARATIONS --
---------------------    

-- tables for player stats
local pcStats = {}
local pcPetStats = {}

-- npc stat tables
local npcStats = {}
local npcPetStats = {}

-- contains damage and matchups for multi turn abilities
-- the index will be a string defined in scene:Initialize(). the value stored will be damage to inflict.
-- a value is set if it is not 0. for 1 hit kills or 0 damage to be inflicted, the value is set to -1
local nextTurnDmg = {}

-- some flags used by the game
local turnLost = false -- bool value

-- bools to keep track of pets that are out. pc and npc can only have one type of pet at a time
local pcPetMelee = false
local npcPetMelee = false
local pcPetMagic = false
local npcPetMagic = false

-- flags to determine who is on the offensive. if these are all false it is npc's turn
-- initial starting character will be determined in scene:Initialize()
local pcTurn = false
local pcTurnPet = false
local npcTurnPet = false

-- flag to determine if abilities button is pressed or depressed (show/hide abilities)
local showAbilities = false

-- todo some item variables were here in orig. need a new way to deal with those
-- probably pull up inv screen from shop and disable what doesn't need to be shown
---------------------
--  END FORWARD VARIABLE DECLARATIONS --
---------------------  

---------------------
-- BEGIN FORWARD CONTROL DECLARATIONS --
---------------------   
 
-- buttons
local attackButton,abilityButton,itemButton,meditateButton,runButton,endTurnButton,
abil1Button,abil2Button,abil3Button,abil4Button,abil5Button,abil6Button,
abil7Button,abil8Button,abil9Button,abil10Button,abil11Button,abil12Button

-- button groups (ability buttons)
local buttonGroupTwo,buttonGroupThree
 
-- labels 
local pcHPLabel,pcAPLabel,pcPetHPLabel,pcPetAPLabel,pcPetNameLabel,npcHPLabel,npcAPLabel,npcPetHPLabel,npcPetAPLabel,npcPetNameLabel,pcPetStatGroup,npcPetStatGroup

-- affliction images
local pcCrampImg,pcCrippleImg,pcMindBreakImg,pcDeludeImg,pcPoisonImg,pcBlindImg,pcSilenceImg,pcLullImg,
pcPetCrampImg,pcPetCrippleImg,pcPetMindBreakImg,pcPetDeludeImg,pcPetPoisonImg,pcPetBlindImg,pcPetSilenceImg,pcPetLullImg,
npcCrampImg,npcCrippleImg,npcMindBreakImg,npcDeludeImg,npcPoisonImg,npcBlindImg,npcSilenceImg,npcLullImg,
npcPetCrampImg,npcPetCrippleImg,npcPetMindBreakImg,npcPetDeludeImg,npcPetPoisonImg,npcPetBlindImg,npcPetSilenceImg,npcPetLullImg
 
-- stuff for scrollview
local scrollView
local visibleScroll = 100 -- the visible area of the scrollview
local scrollRectWidth = 725
local scrollArea
local scrollY = 10 -- this will allow the first item added to be in the right position
local newScrollHeight = 0
---------------------
--  END FORWARD CONTROL DECLARATIONS --
---------------------  
function scene:LoadToons()

    -- todo: explicitely set all dots, debuffs and their damage to default values so they are safe to use in comparison operators
    -- it should be ok to not do this but needs tested

    -- pick an enemy and load in their stats. something could be passed in to pick a specific one or could just pick a random
    -- todo could add a field to npc excel table for enemy type: dot, boss, special, etc.
    
    -- load base stats
    -- todo do we need to differentiate npc base stats vs geared stats?
    npcStats["baseHp"] = GLOB.npcs[1]["HP"]
    npcStats["baseStr"] = GLOB.npcs[1]["Str"]
    npcStats["baseDef"] = GLOB.npcs[1]["Def"]
    npcStats["baseAp"] = GLOB.npcs[1]["AP"]
    npcStats["baseInt"] = GLOB.npcs[1]["Int"]
    npcStats["baseWill"] = GLOB.npcs[1]["Will"]
    
    -- for now assign stats the same as base stats for npc
    -- todo change this perhaps to factor in their equipment. see how i did it in paper version
    npcStats["hp"] = npcStats["baseHp"]
    npcStats["str"] = npcStats["baseStr"]
    npcStats["def"] = npcStats["baseDef"]
    npcStats["ap"] = npcStats["baseAp"]
    npcStats["int"] = npcStats["baseInt"]
    npcStats["will"] = npcStats["baseWill"]
    
    -- npc elem resistances
    npcStats["lightning"] = GLOB.npcs[1]["Lightning"]
    npcStats["poison"] = GLOB.npcs[1]["Poison"]
    npcStats["ice"] = GLOB.npcs[1]["Ice"]
    npcStats["disease"] = GLOB.npcs[1]["Disease"]
    npcStats["earth"] = GLOB.npcs[1]["Earth"]
    npcStats["fire"] = GLOB.npcs[1]["Fire"]
    
    --todo load these in from json
    -- npc abilities
    npcStats["abil1"] = 1
    npcStats["abil2"] = 4
    npcStats["abil3"] = 7
    npcStats["abil4"] = 8
    npcStats["abil5"] = 12
    npcStats["abil6"] = 16
    npcStats["abil7"] = 20
    npcStats["abil8"] = 22
    npcStats["abil9"] = 24
    npcStats["abil10"] = 26
    npcStats["abil11"] = 28
    npcStats["abil12"] = 30    
    
    -- npc misc stats
    npcStats["name"] = GLOB.npcs[1]["Name"]
    npcStats["type"] = GLOB.npcs[1]["Type"]
    npcStats["level"] = GLOB.npcs[1]["Level"]
    npcStats["currentHp"] = npcStats["hp"]
    npcStats["currentAp"] = npcStats["ap"]    
    
    -- for now just hard coding player stats
    -- todo change this
    pcStats["baseHp"] = 50
    pcStats["baseStr"] = 4
    pcStats["baseDef"] = 3
    pcStats["baseAp"] = 5
    pcStats["baseInt"] = 0
    pcStats["baseWill"] = 1
    
    pcStats["hp"] = pcStats["baseHp"]
    pcStats["str"] = pcStats["baseStr"]
    pcStats["def"] = pcStats["baseDef"]
    pcStats["ap"] = pcStats["baseAp"]
    pcStats["int"] = pcStats["baseInt"]
    pcStats["will"] = pcStats["baseWill"]    

    pcStats["lightning"] = 1
    pcStats["poison"] = 1
    pcStats["ice"] = 1
    pcStats["disease"] = 1.5
    pcStats["earth"] = 2
    pcStats["fire"] = 0
    
    pcStats["abil1"] = 1
    pcStats["abil2"] = 4
    pcStats["abil3"] = 7
    pcStats["abil4"] = 8
    pcStats["abil5"] = 12
    pcStats["abil6"] = 27
    pcStats["abil7"] = nil
    pcStats["abil8"] = nil
    pcStats["abil9"] = nil
    pcStats["abil10"] = nil
    pcStats["abil11"] = nil
    pcStats["abil12"] = nil

    pcStats["name"] = "Jack"
    pcStats["type"] = "pc"
    pcStats["level"] = 1
    pcStats["currentHp"] = pcStats["hp"]
    pcStats["currentAp"] = pcStats["ap"]    

    print("hello")
end

-- called when attack button is pressed to determine who is attacking (pc or pcPet) who(npc or npcPet. Attack function is called from here
function scene:AttackClick()
    if pcTurnPet then
        if npcPetMelee then
            scene:Attack(pcPetStats, npcPetStats)
        else
            scene:Attack(pcPetStats, npcStats)
        end
    else -- player's turn
        if npcPetMelee then
            scene:Attack(pcStats, npcPetStats)
        else
            scene:Attack(pcStats, npcStats)
        end
    end
end

-- called when meditate button is pressed to determine who is attacking (pc or pcPet). Meditate function is called from here
function scene:MeditateClick()
    if pcTurnPet then
        scene:Meditate(pcPetStats)
    else
        scene:Meditate(pcStats)
    end
end

-- attack function. can be called by players and npcs as well as their pets
function scene:Attack(attacker, defender)
    scene:CheckSilenceBlind("statusBlind") -- if the person attacking is blinded and fails check, the following if statement code will not execute
    
    if not turnLost then
        local roll = utilities:RNG(6)        
        
        local attack = attacker["str"] + attacker["level"] + roll - defender["def"]
        
        if attack < 0 then
            attack = 0
        end          
        
        if attack > 0 then
            defender["currentHp"] = defender["currentHp"] - attack
            scene:BattleLogAdd(attacker["name"].." makes an Attack, doing "..attack.." damage to "..defender["name"]..".")        
        else            
            scene:BattleLogAdd(attacker["name"].." Attacks "..defender["name"].." but does no damage.")
        end
    end
    
    turnLost = false
    scene:EndTurn()
    
end

-- meditate function. can be called by players and npcs as well as their pets
function scene:Meditate(attacker)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
        local roll = 0
        
        if attacker["level"] < 11 then -- restore 1-3 or 1-6 ap based on level
            roll = utilities:RNG(3)
        else
            roll = utilities:RNG(6)
        end
        
        attacker["currentAp"] = attacker["currentAp"] + roll
        
        if attacker["currentAp"] > attacker["ap"] then
            attacker["currentAp"] = attacker["ap"]
        end
        
        scene:BattleLogAdd(attacker["name"].." Meditates, recovering "..roll.." AP.")
    end
    
    turnLost = false
    scene:EndTurn()
end



-- check for silence or blind. a string value will be passed in to check the table value in the character's stats
-- determine whose turn it is and if they are afflicted. if so, roll and see if they are prevented from acting
-- pass in a string of either "statusBlind" or "statusSilence"
function scene:CheckSilenceBlind(affliction)
    local afflicted = false
    local outputName = ""
    
    if pcTurn then
        if (pcTurnPet and pcPetStats[affliction]) then
            afflicted = true
            outputName = pcPetStats["name"]
        elseif pcStats[affliction] then
            afflicted = true
            outputName = pcStats["name"]
        end
    else
        if (npcTurnPet and npcPetStats[affliction]) then
            afflicted = true
            outputName = npcPetStats["name"]
        elseif npcStats[affliction] then
            afflicted = true
            outputName = npcStats["name"]    
        end 
    end
    
    if afflicted then
        local roll = utilities:RNG(3)
        local affText = ""
        
        if affliction == "statusBlind" then
            affText = "blinded"
        elseif affliction == "statusSilence" then
            affText = "silenced"
        else -- todo remove this condition. it's just here for error checking to make sure this function is called correctly
            scene:BattleLogAdd("YOU FUCKED UP HERE SON")
        end
        
        local outputString = outputName.." is "..affText.." and is unable to make an action."

        if roll ~= 3 then
            scene:BattleLogAdd(outputString)
            turnLost = true
        end   
    end
end

function scene:Cleave(attacker, defender)
    scene:CheckSilenceBlind("statusBlind")
    
    if not turnLost then
        local roll = utilities:RNG(3)
        local attack = (attacker["str"] * roll) - defender["def"]
        
        if attack < 0 then
            attack = 0
        end
        
        defender["currentHp"] = defender["currentHp"] - attack
        
        if roll == 3 and attack > 0 then            
            scene:BattleLogAdd(attacker["name"].." Cleaves with a mighty swing, doing "..attack.." damage to "..defender["name"]..".")
        elseif attack > 0 then
            scene:BattleLogAdd(attacker["name"].." Cleaves, doing "..attack.." damage to "..defender["name"]..".")
        else
            scene:BattleLogAdd(attacker["name"].."'s Cleave does "..attack.." damage to "..defender["name"]..".")            
        end
    end

    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()    
end

function scene:Berserk(attacker, defender)
    scene:CheckSilenceBlind("statusBlind")
    
    if not turnLost then        
        local attack = (attacker["str"] * 2) - defender["def"]  
        
        if attack < 0 then
            attack = 0
        end        
        
        defender["currentHp"] = defender["currentHp"] - attack 
        
        if attack > 0 then            
            scene:BattleLogAdd(attacker["name"].." goes Berserk, doing "..attack.." damage to "..defender["name"]..".")
        else
            scene:BattleLogAdd(attacker["name"].."'s Berserk does "..attack.." damage to "..defender["name"]..".")
        end      
    end

    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()    
end

function scene:TestOfWill(attacker, defender)
    scene:CheckSilenceBlind("statusBlind")
    
    if not turnLost then        
        local attack = attacker["str"] - defender["will"] 
        
        if attack < 0 then
            attack = 0
        end        
        
        defender["currentHp"] = defender["currentHp"] - attack 
        
        if attack > 0 then            
            scene:BattleLogAdd(attacker["name"].." uses a Test of Will, doing "..attack.." damage to "..defender["name"]..".")
        else
            scene:BattleLogAdd(attacker["name"].."'s Test of Will does "..attack.." damage to "..defender["name"]..".")
        end      
    end

    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()    
end

function scene:Backstab(attacker, defender)
    scene:CheckSilenceBlind("statusBlind")
    
    if not turnLost then
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
            scene:BattleLogAdd(attacker["name"].." critically Backstabs  "..defender["name"]..", doing "..attack.." damage.")
        elseif roll == 1 then
            scene:BattleLogAdd(attacker["name"].."'s Backstab misses the mark, doing "..attack.." damage to "..defender["name"]..".")            
        else
            scene:BattleLogAdd(attacker["name"].."'s Backstab does "..attack.." damage to "..defender["name"]..".")            
        end
    end

    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()    
end

function scene:BeatDown(attacker, defender)
    scene:CheckSilenceBlind("statusBlind")
    
    if not turnLost then
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
            scene:BattleLogAdd(attacker["name"].." uses a Beat Down, doing "..attack.." damage to "..defender["name"]..".")
        elseif roll == 1 then
            scene:BattleLogAdd(attacker["name"].." tries a Beat Down but misses his mark, doing "..attack.." damage to "..defender["name"]..".")       
        end
    end

    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()    
end

function scene:DRUTurnOne(attacker, defender, matchup, move)
    if move == "Delayed Reaction" then
        scene:CheckSilenceBlind("statusBlind")
    else
        scene:CheckSilenceBlind("statusSilence")
    end
    
    if not turnLost then
        -- associate attacker with target and determine damage
        if move == "Delayed Reaction" then
            nextTurnDmg[matchup] = (attacker["str"] * 3) - defender["def"]
            attacker["delayedReactionReady"] = true
            scene:BattleLogAdd(attacker["name"].." sizes up "..defender["name"].." for a "..move..".")            
        else
            nextTurnDmg[matchup] = (attacker["int"] * 3) - defender["will"]
            attacker["unleashReady"] = true
            scene:BattleLogAdd(attacker["name"].." prepares to "..move.." on "..defender["name"]..".")
        end   
        
        -- give an arbitrary value to dmg if 0 or below, so that the game shows the text when DRUTurnTwo is activated
        if nextTurnDmg[matchup] < 1 then
            nextTurnDmg[matchup] = -1
        end 
    end
    
    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()  
end

function scene:DRUTurnTwo(attacker, defender, matchup, move)
    if move == "Delayed Reaction" then
        scene:CheckSilenceBlind("statusBlind")
    else
        scene:CheckSilenceBlind("statusSilence")
    end    
    
    if not turnLost then
        if (matchup == "pcVnpcPet" or matchup == "pcPetVnpcPet") and npcPetMelee == false then
            -- npc melee pet is no longer in battle
            scene:BattleLogAdd(attacker["name"].."'s "..move.." does nothing, as the intended target is no longer in the battle.")
        elseif (matchup == "npcVpcPet" or matchup == "npcPetVpcPet") and pcPetMelee == false then
            -- pc melee pet is no longer in battle
            scene:BattleLogAdd(attacker["name"].."'s "..move.." does nothing, as the intended target is no longer in the battle.")            
        elseif nextTurnDmg[matchup] == -1 then
            scene:BattleLogAdd(attacker["name"].."'s "..move.." does no damage to "..defender["name"]..".")                        
        else
            defender["currentHp"] = defender["currentHp"] - nextTurnDmg[matchup]
            scene:BattleLogAdd(attacker["name"].."'s "..move.." goes off, doing "..nextTurnDmg[matchup].." damage to "..defender["name"]..".")                                    
        end
    end
    
    if move == "Delayed Reaction" then
        attacker["delayedReactionReady"] = false
    else
        attacker["delayedReactionReady"] = false
    end        
    
    nextTurnDmg[matchup] = 0
    turnLost = true    
end

function scene:Fireball(attacker, defender)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
        local attack = (attacker["int"] * 2 * defender["fire"]) - defender["will"]
        
        -- set the damage to 0 if it's less than 0, otherwise round it
        if attack < 0 then
            attack = 0
        else
            attack = utilities:Round(attack)
        end
        
        defender["currentHp"] = defender["currentHp"] - attack
        
        if defender["fire"] ~= 0 then            
            scene:BattleLogAdd(attacker["name"].." conjures a Fireball, doing "..attack.." fire damage to "..defender["name"]..".")
        else
            scene:BattleLogAdd(attacker["name"].." conjures a Fireball, but "..defender["name"].." is resistant to fire.")
        end  
    end
    
    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()       
end

function scene:Shockwave(attacker, defender)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
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
            scene:BattleLogAdd(attacker["name"].." releases a mighty Shockwave, doing "..attack.." lightning damage to "..defender["name"]..".")            
        elseif defender["lightning"] == 0 then  
            scene:BattleLogAdd(attacker["name"].." releases a Shockwave, but "..defender["name"].." is resistant to lightning.")            
        else
            scene:BattleLogAdd(attacker["name"].." releases a Shockwave, doing "..attack.." lightning damage to "..defender["name"]..".")   
        end  
    end
    
    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()       
end

function scene:Venom(attacker, defender)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
        local roll = utilities:RNG(3)
        local attack = roll * defender["poison"] * attacker["level"]   
        attack = utilities:Round(attack)
        
        -- poison can be reapplied for new damage. this allows it to be used as an attack or to improve the poison damage
        if attack > 0 then
            defender["currentHp"] = defender["currentHp"] - attack
            defender["dotPoison"] = true
            defender["dotPoisonDmg"] = attack            
            scene:BattleLogAdd(attacker["name"].." uses Venom on "..defender["name"]..", poisoning them for an ongoing "..attack.." damage.")
            
            if defender["type"] == "pc" then
                pcPoisonImg.isVisible = true
            elseif defender["type"] == "pcPet" then
                pcPetPoisonImg.isVisible = true
            elseif defender["type"] == "npc" then
                npcPoisonImg.isVisible = true
            elseif defender["type"] == "npcPet" then
                npcPetPoisonImg.isVisible = true
            end            
        elseif defender["poison"] == 0 then  
            scene:BattleLogAdd(attacker["name"].." uses Venom on "..defender["name"]..", but they are resistant to poison.")            
        else
            scene:BattleLogAdd(attacker["name"].." uses Venom on "..defender["name"]..", but the poison doesn't take hold.")   
        end  
    end
    
    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()       
end

function scene:Leech(attacker, defender)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
        local roll = utilities:RNG(3)
        local attack = roll * defender["disease"] * attacker["level"]
        attack = utilities:Round(attack)
        
        if defender["disease"] ~= 0 then
            defender["currentHp"] = defender["currentHp"] - attack
            attacker["currentHp"] = attacker["currentHp"] + attack
            
            if attacker["currentHp"] > attacker["hp"] then
                attacker["currentHp"] = attacker["hp"]
            end
            
            scene:BattleLogAdd(attacker["name"].." Leeches from "..defender["name"]..", inflicting and restoring "..attack.." disease damage.")            
        else
            scene:BattleLogAdd(attacker["name"].." Leeches, but "..defender["name"].." is resistant to disease.")            
        end  
    end
    
    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()       
end

function scene:IceStorm(attacker, defender)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
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
            scene:BattleLogAdd(attacker["name"].." summons an Ice Storm, but "..defender["name"].." is resistant to ice.")                        
        elseif roll == 2 then
            scene:BattleLogAdd(attacker["name"].." summons an Ice Storm, doing "..attack.." ice damage to "..defender["name"]..".")            
        else
            scene:BattleLogAdd(attacker["name"].." tries to summon an Ice Storm, but fails.")   
        end  
    end
    
    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()       
end

function scene:RockWall(attacker, defender)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
        local attack = (attacker["int"] + attacker["level"]) * defender["earth"]
        attack = utilities:Round(attack)
        
        defender["currentHp"] = defender["currentHp"] - attack
        
        if defender["earth"] ~= 0 then            
            scene:BattleLogAdd(attacker["name"].." creates a Rock Wall, doing "..attack.." earth damage to "..defender["name"]..".")
        else
            scene:BattleLogAdd(attacker["name"].." creates a Rock Wall, but "..defender["name"].." is resistant to earth.")
        end  
    end
    
    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()       
end

function scene:Heal(attacker)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
        local attack = attacker["int"] * 3
 
        attacker["currentHp"] = attacker["currentHp"] + attack

        if attacker["currentHp"] > attacker["hp"] then
            attacker["currentHp"] = attacker["hp"]
        end
            
        if attack > 0 then            
            scene:BattleLogAdd(attacker["name"].." Heals, restoring "..attack.." health.")
        else
            scene:BattleLogAdd(attacker["name"].." tries to Heal, but it has no effect.")
        end  
    end
    
    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()       
end

function scene:Cleanse(attacker)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
        scene:BattleLogAdd(attacker["name"].." Cleanses, removing all negative status effects.")
        
        -- remove status effects
        attacker["dotPoison"] = false
        attacker["dotPoisonDmg"] = false       
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
        
        -- hide images
        if attacker["type"] == "pc" then
            pcCrampImg.isVisible = false
            pcCrippleImg.isVisible = false
            pcMindBreakImg.isVisible = false
            pcDeludeImg.isVisible = false
            pcPoisonImg.isVisible = false
            pcBlindImg.isVisible = false
            pcSilenceImg.isVisible = false
            pcLullImg.isVisible = false            
        elseif attacker["type"] == "pcPet" then
            pcPetCrampImg.isVisible = false
            pcPetCrippleImg.isVisible = false
            pcPetMindBreakImg.isVisible = false
            pcPetDeludeImg.isVisible = false
            pcPetPoisonImg.isVisible = false
            pcPetBlindImg.isVisible = false
            pcPetSilenceImg.isVisible = false
            pcPetLullImg.isVisible = false           
        elseif attacker["type"] == "npc" then
            npcCrampImg.isVisible = false
            npcCrippleImg.isVisible = false
            npcMindBreakImg.isVisible = false
            npcDeludeImg.isVisible = false
            npcPoisonImg.isVisible = false
            npcBlindImg.isVisible = false
            npcSilenceImg.isVisible = false
            npcLullImg.isVisible = false               
        elseif attacker["type"] == "npcPet" then
            npcPetCrampImg.isVisible = false
            npcPetCrippleImg.isVisible = false
            npcPetMindBreakImg.isVisible = false
            npcPetDeludeImg.isVisible = false
            npcPetPoisonImg.isVisible = false
            npcPetBlindImg.isVisible = false
            npcPetSilenceImg.isVisible = false
            npcPetLullImg.isVisible = false               
        end 
    end
    
    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()       
end

function scene:CrampCrippleMindBreakDelude(attacker, defender, affliction)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
        local stat = ""
        local halfStat = 0
        
        -- todo consider whether to start the tick count at 0 or 1. at 0 they get 3 full turns of debuff applied to them
        if affliction == "Cramp" then
            stat = "strength"
            halfStat = defender["baseStr"] / 2
            defender["str"] = utilities:Round(halfStat)
            defender["debuffCramp"] = true
            defender["tickDebuffCramp"] = 0
            
            if defender["type"] == "pc" then
                pcCrampImg.isVisible = true
            elseif defender["type"] == "pcPet" then
                pcPetCrampImg.isVisible = true
            elseif defender["type"] == "npc" then
                npcCrampImg.isVisible = true
            elseif defender["type"] == "npcPet" then
                npcPetCrampImg.isVisible = true
            end                  
        elseif affliction == "Cripple" then
            stat = "defense"
            halfStat = defender["baseDef"] / 2
            defender["def"] = utilities:Round(halfStat)
            defender["debuffCripple"] = true
            defender["tickDebuffCripple"] = 0
            
            if defender["type"] == "pc" then
                pcCrippleImg.isVisible = true
            elseif defender["type"] == "pcPet" then
                pcPetCrippleImg.isVisible = true
            elseif defender["type"] == "npc" then
                npcCrippleImg.isVisible = true
            elseif defender["type"] == "npcPet" then
                npcPetCrippleImg.isVisible = true
            end                     
        elseif affliction == "Mind Break" then
            stat = "intelligence"
            halfStat = defender["baseInt"] / 2
            defender["int"] = utilities:Round(halfStat)
            defender["debuffMindBreak"] = true
            defender["tickDebuffMindBreak"] = 0
            
            if defender["type"] == "pc" then
                pcMindBreakImg.isVisible = true
            elseif defender["type"] == "pcPet" then
                pcPetMindBreakImg.isVisible = true
            elseif defender["type"] == "npc" then
                npcMindBreakImg.isVisible = true
            elseif defender["type"] == "npcPet" then
                npcPetMindBreakImg.isVisible = true
            end                     
        else
            stat = "will"
            halfStat = defender["baseWill"] / 2
            defender["will"] = utilities:Round(halfStat)
            defender["debuffDelude"] = true
            defender["tickDebuffDelude"] = 0
            
            if defender["type"] == "pc" then
                pcDeludeImg.isVisible = true
            elseif defender["type"] == "pcPet" then
                pcPetDeludeImg.isVisible = true
            elseif defender["type"] == "npc" then
                npcDeludeImg.isVisible = true
            elseif defender["type"] == "npcPet" then
                npcPetDeludeImg.isVisible = true
            end                     
        end

        scene:BattleLogAdd(attacker["name"].." casts "..affliction..", lowering "..defender["name"].."'s "..stat..".")
    end
    
    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()       
end

function scene:ForbiddenRitual(attacker, defender)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
        local roll = utilities:RNG(3)
        local attack = 0
        
        if roll ~= 1 then
            attack = defender["currentHp"] / 2
            attack = utilities:Round(attack)
            
            -- prevent defender from being killed if currentHp is 1
            if defender["currentHp"] == 1 and attack == 1 then
                scene:BattleLogAdd(attacker["name"].."'s Forbidden Ritual does no damage to "..defender["name"]..".")                            
            else
                defender["currentHp"] = defender["currentHp"] - attack                
                scene:BattleLogAdd(attacker["name"].." commits a Forbidden Ritual, doing "..attack.." damage to "..defender["name"]..".")              
            end
        else
            scene:BattleLogAdd(attacker["name"].." commits a Forbidden Ritual, but it fails.")                        
        end
    end
    
    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()       
end

function scene:Cannibalize(attacker, defender)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
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

        scene:BattleLogAdd(attacker["name"].." Cannibalizes flesh, suffering "..canniAtk.." damage and inflicting "..canniDef.." damage to "..defender["name"]..".")            
    end
    
    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()       
end

function scene:MindOverMatter(attacker, defender)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then        
        local attack = attacker["int"] - defender["def"] 
        
        if attack < 0 then
            attack = 0
        end        
        
        defender["currentHp"] = defender["currentHp"] - attack 
        
        if attack > 0 then            
            scene:BattleLogAdd(attacker["name"].." projects Mind Over Matter, doing "..attack.." damage to "..defender["name"]..".")
        else
            scene:BattleLogAdd(attacker["name"].."'s Mind Over Matter does "..attack.." damage to "..defender["name"]..".")
        end      
    end

    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()    
end

function scene:Blast(attacker, defender)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
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
            scene:BattleLogAdd(attacker["name"].." critically Blasts  "..defender["name"]..", doing "..attack.." damage.")
        elseif roll == 1 then
            scene:BattleLogAdd(attacker["name"].."'s Blast misses the mark, doing "..attack.." damage to "..defender["name"]..".")            
        else
            scene:BattleLogAdd(attacker["name"].."'s Blast does "..attack.." damage to "..defender["name"]..".")            
        end
    end

    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()    
end

function scene:FinalCountdownTurnOne(attacker, defender, matchup)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
        local roll = utilities:RNG(2)
        
        if roll == 2 then
            nextTurnDmg[matchup] = -1
            attacker["finalCountdownReady"] = true
            attacker["tickFinalCountdown"] = 1 -- could set this to 0 if FC is too OP            
            scene:BattleLogAdd(attacker["name"].." begins a Final Countdown, hexing "..defender["name"]..".")            
        else
            scene:BattleLogAdd(attacker["name"].." tries to hex "..defender["name"].." with Final Countdown, but fails.")
        end  
    end

    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()    
end

function scene:FinalCountdownActive(attacker, defender, matchup)
    -- the way this is set up, silence will stop the FC
    if attacker["tickFinalCountdown"] ~= 3 then
        scene:CheckSilenceBlind("statusSilence")

        if not turnLost then
            scene:BattleLogAdd(attacker["name"].." continues the Final Countdown.")
            attacker["tickFinalCountdown"] = attacker["tickFinalCountdown"] + 1         
        else
            -- fc broken by silence
            attacker["tickFinalCountdown"] = 0
            attacker["finalCountdownReady"] = false
            nextTurnDmg[matchup] = 0
        end
    else
        scene:CheckSilenceBlind("statusSilence")    
    
        if not turnLost then
            if (matchup == "pcVnpcPet" or matchup == "pcPetVnpcPet") and npcPetMelee == false then
                -- npc melee pet is no longer in battle
                scene:BattleLogAdd(attacker["name"].."'s Final Countdown does nothing, as the intended target is no longer in the battle.")
            elseif (matchup == "npcVpcPet" or matchup == "npcPetVpcPet") and pcPetMelee == false then
                -- pc melee pet is no longer in battle
                scene:BattleLogAdd(attacker["name"].."'s Final Countdown does nothing, as the intended target is no longer in the battle.")            
            else -- FC goes off
                defender["currentHp"] = 0
                scene:BattleLogAdd(attacker["name"].."'s Final Countdown ends, killing "..defender["name"]..".")                                                    
            end     
        end
        
        -- fc broken by silence or it was executed
        attacker["tickFinalCountdown"] = 0
        attacker["finalCountdownReady"] = false
        nextTurnDmg[matchup] = 0  
    end
    
    turnLost = true
end

function scene:SilenceLullBlind(attacker, defender, affliction)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
        local roll = utilities:RNG(3)
        
        if roll ~= 1 then
            if affliction == "Silences" then
                defender["statusSilence"] = true
                defender["tickStatusSilence"] = 0

                if defender["type"] == "pc" then
                    pcSilenceImg.isVisible = true
                elseif defender["type"] == "pcPet" then
                    pcPetSilenceImg.isVisible = true
                elseif defender["type"] == "npc" then
                    npcSilenceImg.isVisible = true
                elseif defender["type"] == "npcPet" then
                    npcPetSilenceImg.isVisible = true
                end       
                
                scene:BattleLogAdd(attacker["name"].." "..affliction.." "..defender["name"]..", preventing them from using magical abilities.")                
            elseif affliction == "Blinds" then
                defender["statusBlind"] = true
                defender["tickStatusBlind"] = 0

                if defender["type"] == "pc" then
                    pcBlindImg.isVisible = true
                elseif defender["type"] == "pcPet" then
                    pcPetBlindImg.isVisible = true
                elseif defender["type"] == "npc" then
                    npcBlindImg.isVisible = true
                elseif defender["type"] == "npcPet" then
                    npcPetBlindImg.isVisible = true
                end  
                
                scene:BattleLogAdd(attacker["name"].." "..affliction.." "..defender["name"]..", preventing them from using physical abilities.")
            else -- lull
                defender["statusLull"] = true

                if defender["type"] == "pc" then
                    pcLullImg.isVisible = true
                elseif defender["type"] == "pcPet" then
                    pcPetLullImg.isVisible = true
                elseif defender["type"] == "npc" then
                    npcLullImg.isVisible = true
                elseif defender["type"] == "npcPet" then
                    npcPetLullImg.isVisible = true
                end  
                
                scene:BattleLogAdd(attacker["name"].." "..affliction.." "..defender["name"].." to sleep, preventing them from taking action.")
            end        
        else
            scene:BattleLogAdd(attacker["name"].." "..affliction.." "..defender["name"]..", but they avoid the attempt.")
        end
    
    end
    
    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()       
end

function scene:MirrorMania(attacker, defender, pet)
    -- pass in tables for caster, character being mirrored, and the pet to be created
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then        
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
            
            -- todo add image
            if attacker["type"] == "pc" then
                pet["type"] = "pcPet"
                pcPetMagic = true   
                
                -- set labels
                pcPetStatGroup.isVisible = true
                pcPetNameLabel.text = pet["name"]
                pcPetHPLabel.text = pet["currentHp"].."/"..pet["hp"]
                pcPetAPLabel.text = pet["currentAp"].."/"..pet["ap"]                  
            elseif attacker["type"] == "npc" then
                pet["type"] = "npcPet"
                npcPetMagic = true
                
                -- set labels
                npcPetStatGroup.isVisible = true
                npcPetNameLabel.text = pet["name"]
                npcPetHPLabel.text = pet["currentHp"].."/"..pet["hp"]
                npcPetAPLabel.text = pet["currentAp"].."/"..pet["ap"]                  
            end
            
            scene:BattleLogAdd(attacker["name"].." casts Mirror Mania and spawns a shadow of "..defender["name"]..".")            
        else
            scene:BattleLogAdd(attacker["name"].." casts Mirror Mania, but it fails.")            
        end            
    end

    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()    
end

function scene:UndeadMinion(attacker, pet)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then        
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
                pcPetMelee = true   
                
                -- set labels
                pcPetStatGroup.isVisible = true
                pcPetNameLabel.text = pet["name"]
                pcPetHPLabel.text = pet["currentHp"].."/"..pet["hp"]
                pcPetAPLabel.text = pet["currentAp"].."/"..pet["ap"]                  
            elseif attacker["type"] == "npc" then
                pet["type"] = "npcPet"
                npcPetMelee = true
                
                -- set labels
                npcPetStatGroup.isVisible = true
                npcPetNameLabel.text = pet["name"]
                npcPetHPLabel.text = pet["currentHp"].."/"..pet["hp"]
                npcPetAPLabel.text = pet["currentAp"].."/"..pet["ap"]                  
            end
            
            scene:BattleLogAdd(attacker["name"].." summons an Undead Minion to aid in battle.")            
        else
            scene:BattleLogAdd(attacker["name"].." tries to summon an Undead Minion, but fails.")            
        end            
    end

    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()    
end

function scene:AssistedSuicide(attacker, defender)
    scene:CheckSilenceBlind("statusSilence")
    
    if not turnLost then
        local roll = utilities:RNG(4)
        local attack = 0
        
        if roll ~= 1 then
            roll = utilities:RNG(6)
            attack = defender["str"] + defender["level"] + roll - defender["def"]
            
            if attack < 0 then
                attack = 0
            end  
            
            defender["currentHp"] = defender["currentHp"] - attack
            
            scene:BattleLogAdd(attacker["name"].." performs Assisted Suicide on "..defender["name"].." doing "..attack.." damage.")            
        else
            scene:BattleLogAdd(attacker["name"].."'s Assisted Suicide misses the mark, doing "..attack.." damage to "..defender["name"]..".")
        end
    end

    attacker["currentAp"] =  attacker["currentAp"] - 1
    scene:EndTurn()    
end

function scene:AbilityOneClick()
    if not pcTurnPet and pcStats["currentAp"] == 0 then
        scene:BattleLogAdd("You are out of AP. Try Meditating.")
    elseif pcTurnPet and pcPetStats["currentAp"] == 0 then
        scene:BattleLogAdd("Your pet is out of AP. Try Meditating.")
    elseif pcTurn and not pcTurnPet then
        scene:UseAbilityClick(pcStats["abil1"])
    elseif pcTurn and pcTurnPet then
        scene:UseAbilityClick(pcPetStats["abil1"])
    end    
end

function scene:AbilityTwoClick()
    if not pcTurnPet and pcStats["currentAp"] == 0 then
        scene:BattleLogAdd("You are out of AP. Try Meditating.")
    elseif pcTurnPet and pcPetStats["currentAp"] == 0 then
        scene:BattleLogAdd("Your pet is out of AP. Try Meditating.")
    elseif pcTurn and not pcTurnPet then
        scene:UseAbilityClick(pcStats["abil2"])
    elseif pcTurn and pcTurnPet then
        scene:UseAbilityClick(pcPetStats["abil2"])
    end    
end

function scene:AbilityThreeClick()
    if not pcTurnPet and pcStats["currentAp"] == 0 then
        scene:BattleLogAdd("You are out of AP. Try Meditating.")
    elseif pcTurnPet and pcPetStats["currentAp"] == 0 then
        scene:BattleLogAdd("Your pet is out of AP. Try Meditating.")
    elseif pcTurn and not pcTurnPet then
        scene:UseAbilityClick(pcStats["abil3"])
    elseif pcTurn and pcTurnPet then
        scene:UseAbilityClick(pcPetStats["abil3"])
    end    
end

function scene:AbilityFourClick()
    if not pcTurnPet and pcStats["currentAp"] == 0 then
        scene:BattleLogAdd("You are out of AP. Try Meditating.")
    elseif pcTurnPet and pcPetStats["currentAp"] == 0 then
        scene:BattleLogAdd("Your pet is out of AP. Try Meditating.")
    elseif pcTurn and not pcTurnPet then
        scene:UseAbilityClick(pcStats["abil4"])
    elseif pcTurn and pcTurnPet then
        scene:UseAbilityClick(pcPetStats["abil4"])
    end    
end

function scene:AbilityFiveClick()
    if not pcTurnPet and pcStats["currentAp"] == 0 then
        scene:BattleLogAdd("You are out of AP. Try Meditating.")
    elseif pcTurnPet and pcPetStats["currentAp"] == 0 then
        scene:BattleLogAdd("Your pet is out of AP. Try Meditating.")
    elseif pcTurn and not pcTurnPet then
        scene:UseAbilityClick(pcStats["abil5"])
    elseif pcTurn and pcTurnPet then
        scene:UseAbilityClick(pcPetStats["abil5"])
    end    
end

function scene:AbilitySixClick()
    if not pcTurnPet and pcStats["currentAp"] == 0 then
        scene:BattleLogAdd("You are out of AP. Try Meditating.")
    elseif pcTurnPet and pcPetStats["currentAp"] == 0 then
        scene:BattleLogAdd("Your pet is out of AP. Try Meditating.")
    elseif pcTurn and not pcTurnPet then
        scene:UseAbilityClick(pcStats["abil6"])
    elseif pcTurn and pcTurnPet then
        scene:UseAbilityClick(pcPetStats["abil6"])
    end    
end

-- called by ability buttons to perform the ability. afflictions and pets will be checked to make sure they can be used.
-- all other abilities will just be executed
function scene:UseAbilityClick(ability)
    if ability == 9 then -- venom
        scene:StatusAilmentCheck(ability, "dotPoison", "Poisoned")
    elseif ability == 15 then   -- cramp
        scene:StatusAilmentCheck(ability, "debuffCramp", "Cramped")
    elseif ability == 16 then   -- cripple
        scene:StatusAilmentCheck(ability, "debuffCripple", "Crippled")
    elseif ability == 17 then   -- mind break
        scene:StatusAilmentCheck(ability, "debuffMindBreak", "Mind Broken")
    elseif ability == 18 then   -- delude
        scene:StatusAilmentCheck(ability, "debuffDelude", "Deluded")
    elseif ability == 25 then   -- silence
        scene:StatusAilmentCheck(ability, "statusSilence", "Silenced")
    elseif ability == 26 then   -- mirror mania
        scene:PetOutCheck(ability)
    elseif ability == 27 then   -- undead minion
        scene:PetOutCheck(ability)
    elseif ability == 28 then   -- lull
        scene:StatusAilmentCheck(ability, "statusLull", "Lulled")
    elseif ability == 30 then   -- blind
        scene:StatusAilmentCheck(ability, "statusBlind", "Blinded")
    else -- ability isn't an affliction or pet
        scene:ExecuteAbility(ability)
    end
end

-- make sure player isn't trying to debuff or poison if they are already active when trying to use ability
function scene:StatusAilmentCheck(ability, affliction, afflictionText)
    if npcPetMelee then
        if npcPetStats[affliction] then
            scene:BattleLogAdd(npcPetStats["name"].." is already "..affliction..".")
        else
            scene:ExecuteAbility(ability)
        end
    else
        if npcStats[affliction] then
            scene:BattleLogAdd(npcStats["name"].." is already "..affliction..".")
        else
            scene:ExecuteAbility(ability)
        end        
    end
end

-- make sure player isn't trying to call a pet if one is out already
function scene:PetOutCheck(ability)
    if pcPetMelee or pcPetMagic then
        scene:BattleLogAdd("There is already a pet in the battle.")
    else
        scene:ExecuteAbility(ability)
    end
end

-- calls individual ability functions based on the passed in index number
-- parameters will be passed into the ability based on whose turn it is and who is active in battle
-- this function will be called from the ability buttons by the player or by the ai function
-- any checks such as if a pet is already active or if an affliction is already active are done before this is called
function scene:ExecuteAbility(abilIndex)    
    -- todo make sure this works right doing it this way
    
    local attacker, defender, pet, matchup
    
    -- first determine whose turn it is (attacker), then who is defending (defender)
    -- also create a string for the matchup of who is facing off. this is only used by multi turn abilities
    -- some functions may not need all of this info, but gather it just in case to cut down on bloat of determining this individually for each ability
    if pcTurn then
        if pcTurnPet then -- pc pet turn
            attacker = pcPetStats
            pet = {}
            if npcPetMelee then -- attack npc pet
                defender = npcPetStats
                matchup = "pcPetVnpcPet"
            else -- attack npc
                defender = npcStats
                matchup = "pcPetVnpc"
            end
        else -- pc turn
            attacker = pcStats
            pet = pcPetStats
            if npcPetMelee then -- attack npc pet
                defender = npcPetStats
                matchup = "pcVnpcPet"
            else -- attack npc
                defender = npcStats
                matchup = "pcVnpc"
            end                
        end
    else
        if npcTurnPet then -- npc pet turn
            attacker = npcPetStats
            pet = {}
            if pcPetMelee then -- attack pc pet
                defender = pcPetStats
                matchup = "npcPetVpcPet"
            else -- attack pc
                defender = pcStats
                matchup = "npcPetVpc"
            end
        else -- npc turn
            attacker = npcStats
            pet = npcPetStats
            if pcPetMelee then -- attack pc pet
                defender = pcPetStats
                matchup = "npcVpcPet"
            else -- attack pc
                defender = pcStats
                matchup = "npcVpc"
            end                
        end  
    end        
    
    -- call the individual ability function, passing in relevent data as determined above
    if abilIndex == 1 then  -- cleave
        scene:Cleave(attacker, defender)
    elseif abilIndex == 2 then  -- berserk
        scene:Berserk(attacker, defender)
    elseif abilIndex == 3 then  -- test of will
        scene:TestOfWill(attacker, defender)
    elseif abilIndex == 4 then  -- backstab
        scene:Backstab(attacker, defender)
    elseif abilIndex == 5 then  -- beat down
        scene:BeatDown(attacker, defender)
    elseif abilIndex == 6 then  -- delayed reaction
        scene:DRUTurnOne(attacker, defender, matchup, "Delayed Reaction")
    elseif abilIndex == 7 then  -- fireball
        scene:Fireball(attacker, defender)
    elseif abilIndex == 8 then  -- shockwave
        scene:Shockwave(attacker, defender)
    elseif abilIndex == 9 then  -- venom
        scene:Venom(attacker, defender)
    elseif abilIndex == 10 then -- leech
        scene:Leech(attacker, defender)
    elseif abilIndex == 11 then -- ice storm
        scene:IceStorm(attacker, defender)
    elseif abilIndex == 12 then -- rock wall
        scene:RockWall(attacker, defender)
    elseif abilIndex == 13 then -- heal
        scene:Heal(attacker)
    elseif abilIndex == 14 then -- cleanse
        scene:Cleanse(attacker)
    elseif abilIndex == 15 then -- cramp
        scene:CrampCrippleMindBreakDelude(attacker, defender, "Cramp")
    elseif abilIndex == 16 then -- cripple
        scene:CrampCrippleMindBreakDelude(attacker, defender, "Cripple")
    elseif abilIndex == 17 then -- mind break
        scene:CrampCrippleMindBreakDelude(attacker, defender, "Mind Break")
    elseif abilIndex == 18 then -- delude
        scene:CrampCrippleMindBreakDelude(attacker, defender, "Delude")
    elseif abilIndex == 19 then -- forbidden ritual
        scene:ForbiddenRitual(attacker, defender)
    elseif abilIndex == 20 then -- cannibalize
        scene:Cannibalize(attacker, defender)
    elseif abilIndex == 21 then -- mind over matter
        scene:MindOverMatter(attacker, defender)
    elseif abilIndex == 22 then -- blast
        scene:Blast(attacker, defender)
    elseif abilIndex == 23 then -- final countdown
        scene:FinalCountdownTurnOne(attacker, defender, matchup)
    elseif abilIndex == 24 then -- unleash
        scene:DRUTurnOne(attacker, defender, matchup, "Unleash")
    elseif abilIndex == 25 then -- silence
        scene:SilenceLullBlind(attacker, defender, "Silences")
    elseif abilIndex == 26 then -- mirror mania
        scene:MirrorMania(attacker, defender, pet)
    elseif abilIndex == 27 then -- undead minion
        scene:UndeadMinion(attacker, pet)
    elseif abilIndex == 28 then -- lull
        scene:SilenceLullBlind(attacker, defender, "Lulls")
    elseif abilIndex == 29 then -- assisted suicide
        scene:AssistedSuicide(attacker, defender)
    elseif abilIndex == 30 then -- blind
        scene:SilenceLullBlind(attacker, defender, "Blinds")
    end
end

function scene:EndTurnClick()
    scene:EndTurn() -- this will see if anyone has died, update labels, etc. added this for if player hits end turn without taking any sort of regular action
    
    -- decide who's turn is next and who the defender is
    if (pcTurn and not pcTurnPet) then
        if (pcPetMelee or pcPetMagic) then
            pcTurnPet = true
            scene:BattleLogAdd(pcPetStats["name"].."'s turn.")
            
            if npcPetMelee then
                scene:StartTurn(pcPetStats, npcPetStats)
            else
                scene:StartTurn(pcPetStats, npcStats)
            end
        else
            pcTurn = false
            scene:BattleLogAdd(npcStats["name"].."'s turn.")
            scene:StartTurn(npcStats, pcStats)
        end        
    elseif pcTurnPet then
        pcTurn = false
        pcTurnPet = false
        scene:BattleLogAdd(npcStats["name"].."'s turn.")
        
        if pcPetMelee then
            scene:StartTurn(npcStats, pcPetStats)
        else
            scene:StartTurn(npcStats, pcStats)
        end
    elseif (not pcTurn and not pcTurnPet) then
        if (npcPetMelee or npcPetMagic) then
            npcTurnPet = true
            scene:BattleLogAdd(npcPetStats["name"].."'s turn.")
            
            if pcPetMelee then
                scene:StartTurn(npcPetStats, pcPetStats)
            else
                scene:StartTurn(npcPetStats, pcStats)
            end
        else
            pcTurn = true
            scene:BattleLogAdd(pcStats["name"].."'s turn.")
            scene:StartTurn(pcStats, npcStats)
        end
    else -- pc turn
        pcTurn = true
        npcTurnPet = false
        scene:BattleLogAdd(pcStats["name"].."'s turn.")
        
        if npcPetMelee then
            scene:StartTurn(pcStats, npcPetStats)
        else
            scene:StartTurn(pcStats, npcStats)
        end
    end
end

function scene:EndTurn()
    turnLost = false -- explicitely set this back to false. todo make sure this is where this should be
    
    --check for deaths, make hp 0 if < 0
    scene:Die()
    
    -- update hp/ap labels for all
    pcHPLabel.text = "HP: "..pcStats["currentHp"].."/"..pcStats["hp"]
    pcAPLabel.text = "AP: "..pcStats["currentAp"].."/"..pcStats["ap"]
    
    if pcPetMelee or pcPetMagic then
        pcPetHPLabel.text = "HP: "..pcPetStats["currentHp"].."/"..pcPetStats["hp"]
        pcPetAPLabel.text = "AP: "..pcPetStats["currentAp"].."/"..pcPetStats["ap"] 
    end    

    npcHPLabel.text = "HP: "..npcStats["currentHp"].."/"..npcStats["hp"]
    npcAPLabel.text = "AP: "..npcStats["currentAp"].."/"..npcStats["ap"]
    
    if npcPetMelee or pcPetMagic then    
        npcPetHPLabel.text = "HP: "..npcPetStats["currentHp"].."/"..npcPetStats["hp"]
        npcPetAPLabel.text = "AP: "..npcPetStats["currentAp"].."/"..npcPetStats["ap"]    
    end
    
    -- todo find a better way to deal with this. using images might be ok, then just disable them ex: attackButton:setEnabled(false)
    attackButton.isVisible = false
    abilityButton.isVisible = false
    itemButton.isVisible = false
    meditateButton.isVisible = false
    runButton.isVisible = false  
    endTurnButton.isVisible = true
            
    -- hide abil buttons     
    showAbilities = false
    abil1Button.isVisible = false
    abil2Button.isVisible = false
    abil3Button.isVisible = false
    abil4Button.isVisible = false
    abil5Button.isVisible = false
    abil6Button.isVisible = false
    abil7Button.isVisible = false
    abil8Button.isVisible = false
    abil9Button.isVisible = false
    abil10Button.isVisible = false
    abil11Button.isVisible = false
    abil12Button.isVisible = false

    -- todo add anything else that needs changed here    
end

--check ticks, call on ai after player finishes turn, check to see if a player is dead
-- tables are passed in for attacker (whomever's turn it is) and defender (defender is pc or npc or melee pet)
-- called by the EndTurnClick function
function scene:StartTurn(attacker, defender)
    
    scene:Ticks("Poison", attacker) -- tick poison first since it may kill attacker and doesn't go away. turnLost will be set to true if attacker dies
    
    if not turnLost then -- tick non damaging afflictions, status effects, and mirror mania
       scene:Ticks("Cramped", attacker)
       scene:Ticks("Crippled", attacker)
       scene:Ticks("Mind Broken", attacker)
       scene:Ticks("Deluded", attacker)
       scene:Ticks("Silenced", attacker)
       scene:Ticks("Blinded", attacker)
       scene:Ticks("Mirror Mania", attacker)
       scene:Ticks("Lulled", attacker)
    end
    
    -- try to execute a multiturn move
    if not turnLost then
        scene:TickMultiTurnMoves(attacker, defender)
    end    
    
    if not turnLost and not pcTurn then
        scene:AI(attacker, defender)-- start AI routine
        endTurnButton:setLabel("End NPC Turn")
    elseif not turnLost and pcTurn then
        if pcTurnPet then
            endTurnButton:setLabel("End Player Pet Turn")            
        else
            endTurnButton:setLabel("End Player Turn")
        end
        
        -- enable controls
        attackButton.isVisible = true
        abilityButton.isVisible = true
        itemButton.isVisible = true
        meditateButton.isVisible = true
        runButton.isVisible = true    
    else
        turnLost = false
        scene:EndTurn()
    end    
end

-- tick down various conditions or abilities, apply damage if applicable
-- this is called before a turn starts and an action can be taken
function scene:Ticks(condition, attacker)
    
    local toonName = attacker["name"]
    local toonType = attacker["type"] -- this will either be pc, npc, pcPet, or npcPet
    
    if condition == "Poison" and attacker["dotPoison"] then
        attacker["currentHp"] = attacker["currentHp"] - attacker["dotPoisonDmg"]
        
        if attacker["currentHp"] < 1 then
            attacker["currentHp"] = 0
        end        

        if toonType == "pc" then
            pcHPLabel.text = "HP: "..attacker["currentHp"].."/"..attacker["hp"]    
        elseif toonType == "pcPet" then
            pcPetHPLabel.text = "HP: "..attacker["currentHp"].."/"..attacker["hp"] 
        elseif toonType == "npc" then
            npcHPLabel.text = "HP: "..attacker["currentHp"].."/"..attacker["hp"] 
        elseif toonType == "npcPet" then
            npcPetHPLabel.text = "HP: "..attacker["currentHp"].."/"..attacker["hp"] 
        end
        
        scene:BattleLogAdd(toonName.." has taken "..attacker["dotPoisonDmg"].." damage from "..condition..".") 
        
        if attacker["currentHp"] < 1 then
            turnLost = true
        end       
    elseif condition == "Cramped" and attacker["debuffCramp"] then
        if attacker["tickDebuffCramp"] ~= 3 then
            attacker["tickDebuffCramp"] = attacker["tickDebuffCramp"] + 1
        else
            attacker["tickDebuffCramp"] = 0
            attacker["debuffCramp"] = false            
            attacker["str"] = attacker["baseStr"]
            
            if toonType == "pc" then
                pcCrampImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetCrampImg.isVisible = false
            elseif toonType == "npc" then
                npcCrampImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetCrampImg.isVisible = false
            end       
            
            scene:BattleLogAdd(toonName.." is no longer "..condition..".")
        end
    elseif condition == "Crippled" and attacker["debuffCripple"] then
        if attacker["tickDebuffCripple"] ~= 3 then
            attacker["tickDebuffCripple"] = attacker["tickDebuffCripple"] + 1
        else
            attacker["tickDebuffCripple"] = 0
            attacker["debuffCripple"] = false            
            attacker["def"] = attacker["baseDef"]
            
            if toonType == "pc" then
                pcCrippleImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetCrippleImg.isVisible = false
            elseif toonType == "npc" then
                npcCrippleImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetCrippleImg.isVisible = false
            end       
            
            scene:BattleLogAdd(toonName.." is no longer "..condition..".")
        end        
    elseif condition == "Mind Broken" and attacker["debuffMindBreak"] then
        if attacker["tickDebuffMindBreak"] ~= 3 then
            attacker["tickDebuffMindBreak"] = attacker["tickDebuffMindBreak"] + 1
        else
            attacker["tickDebuffMindBreak"] = 0
            attacker["debuffMindBreak"] = false            
            attacker["int"] = attacker["baseInt"]
            
            if toonType == "pc" then
                pcMindBreakImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetMindBreakImg.isVisible = false
            elseif toonType == "npc" then
                npcMindBreakImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetMindBreakImg.isVisible = false
            end       
            
            scene:BattleLogAdd(toonName.." is no longer "..condition..".")
        end             
    elseif condition == "Deluded" and attacker["debuffDelude"] then
        if attacker["tickDebuffDelude"] ~= 3 then
            attacker["tickDebuffDelude"] = attacker["tickDebuffDelude"] + 1
        else
            attacker["tickDebuffDelude"] = 0
            attacker["debuffDelude"] = false            
            attacker["will"] = attacker["baseWill"]
            
            if toonType == "pc" then
                pcDeludeImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetDeludeImg.isVisible = false
            elseif toonType == "npc" then
                npcDeludeImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetDeludeImg.isVisible = false
            end       
            
            scene:BattleLogAdd(toonName.." is no longer "..condition..".")
        end             
    elseif condition == "Silenced" and attacker["statusSilence"] then
        if attacker["tickStatusSilence"] ~= 3 then
            attacker["tickStatusSilence"] = attacker["tickStatusSilence"] + 1
        else
            attacker["tickStatusSilence"] = 0
            attacker["statusSilence"] = false
            
            if toonType == "pc" then
                pcSilenceImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetSilenceImg.isVisible = false
            elseif toonType == "npc" then
                npcSilenceImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetSilenceImg.isVisible = false
            end       
            
            scene:BattleLogAdd(toonName.." is no longer "..condition..".")
        end             
    elseif condition == "Blinded" and attacker["statusBlind"] then
        if attacker["tickStatusBlind"] ~= 3 then
            attacker["tickStatusBlind"] = attacker["tickStatusBlind"] + 1
        else
            attacker["tickStatusBlind"] = 0
            attacker["statusBlind"] = false
            
            if toonType == "pc" then
                pcBlindImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetBlindImg.isVisible = false
            elseif toonType == "npc" then
                npcBlindImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetBlindImg.isVisible = false
            end       
            
            scene:BattleLogAdd(toonName.." is no longer "..condition..".")
        end                     
    elseif condition == "Mirror Mania" and attacker["petMirrorMania"] then -- todo make sure this is working correctly
        if attacker["tickPetMirroMania"] ~= 3 then
            attacker["tickPetMirroMania"] = attacker["tickPetMirroMania"] + 1
        else
            attacker["tickPetMirroMania"] = 0
            attacker["petMirrorMania"] = false
            
            scene:ClearStats(toonType)
            
            scene:BattleLogAdd(toonName.."'s "..condition.." has ended.")
        end               
    elseif condition == "Lulled" and attacker["statusLull"] then
        local roll = utilities:RNG(3)
        
        if roll ~= 3 then
            scene:BattleLogAdd(toonName.." is still "..condition..".")
            turnLost = true
        else
            attacker["statusLull"] = false
            
            if toonType == "pc" then
                pcLullImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetLullImg.isVisible = false
            elseif toonType == "npc" then
                npcLullImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetLullImg.isVisible = false
            end       
            
            scene:BattleLogAdd(toonName.." is no longer "..condition..".")
        end             
    end
end

-- try to execute or tick Delayed Reaction, Unleash, and Final Countdown
-- this occurs by the StartTurn function
function scene:TickMultiTurnMoves(attacker, defender)
    -- first build a string of the current matchup to use as the index for nextTurnDmg table
    local matchup = attacker["type"].."V"..defender["type"]
    
    -- execute delayed reatcion
    if pcTurn then
        if pcTurnPet and attacker["delayedReactionReady"] then
            if nextTurnDmg[matchup] ~= 0 then
                scene:DRUTurnTwo(attacker, defender, matchup, "Delayed Reaction")                
            end
        elseif pcTurnPet == false and attacker["delayedReactionReady"] then
            if nextTurnDmg[matchup] ~= 0 then
                scene:DRUTurnTwo(attacker, defender, matchup, "Delayed Reaction") 
            end
        end
    else
        if npcTurnPet and attacker["delayedReactionReady"] then
            if nextTurnDmg[matchup] ~= 0 then
                scene:DRUTurnTwo(attacker, defender, matchup, "Delayed Reaction")                
            end
        elseif npcTurnPet == false and attacker["delayedReactionReady"] then
            if nextTurnDmg[matchup] ~= 0 then
                scene:DRUTurnTwo(attacker, defender, matchup, "Delayed Reaction") 
            end
        end        
    end
    
    -- execute unleash
    if pcTurn then
        if pcTurnPet and attacker["unleashReady"] then
            if nextTurnDmg[matchup] ~= 0 then
                scene:DRUTurnTwo(attacker, defender, matchup, "Unleash")                
            end
        elseif pcTurnPet == false and attacker["unleashReady"] then
            if nextTurnDmg[matchup] ~= 0 then
                scene:DRUTurnTwo(attacker, defender, matchup, "Unleash") 
            end
        end
    else
        if npcTurnPet and attacker["unleashReady"] then
            if nextTurnDmg[matchup] ~= 0 then
                scene:DRUTurnTwo(attacker, defender, matchup, "Unleash")                
            end
        elseif npcTurnPet == false and attacker["unleashReady"] then
            if nextTurnDmg[matchup] ~= 0 then
                scene:DRUTurnTwo(attacker, defender, matchup, "Unleash") 
            end
        end        
    end   
    
    -- execute final countdown
    if pcTurn then
        if pcTurnPet and attacker["finalCountdownReady"] then
            if nextTurnDmg[matchup] ~= 0 then
                scene:FinalCountdownActive(attacker, defender, matchup)                
            end
        elseif pcTurnPet == false and attacker["finalCountdownReady"] then
            if nextTurnDmg[matchup] ~= 0 then
                scene:FinalCountdownActive(attacker, defender, matchup) 
            end
        end
    else
        if npcTurnPet and attacker["finalCountdownReady"] then
            if nextTurnDmg[matchup] ~= 0 then
                scene:FinalCountdownActive(attacker, defender, matchup)                
            end
        elseif npcTurnPet == false and attacker["finalCountdownReady"] then
            if nextTurnDmg[matchup] ~= 0 then
                scene:FinalCountdownActive(attacker, defender, matchup) 
            end
        end        
    end        
end

-- determine if anyone has died
-- todo end the battle if npc or pc have died
function scene:Die()
    if pcStats["currentHp"] < 1 then
        pcStats["currentHp"] = 0
        scene:BattleLogAdd(pcStats["name"].." has died.")
    end
    
    if pcPetMelee and pcPetStats["currentHp"] < 1 then
        scene:BattleLogAdd(pcPetStats["name"].." has died.")
        pcPetStats = {}
        pcPetMelee = false
        pcPetMagic = false
        scene:ClearStats("pc")
    end
    
    if npcStats["currentHp"] < 1 then
        npcStats["currentHp"] = 0
        scene:BattleLogAdd(npcStats["name"].." has died.")
    end
    
    if npcPetMelee and npcPetStats["currentHp"] < 1 then
        scene:BattleLogAdd(npcPetStats["name"].." has died.")
        npcPetStats = {}
        npcPetMelee = false
        npcPetMagic = false
        scene:ClearStats("npc")
    end    
    
end

function scene:AI(attacker, defender)
    --todo add rest of stuff. for now just attack and return control to player
    scene:Attack(attacker, defender)
end

-- nil out tables for a pc or npc pet and hide their stat labels
-- passed in string will determine if clearing pc or npc pet
-- called when a pet dies or turns run out(mirror mania)
function scene:ClearStats(owner)
    if owner == "pc" then
        pcPetStats = {}
        pcPetMelee = false
        pcPetMagic = false
        
        pcPetCrampImg.isVisible = false
        pcPetCrippleImg.isVisible = false
        pcPetMindBreakImg.isVisible = false
        pcPetDeludeImg.isVisible = false
        pcPetPoisonImg.isVisible = false
        pcPetBlindImg.isVisible = false
        pcPetSilenceImg.isVisible = false
        pcPetLullImg.isVisible = false    
        pcPetStatGroup.isVisible = false
        
        pcPetNameLabel.text = ""
        pcPetHPLabel.text = "0/0"
        pcPetAPLabel.text = "0/0"        
    elseif owner == "npc" then
        npcPetStats = {}
        npcPetMelee = false
        npcPetMagic = false
        
        npcPetCrampImg.isVisible = false
        npcPetCrippleImg.isVisible = false
        npcPetMindBreakImg.isVisible = false
        npcPetDeludeImg.isVisible = false
        npcPetPoisonImg.isVisible = false
        npcPetBlindImg.isVisible = false
        npcPetSilenceImg.isVisible = false
        npcPetLullImg.isVisible = false    
        npcPetStatGroup.isVisible = false
        
        npcPetNameLabel.text = ""
        npcPetHPLabel.text = "0/0"
        npcPetAPLabel.text = "0/0"            
    end
end

-- set some initial conditions for battle
function scene:Initialize()
    pcPetMelee = false
    pcPetMagic = false
    npcPetMelee = false
    npcPetMagic = false
    turnLost = false
    
    -- explicitely set these to 0 so that if they are used in a comparison, a table index error doesn't occur
    nextTurnDmg["pcVnpc"] = 0
    nextTurnDmg["pcVnpcPet"] = 0
    nextTurnDmg["pcPetVnpc"] = 0
    nextTurnDmg["pcPetVnpcPet"] = 0
    nextTurnDmg["npcVpc"] = 0
    nextTurnDmg["npcVpcPet"] = 0
    nextTurnDmg["npcPetVpc"] = 0
    nextTurnDmg["npcPetVpcPet"] = 0
    
    pcPetStatGroup.isVisible = false
    npcPetStatGroup.isVisible = false
    
    -- todo add initiative roll here
    pcTurn = true
    pcTurnPet = false
    npcTurnPet = false    
    endTurnButton:setLabel("End Player Turn")
end

-- add a battle event to the scroller log
function scene:BattleLogAdd(logText)
    -- multiline text will be split and looped through, adding a max number of characters each line until completion
    
    local strMaxLen = 120
    local textWidth = scrollRectWidth
    local textHeight = 20    
    local outputDone = false
    local charCount = 0
    
    while not outputDone do
        local multiLine = ""
        charCount = string.len(logText)

        if charCount > strMaxLen then            
            multiLine = string.sub(logText, strMaxLen + 1)
            logText = string.sub(logText, 0, strMaxLen)
        end    

       local logOptions = {
            text = logText,
            x = textWidth/2 + 5,
            y = scrollY,
            width = textWidth,
            height = textHeight,
            font = native.systemFont,
            fontSize = 14,
            align = "left"    
        }  

        scrollY = scrollY + textHeight

        local itemLabel = display.newText(logOptions)
        itemLabel:setFillColor(1,1,1) 

        newScrollHeight = newScrollHeight + textHeight 
        scrollArea:insert(itemLabel)
        scrollArea.height = newScrollHeight * 2
        scrollView:setScrollHeight(newScrollHeight)  
        
        if charCount > strMaxLen then
            logText = "     "..multiLine
        else
            outputDone = true
        end    
    end
    
    -- once the visible area of the scroller is filled, new events will be added to the bottom and will give appearance of scrolling up
    if newScrollHeight >= visibleScroll then
        scrollView:scrollToPosition {x = 0,y = - newScrollHeight + visibleScroll,time = 400} -- had to set the y position to negative to get this to work right
    end      
    
end

-- functionality to press/depress abilities button and hide ability buttons
-- if they are to be shown, label and press functionality will be set by scene:SetAbilButtons
-- this function is called by the ability button when pressed
function scene:ShowHideAbilities()
    if not showAbilities then -- show ability buttons
        if not pcTurnPet then
            scene:SetAbilButtons(pcStats)
            
            attackButton.isVisible = false  
            abilityButton.isVisible = true
            itemButton.isVisible = false
            meditateButton.isVisible = false
            runButton.isVisible = false   
            endTurnButton.isVisible = false 
        elseif pcTurnPet then
            scene:SetAbilButtons(pcPetStats)
            
            attackButton.isVisible = false  
            abilityButton.isVisible = true
            itemButton.isVisible = false
            meditateButton.isVisible = false
            runButton.isVisible = false   
            endTurnButton.isVisible = false               
        end
    else -- hide ability buttons
        attackButton.isVisible = true
        abilityButton.isVisible = true
        itemButton.isVisible = true
        meditateButton.isVisible = true
        runButton.isVisible = true   
        endTurnButton.isVisible = true
        
        abil1Button.isVisible = false
        abil2Button.isVisible = false
        abil3Button.isVisible = false
        abil4Button.isVisible = false
        abil5Button.isVisible = false
        abil6Button.isVisible = false
        abil7Button.isVisible = false
        abil8Button.isVisible = false
        abil9Button.isVisible = false
        abil10Button.isVisible = false
        abil11Button.isVisible = false
        abil12Button.isVisible = false        
    end
    
    showAbilities = not showAbilities
end

function scene:SetAbilButtons(attacker)   
    if attacker["abil1"] then
        abil1Button:setLabel(GLOB.abilities[attacker["abil1"]]["Name"])
        abil1Button.isVisible = true
    else
        abil1Button.isVisible = false
    end
    
    if attacker["abil2"] then
        abil2Button:setLabel(GLOB.abilities[attacker["abil2"]]["Name"])
        abil2Button.isVisible = true
    else
        abil2Button.isVisible = false
    end

    if attacker["abil3"] then
        abil3Button:setLabel(GLOB.abilities[attacker["abil3"]]["Name"])
        abil3Button.isVisible = true
    else
        abil3Button.isVisible = false
    end
    
    if attacker["abil4"] then
        abil4Button:setLabel(GLOB.abilities[attacker["abil4"]]["Name"])
        abil4Button.isVisible = true
    else
        abil4Button.isVisible = false
    end
    
    if attacker["abil5"] then
        abil5Button:setLabel(GLOB.abilities[attacker["abil5"]]["Name"])
        abil5Button.isVisible = true
    else
        abil5Button.isVisible = false
    end
    
    if attacker["abil6"] then
        abil6Button:setLabel(GLOB.abilities[attacker["abil6"]]["Name"])
        abil6Button.isVisible = true
    else
        abil6Button.isVisible = false
    end
    
    if attacker["abil7"] then
        abil7Button:setLabel(GLOB.abilities[attacker["abil7"]]["Name"])
        abil7Button.isVisible = true
    else
        abil7Button.isVisible = false
    end
    
    if attacker["abil8"] then
        abil8Button:setLabel(GLOB.abilities[attacker["abil8"]]["Name"])
        abil8Button.isVisible = true
    else
        abil8Button.isVisible = false
    end
    
    if attacker["abil9"] then
        abil9Button:setLabel(GLOB.abilities[attacker["abil9"]]["Name"])
        abil9Button.isVisible = true
    else
        abil9Button.isVisible = false
    end
    
    if attacker["abil10"] then
        abil10Button:setLabel(GLOB.abilities[attacker["abil10"]]["Name"])
        abil10Button.isVisible = true
    else
        abil10Button.isVisible = false
    end
    
    if attacker["abil11"] then
        abil11Button:setLabel(GLOB.abilities[attacker["abil11"]]["Name"])
        abil11Button.isVisible = true
    else
        abil11Button.isVisible = false
    end
    
    if attacker["abil12"] then
        abil12Button:setLabel(GLOB.abilities[attacker["abil12"]]["Name"])
        abil12Button.isVisible = true
    else
        abil12Button.isVisible = false
    end  
    
    
end

function scene:MakeLabels(myScene)
    ---------------------
    -- BEGIN LABELS --
    ---------------------
    
    --todo: make the x and y coordinates for labels set at their top left point rather than center

    ------------------
    -- PC LABELS
    ------------------
    local pcStartingY = 15    
    local pcStatGroup = display.newContainer(300, 200) -- container for player stats on screen. could change to a regular group if there is a problem with the container
    pcStatGroup.x = 50
    

    -- the text label's center is point 0,0. this must be accounted for
    -- label for player name
    local textOptions = {
        text = pcStats["name"],
        x = 30,
        y = pcStartingY,
        anchorX = 0,
        width = 150,
        height = 30,
        font = native.systemFont,
        fontSize = 16,
        align = "left"    
    }    

    local pcNameLabel = display.newText(textOptions)
    --pcNameLabel:setFillColor(0,0,0)    
    
    -- HP label
    textOptions["y"] = pcStartingY * 2
    textOptions["x"] = 35
    textOptions["text"] = "HP: "..pcStats["hp"].."/"..pcStats["hp"]
    
    pcHPLabel = display.newText(textOptions)
    
    -- AP Label
    textOptions["y"] = pcStartingY * 3
    textOptions["text"] = "AP: "..pcStats["ap"].."/"..pcStats["ap"]
    
    pcAPLabel = display.newText(textOptions)    
    
    -- images
    pcCrampImg = display.newImage("images/cramp.png", system.ResourceDirectory)
    pcCrampImg.x = -36
    pcCrampImg.y = pcStartingY * 4
    
    pcCrippleImg = display.newImage("images/cripple.png", system.ResourceDirectory)    
    pcCrippleImg.x = -12
    pcCrippleImg.y = pcStartingY * 4    
    
    pcMindBreakImg = display.newImage("images/mindbreak.png", system.ResourceDirectory)    
    pcMindBreakImg.x = 12
    pcMindBreakImg.y = pcStartingY * 4        
    
    pcDeludeImg = display.newImage("images/delude.png", system.ResourceDirectory)    
    pcDeludeImg.x = 36
    pcDeludeImg.y = pcStartingY * 4   
    
    pcPoisonImg = display.newImage("images/poison.png", system.ResourceDirectory)    
    pcPoisonImg.x = -36
    pcPoisonImg.y = pcStartingY * 4 + 24       
    
    pcBlindImg = display.newImage("images/blind.png", system.ResourceDirectory)    
    pcBlindImg.x = -12
    pcBlindImg.y = pcStartingY * 4 + 24     
    
    pcSilenceImg = display.newImage("images/silence.png", system.ResourceDirectory)    
    pcSilenceImg.x = 12
    pcSilenceImg.y = pcStartingY * 4 + 24       
    
    pcLullImg = display.newImage("images/lull.png", system.ResourceDirectory)    
    pcLullImg.x = 36
    pcLullImg.y = pcStartingY * 4 + 24         
    
    pcStatGroup:insert(pcNameLabel) 
    pcStatGroup:insert(pcHPLabel)
    pcStatGroup:insert(pcAPLabel)
    pcStatGroup:insert(pcCrampImg)
    pcStatGroup:insert(pcCrippleImg)
    pcStatGroup:insert(pcMindBreakImg)
    pcStatGroup:insert(pcDeludeImg)
    pcStatGroup:insert(pcPoisonImg)
    pcStatGroup:insert(pcBlindImg)
    pcStatGroup:insert(pcSilenceImg)
    pcStatGroup:insert(pcLullImg)
    
    
    ------------------
    -- PC PET LABELS
    ------------------
    local pcPetStartingY = 15      
    pcPetStatGroup = display.newContainer(300, 200) -- container for player stats on screen. could change to a regular group if there is a problem with the container
    pcPetStatGroup.x = 50
    pcPetStatGroup.y = 100
    
    -- the text label's center is point 0,0. this must be accounted for
    -- label for player pet name
    textOptions["x"] = 30
    textOptions["y"] = pcPetStartingY    
    textOptions["text"] = "PC Pet Name"

    pcPetNameLabel = display.newText(textOptions)
    --pcNameLabel:setFillColor(0,0,0)    
    
    -- HP label
    textOptions["y"] = pcPetStartingY * 2
    textOptions["x"] = 35
    textOptions["text"] = "HP: 0/0"
    
    pcPetHPLabel = display.newText(textOptions)
    
    -- AP Label
    textOptions["y"] = pcPetStartingY * 3
    textOptions["text"] = "AP: 0/0"
    
    pcPetAPLabel = display.newText(textOptions)    
    
    -- images
    pcPetCrampImg = display.newImage("images/cramp.png", system.ResourceDirectory)
    pcPetCrampImg.x = -36
    pcPetCrampImg.y = pcPetStartingY * 4
    
    pcPetCrippleImg = display.newImage("images/cripple.png", system.ResourceDirectory)    
    pcPetCrippleImg.x = -12
    pcPetCrippleImg.y = pcPetStartingY * 4    
    
    pcPetMindBreakImg = display.newImage("images/mindbreak.png", system.ResourceDirectory)    
    pcPetMindBreakImg.x = 12
    pcPetMindBreakImg.y = pcPetStartingY * 4        
    
    pcPetDeludeImg = display.newImage("images/delude.png", system.ResourceDirectory)    
    pcPetDeludeImg.x = 36
    pcPetDeludeImg.y = pcPetStartingY * 4   
    
    pcPetPoisonImg = display.newImage("images/poison.png", system.ResourceDirectory)    
    pcPetPoisonImg.x = -36
    pcPetPoisonImg.y = pcPetStartingY * 4 + 24       
    
    pcPetBlindImg = display.newImage("images/blind.png", system.ResourceDirectory)    
    pcPetBlindImg.x = -12
    pcPetBlindImg.y = pcPetStartingY * 4 + 24     
    
    pcPetSilenceImg = display.newImage("images/silence.png", system.ResourceDirectory)    
    pcPetSilenceImg.x = 12
    pcPetSilenceImg.y = pcPetStartingY * 4 + 24       
    
    pcPetLullImg = display.newImage("images/lull.png", system.ResourceDirectory)    
    pcPetLullImg.x = 36
    pcPetLullImg.y = pcPetStartingY * 4 + 24   
    
    pcPetStatGroup:insert(pcPetNameLabel) 
    pcPetStatGroup:insert(pcPetHPLabel)
    pcPetStatGroup:insert(pcPetAPLabel)    
    pcPetStatGroup:insert(pcPetCrampImg)
    pcPetStatGroup:insert(pcPetCrippleImg)
    pcPetStatGroup:insert(pcPetMindBreakImg)
    pcPetStatGroup:insert(pcPetDeludeImg)
    pcPetStatGroup:insert(pcPetPoisonImg)
    pcPetStatGroup:insert(pcPetBlindImg)
    pcPetStatGroup:insert(pcPetSilenceImg)
    pcPetStatGroup:insert(pcPetLullImg)    
    
    ------------------
    -- NPC LABELS
    ------------------
    local npcStartingY = 15
    local npcStatGroup = display.newContainer(300, 200)
    npcStatGroup.x = GLOB.width - 100
    npcStatGroup.y = 0
    
    -- label for npc name
    textOptions["x"] = 30
    textOptions["y"] = npcStartingY
    textOptions["text"] = npcStats["name"]

    local npcNameLabel = display.newText(textOptions)
    --pcNameLabel:setFillColor(0,0,0)    
    
    -- HP label
    textOptions["y"] = npcStartingY * 2
    textOptions["x"] = 35
    textOptions["text"] = "HP: "..npcStats["hp"].."/"..npcStats["hp"]
    
    npcHPLabel = display.newText(textOptions)
    
    -- AP Label
    textOptions["y"] = npcStartingY * 3
    textOptions["text"] = "AP: "..npcStats["ap"].."/"..npcStats["ap"]
    
    npcAPLabel = display.newText(textOptions)  
    
    -- images
    npcCrampImg = display.newImage("images/cramp.png", system.ResourceDirectory)
    npcCrampImg.x = -36
    npcCrampImg.y = npcStartingY * 4
    
    npcCrippleImg = display.newImage("images/cripple.png", system.ResourceDirectory)    
    npcCrippleImg.x = -12
    npcCrippleImg.y = npcStartingY * 4    
    
    npcMindBreakImg = display.newImage("images/mindbreak.png", system.ResourceDirectory)    
    npcMindBreakImg.x = 12
    npcMindBreakImg.y = npcStartingY * 4        
    
    npcDeludeImg = display.newImage("images/delude.png", system.ResourceDirectory)    
    npcDeludeImg.x = 36
    npcDeludeImg.y = npcStartingY * 4   
    
    npcPoisonImg = display.newImage("images/poison.png", system.ResourceDirectory)    
    npcPoisonImg.x = -36
    npcPoisonImg.y = npcStartingY * 4 + 24       
    
    npcBlindImg = display.newImage("images/blind.png", system.ResourceDirectory)    
    npcBlindImg.x = -12
    npcBlindImg.y = npcStartingY * 4 + 24     
    
    npcSilenceImg = display.newImage("images/silence.png", system.ResourceDirectory)    
    npcSilenceImg.x = 12
    npcSilenceImg.y = npcStartingY * 4 + 24       
    
    npcLullImg = display.newImage("images/lull.png", system.ResourceDirectory)    
    npcLullImg.x = 36
    npcLullImg.y = npcStartingY * 4 + 24        
    
    npcStatGroup:insert(npcNameLabel) 
    npcStatGroup:insert(npcHPLabel)
    npcStatGroup:insert(npcAPLabel)
    npcStatGroup:insert(npcCrampImg)
    npcStatGroup:insert(npcCrippleImg)
    npcStatGroup:insert(npcMindBreakImg)
    npcStatGroup:insert(npcDeludeImg)
    npcStatGroup:insert(npcPoisonImg)
    npcStatGroup:insert(npcBlindImg)
    npcStatGroup:insert(npcSilenceImg)
    npcStatGroup:insert(npcLullImg)      
    
    ------------------
    -- NPC PET LABELS
    ------------------
    local npcPetStartingY = 15
    npcPetStatGroup = display.newContainer(300, 200) -- container for player stats on screen. could change to a regular group if there is a problem with the container
    npcPetStatGroup.x = GLOB.width - 100
    npcPetStatGroup.y = 100
    
    -- the text label's center is point 0,0. this must be accounted for
    -- label for player pet name
    textOptions["x"] = 30
    textOptions["y"] = npcPetStartingY    
    textOptions["text"] = "NPC Pet Name"

    npcPetNameLabel = display.newText(textOptions)
    --pcNameLabel:setFillColor(0,0,0)    
    
    -- HP label
    textOptions["y"] = npcPetStartingY * 2
    textOptions["x"] = 35
    textOptions["text"] = "HP: 0/0"
    
    npcPetHPLabel = display.newText(textOptions)
    
    -- AP Label
    textOptions["y"] = npcPetStartingY * 3
    textOptions["text"] = "AP: 0/0"
    
    npcPetAPLabel = display.newText(textOptions)  
    
    -- images
    npcPetCrampImg = display.newImage("images/cramp.png", system.ResourceDirectory)
    npcPetCrampImg.x = -36
    npcPetCrampImg.y = npcPetStartingY * 4
    
    npcPetCrippleImg = display.newImage("images/cripple.png", system.ResourceDirectory)    
    npcPetCrippleImg.x = -12
    npcPetCrippleImg.y = npcPetStartingY * 4    
    
    npcPetMindBreakImg = display.newImage("images/mindbreak.png", system.ResourceDirectory)    
    npcPetMindBreakImg.x = 12
    npcPetMindBreakImg.y = npcPetStartingY * 4        
    
    npcPetDeludeImg = display.newImage("images/delude.png", system.ResourceDirectory)    
    npcPetDeludeImg.x = 36
    npcPetDeludeImg.y = npcPetStartingY * 4   
    
    npcPetPoisonImg = display.newImage("images/poison.png", system.ResourceDirectory)    
    npcPetPoisonImg.x = -36
    npcPetPoisonImg.y = npcPetStartingY * 4 + 24       
    
    npcPetBlindImg = display.newImage("images/blind.png", system.ResourceDirectory)    
    npcPetBlindImg.x = -12
    npcPetBlindImg.y = npcPetStartingY * 4 + 24     
    
    npcPetSilenceImg = display.newImage("images/silence.png", system.ResourceDirectory)    
    npcPetSilenceImg.x = 12
    npcPetSilenceImg.y = npcPetStartingY * 4 + 24       
    
    npcPetLullImg = display.newImage("images/lull.png", system.ResourceDirectory)    
    npcPetLullImg.x = 36
    npcPetLullImg.y = npcPetStartingY * 4 + 24        
    
    npcPetStatGroup:insert(npcPetNameLabel) 
    npcPetStatGroup:insert(npcPetHPLabel)
    npcPetStatGroup:insert(npcPetAPLabel)
    npcPetStatGroup:insert(npcPetCrampImg)
    npcPetStatGroup:insert(npcPetCrippleImg)
    npcPetStatGroup:insert(npcPetMindBreakImg)
    npcPetStatGroup:insert(npcPetDeludeImg)
    npcPetStatGroup:insert(npcPetPoisonImg)
    npcPetStatGroup:insert(npcPetBlindImg)
    npcPetStatGroup:insert(npcPetSilenceImg)
    npcPetStatGroup:insert(npcPetLullImg)    
    
    -- add the containers to the main display group
    myScene:insert(pcStatGroup)
    myScene:insert(pcPetStatGroup)
    myScene:insert(npcStatGroup)
    myScene:insert(npcPetStatGroup)    
    ---------------------
    -- END LABELS --
    ---------------------    

    -- hide all the affliction images. can comment these all out to make sure they are in correct positions
    pcCrampImg.isVisible = false
    pcCrippleImg.isVisible = false
    pcMindBreakImg.isVisible = false
    pcDeludeImg.isVisible = false
    pcPoisonImg.isVisible = false
    pcBlindImg.isVisible = false
    pcSilenceImg.isVisible = false
    pcLullImg.isVisible = false
    pcPetCrampImg.isVisible = false
    pcPetCrippleImg.isVisible = false
    pcPetMindBreakImg.isVisible = false
    pcPetDeludeImg.isVisible = false
    pcPetPoisonImg.isVisible = false
    pcPetBlindImg.isVisible = false
    pcPetSilenceImg.isVisible = false
    pcPetLullImg.isVisible = false    
    npcCrampImg.isVisible = false
    npcCrippleImg.isVisible = false
    npcMindBreakImg.isVisible = false
    npcDeludeImg.isVisible = false
    npcPoisonImg.isVisible = false
    npcBlindImg.isVisible = false
    npcSilenceImg.isVisible = false
    npcLullImg.isVisible = false    
    npcPetCrampImg.isVisible = false
    npcPetCrippleImg.isVisible = false
    npcPetMindBreakImg.isVisible = false
    npcPetDeludeImg.isVisible = false
    npcPetPoisonImg.isVisible = false
    npcPetBlindImg.isVisible = false
    npcPetSilenceImg.isVisible = false
    npcPetLullImg.isVisible = false
end

function scene:MakeButtons(myScene)
    ---------------------
    -- BEGIN BUTTONS --
    ---------------------
    local buttonGroupOne = display.newContainer(display.contentWidth * 2, 40) -- container for main set of buttons. still don't know why width has to be doubled on containers?
    buttonGroupOne.x = 0
    buttonGroupOne.y = 360
    
    -- options for the attack button
    local buttonWidth = 100 -- factors in stroke
    local strokeWidth = 4
    local buttonOrigLoc = (buttonWidth + strokeWidth) / 2 + 37 -- this should center everything
    local buttonXLoc = buttonOrigLoc
    
    local options = {
        label = "Attack",
        emboss = false,
        shape = "roundedRect",
        x = buttonOrigLoc,
        y = 0,
        width = 100,
        height = 30,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4,
        labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
        font = native.systemFont,
        fontSize = 14,
        onRelease = self.AttackClick               
    }

    attackButton = widget.newButton(options) 
    
    -- options for ability
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Ability"
    options["x"] = buttonXLoc
    options["onRelease"] = self.ShowHideAbilities    
    abilityButton = widget.newButton(options)
    
    -- item button
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Item"
    options["x"] = buttonXLoc  
    options["onRelease"] = nil
    itemButton = widget.newButton(options)
    
    -- meditate button
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Meditate"
    options["x"] = buttonXLoc    
    options["onRelease"] = self.MeditateClick     
    meditateButton = widget.newButton(options)     
    
    -- run button
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Run"
    options["x"] = buttonXLoc 
    options["onRelease"] = nil 
    runButton = widget.newButton(options)      
    
    -- end turn button
    buttonXLoc = buttonXLoc + 125
    options["label"] = "End Turn"
    options["x"] = buttonXLoc
    options["onRelease"] = self.EndTurnClick      
    endTurnButton = widget.newButton(options) 
    
    -- abilities group 1 and buttons
    buttonGroupTwo = display.newContainer(display.contentWidth * 2, 40) -- container for main set of buttons. still don't know why width has to be doubled on containers?
    buttonGroupTwo.x = 0
    buttonGroupTwo.y = 400  
    
    buttonXLoc = buttonOrigLoc
    options["label"] = "Abil1"
    options["x"] = buttonXLoc
    options["onRelease"] = self.AbilityOneClick
    abil1Button = widget.newButton(options)
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil2"
    options["x"] = buttonXLoc    
    options["onRelease"] = self.AbilityTwoClick
    abil2Button = widget.newButton(options)    
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil3"
    options["x"] = buttonXLoc 
    options["onRelease"] = self.AbilityThreeClick
    abil3Button = widget.newButton(options)  
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil4"
    options["x"] = buttonXLoc   
    options["onRelease"] = self.AbilityFourClick
    abil4Button = widget.newButton(options)  
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil5"
    options["x"] = buttonXLoc   
    options["onRelease"] = self.AbilityFiveClick
    abil5Button = widget.newButton(options)  
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil6"
    options["x"] = buttonXLoc    
    options["onRelease"] = self.AbilitySixClick
    abil6Button = widget.newButton(options)      
    
    -- abilities group 2 and buttons
    buttonGroupThree = display.newContainer(display.contentWidth * 2, 40) -- container for main set of buttons. still don't know why width has to be doubled on containers?
    buttonGroupThree.x = 0
    buttonGroupThree.y = 440  
    
    buttonXLoc = buttonOrigLoc
    options["label"] = "Abil7"
    options["x"] = buttonXLoc
    options["onRelease"] = nil
    abil7Button = widget.newButton(options)
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil8"
    options["x"] = buttonXLoc    
    abil8Button = widget.newButton(options)    
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil9"
    options["x"] = buttonXLoc    
    abil9Button = widget.newButton(options)  
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil10"
    options["x"] = buttonXLoc    
    abil10Button = widget.newButton(options)  
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil11"
    options["x"] = buttonXLoc    
    abil11Button = widget.newButton(options)  
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil12"
    options["x"] = buttonXLoc    
    abil12Button = widget.newButton(options)      
    
    abil1Button.isVisible = false
    abil2Button.isVisible = false
    abil3Button.isVisible = false
    abil4Button.isVisible = false
    abil5Button.isVisible = false
    abil6Button.isVisible = false
    abil7Button.isVisible = false
    abil8Button.isVisible = false
    abil9Button.isVisible = false
    abil10Button.isVisible = false
    abil11Button.isVisible = false
    abil12Button.isVisible = false
    
    -- add controls to group 
    buttonGroupOne:insert(attackButton)
    buttonGroupOne:insert(abilityButton)
    buttonGroupOne:insert(itemButton)
    buttonGroupOne:insert(meditateButton)
    buttonGroupOne:insert(runButton)
    buttonGroupOne:insert(endTurnButton) 
    buttonGroupTwo:insert(abil1Button)
    buttonGroupTwo:insert(abil2Button)
    buttonGroupTwo:insert(abil3Button)
    buttonGroupTwo:insert(abil4Button)
    buttonGroupTwo:insert(abil5Button)
    buttonGroupTwo:insert(abil6Button)
    buttonGroupThree:insert(abil7Button)
    buttonGroupThree:insert(abil8Button)
    buttonGroupThree:insert(abil9Button)
    buttonGroupThree:insert(abil10Button)
    buttonGroupThree:insert(abil11Button)
    buttonGroupThree:insert(abil12Button)    
    myScene:insert(buttonGroupOne)
    myScene:insert(buttonGroupTwo)
    myScene:insert(buttonGroupThree)
    ---------------------
    -- END BUTTONS --
    ---------------------       
end

function scene:MakeScroller(myScene)
    ---------------------
    -- START SCROLLVIEW --
    ---------------------  
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

    newScrollHeight = 0

    scrollView = widget.newScrollView
    {
        left = 37.5,
        top = 225,
        width = scrollRectWidth,
        height = visibleScroll,
        scrollWidth = scrollRectWidth, -- width of scrollable area
        scrollHeight = newScrollHeight, -- height of scrollable area
        horizontalScrollDisabled = true,
        isBounceEnabled = false,
        listener = scrollListener,
        hideScrollBar = false,
        backgroundColor = {.5,.5,.5},
        friction = 0
    }
    
    scrollArea = display.newContainer(scrollRectWidth * 2, 0) -- had to double rectWidth here for some reason?

    scrollView:insert(scrollArea)
    myScene:insert(scrollView)
    
    ---------------------
    -- END SCROLLVIEW --
    ---------------------       
end

function scene:create(event)
    local sceneGroup = self.view
    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.    

    -- load the pc and npc. need to do this before creating labels
    scene:LoadToons()
    
    ---------------------
    --  MAKE CONTROLS --
    ---------------------
    scene:MakeLabels(sceneGroup)
    scene:MakeButtons(sceneGroup)
    scene:MakeScroller(sceneGroup)  

    -- set up some initial conditions
    scene:Initialize()   
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    
    if phase == "will" then
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

