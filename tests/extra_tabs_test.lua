package.path = "./?.lua;./?/init.lua;" .. package.path

local TestHelper = require("tests.test_helper")
local ExtraTabs = require("modules.extra_tabs")

local assertEqual = TestHelper.assertEqual
local test, run = TestHelper.newSuite()

local function noop() end
local RESERVED = { books = true, series = true }

local function collect(registered)
    local warnings = {}
    local tabs = ExtraTabs.collect(registered, RESERVED, function(message, key)
        warnings[#warnings + 1] = key or message
    end)
    return tabs, warnings
end

test("no registered tabs gives an empty list", function()
    assertEqual(#collect(nil), 0)
    assertEqual(#collect({}), 0)
end)

test("valid tabs keep their registration order", function()
    local tabs, warnings = collect({
        { key = "games", text = "Games", callback = noop },
        { key = "notes", text = "Notes", callback = noop },
    })
    assertEqual(#tabs, 2)
    assertEqual(tabs[1].key, "games")
    assertEqual(tabs[2].key, "notes")
    assertEqual(#warnings, 0)
end)

test("malformed tabs are ignored with a warning", function()
    local tabs, warnings = collect({
        "not a table",
        { text = "No key", callback = noop },
        { key = "", text = "Empty key", callback = noop },
        { key = "no_text", callback = noop },
        { key = "no_callback", text = "No callback" },
        { key = "games", text = "Games", callback = noop },
    })
    assertEqual(#tabs, 1)
    assertEqual(tabs[1].key, "games")
    assertEqual(#warnings, 5)
end)

test("reserved and repeated keys are ignored with a warning", function()
    local tabs, warnings = collect({
        { key = "books", text = "My books", callback = noop },
        { key = "games", text = "Games", callback = noop },
        { key = "games", text = "More games", callback = noop },
    })
    assertEqual(#tabs, 1)
    assertEqual(tabs[1].text, "Games")
    assertEqual(warnings[1], "books")
    assertEqual(warnings[2], "games")
end)

run()
