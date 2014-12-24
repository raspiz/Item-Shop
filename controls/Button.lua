local widget = require "widget"

-- create a button using the widget button. this has an error when i try to use it when the button is moused over

local button = {}
local button_mt = {__index = button}

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

-- contstructor
function button.new (xLoc, yLoc, width, height, text)    
    local newControl = --[[{
                    xLoc = xLoc or 0,
                    yLoc = yLoc or 0, 
                    function handleButtonEvent = function(event)
                        if ( "ended" == event.phase ) then
                            print( "Button was pressed and released" )
                        end 
                    end,
                    -- button is created with a table of options
                    {button =--]] widget.newButton {
                        label = text or "",
                        emboss = false,
                        shape = "roundedRect",
                        x = xLoc,
                        y = yLoc,
                        width = width,
                        height = height,
                        cornerRadius = 2,
                        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
                        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
                        strokeWidth = 4,
                        labelColor = { default={ 0, 0, 0, 1 }, over={ 0, 0, 0, 1 } },
                        --[[onEvent = function(event)
                                if ( "ended" == event.phase ) then
                                    print( "Button was pressed and released" )
                                end 
                            end--]] 
                        --},
                    
                    --button:setTextColor({ 1, 0, 0, 1 })
                    --bg = display.newRect(xLoc, yLoc, width, height),
                    --bg:setFillColor( 0.5 )
    }
    
    return setmetatable(newControl, button_mt)    
end


-- add fx for setLabel and maybe change color or others


----------------------------------
 
 return button