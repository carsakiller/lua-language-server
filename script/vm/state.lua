local util       = require 'utility'
local files      = require 'files'
local globalNode = require 'vm.global-node'
local guide      = require 'parser.guide'

---@class vm.state
local m = {}
---@type table<uri, parser.object[]>
m.literals = util.multiTable(2)
---@type table<parser.object, table<parser.object, boolean>>
m.literalSubs = util.multiTable(2, function ()
    return setmetatable({}, util.MODE_K)
end)
---@type table<parser.object, boolean>
m.allLiterals = {}

---@param source parser.object
function m.declareLiteral(source)
    if m.allLiterals[source] then
        return
    end
    m.allLiterals[source] = true
    local uri = guide.getUri(source)
    local literals = m.literals[uri]
    literals[#literals+1] = source
end

---@param source parser.object
---@param node   vm.node
function m.subscribeLiteral(source, node)
    if not node then
        return
    end
    if node.type == 'union'
    or node.type == 'cross' then
        node:subscribeLiteral(source)
        return
    end
    if not m.allLiterals[source] then
        return
    end
    m.literalSubs[node][source] = true
end

---@param uri uri
function m.dropUri(uri)
    local literals = m.literals[uri]
    m.literals[uri] = nil
    for _, literal in ipairs(literals) do
        m.allLiterals[literal] = nil
        local literalSubs = m.literalSubs[literal]
        m.literalSubs[literal] = nil
        for source in pairs(literalSubs) do
            source._node = nil
        end
    end
end

for uri in files.eachFile() do
    local state = files.getState(uri)
    if state then
        globalNode.compileAst(state.ast)
    end
end

files.watch(function (ev, uri)
    if ev == 'update' then
        local state = files.getState(uri)
        if state then
            globalNode.compileAst(state.ast)
        end
    end
    if ev == 'remove' then
        m.dropUri(uri)
        globalNode.dropUri(uri)
    end
end)


return m