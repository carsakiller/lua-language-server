local searchParams = require "addon-manager.lib.url.searchParams"

local PROTOCOL_PORTS = {
    ["http"] = "80",
    ["https"] = "443",
    ["ftp"] = "21"
}

---Check whether the provided port is the default for the given protocol
---@param protocol string
---@param port string
---@return boolean
local function isDefaultPort(protocol, port)
    return PROTOCOL_PORTS[protocol] == port
end

---@class URL.URL : URL.prototype
---@field protocol string The protocol scheme of the URL, **NOT** including the `:` suffix.<hr/>[MDN](https://developer.mozilla.org/en-US/docs/Web/API/URL/protocol)
---@field host string The hostname and port (if included and not default for provided scheme) separated by `:`.<hr/>[MDN](https://developer.mozilla.org/en-US/docs/Web/API/URL/host)
---@field hostname string The hostname.<hr/>[MDN](https://developer.mozilla.org/en-US/docs/Web/API/URL/hostname)
---@field origin string The `scheme` + `host`.<hr/>[MDN](https://developer.mozilla.org/en-US/docs/Web/API/URL/origin)
---@field pathname string The path of the URL.<hr/>[MDN](https://developer.mozilla.org/en-US/docs/Web/API/URL/pathname)
---@field port string? The port of the URL, if provided.<hr/>[MDN](https://developer.mozilla.org/en-US/docs/Web/API/URL/port)
---@field username string? The username specified before the hostname, if provided.<hr/>[MDN](https://developer.mozilla.org/en-US/docs/Web/API/URL/username)
---@field password string? The password specified before the hostname, if provided.<hr/>[MDN](https://developer.mozilla.org/en-US/docs/Web/API/URL/password)
---@field hash string? The fragment identifier, if provided, prefixed with `#`.<hr/>[MDN](https://developer.mozilla.org/en-US/docs/Web/API/URL/hash)
---@field search string? The search/query string, if provided, prefixed with `?`.<hr/>[MDN](https://developer.mozilla.org/en-US/docs/Web/API/URL/search)
---@field searchParams table<string, string> The search/query key/value pairs in a table for ease of use.

local URL = {}

---@class URL.prototype
---@field private __type "URL"
---@field package _setHostname fun(self: URL.URL, hostname: string)
---@field package _setPort fun(self: URL.URL, port: string)
---@field package _setHost fun(self: URL.URL, host: string)
---@field package _setSearch fun(self: URL.URL, search: string)
URL.prototype = {
    __type = "URL",

    _setHostname = function(self, hostname)
        rawset(rawget(self, "_data"), "hostname", hostname)
        rawset(rawget(self, "_data"), "host", hostname)

        local port = rawget(self, "_data").port
        local host = rawget(self, "_data").host
        if port then
            rawset(rawget(self, "_data"), "host", string.format("%s:%s", host, port))
        end
    end,

    _setPort = function(self, port)
        local protocol = rawget(self, "_data").protocol
        local hostname = rawget(self, "_data").hostname

        if not port or isDefaultPort(protocol, port) then
            rawset(rawget(self, "_data"), "port", nil)
            rawset(rawget(self, "_data"), "host", hostname)
            return
        end

        rawset(rawget(self, "_data"), "port", port)
        rawset(rawget(self, "_data"), "host", string.format("%s:%s", hostname, port))
    end,

    _setHost = function(self, host)
        local hostname, port = string.match(host, "([^:]+):?(.*)")

        rawset(rawget(self, "_data"), "hostname", hostname)
        self:_setPort(port ~= "" and port or nil)
    end,

    _setSearch = function(self, search)
        rawget(self, "_data").searchParams = searchParams.fromString(self, search)
    end
}

URL.metatable = {
    ---@param self URL.URL
    ---@param key any
    __index = function(self, key)
        if key == "search" then
            local asString = tostring(rawget(self, "_data").searchParams)
            return asString ~= "" and asString or nil
        end
        return rawget(self, "_data")[key] or URL.prototype[key]
    end,

    ---@param self URL.URL
    ---@param key any
    ---@param value any
    __newindex = function(self, key, value)
        if key == "host" then
            self:_setHost(value)
        elseif key == "hostname" then
            self:_setHostname(value)
        elseif key == "port" then
            self:_setPort(value)
        elseif key == "pathname" then
            -- add leading slash if not included
            if value and string.sub(value, 1, 1) ~= "/" then
                value = "/" .. value
            end
            rawget(self, "_data")[key] = value
        elseif key == "search" then
            self:_setSearch(value)
        elseif key == "searchParams" then
            if type(value) == "table" then
                for k, v in pairs(value) do
                    rawget(self, "_data").searchParams[k] = v
                end
            else
                error("cannot replace searchParams with a non-table", 2)
            end
        elseif key == "hash" then
            if value and string.sub(value, 1, 1) ~= "#" then
                value = "#" .. value
            end
            rawget(self, "_data")[key] = value
        else
            rawget(self, "_data")[key] = value
        end
    end,

    ---@param self URL.URL
    __tostring = function(self)
        local str = string.format("%s://", self.protocol)

        if self.username then
            str = str .. self.username
        end
        if self.password then
            str = str .. ":" .. self.password
        end

        if self.username or self.password then
            str = str .. "@"
        end

        str = str .. self.host

        str = str .. self.pathname

        if self.search then
            str = str .. self.search
        end

        if self.hash then
            str = str .. self.hash
        end

        return str
    end
}

function URL.parse(url)
    ---@type URL.URL
    local self = setmetatable({ _data = {} }, URL.metatable)

    rawset(rawget(self, "_data"), "searchParams", searchParams.new(self))

    local start = 1

    local a, z, protocol = string.find(url, "^([^:]+)://")
    if not z then
        error("cannot parse malformed URL", 2)
    end
    self.protocol = protocol
    start = z + 1

    local a, z, userInfo = string.find(url, "^([^@]+)@", start)
    if z then
        local username, password = string.match(userInfo, "^([^:]+):?(.*)$")
        self.username = username
        self.password = password ~= "" and password or nil
        start = z + 1
    end

    local a, z, hostname = string.find(url, "([^:/#?]+)", start)
    if not z then
        error("cannot parse malformed URL", 2)
    end
    self.hostname = hostname
    start = z + 1

    local a, z, port = string.find(url, ":(%d+)", start)
    if z then
        self:_setPort(port)
        start = z + 1
    end

    local a, z, path = string.find(url, "(/[^?#]+)", start)
    if z then
        self.pathname = path
        start = z + 1
    else
        self.pathname = "/"
    end

    local a, z, query = string.find(url, "(%?[^#]+)")
    if z then
        self:_setSearch(query)
        start = z + 1
    end

    local a, z, fragment = string.find(url, "(#.+)")
    if z then
        self.hash = fragment
        start = z + 1
    end

    return self
end

return URL
