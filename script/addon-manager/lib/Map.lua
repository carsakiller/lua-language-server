---@class Map.Map : Map.prototype
---@field package _keys any[]
---@field package _values any[]

local Map = {}

---@class Map.prototype
Map.prototype = {
    ---Set a value in the map
    ---@param self Map.Map
    ---@param key any
    ---@param value any
    set = function(self, key, value)
        if not self:contains(key) then
            table.insert(self._keys, key)
        end

        self._values[key] = value
    end,

    ---Check whether the Map contains a key
    ---@param self Map.Map
    ---@param key any
    ---@return boolean
    contains = function(self, key)
        return self._values[key] ~= nil
    end,

    ---Get a value from the map using its `key`
    ---@param self Map.Map
    ---@param key any
    ---@return any
    get = function(self, key)
        return self._values[key]
    end,

    ---Remove an entry from the maps
    ---@param self Map.Map
    ---@param key any
    remove = function(self, key)
        for i, k in ipairs(self._keys) do
            if k == key then
                table.remove(self._keys, i)
                break
            end
        end

        self._values[key] = nil
    end,

    ---Iterate over the keys and values of the map in order of insertion.
    ---@param self Map.Map
    iter = function(self)
        local index = 0
        return function()
            index = index + 1
            local key = rawget(self, "_keys")[index]
            if key then
                return index, key, rawget(self, "_values")[key]
            end
        end
    end,

    ---Get an iterator for the _keys of the map
    ---@param self Map.Map
    keys = function(self)
        return ipairs(self._keys)
    end,

    ---Get an iterator for the value of the map
    ---@param self Map.Map
    values = function(self)
        return pairs(self._values)
    end
}

---@class Map.metatable
Map.metatable = {
    ---@param self Map.Map
    ---@param key any
    __index = function(self, key)
        return rawget(self, "_values")[key] or Map.prototype[key]
    end,

    ---@param self Map.Map
    __len = function(self)
        return #rawget(self, "_keys")
    end,

    ---@param self Map.Map
    __pairs = function(self)
        return pairs(rawget(self, "_values"))
    end
}

---@return Map.Map
function Map.new()
    ---@type Map.Map
    local self = {
        _keys = {},
        _values = {}
    }

    return setmetatable(self, Map.metatable)
end

return Map
