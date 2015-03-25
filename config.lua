application = {
	content = {
		width = 640,-- 480 not sure if this is best. popular size. fits between 16:9 and 16:10 aspect ratios
		height = 960, --800
		fps = 30,
                scale = "letterbox",
		
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
