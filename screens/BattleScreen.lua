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

-- todo. should these be pulled in from JSON? figure out how to store the data
-- tables for player stats
-- todo consider whether to do these as numeric or associative. do we need to store both base and boosted stats?
local pcStats = {}
local pcPetStats = {}

-- npc stat tables
local npcStats = {}
local npcPetStats = {}

-- tables for abilities. numeric index of table represent ability slots (max 12). 
-- data stored in each index is the numeric value of ability
local pcAbilities = {}
local pcPetAbilities = {}
local npcAbilities = {}
local npcPetAbilities = {}

-- tables for various conditions. this may need changed
-- original version used these as bool values with each index representing pc, pc pet, npc, npc pet
local delayedReactionReady = {}
local unleashReady = {}
local finalCountdownReady = {}

-- contains damage and matchups for multi turn abilities
-- subscript 0-pcVnpc, 1-pcVnpcpet, 2-pcpetVnpc, 3-pcpetVnpcpet, 4-npcVpc, 5-npcVpcpet, 6-npcpetVpc, 7-npcpetVpcpet                
-- might want to change this
local nextTurnDmg = {}

-- the next tables are status ailments. the first table is a bool for whether they are afflicted
-- second is either damage taken or ticks left on ailment

-- venom from orig, will refer as poison here
-- todo remove these variables. they will be included in each set of stat tables instead
local dotPoison = {} -- bool for whether poisoned or not
local dotPoisonDmg = {} -- actual damage inflicted

-- cramp
local debuffCramp = {} -- bool
local tickDebuffCramp = {}

-- cripple
local debuffCripple = {}
local tickDebuffCripple = {}

-- mind break
local debuffMindBreak = {}
local tickDebuffMindBreak = {}

-- delude
local debuffDelude = {}
local tickDebuffDelude = {}

-- final countdown
local tickFinalCountdown = {}

-- blind
local statusBlind = {}
local tickStatusBlind = {}

-- lull
local statusLull = {}

-- silence
local statusSilence = {}
local tickStatusSilence = {}

-- mirror mania
local petMirrorMania = {}
local tickPetMirrorMania = {}

-- various variables for battle
local pcInit
local npcInit
local roll
local attack
local doubleAttack -- might not need
local turnLost -- bool value

-- some string values
local abilName
local encounter

-- bools to keep track of pets that are out
local pcPetMelee
local npcPetMelee
local pcPetMagic
local npcPetMagic

-- more bools
-- i must have it set up so that if these are all false it is npc's turn?
local pcTurn
local pcTurnPet
local npcTurnPet

-- todo some item variables were here in orig. need a new way to deal with those
-- probably pull up inv screen from shop and disable what doesn't need to be shown
---------------------
--  END FORWARD VARIABLE DECLARATIONS --
---------------------  

---------------------
-- BEGIN FORWARD CONTROL DECLARATIONS --
---------------------   
 
-- buttons
local attackButton
local abilityButton
local itemButton
local meditateButton
local runButton
local endTurnButton
 
-- labels 
local pcHPLabel
local pcAPLabel 
local pcPetHPLabel
local pcPetAPLabel 
local npcHPLabel
local npcAPLabel 
local npcPetHPLabel
local npcPetAPLabel  

-- affliction images
local pcCrampImg
local pcCrippleImg
local pcMindBreakImg
local pcDeludeImg
local pcPoisonImg
local pcBlindImg
local pcSilenceImg
local pcLullImg
local pcPetCrampImg
local pcPetCrippleImg
local pcPetMindBreakImg
local pcPetDeludeImg
local pcPetPoisonImg
local pcPetBlindImg
local pcPetSilenceImg
local pcPetLullImg
local npcCrampImg
local npcCrippleImg
local npcMindBreakImg
local npcDeludeImg
local npcPoisonImg
local npcBlindImg
local npcSilenceImg
local npcLullImg
local npcPetCrampImg
local npcPetCrippleImg
local npcPetMindBreakImg
local npcPetDeludeImg
local npcPetPoisonImg
local npcPetBlindImg
local npcPetSilenceImg
local npcPetLullImg
 
-- stuff for scrollview
local scrollView
local visibleScroll = 100 -- the visible area of the scrollview
local scrollRectWidth = 400
local scrollArea
local scrollY = 10 -- this will allow the first item added to be in the right position
local newScrollHeight = 0
---------------------
--  END FORWARD CONTROL DECLARATIONS --
---------------------  
  

function scene:LoadToons()

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
            scene:Attack(pcPetStats["name"], npcPetStats["name"], pcPetStats["str"], npcPetStats["def"], npcPetStats)
        else
            scene:Attack(pcPetStats["name"], npcStats["name"], pcPetStats["str"], npcStats["def"], npcStats)
        end
    else -- player's turn
        if npcPetMelee then
            scene:Attack(pcStats["name"], npcPetStats["name"], pcStats["str"], npcPetStats["def"], npcPetStats)
        else
            scene:Attack(pcStats["name"], npcStats["name"], pcStats["str"], npcStats["def"], npcStats)
        end
    end
end

-- attack function. can be called by players and npcs as well as their pets
function scene:Attack(atkName, defName, atkStat, defStat, defTable)
    scene:CheckSilenceBlind("blind") -- if the person attacking is blinded and fails check, the following if statement code will not execute
    
    if not turnLost then
        local roll = utilities:RNG(6)        
        
        local attack = atkStat + roll - defStat
        
        if attack > 0 then
            defTable["currentHp"] = defTable["currentHp"] - attack
            scene:BattleLogAdd(atkName.." makes an Attack, doing "..attack.." damage to "..defName..".")
        else            
            scene:BattleLogAdd(atkName.." Attacks "..defName.." but does no damage.")
        end
    end
    
    turnLost = false
    scene:EndTurn()
    
end

-- check for silence or blind. a string value will be passed in to check the table value in the character's stats
-- determine whose turn it is and if they are afflicted. if so, roll and see if they are prevented from acting
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
        
        if affliction == "blind" then
            affText = "blinded"
        else
            affText = "silenced"
        end
        
        local outputString = outputName.." is "..affText.." and is unable to make an action."

        if roll ~= 3 then
            scene:BattleLogAdd(outputString)
            turnLost = true
        end   
    end
end

function scene:EndTurnClick()
    --todo finish this up. since each outcome will output some text and then start turn, just set the values in each if statement and execute at end of function
    
    -- decide who's turn is next
    if (pcTurn and not pcTurnPet) then
        if (pcPetMelee or pcPetMagic) then
            pcTurnPet = true
            -- output some text
            if npcPetMelee then
                --StartTurn()
            else
                --StartTurn()
            end
        else
            pcTurn = false
            --output some text
            scene:StartTurn(npcStats, pcStats)
        end        
    elseif pcTurnPet then
        pcTurn = false
        pcTurnPet = false
        --output some text
        if pcPetMelee then
            --StartTurn()
        else
            --StartTurn()
        end
    elseif (not pcTurn and not pcTurnPet) then
        if (npcPetMelee or npcPetMagic) then
            npcTurnPet = true
            --output some text
            if pcPetMelee then
                --StartTurn()
            else
                --StartTurn()
            end
        else
            pcTurn = true
            --output some text
            scene:StartTurn(pcStats, npcStats)
        end
    else -- pc turn
        pcTurn = true
        npcTurnPet = false
        --output some text
        if npcPetMelee then
            --StartTurn()
        else
            --StartTurn()
        end
    end
end

function scene:EndTurn()
    
    --check for deaths, make hp 0 if < 0
    scene:Die()
    
    -- update hp/ap labels for all
    -- todo figure out how to deal with pets here
    pcHPLabel.text = "HP: "..pcStats["currentHp"].."/"..pcStats["hp"]
    pcAPLabel.text = "AP: "..pcStats["currentAp"].."/"..pcStats["ap"]
    --pcPetHPLabel.text = "HP: "..pcPetStats["currentHp"].."/"..pcPetStats["hp"]
    --pcPetAPLabel.text = "AP: "..pcPetStats["currentAp"].."/"..pcPetStats["ap"] 
    npcHPLabel.text = "HP: "..npcStats["currentHp"].."/"..npcStats["hp"]
    npcAPLabel.text = "AP: "..npcStats["currentAp"].."/"..npcStats["ap"]
    --npcPetHPLabel.text = "HP: "..npcPetStats["currentHp"].."/"..npcPetStats["hp"]
    --npcPetAPLabel.text = "AP: "..npcPetStats["currentAp"].."/"..npcPetStats["ap"]    
    
    -- todo find a better way to deal with this. using images might be ok, then just disable them ex: attackButton:setEnabled(false)
    attackButton.isVisible = false
    abilityButton.isVisible = false
    itemButton.isVisible = false
    meditateButton.isVisible = false
    runButton.isVisible = false

    -- todo add anything else that needs changed here
    
end

--check ticks, call on ai after player finishes turn, check to see if a player is dead
function scene:StartTurn(attacker, defender)
    
    --scene:Ticks("poison", attacker)
    
    if not turnLost then
        -- tick non damaging afflictions
        
        
    end
    
    if not turnLost then
        -- tick multi turn moves
    end
    
    -- start AI routine
    if not turnLost and not pcTurn then
        scene:AI(attacker, defender)
    elseif not turnLost and pcTurn then
        if pcTurnPet then
            -- set up controls for pet's turn
        else
            -- set up controls for player's turn
            attackButton.isVisible = true
            abilityButton.isVisible = true
            itemButton.isVisible = true
            meditateButton.isVisible = true
            runButton.isVisible = true
        end
    else
        turnLost = false
        scene:EndTurn()
    end
    
end

-- tick down various conditions or abilities, apply damage if applicable
function scene:Ticks(condition, attacker)
    
    local toonName = attacker["name"]
    local toonType = attacker["type"] -- this will either be pc, npc, pcPet, or npcPet
    
    if condition == "Poison" and attacker["dotPoison"] then
        
    elseif condition == "Cramped" and attacker["debuffCramp"] then
        
    elseif condition == "Crippled" and attacker["debuffCripple"] then
        
    elseif condition == "Mind Broken" and attacker["debuffMindBreak"] then
        
    elseif condition == "Deluded" and attacker["debuffDelude"] then
        
    elseif condition == "Silenced" and attacker["debuffSilence"] then
        
    elseif condition == "Blinded" and attacker["debuffBlind"] then
        
    elseif condition == "Mirror Mania" and attacker["petMirrorMania"] then -- todo make sure this is working correctly
    
    elseif condition == "Lulled" and attacker["debuffLull"] then
        
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
        pcPetStats = nil
        pcPetMelee = false
        pcPetMagic = false
        -- todo need to clear out or hide any other variable associated with pet (ticks, stats, labels, etc)
    end
    
    if npcStats["currentHp"] < 1 then
        npcStats["currentHp"] = 0
        scene:BattleLogAdd(npcStats["name"].." has died.")
    end
    
    if npcPetMelee and npcPetStats["currentHp"] < 1 then
        scene:BattleLogAdd(npcPetStats["name"].." has died.")
        npcPetStats = nil
        npcPetMelee = false
        npcPetMagic = false
        -- todo need to clear out or hide any other variable associated with pet (ticks, stats, labels, etc)
    end    
    
end

function scene:AI(attacker, defender)
    --todo add rest of stuff. for now just attack and return control to player
    scene:Attack(npcStats["name"], pcStats["name"], npcStats["str"], pcStats["def"], pcStats)
end

-- set some initial conditions for battle
function scene:Initialize()
    pcPetMelee = false
    pcPetMagic = false
    npcPetMelee = false
    npcPetMagic = false
    turnLost = false
    
    -- todo add initiative roll here
    pcTurn = true
    pcTurnPet = false
    npcTurnPet = false    
    
end

-- add a battle event to the scroller log
function scene:BattleLogAdd(logText)
    
    --todo: deal with text that will be multiline. could bump up scrollY's increase if text is too long for a line
    
    local textWidth = 600 -- had this at 400 but bumped it up to 600 to fill entire container?
    local textHeight = 20
    
    local logOptions = {
        text = logText,
        x = textWidth/2,
        y = scrollY,
        width = textWidth,
        height = textHeight,
        font = native.systemFont,
        fontSize = 14,
        align = "left"    
    }  
    
    scrollY = scrollY + textHeight

    --logOptions["text"] = "Nothing "..scrollY        
    local itemLabel = display.newText(logOptions)
    itemLabel:setFillColor(1,1,1) 

    newScrollHeight = newScrollHeight + textHeight 
    scrollArea:insert(itemLabel)
    scrollArea.height = newScrollHeight * 2
    scrollView:setScrollHeight(newScrollHeight)  
    
    -- once the visible area of the scroller is filled, new events will be added to the bottom and will give appearance of scrolling up
    if newScrollHeight >= visibleScroll then
        scrollView:scrollToPosition {x = 0,y = - newScrollHeight + visibleScroll,time = 400} -- had to set the y position to negative to get this to work right
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
    local pcPetStatGroup = display.newContainer(300, 200) -- container for player stats on screen. could change to a regular group if there is a problem with the container
    pcPetStatGroup.x = 50
    pcPetStatGroup.y = 100
    
    -- the text label's center is point 0,0. this must be accounted for
    -- label for player pet name
    textOptions["x"] = 30
    textOptions["y"] = pcPetStartingY    
    textOptions["text"] = "PC Pet Name"

    local pcPetNameLabel = display.newText(textOptions)
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
    local npcPetStatGroup = display.newContainer(300, 200) -- container for player stats on screen. could change to a regular group if there is a problem with the container
    npcPetStatGroup.x = GLOB.width - 100
    npcPetStatGroup.y = 100
    
    -- the text label's center is point 0,0. this must be accounted for
    -- label for player pet name
    textOptions["x"] = 30
    textOptions["y"] = npcPetStartingY    
    textOptions["text"] = "NPC Pet Name"

    local npcPetNameLabel = display.newText(textOptions)
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
    local buttonXLoc = (buttonWidth + strokeWidth) / 2 + 37 -- this should center everything
    
    local options = {
        label = "Attack",
        emboss = false,
        shape = "roundedRect",
        x = buttonXLoc,
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
    options["onRelease"] = nil
    
    abilityButton = widget.newButton(options)
    
    -- item button
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Item"
    options["x"] = buttonXLoc

    
    itemButton = widget.newButton(options)
    
    -- meditate button
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Meditate"
    options["x"] = buttonXLoc

    
    meditateButton = widget.newButton(options)     
    
    -- run button
    buttonXLoc = buttonXLoc + 125
    options["label"] = "Run"
    options["x"] = buttonXLoc

    
    runButton = widget.newButton(options)      
    
    -- end turn button
    buttonXLoc = buttonXLoc + 125
    options["label"] = "End Turn"
    options["x"] = buttonXLoc
    options["onRelease"] = self.EndTurnClick  
    
    endTurnButton = widget.newButton(options)      
    
    -- add controls to group 
    buttonGroupOne:insert(attackButton)
    buttonGroupOne:insert(abilityButton)
    buttonGroupOne:insert(itemButton)
    buttonGroupOne:insert(meditateButton)
    buttonGroupOne:insert(runButton)
    buttonGroupOne:insert(endTurnButton) 
    myScene:insert(buttonGroupOne)
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
        left = 200,
        top = 225,
        width = 400,
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
    
    scrollArea = display.newContainer(800, 0) -- had to double rectWidth here for some reason?

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

    scene:LoadToons()
    scene:Initialize()    

    ---------------------
    --  BEGIN CONTROLS --
    ---------------------
    scene:MakeLabels(sceneGroup)
    scene:MakeButtons(sceneGroup)
    scene:MakeScroller(sceneGroup)    
    
    ---------------------
    --  END CONTROLS --
    ---------------------
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

