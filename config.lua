application = {
	content = {
		width = 480,-- not sure if this is best. popular size. fits between 16:9 and 16:10 aspect ratios
		height = 800,
		fps = 30,
                scale = "zoomStretch",
		
		--[[
        imageSuffix = {
		    ["@2x"] = 2,
		}
		--]]
	},

    --[[
    -- Push notifications

    notification =
    {
        iphone =
        {
            types =
            {
                "badge", "sound", "alert", "newsstand"
            }
        }
    }
    --]]    
}
