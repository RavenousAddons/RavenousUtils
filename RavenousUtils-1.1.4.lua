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

--- Toggles a feature with a specified timeout
-- @param {table} toggles
-- @param {string} toggle
-- @param {number} timeout
function ns:Toggle(toggle, timeout)
    if not ns.data.toggles[toggle] then
        ns.data.toggles[toggle] = GetServerTime() + math.max(timeout, 0)
        C_Timer.After(math.max(timeout, 0), function()
            ns.data.toggles[toggle] = false
        end)
    end
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
function ns:SetOptionDefault(optionsTable, key, default)
    if optionsTable[ns.prefix .. key] == nil then
        optionsTable[ns.prefix .. key] = default
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
