

local background = {}
local background_mt = {__index = background}

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

-- contstructor
function background.new (xLoc, yLoc, width, height)    
    local newControl = {
                    xLoc = xLoc or 0,
                    yLoc = yLoc or 0,  
                    bg = display.newRect(xLoc, yLoc, width, height),
                    --bg:setFillColor( 0.5 )
    }
    
    return setmetatable(newControl, background_mt)    
end

----------------------------------
 
 return background