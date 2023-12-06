---@class addonManager.vcs.GitHub : addonManager.vcs.VCS
local GitHub = {}

function GitHub.getLatestRelease(repoURL)
    -- https://api.github.com/repos/{owner}/{repo}/releases/latest
    -- https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28#get-the-latest-release

    ---@type addonManager.vcs.Release
    return {

    }
end

function GitHub.getReleaseByTag(repoURL, tagName)
    -- https://api.github.com/repos/{owner}/{repo}/releases/tags/{tag}
    -- https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28#get-a-release-by-tag-name

    ---@type addonManager.vcs.Release
    return {

    }
end

function GitHub.getRawFileContent(repoURL, ref, path)
    -- https://api.github.com/repos/{owner}/{repo}/contents/{path}?ref={ref}
    -- https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28#get-repository-content
    -- Accept: application/vnd.github.raw

    return
end

function GitHub.downloadAsset(repoURL, asset, installDirPath)
    -- https://api.github.com/repos/{owner}/{repo}/releases/assets/{assetID}
    -- https://docs.github.com/en/rest/releases/assets?apiVersion=2022-11-28#get-a-release-asset
    -- Accept: application/octet-stream
    -- May redirect (302) to asset
end

return GitHub