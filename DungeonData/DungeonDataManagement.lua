expansions = {
    "Classic",
    "The Burning Crusade", 
    "Wrath of the Lich King",
    "Cataclysm",
    "Mists of Pandaria",
    "Warlords of Draenor",
    "Legion",
    "Battle for Azeroth",
    "Shadowlands",  
    "Dragonflight",
    "The War Within"
}

-- Store selected expansion
local selectedExpansion = 1

-- Dropdown initialization function
local function ExpansionDropdown_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for i, expansion in ipairs(expansions) do
        info.text = expansion
        info.func = function()
            UIDropDownMenu_SetSelectedID(self, i)
            selectedExpansion = i
        end
        info.checked = (selectedExpansion == i)
        UIDropDownMenu_AddButton(info, level)
    end
end

local typeOptions = {"Dungeons", "Raids"}
local selectedType = 1

local function TypeDropdown_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for i, option in ipairs(typeOptions) do
        info.text = option
        info.func = function()
            UIDropDownMenu_SetSelectedID(self, i)
            selectedType = i
        end
        info.checked = (selectedType == i)
        UIDropDownMenu_AddButton(info, level)
    end
end

local selectedInstance = 1
local instanceList = {}

local function UpdateInstanceList()
    instanceList = {}
    if not DungeonData then
        table.insert(instanceList, "No data loaded")
        selectedInstance = 1
        return
    end
    local expansionData = DungeonData[expansions[selectedExpansion]]
    if expansionData then
        local typeKey = typeOptions[selectedType]
        if expansionData[typeKey] then
            for _, name in ipairs(expansionData[typeKey]) do
                table.insert(instanceList, name)
            end
        end
    end
    if #instanceList == 0 then
        table.insert(instanceList, "No instances found")
    end
    selectedInstance = 1
end

local function InstanceDropdown_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for i, name in ipairs(instanceList) do
        info.text = name
        info.func = function()
            UIDropDownMenu_SetSelectedID(self, i)
            selectedInstance = i
        end
        info.checked = (selectedInstance == i)
        UIDropDownMenu_AddButton(info, level)
    end
end

-- Update dropdowns when expansion/type changes
local function OnExpansionChanged(self, i)
    UIDropDownMenu_SetSelectedID(self, i)
    selectedExpansion = i
    UpdateInstanceList()
    UIDropDownMenu_SetText(DungeonLootSellerInstanceDropdown, instanceList[selectedInstance])
    UIDropDownMenu_Initialize(DungeonLootSellerInstanceDropdown, InstanceDropdown_Initialize)
end

local function OnTypeChanged(self, i)
    UIDropDownMenu_SetSelectedID(self, i)
    selectedType = i
    UpdateInstanceList()
    UIDropDownMenu_SetText(DungeonLootSellerInstanceDropdown, instanceList[selectedInstance])
    UIDropDownMenu_Initialize(DungeonLootSellerInstanceDropdown, InstanceDropdown_Initialize)
end

-- Patch the original dropdowns to use the new handlers
local function ExpansionDropdown_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for i, expansion in ipairs(expansions) do
        info.text = expansion
        info.func = function() OnExpansionChanged(self, i) end
        info.checked = (selectedExpansion == i)
        UIDropDownMenu_AddButton(info, level)
    end
end

local function TypeDropdown_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for i, option in ipairs(typeOptions) do
        info.text = option
        info.func = function() OnTypeChanged(self, i) end
        info.checked = (selectedType == i)
        UIDropDownMenu_AddButton(info, level)
    end
end

function DungeonLootSeller_ShowWindow()
    if not DungeonLootSellerFrame then
        local f = CreateFrame("Frame", "DungeonLootSellerFrame", UIParent, "BasicFrameTemplateWithInset")
        f:SetSize(300, 200)
        f:SetPoint("CENTER")
        f.title = f:CreateFontString(nil, "OVERLAY")
        f.title:SetFontObject("GameFontHighlight")
        f.title:SetPoint("LEFT", f.TitleBg, "LEFT", 5, 0)
        f.title:SetText("Dungeon Data Management")

        -- Expansion dropdown
        local dropdown = CreateFrame("Frame", "DungeonLootSellerExpansionDropdown", f, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", 10, -40)
        UIDropDownMenu_SetWidth(dropdown, 180)
        UIDropDownMenu_SetText(dropdown, expansions[selectedExpansion])
        UIDropDownMenu_Initialize(dropdown, ExpansionDropdown_Initialize)
        UIDropDownMenu_SetSelectedID(dropdown, selectedExpansion)

        -- Type dropdown (Dungeons/Raids)
        local typeDropdown = CreateFrame("Frame", "DungeonLootSellerTypeDropdown", f, "UIDropDownMenuTemplate")
        typeDropdown:SetPoint("TOPLEFT", 10, -80)
        UIDropDownMenu_SetWidth(typeDropdown, 180)
        UIDropDownMenu_SetText(typeDropdown, typeOptions[selectedType])
        UIDropDownMenu_Initialize(typeDropdown, TypeDropdown_Initialize)
        UIDropDownMenu_SetSelectedID(typeDropdown, selectedType)

        -- Instance dropdown (Dungeon/Raid names)
        UpdateInstanceList()
        local instanceDropdown = CreateFrame("Frame", "DungeonLootSellerInstanceDropdown", f, "UIDropDownMenuTemplate")
        instanceDropdown:SetPoint("TOPLEFT", 10, -120)
        UIDropDownMenu_SetWidth(instanceDropdown, 180)
        UIDropDownMenu_SetText(instanceDropdown, instanceList[selectedInstance])
        UIDropDownMenu_Initialize(instanceDropdown, InstanceDropdown_Initialize)
        UIDropDownMenu_SetSelectedID(instanceDropdown, selectedInstance)

        DungeonLootSellerFrame = f
    end
    DungeonLootSellerFrame:Show()
end

-- Make sure DungeonData is loaded before calling DungeonLootSeller_ShowWindow

