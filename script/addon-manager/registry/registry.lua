local json = require "json"
local cache = require "addon-manager.fs-cache"

---@class addonManager.registry.Addon
---@field name string
---@field author string
---@field description string
---@field repository string

local registry = {}

registry.REPO_URL = "https://github.com/carsakiller/lls-addon-registry"
registry.REPO_BRANCH = "main"
registry.FILE_PATH = "addons.json"

---Get the raw list of addons from the official registry as a JSON string.
---@param githubClient addonManager.vcs.GitHub
---@return string
function registry.getAddonListRaw(githubClient)
    local function fetchAddonList()
        local content = githubClient.getRawFileContent(registry.REPO_URL, registry.REPO_BRANCH, registry.FILE_PATH)
        return content
    end

    return cache.get("addon-registry", fetchAddonList, 60 * 5) --[[@as string]]
end

---Get the list of addons from the official registry
---@param githubClient addonManager.vcs.GitHub
---@return table<string, addonManager.registry.Addon>
function registry.getAddonList(githubClient)
    local content = githubClient.getRawFileContent(registry.REPO_URL, registry.REPO_BRANCH, registry.FILE_PATH)

    return assert(json.decode(content))
end

return registry
