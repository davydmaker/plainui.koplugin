-- SPDX-FileCopyrightText: 2026 Davyd Maker
-- SPDX-License-Identifier: MIT

local ExtraTabs = {}

local function isWellFormed(tab)
    return type(tab) == "table"
        and type(tab.key) == "string" and tab.key ~= ""
        and type(tab.text) == "string" and tab.text ~= ""
        and type(tab.callback) == "function"
end

-- Returns the registered tabs that can be shown, in registration order.
-- reserved_keys is a table whose keys are the tab keys already in use.
function ExtraTabs.collect(registered, reserved_keys, warn)
    local valid, seen = {}, {}
    for _, tab in ipairs(registered or {}) do
        if not isWellFormed(tab) then
            warn("Plain UI: ignoring a tab without key, text and callback")
        elseif reserved_keys[tab.key] or seen[tab.key] then
            warn("Plain UI: ignoring a tab with a key already in use:", tab.key)
        else
            seen[tab.key] = true
            valid[#valid + 1] = tab
        end
    end
    return valid
end

return ExtraTabs
