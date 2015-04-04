require "CiderDebugger";local composer = require "composer"


-- can comment this out to get predicable values for testing
math.randomseed(os.time()) -- seed the RNG


    -- this will sort the table alphabetically a-z by name.
    -- will probably need this elsewhere
    -- can also set up a way to return a table of just items that match a criteria through sorting and iterating
--table.sort(GLOB.items, function (a,b) return (a.Name < b.Name) end)

-- call starting scene or attach event to a button
-- also set up any runtime listeners here
-- also can set up global variables
composer.gotoScene("screens.Start")