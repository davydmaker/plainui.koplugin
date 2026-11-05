local HiddenTabs = {}

HiddenTabs.SETTINGS_KEY = "plainui_hidden_tabs"

-- Books stays visible, since it is the way back to the library.
local HIDEABLE = {
    series = true,
    authors = true,
    tags = true,
}

function HiddenTabs.isHidden(key)
    if not HIDEABLE[key] or not G_reader_settings then
        return false
    end
    local hidden = G_reader_settings:readSetting(HiddenTabs.SETTINGS_KEY)
    return type(hidden) == "table" and hidden[key] == true
end

function HiddenTabs.filter(tabs)
    local visible = {}
    for _, tab in ipairs(tabs) do
        if not HiddenTabs.isHidden(tab.key) then
            table.insert(visible, tab)
        end
    end
    return visible
end

return HiddenTabs
