---@class addonManager.vcs.GitLab : addonManager.vcs.VCS
local GitLab = {}

function GitLab.getLatestRelease(repoURL)
    -- https://gitlab.com/api/v4/projects/{id}/releases/permalink/latest
    -- https://docs.gitlab.com/ee/api/releases/#get-the-latest-release

    ---@type addonManager.vcs.Release
    return {

    }
end

function GitLab.getReleaseByTag(repoURL, tagName)
    -- https://gitlab.com/api/v4/projects/{id}/releases/{tag_name}
    -- https://docs.gitlab.com/ee/api/releases/#get-a-release-by-a-tag-name

    ---@type addonManager.vcs.Release
    return {

    }
end

function GitLab.getRawFileContent(repoURL, ref, path)
    -- https://gitlab.com/api/v4/projects/{id}/repository/files/{file_path}/raw
    -- https://docs.gitlab.com/ee/api/repository_files.html#get-raw-file-from-repository

    return
end

function GitLab.downloadAsset(repoURL, asset, installDirPath)
    -- https://gitlab.com/api/v4/projects/{id}/releases/{tag_name}/downloads/{direct_asset_path}
    -- https://docs.gitlab.com/ee/api/releases/#download-a-release-asset
end

return GitLab