---@class addonManager.versioning.Version
---@field major integer
---@field minor integer
---@field patch integer

local versioning = {}

---@param v any
---@return boolean
function versioning.isVersion(v)
    if type(v) ~= "table" then
        return false
    end

    if v.major and v.minor and v.patch then
        return true
    end

    return false
end

---Parse a version string into its parts
---@param v string Version string to parse
---@return addonManager.versioning.Version?
---@return string? err
function versioning.parse(v)
    local major, minor, patch = string.match(v, "(%d+).(%d+).(%d+)")

    if not major or not minor or not patch then
        return nil, "cannot parse version string"
    end

    local t = {
        major = major,
        minor = minor,
        patch = patch
    }

    for k, v in pairs(t) do
        t[k] = tonumber(v)

        if t[k] == nil then
            return nil, string.format("failed to cast \"%s\" component to number", k)
        end
    end

    return t
end

---@param a string | addonManager.versioning.Version
---@param b string | addonManager.versioning.Version
---@return -1|0|1|nil `1` if `a` is greater, `0` if equal, `-1` if `b` is greater
---@return string? err An error message, if any
function versioning.compare(a, b)
    if not versioning.isVersion(a) then
        ---@cast a string
        local v, err = versioning.parse(a)
        if err then
            return nil, err
        end
        ---@cast v addonManager.versioning.Version
        a = v
    end
    if not versioning.isVersion(b) then
        ---@cast b string
        local v, err = versioning.parse(b)
        if err then
            return nil, err
        end
        ---@cast v addonManager.versioning.Version
        b = v
    end

    if a.major == b.major and a.minor == b.minor and a.patch == b.patch then
        return 0, nil
    end

    if a.major < b.major or a.minor < b.minor or a.patch < b.patch then
        return -1, nil
    end

    return 1, nil
end

---Check that two versions are equal
---@param a string | addonManager.versioning.Version
---@param b string | addonManager.versioning.Version
---@return boolean
---### Example
---```
---equal("1.0.0", "1.0.0") -> true
---```
function versioning.equal(a, b)
    if versioning.compare(a, b) == 0 then
        return true
    end
    return false
end

---Check that version `a` is greater than version `b`
---@param a string | addonManager.versioning.Version
---@param b string | addonManager.versioning.Version
---@return boolean
---### Example
---```
---greaterThan("1.2.0", "1.1.0") -> true
---```
function versioning.greaterThan(a, b)
    if versioning.compare(a, b) == 1 then
        return true
    end
    return false
end

---Check that version `a` is less than version `b`
---@param a string | addonManager.versioning.Version
---@param b string | addonManager.versioning.Version
---@return boolean
---### Example:
---```
---lessThan("1.1.2", "1.1.3") -> true
---```
function versioning.lessThan(a, b)
    if versioning.compare(a, b) == -1 then
        return true
    end
    return false
end

return versioning
