local command = {}

local tables = require("tables")
-- Convert brightness from 1-10 to 0-255 scale
local function convertBrightness(brightness)
    return math.floor((brightness) * 25.5)
end

-- Construct and run the command based on settings
function command.run(settings, colors, double_colors)
    local commandStr = "/opt/muos/device/rg40xx-h/script/led_control.sh"
    local mode = settings.mode
    local brightness = convertBrightness(settings.brightness)
    local color = colors[settings.color].rgb
    local speed = settings.speed * 5

    if mode == 1 then
        -- "Off" mode
        commandStr = commandStr .. string.format(" 1 0 0 0 0 0 0 0")
    elseif mode == 2 then
        -- "Static" mode
        commandStr = commandStr .. string.format(" 1 %d %d %d %d %d %d %d", brightness, color[1], color[2], color[3], color[1], color[2], color[3])
    elseif mode == 3 then
        -- "Fast Breathing" mode
        commandStr = commandStr .. string.format(" 2 %d %d %d %d", brightness, color[1], color[2], color[3])
    elseif mode == 4 then
        -- "Med Breathing" mode
        commandStr = commandStr .. string.format(" 3 %d %d %d %d", brightness, color[1], color[2], color[3])
    elseif mode == 5 then
        -- "Slow Breathing" mode
        commandStr = commandStr .. string.format(" 4 %d %d %d %d", brightness, color[1], color[2], color[3])
    elseif mode == 6 then
        -- "Static Combo" mode
        local comboIndex = settings.combo
        local comboColors = double_colors[comboIndex].rgb
        commandStr = commandStr .. string.format(" 1 %d %d %d %d %d %d %d", brightness, comboColors[1], comboColors[2], comboColors[3], comboColors[4], comboColors[5], comboColors[6])
    elseif mode == 7 then
        -- "Mono Rainbow" mode
        commandStr = commandStr .. string.format(" 5 %d %d", brightness, speed)
    elseif mode == 8 then
        -- "Multi Rainbow" mode
        commandStr = commandStr .. string.format(" 6 %d %d", brightness, speed)
    end

    -- Print the command to the console
    print("Running command: " .. commandStr)

	--Define the path to the folder and the command file
	local folderPath = "/run/muos/storage/theme/active/rgb"
	local commandFile = folderPath .. "/rgbconf.sh"

	-- Ensure the directory exists
	os.execute("mkdir -p " .. folderPath)

	-- Open the file for writing
	local file = io.open(commandFile, "w")
	if file then
    -- Write the command string to the file
    file:write(commandStr)
    file:close()
    print("Command saved to: " .. commandFile)
	else
    print("Error: Could not save the file.")
	end

    -- Execute the command in the system shell
    os.execute(commandStr)
end

return command
