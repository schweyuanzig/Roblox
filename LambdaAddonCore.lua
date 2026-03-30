local AddonSystem = {
    LoadedAddons = {},
}

function AddonSystem:ScanAddonsFolder()
    local detectedAddons = {}
    
    local addonFolder = game:GetService("ServerStorage"):FindFirstChild("Addons")
    
    if not addonFolder then
        return detectedAddons
    end
    
    for _, file in ipairs(addonFolder:GetChildren()) do
        if file:IsA("ModuleScript") then
            local success, loadedModule = pcall(function()
                return require(file)
            end)
            
            if success and loadedModule then
                detectedAddons[file.Name] = {
                    name = file.Name,
                    module = loadedModule,
                    loaded = false
                }
            end
        end
    end
    
    return detectedAddons
end

function AddonSystem:CreateAddonsTab(Window, detectedAddons)
    local AddonsTab = Window:AddTab('Addons')
    
    if not detectedAddons or table.getn(detectedAddons) == 0 then
        local EmptySection = AddonsTab:AddLeftGroupbox('Activated Addons')
        EmptySection:AddLabel('No addon found.')
        return AddonsTab
    end
    
    for filename, addonData in pairs(detectedAddons) do
        local addonGroupbox = AddonsTab:AddLeftGroupbox(filename)
        
        local loadedAddon = addonData.module
        
        if loadedAddon then
            local features = self:ExtractAddonFeatures(loadedAddon)
            self:CreateDynamicUIElements(addonGroupbox, filename, features)
        end
    end
    
    return AddonsTab
end

function AddonSystem:ExtractAddonFeatures(loadedAddon)
    local features = {
        buttons = {},
        toggles = {},
        sliders = {},
        dropdowns = {},
        functions = {}
    }
    
    for key, value in pairs(loadedAddon) do
        if type(value) == "function" then
            features.functions[key] = value
        elseif type(value) == "table" then
            if value.Type == "Button" then
                features.buttons[key] = value
            elseif value.Type == "Toggle" then
                features.toggles[key] = value
            elseif value.Type == "Slider" then
                features.sliders[key] = value
            elseif value.Type == "Dropdown" then
                features.dropdowns[key] = value
            end
        end
    end
    
    return features
end

function AddonSystem:CreateDynamicUIElements(groupbox, addonId, features)
    for buttonName, buttonData in pairs(features.buttons) do
        groupbox:AddButton({
            Text = buttonData.Text or buttonName,
            Func = buttonData.Func or function() end,
            DoubleClick = buttonData.DoubleClick or false,
            Tooltip = buttonData.Tooltip or ""
        })
    end
    
    for toggleName, toggleData in pairs(features.toggles) do
        groupbox:AddToggle(addonId .. "_" .. toggleName, {
            Text = toggleData.Text or toggleName,
            Default = toggleData.Default or false,
            Callback = toggleData.Callback or function() end,
            Tooltip = toggleData.Tooltip or ""
        })
    end
    
    for sliderName, sliderData in pairs(features.sliders) do
        if sliderData.Min and sliderData.Max and sliderData.Default then
            groupbox:AddSlider(addonId .. "_" .. sliderName, {
                Text = sliderData.Text or sliderName,
                Default = sliderData.Default,
                Min = sliderData.Min,
                Max = sliderData.Max,
                Rounding = sliderData.Rounding or 0,
                Callback = sliderData.Callback or function() end
            })
        end
    end
    
    for dropdownName, dropdownData in pairs(features.dropdowns) do
        if dropdownData.Values then
            groupbox:AddDropdown(addonId .. "_" .. dropdownName, {
                Text = dropdownData.Text or dropdownName,
                Values = dropdownData.Values,
                Default = dropdownData.Default or 1,
                Multi = dropdownData.Multi or false,
                Callback = dropdownData.Callback or function() end
            })
        end
    end
end

function AddonSystem:Initialize(Window)
    local detectedAddons = self:ScanAddonsFolder()
    local AddonsTab = self:CreateAddonsTab(Window, detectedAddons)
    
    return AddonsTab
end

return AddonSystem
