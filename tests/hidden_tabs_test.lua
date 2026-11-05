package.path = "./?.lua;./?/init.lua;" .. package.path

local TestHelper = require("tests.test_helper")
local HiddenTabs = require("modules.hidden_tabs")

local assertEqual = TestHelper.assertEqual
local test, run = TestHelper.newSuite()

local saved_settings = G_reader_settings

local function withHidden(hidden, fn)
    G_reader_settings = {
        readSetting = function(_self, key)
            if key == HiddenTabs.SETTINGS_KEY then
                return hidden
            end
        end,
    }
    local ok, err = pcall(fn)
    G_reader_settings = saved_settings
    if not ok then
        error(err, 0)
    end
end

local function keys(tabs)
    local out = {}
    for _, tab in ipairs(tabs) do
        table.insert(out, tab.key)
    end
    return table.concat(out, " ")
end

local ALL = { { key = "books" }, { key = "series" }, { key = "authors" }, { key = "tags" } }

test("keeps every tab without the setting", function()
    withHidden(nil, function()
        assertEqual(keys(HiddenTabs.filter(ALL)), "books series authors tags")
    end)
end)

test("hides the configured tabs and keeps the order", function()
    withHidden({ tags = true, series = true }, function()
        assertEqual(keys(HiddenTabs.filter(ALL)), "books authors")
    end)
end)

test("never hides Books", function()
    withHidden({ books = true }, function()
        assertEqual(keys(HiddenTabs.filter(ALL)), "books series authors tags")
    end)
end)

test("ignores a setting with the wrong shape", function()
    withHidden("tags", function()
        assertEqual(keys(HiddenTabs.filter(ALL)), "books series authors tags")
    end)
    withHidden({ tags = "yes" }, function()
        assertEqual(keys(HiddenTabs.filter(ALL)), "books series authors tags")
    end)
end)

run()
