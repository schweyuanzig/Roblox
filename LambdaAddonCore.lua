local function loadAddonSystem()
    local addonFolder = "ProjectLambda/Addons"
    local foundAddons = {}

    if not isfolder(addonFolder) then
        makefolder(addonFolder)
    end

    local files = listfiles(addonFolder)

    for _, filePath in ipairs(files) do
        if filePath:sub(-4) == ".lua" or filePath:sub(-5) == ".luau" then
            local ok, content = pcall(readfile, filePath)
            if ok and content then
                local hasAddonsArray = content:find("local%s+Addons%s*=") ~= nil
                    or content:find("Addons%.name%s*=") ~= nil

                if hasAddonsArray then
                    local fileName = filePath:match("([^/\\]+)$") or filePath

                    local loadOk, addonModule = pcall(loadstring(content))
                    if loadOk and type(addonModule) == "table" then
                        if addonModule.name and addonModule.version
                            and addonModule.id and addonModule.box then
                            addonModule._fileName = fileName
                            table.insert(foundAddons, addonModule)
                        end
                    end
                end
            end
        end
    end

    if #foundAddons == 0 then
        ActAddSection:AddLabel("No addon found.")
    else
        for _, addon in ipairs(foundAddons) do
            ActAddSection:AddLabel(addon.name .. " v" .. addon.version)
        end
    end

    for _, addon in ipairs(foundAddons) do
        local groupbox

        if addon.box == "left" then
            groupbox = Tabs.Addons:AddLeftGroupbox(addon.name .. " v" .. addon.version)
        else
            groupbox = Tabs.Addons:AddRightGroupbox(addon.name .. " v" .. addon.version)
        end

        if type(addon.Load) == "function" then
            local loadOk, err = pcall(addon.Load, groupbox, Library, Toggles, Options)
            if not loadOk then
                groupbox:AddLabel("[Error] " .. tostring(err):sub(1, 60))
            end
        else
            groupbox:AddLabel("(No Load function defined)")
        end
    end
end

pcall(loadAddonSystem)
