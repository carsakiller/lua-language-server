local lclient   = require 'lclient'
local ws        = require 'workspace'
local await     = require 'await'
local config    = require 'config'

---@async
lclient():start(function (client)
    client:registerFakers()
    client:initialize()

    config.set(nil, 'Lua.diagnostics.enable', false)

    ws.awaitReady()

    client:notify('textDocument/didOpen', {
        textDocument = {
            uri = 'file://test.lua',
            languageId = 'lua',
            version = 0,
            text = [[
---@type number
local x

---@type number
local y

x = y

y = x
]]
        }
    })

    await.sleep(0.1)

    local hover1 = client:awaitRequest('textDocument/hover', {
        textDocument = { uri = 'file://test.lua' },
        position = { line = 1, character = 7 },
    })

    local hover2 = client:awaitRequest('textDocument/hover', {
        textDocument = { uri = 'file://test.lua' },
        position = { line = 8, character = 1 },
    })

    assert(hover1.contents.value:find 'number')
    assert(hover2.contents.value:find 'number')

    client:notify('textDocument/didOpen', {
        textDocument = {
            uri = 'file://test.lua',
            languageId = 'lua',
            version = 1,
            text = [[
---@type number
local x

---@type number
local y

---@type number
local z

x = y
y = z
z = y
x = y
x = z
z = x
y = x
]]
        }
    })


    await.sleep(0.1)

    local hover1 = client:awaitRequest('textDocument/hover', {
        textDocument = { uri = 'file://test.lua' },
        position = { line = 9, character = 0 },
    })

    local hover2 = client:awaitRequest('textDocument/hover', {
        textDocument = { uri = 'file://test.lua' },
        position = { line = 10, character = 0 },
    })

    local hover3 = client:awaitRequest('textDocument/hover', {
        textDocument = { uri = 'file://test.lua' },
        position = { line = 11, character = 0 },
    })

    local hover4 = client:awaitRequest('textDocument/hover', {
        textDocument = { uri = 'file://test.lua' },
        position = { line = 12, character = 0 },
    })

    local hover5 = client:awaitRequest('textDocument/hover', {
        textDocument = { uri = 'file://test.lua' },
        position = { line = 13, character = 0 },
    })

    local hover6 = client:awaitRequest('textDocument/hover', {
        textDocument = { uri = 'file://test.lua' },
        position = { line = 14, character = 0 },
    })

    local hover7 = client:awaitRequest('textDocument/hover', {
        textDocument = { uri = 'file://test.lua' },
        position = { line = 15, character = 0 },
    })

    assert(hover1.contents.value:find 'number')
    assert(hover2.contents.value:find 'number')
    assert(hover3.contents.value:find 'number')
    assert(hover4.contents.value:find 'number')
    assert(hover5.contents.value:find 'number')
    assert(hover6.contents.value:find 'number')
    assert(hover7.contents.value:find 'number')

    config.set(nil, 'Lua.diagnostics.enable', true)
end)
