local ADDON_NAME, ns = ...

--- Prints a formatted message to the chat
-- @param {string} message
function ns:PrettyPrint(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff" .. ns.color .. ns.name .. "|r " .. message)
end

-- Returns the index of a given value in a table or false if not found
-- @param {table} table
-- @param {any} value
-- @return {number|boolean}
function ns:Contains(table, value)
    for index, check in ipairs(table) do
        if value == check then
            return index
        end
    end
    return false
end

--- Returns a key from the options table
-- @param {table} optionsTable
-- @param {string} key
-- @return {any}
function ns:OptionValue(optionsTable, key)
    return optionsTable[ns.prefix .. key]
end

-- Set default values for options which are not yet set
-- @param {table} optionsTable
-- @param {string} key
-- @param {any} default
function ns:SetOptionDefaults(optionsTable, key, default)
    if optionsTable[ns.prefix .. key] == nil then
        if optionsTable[key] ~= nil then
            optionsTable[ns.prefix .. key] = optionsTable[key]
            optionsTable[key] = nil
        else
            optionsTable[ns.prefix .. key] = default
        end
    end
end

--- Toggles a feature with a specified timeout
-- @param {table} toggles
-- @param {string} toggle
-- @param {number} timeout
function ns:Toggle(toggle, timeout)
    if not ns.data.toggles[toggle] then
        ns.data.toggles[toggle] = true
        CT.After(math.max(timeout, 0), function()
            ns.data.toggles[toggle] = false
        end)
    end
end

--- Plays a sound if option is enabled
-- @param {table} optionsTable
-- @param {number} id
-- @param {string} [key]
function ns:PlaySound(optionsTable, id, key)
    if ns:OptionValue(optionsTable, key ~= nil and key or "sound") then
        PlaySoundFile(id)
    end
end

--- Opens the Addon settings menu and plays a sound
function ns:OpenSettings()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    Settings.OpenToCategory(ns.Settings:GetID())
end

--- Returns a number of runs to expect a drop based on its percentage drop
--- chance and optionally a reasonable percentage to expect it by and a bound to
--- limit the loop by
-- @param {number} chance
-- @param {number} [reasonable]
-- @param {number} [bound]
-- @return {number}
function ns:RunsUntilDrop(chance, reasonable, bound)
    reasonable = reasonable and math.max(1, math.min(99, reasonable)) or 95
    bound = bound and bound or 10000
    for runs = 1, bound do
        local percentage = 1 - ((1 - chance / 100) ^ runs)
        if percentage > (reasonable / 100) then
            return runs
        end
    end
    return bound
end
