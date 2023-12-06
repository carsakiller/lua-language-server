local filesystem = require "bee.filesystem"

---@class addonManager.fs-cache.Item
---@field path fs.path
---@field updated integer Modified timestamp


---@class addonManager.fs-cache
---@field private cachePath fs.path? Path to directory to store cached files
local fsCache = {}

fsCache.cachePath = nil

function fsCache.init()
    fsCache.cachePath = ROOT / "addonManager" / "cache"

    if not filesystem.exists(fsCache.cachePath) then
        filesystem.create_directories(fsCache.cachePath)
        return
    end

    if filesystem.is_directory(fsCache.cachePath) then
        return
    end
    filesystem.remove(fsCache.cachePath)
end

---Get a simple hash of a cache key for use as a file name
---@param key string
---@return string
function fsCache.getCacheFilename(key)
    return string.format("%x", key)
end

---Get the file path of a cache key
---@param key string
---@return fs.path
function fsCache.getCacheFilepath(key)
    return fsCache.cachePath / fsCache.getCacheFilename(key)
end

---Get a cache `Item` from the cache directory.
---@param path fs.path
---@return addonManager.fs-cache.Item
function fsCache.getCacheEntry(path)
    local mtime = filesystem.last_write_time(path)

    ---@type addonManager.fs-cache.Item
    return {
        path = path,
        updated = mtime
    }
end

---Get an entry from the cache or fetch it if expired or nil
---@generic T
---@param key string
---@param fetchFunc fun(): T
---@param timeout integer
---@return T?
function fsCache.get(key, fetchFunc, timeout)
    local path = fsCache.getCacheFilepath(key)
    local entry = fsCache.getCacheEntry(path)
    local now = os.time(os.date("!*t") --[[@as osdateparam]])

    if entry and now - entry.updated < timeout then
        -- Cache hit
        local file = assert(io.open(path:string(), "r"))
        local content = file:read("a")
        file:close()
        return content
    end

    -- Cache miss
    local content = fetchFunc()
    local file = assert(io.open(path:string(), "w"))
    assert(file:write(content))
    return content
end

return fsCache
