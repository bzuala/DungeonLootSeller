local itemsToSell = {
    [82772] = true,   -- Snarlmouth Leggings
    [151421] = true,  -- Scorched Blazehound Boots
    [151422] = true,  -- Bonecoal Waistguard
    [82879] = true,   -- Collarspike Bracers
    [82880] = true,   -- Fang of Adarogg
    [82882] = true,   -- Dark Ritual Cape
    [82881] = true,   -- Cuffs of Black Elements
    [82877] = true,   -- Grasp of the Broken Totem
    [132551] = true,  -- Dark Shaman's Jerkin
    [82878] = true,   -- Fireworm Robes
    [82884] = true,   -- Chitonous Bracers
    [132552] = true,  -- Chitonous Bindings
    [82885] = true,   -- Flameseared Carapace
    [82886] = true,   -- Gorewalker Treads
    [82883] = true,   -- Bloodcursed Felblade
    [82888] = true,   -- Heartboiler Staff
}

-- Slash command registration
SLASH_DDM1 = "/ddm"
SlashCmdList["DDM"] = function()
    DungeonLootSeller_ShowWindow()
end

local function SellSpecificItems()
    local itemsToProcess = {}
    local totalPrice = 0

    -- Gather all items to sell first
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            if itemInfo then
                local itemID = itemInfo.itemID
                local itemName = C_Item.GetItemNameByID(itemID)
                if itemsToSell[itemID] or (itemName and itemsToSell[itemName]) then
                    table.insert(itemsToProcess, {bag = bag, slot = slot, itemID = itemID, count = itemInfo.stackCount or 1})
                end
            end
        end
    end

    local function SellNextItem()
        local item = table.remove(itemsToProcess, 1)
        if item then
            local itemName = C_Item.GetItemNameByID(item.itemID)
            local itemLink = select(2, GetItemInfo(item.itemID)) or ("ItemID: " .. item.itemID)
            local _, _, _, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(item.itemID)
            local itemPrice = (vendorPrice or 0) * item.count
            C_Container.UseContainerItem(item.bag, item.slot)
            totalPrice = totalPrice + itemPrice
            print(string.format("Sold: %s x%d for %s",
                itemLink,
                item.count,
                GetCoinTextureString(itemPrice)
            ))
            C_Timer.After(0.5, SellNextItem)
        else
            if totalPrice > 0 then
                print(string.format("Total earned: %s", GetCoinTextureString(totalPrice)))
            else
                print("No items sold.")
            end
        end
    end

    SellNextItem()
end

local f = CreateFrame("Frame")
f:RegisterEvent("MERCHANT_SHOW")
-- Create a button frame
local sellButton = CreateFrame("Button", "DungeonLootSellerButton", MerchantFrame, "UIPanelButtonTemplate")
sellButton:SetSize(140, 30)
sellButton:SetText("Sell Dungeon Loot")
sellButton:SetPoint("CENTER", UIParent, "CENTER", 0, -200) -- Centered, adjust Y as needed

sellButton:Hide()

sellButton:SetScript("OnClick", function()
    SellSpecificItems()
end)

-- Show the button when merchant window opens
f:HookScript("OnEvent", function(_, event)
    if event == "MERCHANT_SHOW" then
        sellButton:Show()
    elseif event == "MERCHANT_CLOSED" then
        sellButton:Hide()
    end
end)

f:RegisterEvent("MERCHANT_CLOSED")
