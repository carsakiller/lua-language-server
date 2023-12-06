---A VCS is an abstraction of a Version Control System. It provides a common interface to be implemented for GitHub, GitLab, etc.
---@class addonManager.vcs.VCS
---@field client any HTTP client for making HTTP requests. Should not be re-used as it may contain authorization tokens.
---@field getLatestRelease fun(repoURL: string): addonManager.vcs.Release Get the latest release for the project
---@field getReleaseByTag fun(repoURL: string, tagName: string): addonManager.vcs.Release Get a specific release using a tag name
---@field getRawFileContent fun(repoURL: string, ref: string, path: string): string Get the raw contents of a file
---@field downloadAsset fun(repoURL: string, asset: addonManager.vcs.Asset, installDirPath: string) Download an asset to a file

---An abstraction that provides a common interface for release assets.
---@class addonManager.vcs.Asset
---@field ID integer
---@field name string
---@field downloadURL string

---An abstraction that provides a common interface for releases.
---@class addonManager.vcs.Release
---@field name string
---@field tagName string
---@field description string
---@field releasedAt string
---@field isPrerelease boolean
---@field assets addonManager.vcs.Asset[]

local vcs = {}

---@enum addonManager.vcs.type
vcs.type = {
    GitHub = 1,
    GitLab = 2,
}

---Find a specific `Asset` by name from an `Asset[]`.
---@param assets addonManager.vcs.Asset[]
---@param targetName string
---@return addonManager.vcs.Asset?
function vcs.findAssetByName(assets, targetName)
    for _, asset in ipairs(assets) do
        if asset.name == targetName then
            return asset
        end
    end
    return nil
end

return vcs
