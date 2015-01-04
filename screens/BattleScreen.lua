local composer = require ("composer")
local GLOB = require "globals"
local controls = require("controls.Controls")
local button = require("controls.Button")
local widget = require "widget"
local utilities = require "functions.Utilities"
local abilitiesT1 = require "functions.AbilitiesT1"
local abilitiesT2 = require "functions.AbilitiesT2"
local rpg = require "functions.RPG"
local ai = require "functions.AI"
local json = require "json"
local scene = composer.newScene()

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
local turnLost = false
local battleEnded = false

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
-- flags for special abilities that have to overwrite regular ability labels and functionality
local showAbilities = false
local kineticTouchOn = false
local chooseElemResOn = false
local chooseImbueOn = false
local switchElem = ""

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
local pcHPLabel,pcAPLabel,pcPetHPLabel,pcPetAPLabel,pcPetNameLabel,npcHPLabel,npcAPLabel,npcPetHPLabel,npcPetAPLabel,npcPetNameLabel,pcStatGroup,pcPetStatGroup,npcStatGroup,npcPetStatGroup

-- affliction images
local pcCrampImg,pcCrippleImg,pcMindBreakImg,pcDeludeImg,pcPoisonImg,pcBlindImg,pcSilenceImg,pcLullImg,
pcPetCrampImg,pcPetCrippleImg,pcPetMindBreakImg,pcPetDeludeImg,pcPetPoisonImg,pcPetBlindImg,pcPetSilenceImg,pcPetLullImg,
npcCrampImg,npcCrippleImg,npcMindBreakImg,npcDeludeImg,npcPoisonImg,npcBlindImg,npcSilenceImg,npcLullImg,
npcPetCrampImg,npcPetCrippleImg,npcPetMindBreakImg,npcPetDeludeImg,npcPetPoisonImg,npcPetBlindImg,npcPetSilenceImg,npcPetLullImg,
pcHasteImg, pcReplenishImg, pcRefShieldImg, pcValorImg, pcElemResImg, pcImbueImg, pcHemorrhageImg, pcHamstringImg, pcIncinerateImg, pcVampEmbImg,
pcPetHasteImg, pcPetReplenishImg, pcPetRefShieldImg, pcPetValorImg, pcPetElemResImg, pcPetImbueImg, pcPetHemorrhageImg, pcPetHamstringImg, pcPetIncinerateImg, pcPetVampEmbImg, 
npcHasteImg, npcReplenishImg, npcRefShieldImg, npcValorImg, npcElemResImg, npcImbueImg, npcHemorrhageImg, npcHamstringImg, npcIncinerateImg, npcVampEmbImg,
npcPetHasteImg, npcPetReplenishImg, npcPetRefShieldImg, npcPetValorImg, npcPetElemResImg, npcPetImbueImg, npcPetHemorrhageImg, npcPetHamstringImg, npcPetIncinerateImg, npcPetVampEmbImg

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
    npcStats["baseLightning"] = GLOB.npcs[1]["Lightning"]
    npcStats["basePoison"] = GLOB.npcs[1]["Poison"]
    npcStats["baseIce"] = GLOB.npcs[1]["Ice"]
    npcStats["baseDisease"] = GLOB.npcs[1]["Disease"]
    npcStats["baseEarth"] = GLOB.npcs[1]["Earth"]
    npcStats["baseFire"] = GLOB.npcs[1]["Fire"]
    
    npcStats["lightning"] = npcStats["baseLightning"]
    npcStats["poison"] = npcStats["basePoison"]
    npcStats["ice"] = npcStats["baseIce"]
    npcStats["disease"] = npcStats["baseDisease"]
    npcStats["earth"] = npcStats["baseEarth"]
    npcStats["fire"] = npcStats["baseFire"]
    
    --todo load these in from json
    -- npc abilities
    npcStats["abil1"] = 1
    npcStats["abil2"] = 4
    npcStats["abil3"] = 7
    npcStats["abil4"] = 8
    npcStats["abil5"] = 22
    npcStats["abil6"] = 26
    npcStats["abil7"] = nil
    npcStats["abil8"] = nil
    npcStats["abil9"] = nil
    npcStats["abil10"] = nil
    npcStats["abil11"] = nil
    npcStats["abil12"] = nil   
    
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
    pcStats["baseAp"] = 50
    pcStats["baseInt"] = 3
    pcStats["baseWill"] = 1
    
    pcStats["hp"] = pcStats["baseHp"]
    pcStats["str"] = pcStats["baseStr"]
    pcStats["def"] = pcStats["baseDef"]
    pcStats["ap"] = pcStats["baseAp"]
    pcStats["int"] = pcStats["baseInt"]
    pcStats["will"] = pcStats["baseWill"]    

    pcStats["baseLightning"] = 1
    pcStats["basePoison"] = 1
    pcStats["baseIce"] = 1
    pcStats["baseDisease"] = 1.5
    pcStats["baseEarth"] = 2
    pcStats["baseFire"] = 0
    
    pcStats["lightning"] = 1
    pcStats["poison"] = 1
    pcStats["ice"] = 1
    pcStats["disease"] = 1.5
    pcStats["earth"] = 2
    pcStats["fire"] = 0    
    
    pcStats["abil1"] = 55
    pcStats["abil2"] = 56
    pcStats["abil3"] = 57
    pcStats["abil4"] = 58
    pcStats["abil5"] = 59
    pcStats["abil6"] = 60
    pcStats["abil7"] = 49
    pcStats["abil8"] = 42
    pcStats["abil9"] = 51
    pcStats["abil10"] = 52
    pcStats["abil11"] = 53
    pcStats["abil12"] = 54

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

function scene:RunClick()
    if pcTurnPet then
        scene:Run(pcPetStats)
    else
        scene:Run(pcStats)
    end    
end

-- attack function. can be called by players and npcs as well as their pets
function scene:Attack(attacker, defender)
    scene:CheckSilenceBlind("statusBlind") -- if the person attacking is blinded and fails check, the following if statement code will not execute
    
    if not turnLost then
        local roll = utilities:RNG(6)        
        
        local attack = attacker["str"] + attacker["level"] + roll - defender["def"]
        attack = rpg:ValorCheck(defender, attack)
        
        if attack < 0 then
            attack = 0
        end          
        
        if attack > 0 then
            defender["currentHp"] = defender["currentHp"] - attack
            
            local textOutput = ""
            
            if attack > 0 and defender["buffRefShield"] then
                if attacker["type"] == "pc" or attacker["type"] == "npc" or (attacker["type"] == "pcPet" and pcPetMelee) or (attacker["type"] == "npcPet" and npcPetMelee)then
                    textOutput = rpg:ReflectiveShieldCheck(attacker, attack, textOutput)
                end
            end                 
            
            scene:BattleLogAdd(attacker["name"].." makes an Attack, doing "..attack.." damage to "..defender["name"].."."..textOutput)        
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
        
        if attacker["level"] < 11 then -- restore 1-3 or 2-6 ap based on level
            roll = utilities:RNG(3)
        else
            roll = utilities:RNG(3) + utilities:RNG(3)
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

function scene:Run(attacker)
    -- npcs can also be passed into here for ones like quiksilver
    local roll = utilities:RNG(3)
    
    if roll ~= 3 then
        scene:BattleLogAdd(attacker["name"].." Runs from battle.")
        battleEnded = true
        endTurnButton:setLabel("End Battle")
    else
        scene:BattleLogAdd(attacker["name"].." tries to Run from battle, but is unsuccessful.")
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
            affText = "Blinded"
        elseif affliction == "statusSilence" then
            affText = "Silenced"
        end
        
        local outputString = outputName.." is "..affText.." and is unable to make an action."

        if roll ~= 3 then
            scene:BattleLogAdd(outputString)
            turnLost = true
        end   
    end
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
            nextTurnDmg[matchup] = rpg:ValorCheck(defender, nextTurnDmg[matchup])
            defender["currentHp"] = defender["currentHp"] - nextTurnDmg[matchup]
            
            local textOutput = ""
            
            if nextTurnDmg[matchup] > 0 and defender["buffRefShield"] then
                if attacker["type"] == "pc" or attacker["type"] == "npc" or (attacker["type"] == "pcPet" and pcPetMelee) or (attacker["type"] == "npcPet" and npcPetMelee)then
                    textOutput = rpg:ReflectiveShieldCheck(attacker, nextTurnDmg[matchup], textOutput)
                end
            end            

            scene:BattleLogAdd(attacker["name"].."'s "..move.." goes off, doing "..nextTurnDmg[matchup].." damage to "..defender["name"].."."..textOutput)                                    
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

function scene:AbilityOneClick()
    --for buttons 7-12 make sure they have 2 ap
    if not pcTurnPet and pcStats["currentAp"] == 0 then
        scene:BattleLogAdd("You are out of AP. Try Meditating.")
    elseif pcTurnPet and pcPetStats["currentAp"] == 0 then
        scene:BattleLogAdd("Your pet is out of AP. Try Meditating.")
    elseif kineticTouchOn then
        if npcPetMelee then
            kineticTouchOn = false
            scene:UseAbilityClick(npcPetStats["abil1"]) 
        else
            kineticTouchOn = false
            scene:UseAbilityClick(npcStats["abil1"]) 
        end  
    elseif chooseElemResOn then
        chooseElemResOn = false
        switchElem = "lightning"
        scene:ExecuteAbility(58)   
    elseif chooseImbueOn then
        chooseImbueOn = false
        switchElem = "lightning"
        scene:ExecuteAbility(59)
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
    elseif kineticTouchOn then
        if npcPetMelee then
            kineticTouchOn = false
            scene:UseAbilityClick(npcPetStats["abil2"]) 
        else
            kineticTouchOn = false
            scene:UseAbilityClick(npcStats["abil2"]) 
        end 
    elseif chooseElemResOn then
        chooseElemResOn = false
        switchElem = "poison"
        scene:ExecuteAbility(58)   
    elseif chooseImbueOn then
        chooseImbueOn = false
        switchElem = "poison"
        scene:ExecuteAbility(59)        
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
    elseif kineticTouchOn then
        if npcPetMelee then
            kineticTouchOn = false
            scene:UseAbilityClick(npcPetStats["abil3"]) 
        else
            kineticTouchOn = false
            scene:UseAbilityClick(npcStats["abil3"]) 
        end      
    elseif chooseElemResOn then
        chooseElemResOn = false
        switchElem = "ice"
        scene:ExecuteAbility(58)   
    elseif chooseImbueOn then
        chooseImbueOn = false
        switchElem = "ice"
        scene:ExecuteAbility(59)        
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
    elseif kineticTouchOn then
        if npcPetMelee then
            kineticTouchOn = false
            scene:UseAbilityClick(npcPetStats["abil4"]) 
        else
            kineticTouchOn = false
            scene:UseAbilityClick(npcStats["abil4"]) 
        end      
    elseif chooseElemResOn then
        chooseElemResOn = false
        switchElem = "disease"
        scene:ExecuteAbility(58)   
    elseif chooseImbueOn then
        chooseImbueOn = false
        switchElem = "disease"
        scene:ExecuteAbility(59)        
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
    elseif kineticTouchOn then
        if npcPetMelee then
            kineticTouchOn = false
            scene:UseAbilityClick(npcPetStats["abil5"]) 
        else
            kineticTouchOn = false
            scene:UseAbilityClick(npcStats["abil5"]) 
        end      
    elseif chooseElemResOn then
        chooseElemResOn = false
        switchElem = "earth"
        scene:ExecuteAbility(58)   
    elseif chooseImbueOn then
        chooseImbueOn = false
        switchElem = "earth"
        scene:ExecuteAbility(59)        
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
    elseif kineticTouchOn then
        if npcPetMelee then
            kineticTouchOn = false
            scene:UseAbilityClick(npcPetStats["abil6"]) 
        else
            kineticTouchOn = false
            scene:UseAbilityClick(npcStats["abil6"]) 
        end   
    elseif chooseElemResOn then
        chooseElemResOn = false
        switchElem = "fire"
        scene:ExecuteAbility(58)   
    elseif chooseImbueOn then
        chooseImbueOn = false
        switchElem = "fire"
        scene:ExecuteAbility(59)        
    elseif pcTurn and not pcTurnPet then
        scene:UseAbilityClick(pcStats["abil6"])
    elseif pcTurn and pcTurnPet then
        scene:UseAbilityClick(pcPetStats["abil6"])
    end    
end

function scene:AbilitySevenClick()
    if not pcTurnPet and pcStats["currentAp"] < 2 then
        scene:BattleLogAdd("You are low on AP. Try Meditating.")
    elseif pcTurnPet and pcPetStats["currentAp"] < 2 then
        scene:BattleLogAdd("Your pet is low on AP. Try Meditating.")
    elseif kineticTouchOn then
        if npcPetMelee then
            kineticTouchOn = false
            scene:UseAbilityClick(npcPetStats["abil7"]) 
        else
            kineticTouchOn = false
            scene:UseAbilityClick(npcStats["abil7"]) 
        end   
    elseif pcTurn and not pcTurnPet then
        scene:UseAbilityClick(pcStats["abil7"])
    elseif pcTurn and pcTurnPet then
        scene:UseAbilityClick(pcPetStats["abil7"])
    end    
end

function scene:AbilityEightClick()
    if not pcTurnPet and pcStats["currentAp"] < 2 then
        scene:BattleLogAdd("You are low on AP. Try Meditating.")
    elseif pcTurnPet and pcPetStats["currentAp"] < 2 then
        scene:BattleLogAdd("Your pet is low on AP. Try Meditating.")
    elseif kineticTouchOn then
        if npcPetMelee then
            kineticTouchOn = false
            scene:UseAbilityClick(npcPetStats["abil8"]) 
        else
            kineticTouchOn = false
            scene:UseAbilityClick(npcStats["abil8"]) 
        end   
    elseif pcTurn and not pcTurnPet then
        scene:UseAbilityClick(pcStats["abil8"])
    elseif pcTurn and pcTurnPet then
        scene:UseAbilityClick(pcPetStats["abil8"])
    end    
end

function scene:AbilityNineClick()
    if not pcTurnPet and pcStats["currentAp"] < 2 then
        scene:BattleLogAdd("You are low on AP. Try Meditating.")
    elseif pcTurnPet and pcPetStats["currentAp"] < 2 then
        scene:BattleLogAdd("Your pet is low on AP. Try Meditating.")
    elseif kineticTouchOn then
        if npcPetMelee then
            kineticTouchOn = false
            scene:UseAbilityClick(npcPetStats["abil9"]) 
        else
            kineticTouchOn = false
            scene:UseAbilityClick(npcStats["abil9"]) 
        end   
    elseif pcTurn and not pcTurnPet then
        scene:UseAbilityClick(pcStats["abil9"])
    elseif pcTurn and pcTurnPet then
        scene:UseAbilityClick(pcPetStats["abil9"])
    end    
end

function scene:AbilityTenClick()
    if not pcTurnPet and pcStats["currentAp"] < 2 then
        scene:BattleLogAdd("You are low on AP. Try Meditating.")
    elseif pcTurnPet and pcPetStats["currentAp"] < 2 then
        scene:BattleLogAdd("Your pet is low on AP. Try Meditating.")
    elseif kineticTouchOn then
        if npcPetMelee then
            kineticTouchOn = false
            scene:UseAbilityClick(npcPetStats["abil10"]) 
        else
            kineticTouchOn = false
            scene:UseAbilityClick(npcStats["abil10"]) 
        end   
    elseif pcTurn and not pcTurnPet then
        scene:UseAbilityClick(pcStats["abil10"])
    elseif pcTurn and pcTurnPet then
        scene:UseAbilityClick(pcPetStats["abil10"])
    end    
end

function scene:AbilityElevenClick()
    if not pcTurnPet and pcStats["currentAp"] < 2 then
        scene:BattleLogAdd("You are low on AP. Try Meditating.")
    elseif pcTurnPet and pcPetStats["currentAp"] < 2 then
        scene:BattleLogAdd("Your pet is low on AP. Try Meditating.")
    elseif kineticTouchOn then
        if npcPetMelee then
            kineticTouchOn = false
            scene:UseAbilityClick(npcPetStats["abil11"]) 
        else
            kineticTouchOn = false
            scene:UseAbilityClick(npcStats["abil11"]) 
        end   
    elseif pcTurn and not pcTurnPet then
        scene:UseAbilityClick(pcStats["abil11"])
    elseif pcTurn and pcTurnPet then
        scene:UseAbilityClick(pcPetStats["abil11"])
    end    
end

function scene:AbilityTwelveClick()
    if not pcTurnPet and pcStats["currentAp"] < 2 then
        scene:BattleLogAdd("You are low on AP. Try Meditating.")
    elseif pcTurnPet and pcPetStats["currentAp"] < 2 then
        scene:BattleLogAdd("Your pet is low on AP. Try Meditating.")
    elseif kineticTouchOn then
        if npcPetMelee then
            kineticTouchOn = false
            scene:UseAbilityClick(npcPetStats["abil12"]) 
        else
            kineticTouchOn = false
            scene:UseAbilityClick(npcStats["abil12"]) 
        end   
    elseif pcTurn and not pcTurnPet then
        scene:UseAbilityClick(pcStats["abil12"])
    elseif pcTurn and pcTurnPet then
        scene:UseAbilityClick(pcPetStats["abil12"])
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
    elseif ability == 33 then -- hemorrhage
        scene:StatusAilmentCheck(ability, "dotHemorrhage", "Hemorrhaged")
    elseif ability == 37 then -- incinerate
        scene:StatusAilmentCheck(ability, "dotIncinerate", "Incinerated")
    elseif ability == 39 then -- debilitate
        scene:StatusAilmentCheck(ability, "dotPoison", "Poisoned")
    elseif ability == 40 then -- vampiric embrace
        scene:BuffCheck(ability, "buffVampEmb", "using a Vampiric Embrace")
    elseif ability == 43 then -- replenish
        scene:BuffCheck(ability, "buffReplenish", "using Replenish")
    elseif ability == 44 then -- hamstring
        scene:StatusAilmentCheck(ability, "statusHamstring", "Hamstrung")
    elseif ability == 45 then -- haste
        scene:BuffCheck(ability, "buffHaste", "Hasted")
    elseif ability == 47 then -- valor
        scene:BuffCheck(ability, "buffValor", "using Valor")
    elseif ability == 48 then -- ref shield
        scene:BuffCheck(ability, "buffRefShield", "using Reflective Shield")
    elseif ability == 50 then
        kineticTouchOn = true
        if npcPetMelee then
            scene:SetAbilButtons(npcPetStats) 
        else
            scene:SetAbilButtons(npcStats) 
        end
    elseif ability == 55 then -- summon demon
        scene:PetOutCheck(ability)
    elseif ability == 56 then -- tame the wild
        scene:PetOutCheck(ability)
    elseif ability == 57 then -- banish
        if npcPetMelee or npcPetMagic then
            scene:ExecuteAbility(ability)
        else
            scene:BattleLogAdd("The opponent does not have an active pet.")
        end
    elseif ability == 58 then -- elem res
        scene:ElemResCheck(ability, "buffElemRes", "using Elemental Resistance")
    elseif ability == 59 then -- imbue
        scene:ImbueCheck(ability, "debuffImbue", "Imbued")
    else -- ability isn't an affliction or pet
        scene:ExecuteAbility(ability)
    end
end

-- make sure player isn't trying to debuff or poison if they are already active when trying to use ability
function scene:StatusAilmentCheck(ability, affliction, afflictionText)
    if npcPetMelee then
        if npcPetStats[affliction] then
            scene:BattleLogAdd(npcPetStats["name"].." is already "..afflictionText..".")
        else
            scene:ExecuteAbility(ability)
        end
    else
        if npcStats[affliction] then
            scene:BattleLogAdd(npcStats["name"].." is already "..afflictionText..".")
        else
            scene:ExecuteAbility(ability)
        end        
    end
end

function scene:ImbueCheck(ability, affliction, afflictionText)
    if npcPetMelee then
        if npcPetStats[affliction] then
            scene:BattleLogAdd(npcPetStats["name"].." is already "..afflictionText..".")
        else
            chooseImbueOn = true
            scene:PickElementButtons()
        end
    else
        if npcStats[affliction] then
            scene:BattleLogAdd(npcStats["name"].." is already "..afflictionText..".")
        else
            chooseImbueOn = true
            scene:PickElementButtons()
        end        
    end
end

function scene:ElemResCheck(ability, buff, buffText)
    if pcTurnPet then
        if pcPetStats[buff] then
            scene:BattleLogAdd(pcPetStats["name"].." is already "..buffText..".")
        else
            chooseElemResOn = true
            scene:PickElementButtons()
        end
    else
        if pcStats[buff] then
            scene:BattleLogAdd(pcStats["name"].." is already "..buffText..".")
        else
            chooseElemResOn = true
            scene:PickElementButtons()
        end        
    end 
end

function scene:BuffCheck(ability, buff, buffText)
    if pcTurnPet then
        if pcPetStats[buff] then
            scene:BattleLogAdd(pcPetStats["name"].." is already "..buffText..".")
        else
            scene:ExecuteAbility(ability)
        end
    else
        if pcStats[buff] then
            scene:BattleLogAdd(pcStats["name"].." is already "..buffText..".")
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
    local attack = nil
    local refShieldTarget = false
    
    -- first determine whose turn it is (attacker), then who is defending (defender)
    -- also create a string for the matchup of who is facing off. this is only used by multi turn abilities
    -- some functions may not need all of this info, but gather it just in case to cut down on bloat of determining this individually for each ability
    if pcTurn then
        if pcTurnPet then -- pc pet turn
            attacker = pcPetStats
            if pcPetMelee then
                refShieldTarget = true
            end
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
            refShieldTarget = true
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
            if npcPetMelee then
                refShieldTarget = true
            end
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
            refShieldTarget = true
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
    
    -- do a silence or blind check. if they fail, the ability does not execute and they lose ap
    if abilIndex <= 6 and (abilIndex > 30 and abilIndex <= 36) then
        scene:CheckSilenceBlind("statusBlind")
    else
        scene:CheckSilenceBlind("statusSilence")
    end
    
    if not turnLost then
        local textOutput = ""
        
        -- call the individual ability function, passing in relevent data as determined above
        if abilIndex == 1 then  -- cleave
            textOutput, attack = abilitiesT1:Cleave(attacker, defender)
        elseif abilIndex == 2 then  -- berserk    
            textOutput, attack = abilitiesT1:Berserk(attacker, defender)            
        elseif abilIndex == 3 then  -- test of will
            textOutput, attack = abilitiesT1:TestOfWill(attacker, defender)
        elseif abilIndex == 4 then  -- backstab
            textOutput, attack = abilitiesT1:Backstab(attacker, defender)
        elseif abilIndex == 5 then  -- beat down
            textOutput, attack = abilitiesT1:BeatDown(attacker, defender)
        elseif abilIndex == 6 then  -- delayed reaction
            textOutput = abilitiesT1:DRUTurnOne(attacker, defender, matchup, "Delayed Reaction", nextTurnDmg)
        elseif abilIndex == 7 then  -- fireball
            textOutput, attack = abilitiesT1:Fireball(attacker, defender)
        elseif abilIndex == 8 then  -- shockwave
            textOutput, attack = abilitiesT1:Shockwave(attacker, defender)
        elseif abilIndex == 9 then  -- venom
            textOutput = abilitiesT1:Venom(attacker, defender)
            if defender["dotPoison"] then -- show affliction image if they have been poisoned
                scene:ShowPoisonImages(defender["type"])
            end
        elseif abilIndex == 10 then -- leech
            textOutput = abilitiesT1:Leech(attacker, defender)
        elseif abilIndex == 11 then -- ice storm
            textOutput, attack = abilitiesT1:IceStorm(attacker, defender)
        elseif abilIndex == 12 then -- rock wall
            textOutput, attack = abilitiesT1:RockWall(attacker, defender)
        elseif abilIndex == 13 then -- heal
            textOutput = abilitiesT1:Heal(attacker)
        elseif abilIndex == 14 then -- cleanse
            textOutput = abilitiesT1:Cleanse(attacker)            
            scene:HideAfflictionImages(attacker["type"], false) 
        elseif abilIndex == 15 then -- cramp
            textOutput = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Cramp")
            scene:ShowCrampImages(defender["type"])
        elseif abilIndex == 16 then -- cripple
            textOutput = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Cripple")
            scene:ShowCrippleImages(defender["type"])
        elseif abilIndex == 17 then -- mind break
            textOutput = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Mind Break")
            scene:ShowMindBreakImages(defender["type"])
        elseif abilIndex == 18 then -- delude
            textOutput = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Delude")
            scene:ShowDeludeImages(defender["type"])
        elseif abilIndex == 19 then -- forbidden ritual
            textOutput = abilitiesT1:ForbiddenRitual(attacker, defender)
        elseif abilIndex == 20 then -- cannibalize
            textOutput, attack = abilitiesT1:Cannibalize(attacker, defender)
        elseif abilIndex == 21 then -- mind over matter
            textOutput, attack = abilitiesT1:MindOverMatter(attacker, defender)
        elseif abilIndex == 22 then -- blast
            textOutput, attack = abilitiesT1:Blast(attacker, defender)
        elseif abilIndex == 23 then -- final countdown
            textOutput = abilitiesT1:FinalCountdownTurnOne(attacker, defender, matchup, nextTurnDmg)
        elseif abilIndex == 24 then -- unleash
            textOutput = abilitiesT1:DRUTurnOne(attacker, defender, matchup, "Unleash", nextTurnDmg)
        elseif abilIndex == 25 then -- silence
            textOutput = abilitiesT1:SilenceLullBlind(attacker, defender, "Silences")
            if defender["statusSilence"] then
                scene:ShowSilenceImages(defender["type"])
            end
        elseif abilIndex == 26 then -- mirror mania
            -- if the defender is a pet, change the table reference to the pets' owner        
            if defender["type"] == "pcPet" then                
                defender = pcStats
            elseif defender["type"] ==  "npcPet" then
                defender = npcStats
            end        
            textOutput = abilitiesT1:MirrorMania(attacker, defender, pet)
            -- todo add image
            if attacker["type"] == "pc" and pet["type"] == "pcPet" then
                pcPetMagic = true                   
                -- set labels
                pcPetStatGroup.isVisible = true
                pcPetNameLabel.text = pet["name"]
                pcPetHPLabel.text = pet["currentHp"].."/"..pet["hp"]
                pcPetAPLabel.text = pet["currentAp"].."/"..pet["ap"]                  
            elseif attacker["type"] == "npc" and pet["type"] == "npcPet"  then
                npcPetMagic = true                
                -- set labels
                npcPetStatGroup.isVisible = true
                npcPetNameLabel.text = pet["name"]
                npcPetHPLabel.text = pet["currentHp"].."/"..pet["hp"]
                npcPetAPLabel.text = pet["currentAp"].."/"..pet["ap"]                  
            end  
        elseif abilIndex == 27 then -- undead minion
            textOutput = abilitiesT1:UndeadMinion(attacker, pet)
            -- todo add image
            if attacker["type"] == "pc" and pet["type"] == "pcPet"  then
                pcPetMelee = true                   
                -- set labels
                pcPetStatGroup.isVisible = true
                pcPetNameLabel.text = pet["name"]
                pcPetHPLabel.text = pet["currentHp"].."/"..pet["hp"]
                pcPetAPLabel.text = pet["currentAp"].."/"..pet["ap"]                  
            elseif attacker["type"] == "npc" and pet["type"] == "npcPet"  then
                npcPetMelee = true                
                -- set labels
                npcPetStatGroup.isVisible = true
                npcPetNameLabel.text = pet["name"]
                npcPetHPLabel.text = pet["currentHp"].."/"..pet["hp"]
                npcPetAPLabel.text = pet["currentAp"].."/"..pet["ap"]                  
            end            
        elseif abilIndex == 28 then -- lull
            textOutput = abilitiesT1:SilenceLullBlind(attacker, defender, "Lulls")
            if defender["statusLull"] then            
                scene:ShowLullImages(defender["type"])
            end
        elseif abilIndex == 29 then -- assisted suicide
            textOutput = abilitiesT1:AssistedSuicide(attacker, defender)
        elseif abilIndex == 30 then -- blind
            textOutput = abilitiesT1:SilenceLullBlind(attacker, defender, "Blinds")
            if defender["statusBlind"] then
                scene:ShowBlindImages(defender["type"])
            end
        elseif abilIndex == 31 then-- concussive blow
            textOutput, attack = abilitiesT2:ConcussiveBlow(attacker, defender)
            local bText = ""
            local sText = ""
            if not defender["statusBlind"] then
                bText = abilitiesT1:SilenceLullBlind(attacker, defender, "Blinds")
                
                if defender["statusBlind"] then
                    scene:ShowBlindImages(defender["type"])
                end 
            else
                bText = defender["name"].." is already Blind."
            end
            if not defender["statusSilence"] then
                sText = abilitiesT1:SilenceLullBlind(attacker, defender, "Silences")
                
                if defender["statusSilence"] then
                    scene:ShowSilenceImages(defender["type"])  
                end
            else
                sText = defender["name"].." is already Silenced."
            end
            
            textOutput = textOutput.." "..bText.." "..sText   
        elseif abilIndex == 32 then-- reckless assault
            textOutput, attack = abilitiesT2:RecklessAssault(attacker, defender)
        elseif abilIndex == 33 then-- hemorrhage
            textOutput = abilitiesT2:Hemorrhage(attacker, defender)
            if defender["dotHemorrhage"] then -- show affliction image if they have been poisoned
                scene:ShowHemorrhageImages(defender["type"])
            end  
        elseif abilIndex == 34 then-- bloodlust
            textOutput, attack = abilitiesT2:Bloodlust(attacker, defender)
            local crampText = ""
            local crippleText = ""
            if not defender["debuffCramp"] then
                crampText = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Cramp")
                scene:ShowCrampImages(defender["type"])
            else
                crampText = defender["name"].." is already Cramped."
            end
            if not defender["debuffCripple"] then
                crippleText = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Cripple")
                scene:ShowCrippleImages(defender["type"])
            else
                crippleText = defender["name"].." is already Crippled."
            end
            
            textOutput = textOutput.." "..crampText.." "..crippleText       
        elseif abilIndex == 35 then -- resistance is futile
            textOutput, attack = abilitiesT2:ResistanceIsFutile(attacker, defender)
            local crampText = ""
            if not defender["debuffCramp"] then
                crampText = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Cramp")
                scene:ShowCrampImages(defender["type"])
            else
                crampText = defender["name"].." is already Cramped."
            end
            
            textOutput = textOutput.." "..crampText 
        elseif abilIndex == 36 then -- achilles heel
            textOutput, attack = abilitiesT2:AchillesHeel(attacker, defender)
            local crippleText = ""
            if not defender["debuffCripple"] then
                crippleText = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Cripple")
                scene:ShowCrippleImages(defender["type"])
            else
                crippleText = defender["name"].." is already Crippled."
            end
            
            textOutput = textOutput.." "..crippleText       
        elseif abilIndex == 37 then -- incinerate
            textOutput, attack = abilitiesT2:Incinerate(attacker, defender)
            if defender["dotIncinerate"] then
                scene:ShowIncinerateImages(defender["type"])
            end    
        elseif abilIndex == 38 then -- electromagnet
            textOutput, attack = abilitiesT2:Electromagnet(attacker, defender)  
        elseif abilIndex == 39 then-- debilitate
            textOutput = abilitiesT2:Debilitate(attacker, defender)
            local crampText = ""
            local mindBreakText = ""
            
            if defender["dotPoison"] then
                if not defender["debuffCramp"] then
                    crampText = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Cramp")
                    scene:ShowCrampImages(defender["type"])
                else
                    crampText = defender["name"].." is already Cramped."
                end
                if not defender["debuffMindBreak"] then
                    mindBreakText = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Mind Break")
                    scene:ShowMindBreakImages(defender["type"])
                else
                    mindBreakText = defender["name"].." is already Mind Broken."
                end                
            end
            
            textOutput = textOutput.." "..crampText.." "..mindBreakText   
        elseif abilIndex == 40 then -- vampiric embrace
            textOutput = abilitiesT2:VampiricEmbrace(attacker, defender)
            local crippleText = ""
            if attacker["buffVampEmb"] then
                scene:ShowVampEmbImages(attacker["type"])
            end     
        elseif abilIndex == 41 then -- brain freeze
            textOutput, attack = abilitiesT2:BrainFreeze(attacker, defender)
            local deludeText = ""
            local crippleText = ""
            if defender["ice"] ~= 0 then
                if not defender["debuffDelude"] then
                    deludeText = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Delude")
                    scene:ShowDeludeImages(defender["type"])
                else
                    deludeText = defender["name"].." is already Deluded."
                end
                if not defender["debuffCripple"] then
                    crippleText = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Cripple")
                    scene:ShowCrippleImages(defender["type"])
                else
                    crippleText = defender["name"].." is already Crippled."
                end
            end
            
            textOutput = textOutput.." "..deludeText.." "..crippleText  
        elseif abilIndex == 42 then -- essence of earth
            textOutput, attack = abilitiesT2:EssenceOfEarth(attacker, defender)   
            textOutput = textOutput.." "..abilitiesT1:Cleanse(attacker)            
            scene:HideAfflictionImages(attacker["type"], false)
        elseif abilIndex == 43 then -- replenish
            textOutput = abilitiesT2:Replenish(attacker)
            scene:ShowReplenishImages(attacker["type"])
        elseif abilIndex == 44 then -- hamstring
            textOutput = abilitiesT2:Hamstring(attacker, defender)
            if defender["statusHamstring"] then
                scene:ShowHamstringImages(defender["type"])
            end    
        elseif abilIndex == 45 then -- haste
            textOutput = abilitiesT2:Haste(attacker)
            if attacker["buffHaste"] then
                scene:ShowHasteImages(attacker["type"])
            end      
        elseif abilIndex == 46 then -- mind shatter
            textOutput = abilitiesT2:MindShatter(attacker, defender) 
        elseif abilIndex == 47 then -- valor
            textOutput = abilitiesT2:Valor(attacker)
            scene:ShowValorImages(attacker["type"])  
        elseif abilIndex == 48 then -- reflective shield
            textOutput = abilitiesT2:ReflectiveShield(attacker)
            scene:ShowRefShieldImages(attacker["type"])  
        elseif abilIndex == 49 then -- dark pact
            textOutput, attack = abilitiesT2:DarkPact(attacker, defender)
            local mindBreakText = ""
            local deludeText = ""
            if not defender["debuffMindBreak"] then
                mindBreakText = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Mind Break")
                scene:ShowMindBreakImages(defender["type"])
            else
                mindBreakText = defender["name"].." is already Mind Broken."
            end
            if not defender["debuffDelude"] then
                deludeText = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Delude")
                scene:ShowDeludeImages(defender["type"])
            else
                deludeText = defender["name"].." is already Deluded."
            end
            
            textOutput = textOutput.." "..mindBreakText.." "..deludeText               
        elseif abilIndex == 50 then -- kinetic touch
            -- player shouldn't be able to get to this. could put npc behavior here
        elseif abilIndex == 51 then -- mental overload
            textOutput, attack = abilitiesT2:MentalOverload(attacker, defender)
            local bText = ""
            local sText = ""
            if not defender["statusBlind"] then
                bText = abilitiesT1:SilenceLullBlind(attacker, defender, "Blinds")
                
                if defender["statusBlind"] then
                    scene:ShowBlindImages(defender["type"])
                end 
            else
                bText = defender["name"].." is already Blind."
            end
            if not defender["statusSilence"] then
                sText = abilitiesT1:SilenceLullBlind(attacker, defender, "Silences")
                
                if defender["statusSilence"] then
                    scene:ShowSilenceImages(defender["type"])  
                end
            else
                sText = defender["name"].." is already Silenced."
            end
            
            textOutput = textOutput.." "..bText.." "..sText      
        elseif abilIndex == 52 then -- siren song
            textOutput = abilitiesT2:SirenSong(attacker, defender)
            local lullText = ""
            if not defender["statusLull"] then
                lullText = abilitiesT1:SilenceLullBlind(attacker, defender, "Lulls")
                
                if defender["statusLull"] then
                    scene:ShowLullImages(defender["type"])
                end 
            else
                lullText = defender["name"].." is already Lulled."
            end
            
            textOutput = textOutput.." "..lullText       
        elseif abilIndex == 53 then -- bend the spoon
            textOutput, attack = abilitiesT2:BendTheSpoon(attacker, defender)
            local mindBreakText = ""
            if not defender["debuffMindBreak"] then
                mindBreakText = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Mind Break")
                scene:ShowMindBreakImages(defender["type"])
            else
                mindBreakText = defender["name"].." is already Mind Broken."
            end
            
            textOutput = textOutput.." "..mindBreakText    
        elseif abilIndex == 54 then -- fallout
            textOutput, attack = abilitiesT2:Fallout(attacker, defender)
            local deludeText = ""
            if not defender["debuffDelude"] then
                deludeText = abilitiesT1:CrampCrippleMindBreakDelude(attacker, defender, "Delude")
                scene:ShowDeludeImages(defender["type"])
            else
                deludeText = defender["name"].." is already Deluded."
            end
            
            textOutput = textOutput.." "..deludeText 
        elseif abilIndex == 55 then -- summon demon
            textOutput = abilitiesT2:SummonDemon(attacker, pet)
            -- todo add image
            if attacker["type"] == "pc" and pet["type"] == "pcPet"  then
                pcPetMagic = true                   
                -- set labels
                pcPetStatGroup.isVisible = true
                pcPetNameLabel.text = pet["name"]
                pcPetHPLabel.text = pet["currentHp"].."/"..pet["hp"]
                pcPetAPLabel.text = pet["currentAp"].."/"..pet["ap"]                  
            elseif attacker["type"] == "npc" and pet["type"] == "npcPet"  then
                npcPetMagic = true                
                -- set labels
                npcPetStatGroup.isVisible = true
                npcPetNameLabel.text = pet["name"]
                npcPetHPLabel.text = pet["currentHp"].."/"..pet["hp"]
                npcPetAPLabel.text = pet["currentAp"].."/"..pet["ap"]                  
            end  
        elseif abilIndex == 56 then -- tame the wild
            -- todo
        elseif abilIndex == 57 then -- banish
            if (attacker["type"] == "pc" or attacker["type"] == "pcPet") and (npcPetMagic or npcPetMelee) then
                textOutput = npcPetStats["name"].." has been banished from battle."
                npcPetStats = {}
                npcPetMelee = false
                npcPetMagic = false
                scene:ClearStats("npc")                
            elseif (attacker["type"] == "npc" or attacker["type"] == "npcPet") and (pcPetMagic or pcPetMelee) then
                textOutput = pcPetStats["name"].." has been banished from battle."
                pcPetStats = {}
                pcPetMelee = false
                pcPetMagic = false
                scene:ClearStats("pc")
            else
                textOutput = attacker["name"].." tries to Banish, but there are no pets available."
            end
        elseif abilIndex == 58 then -- elemental resistance            
            textOutput = abilitiesT2:ElementalResistance(attacker, switchElem)
            scene:ShowElemResImages(attacker["type"])
            switchElem = ""
        elseif abilIndex == 59 then -- imbue
            textOutput = abilitiesT2:Imbue(attacker, defender, switchElem)
            scene:ShowImbueImages(defender["type"])
            switchElem = ""  
        elseif abilIndex == 60 then -- polymorph
            textOutput = abilitiesT2:Polymorph(attacker, defender)
            if defender["debuffCramp"] then
                scene:ShowCrampImages(defender["type"])
            end           
            if defender["debuffCripple"] then
                scene:ShowCrippleImages(defender["type"])
            end           
            if defender["debuffMindBreak"] then
                scene:ShowMindBreakImages(defender["type"])
            end           
            if defender["debuffDelude"] then
                scene:ShowDeludeImages(defender["type"])
            end                       
        end
        
        -- only abilities that return an attack are eligible for reflective shield damage
        if attack and refShieldTarget and defender["buffRefShield"] then
            textOutput = rpg:ReflectiveShieldCheck(attacker, attack, textOutput)            
        end  
        
        scene:BattleLogAdd(textOutput)
    end
    
    if abilIndex <= 30 then
        attacker["currentAp"] =  attacker["currentAp"] - 1
    else
        attacker["currentAp"] =  attacker["currentAp"] - 2
    end
    
    scene:EndTurn()        
    
end

function scene:EndTurnClick()
    scene:EndTurn() -- this will see if anyone has died, update labels, etc. added this for if player hits end turn without taking any sort of regular action
    
    if not battleEnded then
        -- decide who's turn is next and who the defender is. if haste is active, they will begin their second turn
        local attacker, defender        
        
        if (pcTurn and not pcTurnPet) then
            if pcStats["buffHasteOn"] then
                attacker = pcStats 
            
                if npcPetMelee then
                    defender = npcPetStats
                else
                    defender = npcStats
                end            
            elseif (pcPetMelee or pcPetMagic) then
                pcTurnPet = true
                attacker = pcPetStats
                
                if npcPetMelee then
                    defender = npcPetStats
                else
                    defender = npcStats
                end
            else
                pcTurn = false
                attacker = npcStats
                defender = pcStats
            end        
        elseif pcTurnPet then
            if pcPetStats["buffHasteOn"] then
                attacker = pcPetStats 
            
                if npcPetMelee then
                    defender = npcPetStats
                else
                    defender = npcStats
                end  
            else
                pcTurn = false
                pcTurnPet = false
                attacker = npcStats
                
                if pcPetMelee then
                    defender = pcPetStats
                else
                    defender = pcStats
                end
            end
        elseif (not pcTurn and not npcTurnPet) then
            if npcStats["buffHasteOn"] then
                attacker = npcStats 
            
                if pcPetMelee then
                    defender = pcPetStats
                else
                    defender = pcStats
                end 
            elseif (npcPetMelee or npcPetMagic) then
                npcTurnPet = true
                attacker = npcPetStats

                if pcPetMelee then
                    defender = pcPetStats
                else
                    defender = pcStats
                end
            else
                pcTurn = true
                attacker = pcStats
                defender = npcStats
            end
        else -- pc turn
            if npcPetStats["buffHasteOn"] then
                attacker = npcPetStats 
            
                if pcPetMelee then
                    defender = pcPetStats
                else
                    defender = pcStats
                end  
            else    
                pcTurn = true
                npcTurnPet = false
                attacker = pcStats

                if npcPetMelee then
                    defender = npcPetStats
                else
                    defender =  npcStats
                end
            end
        end
        
        if attacker["buffHasteOn"] then
            scene:BattleLogAdd(attacker["name"].."'s Haste allows them to take another turn.")
        else
            scene:BattleLogAdd(attacker["name"].."'s turn.")
        end
        
        scene:StartTurn(attacker, defender)        
    else -- battle is over. todo make this do something different
        composer.gotoScene("screens.Start")
    end
end

function scene:EndTurn()
    turnLost = false -- explicitely set this back to false. todo make sure this is where this should be
    
    --check for deaths, make hp 0 if < 0
    scene:Die()
    
    scene:UpdateStatLabels()
    
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
    
    if not attacker["buffHasteOn"] then -- do not do these actions if the player is on their second haste turn
        scene:TickBuffs("Replenish", attacker, defender)
        scene:TickBuffs("Vampiric Embrace", attacker, defender)
        -- after vampiric embrace is called, make sure defender has not died. if so, change defender or end battle
        if defender["currentHp"] == 0 then
            -- if the defender 
            scene:Die()

            if battleEnded then
                turnLost = true
            else -- choose a new defender. it has to be either the pc or the npc since presumably a pet just died
                if attacker["type"] == "pc" or attacker["type"] == "pcPet" then
                    defender = npcStats
                else
                    defender = pcStats
                end
            end        
        end

        if not battleEnded then
            scene:TickDOTS("Poison", attacker) -- tick dots first since it may kill attacker. turnLost will be set to true if attacker dies
            scene:TickDOTS("Hemorrhage", attacker)
            scene:TickDOTS("Incinerate", attacker)
        end

        if not turnLost then -- tick non damaging afflictions, status effects, and mirror mania        
           scene:TickDebuffs("Cramped", attacker)
           scene:TickDebuffs("Crippled", attacker)
           scene:TickDebuffs("Mind Broken", attacker)
           scene:TickDebuffs("Deluded", attacker)
           scene:TickStatus("Silenced", attacker)
           scene:TickStatus("Blinded", attacker)
           scene:TickStatus("Mirror Mania", attacker) 
           scene:TickBuffs("Valorous", attacker, defender)
           scene:TickBuffs("Shielded", attacker, defender)
           scene:TickBuffs("Elementally Resistant", attacker)
           scene:TickDebuffs("Imbued", attacker)
           scene:TickBuffs("Hasted", attacker, defender)
           scene:TickStatus("Hamstrung", attacker)
        end
    else        
        attacker["buffHasteOn"] = false
    end
    
    scene:TickStatus("Lulled", attacker) 
    -- put hamstring here..maybe
    if attacker["statusHamstring"] then
        -- make sure they aren't trying to also haste
        attacker["buffHasteOn"] = false
        turnLost = true
    end
    
    -- try to execute a multiturn move or lull. these can be called during second haste turn
    if not turnLost then
        scene:TickMultiTurnMoves(attacker, defender)
    end    
    
    scene:UpdateStatLabels()    
    
    if not turnLost and not pcTurn then
        scene:AI(attacker, defender)-- start AI routine
        
        if npcTurnPet then
            if battleEnded then        
                endTurnButton:setLabel("End Battle")
            else
                endTurnButton:setLabel("End NPC Pet Turn")
            end            
            
        else
            if battleEnded then        
                endTurnButton:setLabel("End Battle")
            else
                endTurnButton:setLabel("End NPC Turn")
            end     
        end  
    elseif not turnLost and pcTurn then
        if pcTurnPet then
            if battleEnded then        
                endTurnButton:setLabel("End Battle")
            else
                endTurnButton:setLabel("End Pet Turn") 
            end                       
        else
            if battleEnded then        
                endTurnButton:setLabel("End Battle")
            else
                endTurnButton:setLabel("End Player Turn")
            end   
        end
        
        -- enable controls
        attackButton.isVisible = true
        abilityButton.isVisible = true
        itemButton.isVisible = true
        meditateButton.isVisible = true
        runButton.isVisible = true    
    else
        if battleEnded then
            endTurnButton:setLabel("End Battle")
        elseif pcTurnPet then
            endTurnButton:setLabel("End Pet Turn") 
        elseif pcTurn then
            endTurnButton:setLabel("End Player Turn")
        elseif npcTurnPet then
            endTurnButton:setLabel("End NPC Pet Turn")
        else
            endTurnButton:setLabel("End NPC Turn")
        end
        
        turnLost = false
        scene:EndTurn()
    end    
end

-- tick down various conditions or abilities, apply damage if applicable
-- this is called before a turn starts and an action can be taken
function scene:TickDOTS(condition, attacker)
    local toonName = attacker["name"]
    local toonType = attacker["type"] -- this will either be pc, npc, pcPet, or npcPet  
    
    if condition == "Poison" and attacker["dotPoison"] then
        attacker["currentHp"] = attacker["currentHp"] - attacker["dotPoisonDmg"]
        
        if attacker["currentHp"] < 1 then
            attacker["currentHp"] = 0
        end        
        
        scene:BattleLogAdd(toonName.." has taken "..attacker["dotPoisonDmg"].." damage from "..condition..".") 
        
        if attacker["currentHp"] < 1 then
            turnLost = true
        end   
    elseif condition == "Hemorrhage" and attacker["dotHemorrhage"] then
        local attack = rpg:ValorCheck(attacker, attacker["dotHemorrhageDmg"])
        attacker["currentHp"] = attacker["currentHp"] - attack
        
        if attacker["currentHp"] < 1 then
            attacker["currentHp"] = 0
        end        
        
        scene:BattleLogAdd(toonName.." has taken "..attack.." damage from "..condition..".") 
        
        if attacker["tickDotHemorrhage"] ~= 3 then        
            attacker["tickDotHemorrhage"] = attacker["tickDotHemorrhage"] + 1
        else
            attacker["tickDotHemorrhage"] = 0
            attacker["dotHemorrhage"] = false
            attacker["buffHemorrhageDmg"] = 0
            scene:BattleLogAdd(toonName.."'s "..condition.." has ended.")
            
            if toonType == "pc" then
                pcHemorrhageImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetHemorrhageImg.isVisible = false
            elseif toonType == "npc" then
                npcHemorrhageImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetHemorrhageImg.isVisible = false
            end                   
        end         
        
        if attacker["currentHp"] < 1 then
            turnLost = true
        end  
    elseif condition == "Incinerate" and attacker["dotIncinerate"] then
        local attack = rpg:ValorCheck(attacker, attacker["dotIncinerateDmg"])
        attacker["currentHp"] = attacker["currentHp"] - attack
        
        if attacker["currentHp"] < 1 then
            attacker["currentHp"] = 0
        end        
        
        scene:BattleLogAdd(toonName.." has taken "..attack.." damage from "..condition..".") 
        
        if attacker["tickDotIncinerate"] ~= 3 then        
            attacker["tickDotIncinerate"] = attacker["tickDotIncinerate"] + 1
        else
            attacker["tickDotIncinerate"] = 0
            attacker["dotIncinerate"] = false
            attacker["buffIncinerateDmg"] = 0
            scene:BattleLogAdd(toonName.."'s "..condition.." has ended.")
            
            if toonType == "pc" then
                pcIncinerateImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetIncinerateImg.isVisible = false
            elseif toonType == "npc" then
                npcIncinerateImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetIncinerateImg.isVisible = false
            end                   
        end         
        
        if attacker["currentHp"] < 1 then
            turnLost = true
        end           
    end
end

function scene:TickDebuffs(condition, attacker)
    local toonName = attacker["name"]
    local toonType = attacker["type"] -- this will either be pc, npc, pcPet, or npcPet  
    
    if condition == "Cramped" and attacker["debuffCramp"] then
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
    elseif condition == "Imbued" and attacker["debuffImbue"] then
        if attacker["tickDebuffImbue"] ~= 3 then
            attacker["tickDebuffImbue"] = attacker["tickDebuffImbue"] + 1
        else
            attacker["tickDebuffImbue"] = 0
            attacker["debuffImbue"] = false
            
            if toonType == "pc" then
                pcImbueImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetImbueImg.isVisible = false
            elseif toonType == "npc" then
                npcImbueImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetImbueImg.isVisible = false
            end       
            
            rpg:ImbueElemResRestore(attacker, condition)         
            
            scene:BattleLogAdd(toonName.." is no longer "..condition..".")
        end          
    end
end

function scene:TickStatus(condition, attacker)
    local toonName = attacker["name"]
    local toonType = attacker["type"] -- this will either be pc, npc, pcPet, or npcPet  
    
    if condition == "Silenced" and attacker["statusSilence"] then
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
        if attacker["tickPetMirrorMania"] ~= 3 then
            attacker["tickPetMirrorMania"] = attacker["tickPetMirrorMania"] + 1
        else
            attacker["tickPetMirrorMania"] = 0
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
    elseif condition == "Hamstrung" and attacker["statusHamstring"] then
        if attacker["tickStatusHamstring"] ~= 3 then
            attacker["tickStatusHamstring"] = attacker["tickStatusHamstring"] + 1
            scene:BattleLogAdd(toonName.." is "..condition.." and cannot take an action.")
        else
            attacker["tickStatusHamstring"] = 0
            attacker["statusHamstring"] = false
            
            if toonType == "pc" then
                pcHamstringImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetHamstringImg.isVisible = false
            elseif toonType == "npc" then
                npcHamstringImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetHamstringImg.isVisible = false
            end       
            
            scene:BattleLogAdd(toonName.." is no longer "..condition..".")
        end 
    end
end

function scene:TickBuffs(condition, attacker, defender)
    local toonName = attacker["name"]
    local toonType = attacker["type"] -- this will either be pc, npc, pcPet, or npcPet  
    
    if condition == "Replenish" and attacker["buffReplenish"] then
        attacker["currentHp"] = attacker["currentHp"] + attacker["buffReplenishHeal"]

        if attacker["currentHp"] > attacker["hp"] then
            attacker["currentHp"] = attacker["hp"]
        end        

        scene:BattleLogAdd(toonName.." has restored "..attacker["buffReplenishHeal"].." health from "..condition..".") 
        
        if attacker["tickBuffReplenish"] ~= 3 then        
            attacker["tickBuffReplenish"] = attacker["tickBuffReplenish"] + 1
        else
            attacker["tickBuffReplenish"] = 0
            attacker["buffReplenish"] = false
            attacker["buffReplenishHeal"] = 0
            scene:BattleLogAdd(toonName.."'s "..condition.." has ended.")
            
            if toonType == "pc" then
                pcReplenishImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetReplenishImg.isVisible = false
            elseif toonType == "npc" then
                npcReplenishImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetReplenishImg.isVisible = false
            end                   
        end 
    elseif condition == "Vampiric Embrace" and attacker["buffVampEmb"] then
        local attack = 0
        attack = utilities:Round(attacker["buffVampEmbHeal"] * defender["disease"])
        
        if defender["currentHp"] < attack then
            attack = defender["currentHp"]
        end          
        
        attacker["currentHp"] = attacker["currentHp"] + attacker["buffVampEmbHeal"]
        defender["currentHp"] = defender["currentHp"] - attacker["buffVampEmbHeal"]

        if attacker["currentHp"] > attacker["hp"] then
            attacker["currentHp"] = attacker["hp"]
        end     
        
        if defender["currentHp"] < 1 then
            defender["currentHp"] = 0
        end             

        scene:BattleLogAdd(toonName.."'s "..condition.." has sapped "..attack.." health from "..defender["name"]..".") 
        
        if attacker["tickBuffVampEmb"] ~= 3 then        
            attacker["tickBuffVampEmb"] = attacker["tickBuffVampEmb"] + 1
        else
            attacker["tickBuffVampEmb"] = 0
            attacker["buffVampEmb"] = false
            attacker["buffVampEmbHeal"] = 0
            scene:BattleLogAdd(toonName.."'s "..condition.." has ended.")
            
            if toonType == "pc" then
                pcVampEmbImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetVampEmbImg.isVisible = false
            elseif toonType == "npc" then
                npcVampEmbImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetVampEmbImg.isVisible = false
            end                   
        end 
    elseif condition == "Hasted" and attacker["buffHaste"] then 
        if attacker["tickBuffHaste"] ~= 3 then
            attacker["tickBuffHaste"] = attacker["tickBuffHaste"] + 1
            attacker["buffHasteOn"] = true
        else
            attacker["tickBuffHaste"] = 0
            attacker["buffHaste"] = false
            
            if toonType == "pc" then
                pcHasteImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetHasteImg.isVisible = false
            elseif toonType == "npc" then
                npcHasteImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetHasteImg.isVisible = false
            end       
            
            scene:BattleLogAdd(toonName.." is no longer "..condition..".")
        end  
    elseif condition == "Valorous" and attacker["buffValor"] then
        if attacker["tickBuffValor"] ~= 3 then
            attacker["tickBuffValor"] = attacker["tickBuffValor"] + 1
        else
            attacker["tickBuffValor"] = 0
            attacker["buffValor"] = false
            
            if toonType == "pc" then
                pcValorImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetValorImg.isVisible = false
            elseif toonType == "npc" then
                npcValorImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetValorImg.isVisible = false
            end       
            
            scene:BattleLogAdd(toonName.." is no longer "..condition..".")
        end            
    elseif condition == "Shielded" and attacker["buffRefShield"] then
        if attacker["tickBuffRefShield"] ~= 3 then
            attacker["tickBuffRefShield"] = attacker["tickBuffRefShield"] + 1
        else
            attacker["tickBuffRefShield"] = 0
            attacker["buffRefShield"] = false
            
            if toonType == "pc" then
                pcRefShieldImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetRefShieldImg.isVisible = false
            elseif toonType == "npc" then
                npcRefShieldImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetRefShieldImg.isVisible = false
            end       
            
            scene:BattleLogAdd(toonName.." is no longer "..condition..".")
        end        
    elseif condition == "Elementally Resistant" and attacker["buffElemRes"] then
        if attacker["tickBuffElemRes"] ~= 3 then
            attacker["tickBuffElemRes"] = attacker["tickBuffElemRes"] + 1
        else
            attacker["tickBuffElemRes"] = 0
            attacker["buffElemRes"] = false
            
            if toonType == "pc" then
                pcElemResImg.isVisible = false
            elseif toonType == "pcPet" then
                pcPetElemResImg.isVisible = false
            elseif toonType == "npc" then
                npcElemResImg.isVisible = false
            elseif toonType == "npcPet" then
                npcPetElemResImg.isVisible = false
            end       
            
            rpg:ImbueElemResRestore(attacker, condition)         
            
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
        battleEnded = true
        endTurnButton:setLabel("End Battle")
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
        battleEnded = true
        endTurnButton:setLabel("End Battle")
    end
    
    if npcPetMelee and npcPetStats["currentHp"] < 1 then
        scene:BattleLogAdd(npcPetStats["name"].." has died.")
        npcPetStats = {}
        npcPetMelee = false
        npcPetMagic = false
        scene:ClearStats("npc")
    end  
end

-- calls the ai routine and determines actions
function scene:AI(attacker, defender)
    local petStatus
    
    if (not npcPetMelee) and (not npcPetMagic) then
        petStatus = false
    else
        petStatus = true
    end
    
    local action = ai:AI(attacker, defender, petStatus)
    
    if action == "atk" then
        scene:Attack(attacker, defender)
    elseif action == "med" then
        scene:Meditate(attacker)
    else
        scene:ExecuteAbility(action)
    end
end

-- nil out tables for a pc or npc pet and hide their stat labels
-- passed in string will determine if clearing pc or npc pet
-- called when a pet dies or turns run out(mirror mania)
function scene:ClearStats(owner)
    if owner == "pc" then
        pcPetStats = {}
        pcPetMelee = false
        pcPetMagic = false        
        scene:HideAfflictionImages("pcPet", true) 
        pcPetStatGroup.isVisible = false        
        pcPetNameLabel.text = ""
        pcPetHPLabel.text = "0/0"
        pcPetAPLabel.text = "0/0"        
    elseif owner == "npc" then
        npcPetStats = {}
        npcPetMelee = false
        npcPetMagic = false        
        scene:HideAfflictionImages("npcPet", true)
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
    
    -- todo add initiative roll here. also output text to scroller for whose turn it is
    local roll = utilities:RNG(2)
    
    if roll == 2 then -- player gets first turn
        pcTurn = true     
        endTurnButton:setLabel("End Player Turn")
        scene:BattleLogAdd(pcStats["name"].."'s turn.")
    else    -- npc gets first turn
        pcTurn = false
        scene:BattleLogAdd(npcStats["name"].."'s turn.")
        attackButton.isVisible = false
        abilityButton.isVisible = false
        itemButton.isVisible = false
        meditateButton.isVisible = false
        runButton.isVisible = false  
        endTurnButton:setLabel("End NPC Turn")
        scene:AI(npcStats, pcStats)
    end
    

    pcTurnPet = false
    npcTurnPet = false    
end

-- add a battle event to the scroller log
function scene:BattleLogAdd(logText)
    -- multiline text will be split and looped through, adding a max number of characters each line until completion
    
    local strMaxLen = 110
    local textWidth = scrollRectWidth
    local textHeight = 20    
    local outputDone = false
    local charCount = 0
    
    -- indent the text if it it not indicating whose turn it is
    if not string.find(logText, "'s turn") then
        logText = "   "..logText
    end
        
    
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
            logText = "   "..multiLine
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
    
    kineticTouchOn = false
    chooseElemResOn = false
    chooseImbueOn = false
    switchElem = ""    
    showAbilities = not showAbilities
end

function scene:UpdateStatLabels()
    -- update hp/ap labels for all
    pcHPLabel.text = "HP: "..pcStats["currentHp"].."/"..pcStats["hp"]
    pcAPLabel.text = "AP: "..pcStats["currentAp"].."/"..pcStats["ap"]
    
    if pcPetMelee or pcPetMagic then
        pcPetHPLabel.text = "HP: "..pcPetStats["currentHp"].."/"..pcPetStats["hp"]
        pcPetAPLabel.text = "AP: "..pcPetStats["currentAp"].."/"..pcPetStats["ap"] 
    end    

    npcHPLabel.text = "HP: "..npcStats["currentHp"].."/"..npcStats["hp"]
    npcAPLabel.text = "AP: "..npcStats["currentAp"].."/"..npcStats["ap"]
    
    if npcPetMelee or npcPetMagic then    
        npcPetHPLabel.text = "HP: "..npcPetStats["currentHp"].."/"..npcPetStats["hp"]
        npcPetAPLabel.text = "AP: "..npcPetStats["currentAp"].."/"..npcPetStats["ap"]    
    end
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

function scene:PickElementButtons()
    abil1Button:setLabel("Lightning")
    abil1Button.isVisible = true
    abil2Button:setLabel("Poison")
    abil2Button.isVisible = true
    abil3Button:setLabel("Ice")
    abil3Button.isVisible = true
    abil4Button:setLabel("Disease")
    abil4Button.isVisible = true
    abil5Button:setLabel("Earth")
    abil5Button.isVisible = true
    abil6Button:setLabel("Fire")
    abil6Button.isVisible = true 
    abil7Button.isVisible = false
    abil8Button.isVisible = false
    abil9Button.isVisible = false
    abil10Button.isVisible = false
    abil11Button.isVisible = false
    abil12Button.isVisible = false
    abilityButton.isVisible = false
    
    scene:BattleLogAdd("Choose an element.")
end

-- hide all of the affliction images for the passed in character
function scene:HideAfflictionImages(who, allCheck)
    if who == "pc" then
        scene:HideAffImgPC(allCheck)
    elseif who == "pcPet" then
        scene:HideAffImgPCPet(allCheck)
    elseif who == "npc" then
        scene:HideAffImgNPC(allCheck)
    elseif who == "npcPet" then
        scene:HideAffImgNPCPet(allCheck)
    end   
end

function scene:HideAffImgPC(allCheck)
    pcCrampImg.isVisible = false
    pcCrippleImg.isVisible = false
    pcMindBreakImg.isVisible = false
    pcDeludeImg.isVisible = false
    pcPoisonImg.isVisible = false
    pcBlindImg.isVisible = false
    pcSilenceImg.isVisible = false
    pcLullImg.isVisible = false  
    pcImbueImg.isVisible = false 
    pcHemorrhageImg.isVisible = false 
    pcIncinerateImg.isVisible = false     
    pcHamstringImg.isVisible = false  
    
    -- don't hide these if cleansing
    if allCheck then
        pcValorImg.isVisible = false         
        pcRefShieldImg.isVisible = false  
        pcElemResImg.isVisible = false
        pcReplenishImg.isVisible = false
        pcHasteImg.isVisible = false 
        pcVampEmbImg.isVisible = false 
    end
end

function scene:HideAffImgPCPet(allCheck)
    pcPetCrampImg.isVisible = false
    pcPetCrippleImg.isVisible = false
    pcPetMindBreakImg.isVisible = false
    pcPetDeludeImg.isVisible = false
    pcPetPoisonImg.isVisible = false
    pcPetBlindImg.isVisible = false
    pcPetSilenceImg.isVisible = false
    pcPetLullImg.isVisible = false  
    pcPetImbueImg.isVisible = false 
    pcPetHemorrhageImg.isVisible = false 
    pcPetIncinerateImg.isVisible = false     
    pcPetHamstringImg.isVisible = false  
    
    -- don't hide these if cleansing
    if allCheck then
        pcPetValorImg.isVisible = false         
        pcPetRefShieldImg.isVisible = false  
        pcPetElemResImg.isVisible = false
        pcPetReplenishImg.isVisible = false
        pcPetHasteImg.isVisible = false 
        pcPetVampEmbImg.isVisible = false 
    end   
end

function scene:HideAffImgNPC(allCheck)
    npcCrampImg.isVisible = false
    npcCrippleImg.isVisible = false
    npcMindBreakImg.isVisible = false
    npcDeludeImg.isVisible = false
    npcPoisonImg.isVisible = false
    npcBlindImg.isVisible = false
    npcSilenceImg.isVisible = false
    npcLullImg.isVisible = false  
    npcImbueImg.isVisible = false 
    npcHemorrhageImg.isVisible = false 
    npcIncinerateImg.isVisible = false     
    npcHamstringImg.isVisible = false  
    
    -- don't hide these if cleansing
    if allCheck then
        npcValorImg.isVisible = false         
        npcRefShieldImg.isVisible = false  
        npcElemResImg.isVisible = false
        npcReplenishImg.isVisible = false
        npcHasteImg.isVisible = false 
        npcVampEmbImg.isVisible = false 
    end      
end

function scene:HideAffImgNPCPet(allCheck)
    npcPetCrampImg.isVisible = false
    npcPetCrippleImg.isVisible = false
    npcPetMindBreakImg.isVisible = false
    npcPetDeludeImg.isVisible = false
    npcPetPoisonImg.isVisible = false
    npcPetBlindImg.isVisible = false
    npcPetSilenceImg.isVisible = false
    npcPetLullImg.isVisible = false  
    npcPetImbueImg.isVisible = false 
    npcPetHemorrhageImg.isVisible = false 
    npcPetIncinerateImg.isVisible = false     
    npcPetHamstringImg.isVisible = false  
    
    -- don't hide these if cleansing
    if allCheck then
        npcPetValorImg.isVisible = false         
        npcPetRefShieldImg.isVisible = false  
        npcPetElemResImg.isVisible = false
        npcPetReplenishImg.isVisible = false
        npcPetHasteImg.isVisible = false 
        npcPetVampEmbImg.isVisible = false 
    end          
end

function scene:ShowPoisonImages(who)
    if who == "pc" then
            pcPoisonImg.isVisible = true
    elseif who == "pcPet" then
            pcPetPoisonImg.isVisible = true
    elseif who == "npc" then
            npcPoisonImg.isVisible = true
    elseif who == "npcPet" then
            npcPetPoisonImg.isVisible = true
    end 
end

function scene:ShowCrampImages(who)
    if who == "pc" then
            pcCrampImg.isVisible = true
    elseif who == "pcPet" then
            pcPetCrampImg.isVisible = true
    elseif who == "npc" then
            npcCrampImg.isVisible = true
    elseif who == "npcPet" then
            npcPetCrampImg.isVisible = true
    end    
end

function scene:ShowCrippleImages(who)
    if who == "pc" then
            pcCrippleImg.isVisible = true
    elseif who == "pcPet" then
            pcPetCrippleImg.isVisible = true
    elseif who == "npc" then
            npcCrippleImg.isVisible = true
    elseif who == "npcPet" then
            npcPetCrippleImg.isVisible = true
    end    
end

function scene:ShowMindBreakImages(who)
    if who == "pc" then
            pcMindBreakImg.isVisible = true
    elseif who == "pcPet" then
            pcPetMindBreakImg.isVisible = true
    elseif who == "npc" then
            npcMindBreakImg.isVisible = true
    elseif who == "npcPet" then
            npcPetMindBreakImg.isVisible = true
    end     
end

function scene:ShowDeludeImages(who)
    if who == "pc" then
            pcDeludeImg.isVisible = true
    elseif who == "pcPet" then
            pcPetDeludeImg.isVisible = true
    elseif who == "npc" then
            npcDeludeImg.isVisible = true
    elseif who == "npcPet" then
            npcPetDeludeImg.isVisible = true
    end      
end

function scene:ShowSilenceImages(who)
    if who == "pc" then
            pcSilenceImg.isVisible = true
    elseif who == "pcPet" then
            pcPetSilenceImg.isVisible = true
    elseif who == "npc" then
            npcSilenceImg.isVisible = true
    elseif who == "npcPet" then
            npcPetSilenceImg.isVisible = true
    end   
end

function scene:ShowLullImages(who)
    if who == "pc" then
            pcLullImg.isVisible = true
    elseif who == "pcPet" then
            pcPetLullImg.isVisible = true
    elseif who == "npc" then
            npcLullImg.isVisible = true
    elseif who == "npcPet" then
            npcPetLullImg.isVisible = true
    end    
end

function scene:ShowBlindImages(who)
    if who == "pc" then
            pcBlindImg.isVisible = true
    elseif who == "pcPet" then
            pcPetBlindImg.isVisible = true
    elseif who == "npc" then
            npcBlindImg.isVisible = true
    elseif who == "npcPet" then
            npcPetBlindImg.isVisible = true
    end    
end

function scene:ShowHemorrhageImages(who)
    if who == "pc" then
            pcHemorrhageImg.isVisible = true
    elseif who == "pcPet" then
            pcPetHemorrhageImg.isVisible = true
    elseif who == "npc" then
            npcHemorrhageImg.isVisible = true
    elseif who == "npcPet" then
            npcPetHemorrhageImg.isVisible = true
    end 
end

function scene:ShowIncinerateImages(who)
    if who == "pc" then
            pcIncinerateImg.isVisible = true
    elseif who == "pcPet" then
            pcPetIncinerateImg.isVisible = true
    elseif who == "npc" then
            npcIncinerateImg.isVisible = true
    elseif who == "npcPet" then
            npcPetIncinerateImg.isVisible = true
    end 
end

function scene:ShowVampEmbImages(who)
    if who == "pc" then
            pcVampEmbImg.isVisible = true
    elseif who == "pcPet" then
            pcPetVampEmbImg.isVisible = true
    elseif who == "npc" then
            npcVampEmbImg.isVisible = true
    elseif who == "npcPet" then
            npcPetVampEmbImg.isVisible = true
    end 
end

function scene:ShowImbueImages(who)
    if who == "pc" then
            pcImbueImg.isVisible = true
    elseif who == "pcPet" then
            pcPetImbueImg.isVisible = true
    elseif who == "npc" then
            npcImbueImg.isVisible = true
    elseif who == "npcPet" then
            npcPetImbueImg.isVisible = true
    end 
end

function scene:ShowHamstringImages(who)
    if who == "pc" then
            pcHamstringImg.isVisible = true
    elseif who == "pcPet" then
            pcPetHamstringImg.isVisible = true
    elseif who == "npc" then
            npcHamstringImg.isVisible = true
    elseif who == "npcPet" then
            npcPetHamstringImg.isVisible = true
    end 
end

function scene:ShowValorImages(who)
    if who == "pc" then
            pcValorImg.isVisible = true
    elseif who == "pcPet" then
            pcPetValorImg.isVisible = true
    elseif who == "npc" then
            npcValorImg.isVisible = true
    elseif who == "npcPet" then
            npcPetValorImg.isVisible = true
    end 
end

function scene:ShowRefShieldImages(who)
    if who == "pc" then
            pcRefShieldImg.isVisible = true
    elseif who == "pcPet" then
            pcPetRefShieldImg.isVisible = true
    elseif who == "npc" then
            npcRefShieldImg.isVisible = true
    elseif who == "npcPet" then
            npcPetRefShieldImg.isVisible = true
    end 
end

function scene:ShowElemResImages(who)
    if who == "pc" then
            pcElemResImg.isVisible = true
    elseif who == "pcPet" then
            pcPetElemResImg.isVisible = true
    elseif who == "npc" then
            npcElemResImg.isVisible = true
    elseif who == "npcPet" then
            npcPetElemResImg.isVisible = true
    end 
end

function scene:ShowReplenishImages(who)
    if who == "pc" then
            pcReplenishImg.isVisible = true
    elseif who == "pcPet" then
            pcPetReplenishImg.isVisible = true
    elseif who == "npc" then
            npcReplenishImg.isVisible = true
    elseif who == "npcPet" then
            npcPetReplenishImg.isVisible = true
    end 
end

function scene:ShowHasteImages(who)
    if who == "pc" then
            pcHasteImg.isVisible = true
    elseif who == "pcPet" then
            pcPetHasteImg.isVisible = true
    elseif who == "npc" then
            npcHasteImg.isVisible = true
    elseif who == "npcPet" then
            npcPetHasteImg.isVisible = true
    end 
end

---------------------
-- BEGIN LABELS --
---------------------
function scene:MakePlayerLabels(myScene)

    ------------------
    -- PC LABELS
    ------------------
    local pcStartingY = 15    
    pcStatGroup = display.newContainer(300, 250) -- container for player stats on screen. could change to a regular group if there is a problem with the container
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
        fontSize = 14,
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
    textOptions["y"] = pcStartingY * 2
    textOptions["x"] = 115
    textOptions["text"] = "AP: "..pcStats["ap"].."/"..pcStats["ap"]
    
    pcAPLabel = display.newText(textOptions)    
    
    -- images
    pcCrampImg = display.newImage("images/cramp.png", system.ResourceDirectory)
    pcCrampImg.x = -36
    pcCrampImg.y = pcStartingY * 3
    
    pcCrippleImg = display.newImage("images/cripple.png", system.ResourceDirectory)    
    pcCrippleImg.x = -12
    pcCrippleImg.y = pcStartingY * 3    
    
    pcMindBreakImg = display.newImage("images/mindbreak.png", system.ResourceDirectory)    
    pcMindBreakImg.x = 12
    pcMindBreakImg.y = pcStartingY * 3        
    
    pcDeludeImg = display.newImage("images/delude.png", system.ResourceDirectory)    
    pcDeludeImg.x = 36
    pcDeludeImg.y = pcStartingY * 3   
    
    pcBlindImg = display.newImage("images/blind.png", system.ResourceDirectory)    
    pcBlindImg.x = 60
    pcBlindImg.y = pcStartingY * 3     
    
    pcSilenceImg = display.newImage("images/silence.png", system.ResourceDirectory)    
    pcSilenceImg.x = 84
    pcSilenceImg.y = pcStartingY * 3     
    
    pcPoisonImg = display.newImage("images/poison.png", system.ResourceDirectory)    
    pcPoisonImg.x = -36
    pcPoisonImg.y = pcStartingY * 3 + 24 
    
    pcLullImg = display.newImage("images/lull.png", system.ResourceDirectory)    
    pcLullImg.x = -12
    pcLullImg.y = pcStartingY * 3 + 24 
    
    pcHemorrhageImg = display.newImage("images/hemorrhage.png", system.ResourceDirectory)    
    pcHemorrhageImg.x = 12
    pcHemorrhageImg.y = pcStartingY * 3 + 24       
    
    pcHamstringImg = display.newImage("images/hamstring.png", system.ResourceDirectory)    
    pcHamstringImg.x = 36
    pcHamstringImg.y = pcStartingY * 3 + 24    
    
    pcIncinerateImg = display.newImage("images/incinerate.png", system.ResourceDirectory)    
    pcIncinerateImg.x = 60
    pcIncinerateImg.y = pcStartingY * 3 + 24      
    
    pcImbueImg = display.newImage("images/imbue.png", system.ResourceDirectory)    
    pcImbueImg.x = 84
    pcImbueImg.y = pcStartingY * 3 + 24    
    
    pcHasteImg = display.newImage("images/haste.png", system.ResourceDirectory)    
    pcHasteImg.x = -36
    pcHasteImg.y = pcStartingY * 3 + 48 
    
    pcRefShieldImg = display.newImage("images/reflectiveshield.png", system.ResourceDirectory)    
    pcRefShieldImg.x = -12
    pcRefShieldImg.y = pcStartingY * 3 + 48 
    
    pcValorImg = display.newImage("images/valor.png", system.ResourceDirectory)    
    pcValorImg.x = 12
    pcValorImg.y = pcStartingY * 3 + 48      
    
    pcElemResImg = display.newImage("images/elemresistance.png", system.ResourceDirectory)    
    pcElemResImg.x = 36
    pcElemResImg.y = pcStartingY * 3 + 48    
    
    pcVampEmbImg = display.newImage("images/vampembrace.png", system.ResourceDirectory)    
    pcVampEmbImg.x = 60
    pcVampEmbImg.y = pcStartingY * 3 + 48     
    
    pcReplenishImg = display.newImage("images/replenish.png", system.ResourceDirectory)    
    pcReplenishImg.x = 84
    pcReplenishImg.y = pcStartingY * 3 + 48       
    
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
    pcStatGroup:insert(pcHasteImg)
    pcStatGroup:insert(pcReplenishImg)
    pcStatGroup:insert(pcRefShieldImg)
    pcStatGroup:insert(pcValorImg)
    pcStatGroup:insert(pcElemResImg)
    pcStatGroup:insert(pcImbueImg)
    pcStatGroup:insert(pcHemorrhageImg)
    pcStatGroup:insert(pcIncinerateImg)
    pcStatGroup:insert(pcVampEmbImg)
    pcStatGroup:insert(pcHamstringImg)   
end

function scene:MakePlayerPetLabels(myScene)
    ------------------
    -- PC PET LABELS
    ------------------
    local pcPetStartingY = 15      
    pcPetStatGroup = display.newContainer(300, 250) -- container for player stats on screen. could change to a regular group if there is a problem with the container
    pcPetStatGroup.x = 50
    pcPetStatGroup.y = 110    
    
    local textOptions = {
    text = "PC Pet Name",
    x = 30,
    y = pcPetStartingY,
    anchorX = 0,
    width = 150,
    height = 30,
    font = native.systemFont,
    fontSize = 14,
    align = "left"    
    }    

    pcPetNameLabel = display.newText(textOptions)
    --pcNameLabel:setFillColor(0,0,0)    
    
    -- HP label
    textOptions["y"] = pcPetStartingY * 2
    textOptions["x"] = 35
    textOptions["text"] = "HP: 0/0"
    
    pcPetHPLabel = display.newText(textOptions)
    
    -- AP Label
    textOptions["y"] = pcPetStartingY * 2
    textOptions["x"] = 115
    textOptions["text"] = "AP: 0/0"
    
    pcPetAPLabel = display.newText(textOptions)    
    
    -- images
    pcPetCrampImg = display.newImage("images/cramp.png", system.ResourceDirectory)
    pcPetCrampImg.x = -36
    pcPetCrampImg.y = pcPetStartingY * 3
    
    pcPetCrippleImg = display.newImage("images/cripple.png", system.ResourceDirectory)    
    pcPetCrippleImg.x = -12
    pcPetCrippleImg.y = pcPetStartingY * 3    
    
    pcPetMindBreakImg = display.newImage("images/mindbreak.png", system.ResourceDirectory)    
    pcPetMindBreakImg.x = 12
    pcPetMindBreakImg.y = pcPetStartingY * 3        
    
    pcPetDeludeImg = display.newImage("images/delude.png", system.ResourceDirectory)    
    pcPetDeludeImg.x = 36
    pcPetDeludeImg.y = pcPetStartingY * 3   
    
    pcPetBlindImg = display.newImage("images/blind.png", system.ResourceDirectory)    
    pcPetBlindImg.x = 60
    pcPetBlindImg.y = pcPetStartingY * 3     
    
    pcPetSilenceImg = display.newImage("images/silence.png", system.ResourceDirectory)    
    pcPetSilenceImg.x = 84
    pcPetSilenceImg.y = pcPetStartingY * 3     
    
    pcPetPoisonImg = display.newImage("images/poison.png", system.ResourceDirectory)    
    pcPetPoisonImg.x = -36
    pcPetPoisonImg.y = pcPetStartingY * 3 + 24 
    
    pcPetLullImg = display.newImage("images/lull.png", system.ResourceDirectory)    
    pcPetLullImg.x = -12
    pcPetLullImg.y = pcPetStartingY * 3 + 24 
    
    pcPetHemorrhageImg = display.newImage("images/hemorrhage.png", system.ResourceDirectory)    
    pcPetHemorrhageImg.x = 12
    pcPetHemorrhageImg.y = pcPetStartingY * 3 + 24       
    
    pcPetHamstringImg = display.newImage("images/hamstring.png", system.ResourceDirectory)    
    pcPetHamstringImg.x = 36
    pcPetHamstringImg.y = pcPetStartingY * 3 + 24    
    
    pcPetIncinerateImg = display.newImage("images/incinerate.png", system.ResourceDirectory)    
    pcPetIncinerateImg.x = 60
    pcPetIncinerateImg.y = pcPetStartingY * 3 + 24      
    
    pcPetImbueImg = display.newImage("images/imbue.png", system.ResourceDirectory)    
    pcPetImbueImg.x = 84
    pcPetImbueImg.y = pcPetStartingY * 3 + 24    
    
    pcPetHasteImg = display.newImage("images/haste.png", system.ResourceDirectory)    
    pcPetHasteImg.x = -36
    pcPetHasteImg.y = pcPetStartingY * 3 + 48 
    
    pcPetRefShieldImg = display.newImage("images/reflectiveshield.png", system.ResourceDirectory)    
    pcPetRefShieldImg.x = -12
    pcPetRefShieldImg.y = pcPetStartingY * 3 + 48 
    
    pcPetValorImg = display.newImage("images/valor.png", system.ResourceDirectory)    
    pcPetValorImg.x = 12
    pcPetValorImg.y = pcPetStartingY * 3 + 48      
    
    pcPetElemResImg = display.newImage("images/elemresistance.png", system.ResourceDirectory)    
    pcPetElemResImg.x = 36
    pcPetElemResImg.y = pcPetStartingY * 3 + 48    
    
    pcPetVampEmbImg = display.newImage("images/vampembrace.png", system.ResourceDirectory)    
    pcPetVampEmbImg.x = 60
    pcPetVampEmbImg.y = pcPetStartingY * 3 + 48     
    
    pcPetReplenishImg = display.newImage("images/replenish.png", system.ResourceDirectory)    
    pcPetReplenishImg.x = 84
    pcPetReplenishImg.y = pcPetStartingY * 3 + 48       
    
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
    pcPetStatGroup:insert(pcPetHasteImg)
    pcPetStatGroup:insert(pcPetReplenishImg)
    pcPetStatGroup:insert(pcPetRefShieldImg)
    pcPetStatGroup:insert(pcPetValorImg)
    pcPetStatGroup:insert(pcPetElemResImg)
    pcPetStatGroup:insert(pcPetImbueImg)
    pcPetStatGroup:insert(pcPetHemorrhageImg)
    pcPetStatGroup:insert(pcPetIncinerateImg)
    pcPetStatGroup:insert(pcPetVampEmbImg)
    pcPetStatGroup:insert(pcPetHamstringImg)        
end

function scene:MakeNPCLabels(myScene)
    ------------------
    -- NPC LABELS
    ------------------
    local npcStartingY = 15
    npcStatGroup = display.newContainer(300, 250)
    npcStatGroup.x = GLOB.width - 100
    npcStatGroup.y = 0
    
    local textOptions = {
    text = npcStats["name"],
    x = 30,
    y = npcStartingY,
    anchorX = 0,
    width = 150,
    height = 30,
    font = native.systemFont,
    fontSize = 14,
    align = "left"    
    }    

    local npcNameLabel = display.newText(textOptions)
    --pcNameLabel:setFillColor(0,0,0)    
    
    -- HP label
    textOptions["y"] = npcStartingY * 2
    textOptions["x"] = 35
    textOptions["text"] = "HP: "..npcStats["hp"].."/"..npcStats["hp"]
    
    npcHPLabel = display.newText(textOptions)
    
    -- AP Label
    textOptions["y"] = npcStartingY * 2
    textOptions["x"] = 115
    textOptions["text"] = "AP: "..npcStats["ap"].."/"..npcStats["ap"]
    
    npcAPLabel = display.newText(textOptions)  
    
    -- images
    npcCrampImg = display.newImage("images/cramp.png", system.ResourceDirectory)
    npcCrampImg.x = -36
    npcCrampImg.y = npcStartingY * 3
    
    npcCrippleImg = display.newImage("images/cripple.png", system.ResourceDirectory)    
    npcCrippleImg.x = -12
    npcCrippleImg.y = npcStartingY * 3    
    
    npcMindBreakImg = display.newImage("images/mindbreak.png", system.ResourceDirectory)    
    npcMindBreakImg.x = 12
    npcMindBreakImg.y = npcStartingY * 3        
    
    npcDeludeImg = display.newImage("images/delude.png", system.ResourceDirectory)    
    npcDeludeImg.x = 36
    npcDeludeImg.y = npcStartingY * 3   
    
    npcBlindImg = display.newImage("images/blind.png", system.ResourceDirectory)    
    npcBlindImg.x = 60
    npcBlindImg.y = npcStartingY * 3     
    
    npcSilenceImg = display.newImage("images/silence.png", system.ResourceDirectory)    
    npcSilenceImg.x = 84
    npcSilenceImg.y = npcStartingY * 3     
    
    npcPoisonImg = display.newImage("images/poison.png", system.ResourceDirectory)    
    npcPoisonImg.x = -36
    npcPoisonImg.y = npcStartingY * 3 + 24 
    
    npcLullImg = display.newImage("images/lull.png", system.ResourceDirectory)    
    npcLullImg.x = -12
    npcLullImg.y = npcStartingY * 3 + 24 
    
    npcHemorrhageImg = display.newImage("images/hemorrhage.png", system.ResourceDirectory)    
    npcHemorrhageImg.x = 12
    npcHemorrhageImg.y = npcStartingY * 3 + 24       
    
    npcHamstringImg = display.newImage("images/hamstring.png", system.ResourceDirectory)    
    npcHamstringImg.x = 36
    npcHamstringImg.y = npcStartingY * 3 + 24    
    
    npcIncinerateImg = display.newImage("images/incinerate.png", system.ResourceDirectory)    
    npcIncinerateImg.x = 60
    npcIncinerateImg.y = npcStartingY * 3 + 24      
    
    npcImbueImg = display.newImage("images/imbue.png", system.ResourceDirectory)    
    npcImbueImg.x = 84
    npcImbueImg.y = npcStartingY * 3 + 24    
    
    npcHasteImg = display.newImage("images/haste.png", system.ResourceDirectory)    
    npcHasteImg.x = -36
    npcHasteImg.y = npcStartingY * 3 + 48 
    
    npcRefShieldImg = display.newImage("images/reflectiveshield.png", system.ResourceDirectory)    
    npcRefShieldImg.x = -12
    npcRefShieldImg.y = npcStartingY * 3 + 48 
    
    npcValorImg = display.newImage("images/valor.png", system.ResourceDirectory)    
    npcValorImg.x = 12
    npcValorImg.y = npcStartingY * 3 + 48      
    
    npcElemResImg = display.newImage("images/elemresistance.png", system.ResourceDirectory)    
    npcElemResImg.x = 36
    npcElemResImg.y = npcStartingY * 3 + 48    
    
    npcVampEmbImg = display.newImage("images/vampembrace.png", system.ResourceDirectory)    
    npcVampEmbImg.x = 60
    npcVampEmbImg.y = npcStartingY * 3 + 48     
    
    npcReplenishImg = display.newImage("images/replenish.png", system.ResourceDirectory)    
    npcReplenishImg.x = 84
    npcReplenishImg.y = npcStartingY * 3 + 48       
    
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
    npcStatGroup:insert(npcHasteImg)
    npcStatGroup:insert(npcReplenishImg)
    npcStatGroup:insert(npcRefShieldImg)
    npcStatGroup:insert(npcValorImg)
    npcStatGroup:insert(npcElemResImg)
    npcStatGroup:insert(npcImbueImg)
    npcStatGroup:insert(npcHemorrhageImg)
    npcStatGroup:insert(npcIncinerateImg)
    npcStatGroup:insert(npcVampEmbImg)
    npcStatGroup:insert(npcHamstringImg)      
end

function scene:MakeNPCPetLabels(myScene)
    ------------------
    -- NPC PET LABELS
    ------------------
    local npcPetStartingY = 15
    npcPetStatGroup = display.newContainer(300, 250) -- container for player stats on screen. could change to a regular group if there is a problem with the container
    npcPetStatGroup.x = GLOB.width - 100
    npcPetStatGroup.y = 110
    
    local textOptions = {
    text = "NPC Pet Name",
    x = 30,
    y = npcPetStartingY,
    anchorX = 0,
    width = 150,
    height = 30,
    font = native.systemFont,
    fontSize = 14,
    align = "left"    
    }        

    npcPetNameLabel = display.newText(textOptions)
    --pcNameLabel:setFillColor(0,0,0)    
    
    -- HP label
    textOptions["y"] = npcPetStartingY * 2
    textOptions["x"] = 35
    textOptions["text"] = "HP: 0/0"
    
    npcPetHPLabel = display.newText(textOptions)
    
    -- AP Label
    textOptions["y"] = npcPetStartingY * 2
    textOptions["x"] = 115
    textOptions["text"] = "AP: 0/0"
    
    npcPetAPLabel = display.newText(textOptions)  
    
    -- images
    npcPetCrampImg = display.newImage("images/cramp.png", system.ResourceDirectory)
    npcPetCrampImg.x = -36
    npcPetCrampImg.y = npcPetStartingY * 3
    
    npcPetCrippleImg = display.newImage("images/cripple.png", system.ResourceDirectory)    
    npcPetCrippleImg.x = -12
    npcPetCrippleImg.y = npcPetStartingY * 3    
    
    npcPetMindBreakImg = display.newImage("images/mindbreak.png", system.ResourceDirectory)    
    npcPetMindBreakImg.x = 12
    npcPetMindBreakImg.y = npcPetStartingY * 3        
    
    npcPetDeludeImg = display.newImage("images/delude.png", system.ResourceDirectory)    
    npcPetDeludeImg.x = 36
    npcPetDeludeImg.y = npcPetStartingY * 3   
    
    npcPetBlindImg = display.newImage("images/blind.png", system.ResourceDirectory)    
    npcPetBlindImg.x = 60
    npcPetBlindImg.y = npcPetStartingY * 3     
    
    npcPetSilenceImg = display.newImage("images/silence.png", system.ResourceDirectory)    
    npcPetSilenceImg.x = 84
    npcPetSilenceImg.y = npcPetStartingY * 3     
    
    npcPetPoisonImg = display.newImage("images/poison.png", system.ResourceDirectory)    
    npcPetPoisonImg.x = -36
    npcPetPoisonImg.y = npcPetStartingY * 3 + 24 
    
    npcPetLullImg = display.newImage("images/lull.png", system.ResourceDirectory)    
    npcPetLullImg.x = -12
    npcPetLullImg.y = npcPetStartingY * 3 + 24 
    
    npcPetHemorrhageImg = display.newImage("images/hemorrhage.png", system.ResourceDirectory)    
    npcPetHemorrhageImg.x = 12
    npcPetHemorrhageImg.y = npcPetStartingY * 3 + 24       
    
    npcPetHamstringImg = display.newImage("images/hamstring.png", system.ResourceDirectory)    
    npcPetHamstringImg.x = 36
    npcPetHamstringImg.y = npcPetStartingY * 3 + 24    
    
    npcPetIncinerateImg = display.newImage("images/incinerate.png", system.ResourceDirectory)    
    npcPetIncinerateImg.x = 60
    npcPetIncinerateImg.y = npcPetStartingY * 3 + 24      
    
    npcPetImbueImg = display.newImage("images/imbue.png", system.ResourceDirectory)    
    npcPetImbueImg.x = 84
    npcPetImbueImg.y = npcPetStartingY * 3 + 24    
    
    npcPetHasteImg = display.newImage("images/haste.png", system.ResourceDirectory)    
    npcPetHasteImg.x = -36
    npcPetHasteImg.y = npcPetStartingY * 3 + 48 
    
    npcPetRefShieldImg = display.newImage("images/reflectiveshield.png", system.ResourceDirectory)    
    npcPetRefShieldImg.x = -12
    npcPetRefShieldImg.y = npcPetStartingY * 3 + 48 
    
    npcPetValorImg = display.newImage("images/valor.png", system.ResourceDirectory)    
    npcPetValorImg.x = 12
    npcPetValorImg.y = npcPetStartingY * 3 + 48      
    
    npcPetElemResImg = display.newImage("images/elemresistance.png", system.ResourceDirectory)    
    npcPetElemResImg.x = 36
    npcPetElemResImg.y = npcPetStartingY * 3 + 48    
    
    npcPetVampEmbImg = display.newImage("images/vampembrace.png", system.ResourceDirectory)    
    npcPetVampEmbImg.x = 60
    npcPetVampEmbImg.y = npcPetStartingY * 3 + 48     
    
    npcPetReplenishImg = display.newImage("images/replenish.png", system.ResourceDirectory)    
    npcPetReplenishImg.x = 84
    npcPetReplenishImg.y = npcPetStartingY * 3 + 48       
    
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
    npcPetStatGroup:insert(npcPetHasteImg)
    npcPetStatGroup:insert(npcPetReplenishImg)
    npcPetStatGroup:insert(npcPetRefShieldImg)
    npcPetStatGroup:insert(npcPetValorImg)
    npcPetStatGroup:insert(npcPetElemResImg)
    npcPetStatGroup:insert(npcPetImbueImg)
    npcPetStatGroup:insert(npcPetHemorrhageImg)
    npcPetStatGroup:insert(npcPetIncinerateImg)
    npcPetStatGroup:insert(npcPetVampEmbImg)
    npcPetStatGroup:insert(npcPetHamstringImg)    
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
    options["onRelease"] = self.RunClick 
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
    options["onRelease"] = self.AbilitySevenClick
    abil7Button = widget.newButton(options)
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil8"
    options["x"] = buttonXLoc  
    options["onRelease"] = self.AbilityEightClick
    abil8Button = widget.newButton(options)    
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil9"
    options["x"] = buttonXLoc
    options["onRelease"] = self.AbilityNineClick
    abil9Button = widget.newButton(options)  
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil10"
    options["x"] = buttonXLoc  
    options["onRelease"] = self.AbilityTenClick
    abil10Button = widget.newButton(options)  
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil11"
    options["x"] = buttonXLoc   
    options["onRelease"] = self.AbilityElevenClick
    abil11Button = widget.newButton(options)  
    
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Abil12"
    options["x"] = buttonXLoc   
    options["onRelease"] = self.AbilityTwelveClick
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
    -- add the containers to the main display group

    scene:MakePlayerLabels(sceneGroup)
    scene:MakePlayerPetLabels(sceneGroup)
    scene:MakeNPCLabels(sceneGroup)
    scene:MakeNPCPetLabels(sceneGroup)
    sceneGroup:insert(pcStatGroup)
    sceneGroup:insert(pcPetStatGroup)
    sceneGroup:insert(npcStatGroup)
    sceneGroup:insert(npcPetStatGroup)       
    
    
    
    -- hide all the affliction images. can comment these all out to make sure they are in correct positions
    scene:HideAfflictionImages("pc", true)
    scene:HideAfflictionImages("pcPet", true)
    scene:HideAfflictionImages("npc", true)
    scene:HideAfflictionImages("npcPet", true)    
    
    
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

