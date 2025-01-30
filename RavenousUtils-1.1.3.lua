local ADDON_NAME, ns = ...

---
-- Lookups
---

local gameVersion = GetBuildInfo()

---
-- Utility Functions
---

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
        ns.data.toggles[toggle] = true
        C_Timer.After(math.max(timeout, 0), function()
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

---
-- Settings Panel Functions
---

--- Opens the Addon settings menu and plays a sound
function ns:OpenSettings()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    Settings.OpenToCategory(ns.Settings:GetID())
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

-- Creates a settings panel checkbox
local function CreateCheckBox(optionsTable, category, option)
    local setting = Settings.RegisterAddOnSetting(category, ns.prefix .. option.key, ns.prefix .. option.key, optionsTable, type(ns.data.defaults[option.key]), option.name, ns.data.defaults[option.key])
    setting.owner = ADDON_NAME
    Settings.CreateCheckbox(category, setting, option.tooltip)
    if option.new == ns.version then
        if not NewSettings[gameVersion] then
            NewSettings[gameVersion] = {}
        end
        table.insert(NewSettings[gameVersion], ns.prefix .. option.key)
    end
end

-- Creates a settings panel dropdown
local function CreateDropDown(optionsTable, category, option)
    local setting = Settings.RegisterAddOnSetting(category, ns.prefix .. option.key, ns.prefix .. option.key, optionsTable, type(ns.data.defaults[option.key]), option.name, ns.data.defaults[option.key])
    setting.owner = ADDON_NAME
    Settings.CreateDropdown(category, setting, option.fn, option.tooltip)
    if option.callback then
        Settings.SetOnValueChangedCallback(ns.prefix .. option.key, option.callback)
    end
    if option.new == ns.version then
        if not NewSettings[gameVersion] then
            NewSettings[gameVersion] = {}
        end
        table.insert(NewSettings[gameVersion], ns.prefix .. option.key)
    end
end

-- Creates a settings panel section
local function CreateSection(optionsTable, category, layout, title, options)
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(title))
    for index = 1, #options do
        local option = options[index]
        if option.condition == nil or option.condition() then
            if option.fn then
                CreateDropDown(optionsTable, category, option)
            else
                CreateCheckBox(optionsTable, category, option)
            end
        end
    end
end

-- Creates a settings panel
function ns:CreateSettingsPanel(optionsTable, sections)
    local category, layout = Settings.RegisterVerticalLayoutCategory(ns.name)
    Settings.RegisterAddOnCategory(category)

    for index = 1, #sections do
        local section = sections[index]
        if section.condition == nil or section.condition() then
            CreateSection(optionsTable, category, layout, section.title, section.options)
        end
    end

    ns.Settings = category
end
