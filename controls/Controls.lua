

local controls = {}
local control_mt = {__index = controls}



-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------


-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

-- contstructor
function controls.new (xLoc, yLoc)
    
    local newControl = {
                    xLoc = xLoc or 0,
                    yLoc = yLoc or 0    
    }
    
    return setmetatable(newControl, control_mt)
    
end





function controls:newLabel()
    
    
    
    
end



----------------------------------
 
 return controls


