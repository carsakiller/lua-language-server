local versioning = require "addon-manager.lib.versioning"
local filesystem = require "bee.filesystem"
local install    = require "addon-manager.addons.install"
local json       = require "json"
local management = {}

---@class addonManager.Addon
---@field version string
---@field name string
---@field author string
---@field description string
---@field repository string

---Compare the versions of two addons
---@param addonA addonManager.Addon
---@param addonB addonManager.Addon
---@return -1|0|1|nil
---@return string? err An error message, if any
function management.compareVersions(addonA, addonB)
    return versioning.compare(addonA.version, addonB.version)
end

---Get the list of installed addons
---@return table<string, addonManager.Addon>
function management.getInstalledAddons()
    ---@type table<string, addonManager.Addon>
    local addons = {}

    for path, status in filesystem.pairs(install.directory) do
        if status:is_directory() then
            local name = path:filename()

            local infoFilePath = install.directory / name / "addon.json"
            local file, err = io.open(infoFilePath:string(), "r")
            if err then
                -- TODO: log error
            else
                ---@cast file file*
                local addon = json.decode(file:read("a"))
                addons[name] = addon
            end
        end
    end

    return addons
end

return management
