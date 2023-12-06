
local Map = require "addon-manager.lib.Map"

---@param search string
---@return Map.Map
local function parseSearchString(search)
    if search == nil then
        return {}
    end

    local queries = Map.new()

    local _, z, k, v = string.find(search, "^%?([^=]+)=?([^&]*)")
    if not z then
        error("malformed search string", 2)
    end
    queries:set(k, v)

    search = string.sub(search, z, #search)

    for k, v in string.gmatch(search, "&([^=]+)=?([^&]+)") do
        queries:set(k, v ~= "" and v or nil)
    end

    return queries
end

---@param queries Map.Map
---@return string
local function stringify(queries)
    local str = "?"
    for _, k, v in queries:iter() do
        if v == "" then
            str = str .. k .. "&"
        else
            str = string.format("%s%s=%s&", str, k, v ~= "" and v or "true")
        end
    end
    if str == "?" then
        return ""
    end
    return string.sub(str, 1, #str - 1)
end

local searchParams = {}

---@class URL.searchParams.SearchParams
---@field __type "SearchParams"
---@field _params Map.Map
---@field package _url URL.URL

searchParams.metatable = {
    ---@private
    ---@param self URL.searchParams.SearchParams
    ---@param key any
    __index = function(self, key)
        ---@type Map.Map
        local map = rawget(self, "_params")
        return map:get(key)
    end,

    ---@private
    ---@param self URL.searchParams.SearchParams
    ---@param key any
    ---@param value any
    __newindex = function(self, key, value)
        ---@type Map.Map
        local map = rawget(self, "_params")

        if value == nil then
            map:remove(key)
        else
            map:set(key, value)
        end
    end,

    ---@private
    ---@param self URL.searchParams.SearchParams
    __pairs = function(self)
        return ipairs(rawget(self, "_params"))
    end,

    ---@private
    ---@param self URL.searchParams.SearchParams
    __len = function(self)
        local num = 0
        for _ in pairs(rawget(self, "_params")) do
            num = num + 1
        end
        return num
    end,

    ---@private
    ---@param self URL.searchParams.SearchParams
    __tostring = function(self)
        return stringify(rawget(self, "_params"))
    end
}

function searchParams.fromString(url, search)
    local self = searchParams.new(url)

    local success, result = pcall(parseSearchString, search)
    if not success then
        error(result, 2)
    end

    rawset(self, "_params", result)

    return self
end

---Create a new searchParams object
---@param url URL.URL
---@return URL.searchParams.SearchParams
function searchParams.new(url)
    ---@type URL.searchParams.SearchParams
    local self = {
        __type = "SearchParams",
        _url = url,
        _params = Map.new()
    }

    return setmetatable(self, searchParams.metatable)
end

return searchParams
