local URL = require "addon-manager.url.url"
local vcs = require "addon-manager.vcs.vcs"
local github = require "addon-manager.vcs.github"
local gitlab = require "addon-manager.vcs.gitlab"

local install = {}

install.directory = ROOT / "addonManager" / "addons"

---Parse an addon URI, returning the needed VCS and repo path
---@param uri any
---@return addonManager.vcs.GitHub | addonManager.vcs.GitLab
---@return string repoPath
function install.parseAddonURI(uri)
    local success, result = pcall(URL.parse, uri)

    if not success then
        error(result, 2)
    end

    ---@cast result URL.URL

    if result.protocol == "github:" then
        return github, result.pathname
    elseif result.protocol == "gitlab:" then
        return gitlab, result.pathname
    elseif result.protocol == "https:" or result.protocol == "http:" then
        if result.hostname == "github.com" then
            return github, result.pathname
        elseif result.hostname == "gitlab.com" then
            return gitlab, result.pathname
        end
    end

    error("unable to parse addon URI", 2)
end

---Install an addon from the registry
---@param id string
---@param addon addonManager.registry.Addon
---@param tag string?
function install.fromRegistry(id, addon, tag)
    local zipName = string.format("%s.zip", id)

    local neededVSC, _ = install.parseAddonURI(addon.repository)

    ---@type addonManager.vcs.VCS
    local vcsClient
    if neededVSC == vcs.type.GitHub then
        vcsClient = github.client
    elseif neededVSC == vcs.type.GitLab then
        vcsClient = gitlab.client
    end

    ---@type addonManager.vcs.Release
    local release

    if not tag then
        release = vcsClient.getLatestRelease(addon.repository)
    else
        release = vcsClient.getReleaseByTag(addon.repository, tag)
    end

    if #release.assets < 1 then
        error(string.format("release %s (%s) contains no assets", release.name, release.tagName), 2)
    end

    local asset = vcs.findAssetByName(release.assets, zipName)
    assert(asset, "failed to find suitable .zip asset in the release. There should be a " .. zipName .. " asset in the release")

    vcsClient.downloadAsset(addon.repository, asset, install.directory:string())

    ---TODO: unzip installed addon
    ---TODO: delete installed zip when unzipped
end

return install
