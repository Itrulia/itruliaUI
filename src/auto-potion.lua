local addonName = ...

-- Fixes Autopotion until https://github.com/ollidiemaus/AutoPotion/pull/111 is merged
local extraPotions = {
    { id = 271883, name = "Concentrated Silvermoon Health Potion", after = 271884 },
    { id = 245919, name = "Fleeting Silvermoon Health Potion", after = 245918 },
}

local items = {}

local function getItem(potion)
    local item = items[potion.id]

    if not item then
        item = {
            id = potion.id,
            name = potion.name,
            getId = function()
                return potion.id
            end,
            getCount = function()
                return C_Item.GetItemCount(potion.id, false, false)
            end,
        }

        items[potion.id] = item
    end

    return item
end

local function indexOf(list, id)
    for index, item in ipairs(list) do
        if type(item) == "table" and item.getId and item.getId() == id then
            return index
        end
    end
end

local function injectExtraPotions(list)
    if type(list) ~= "table" then
        return
    end

    for _, potion in ipairs(extraPotions) do
        if not indexOf(list, potion.id) then
            local anchor = indexOf(list, potion.after)

            if anchor then
                table.insert(list, anchor + 1, getItem(potion))
            end
        end
    end
end

local hooked = false

local function hookRemoveFromList()
    if hooked then
        return true
    end

    local removeFromList = _G.RemoveFromList

    if type(removeFromList) ~= "function" then
        return false
    end

    hooked = true

    _G.RemoveFromList = function(list, itemToRemove)
        injectExtraPotions(list)

        return removeFromList(list, itemToRemove)
    end

    return true
end

if not hookRemoveFromList() then
    local frame = CreateFrame("Frame", addonName .. "AutoPotion")
    frame:RegisterEvent("ADDON_LOADED")

    frame:SetScript("OnEvent", function(self, _, name)
        if name == "AutoPotion" and hookRemoveFromList() then
            self:UnregisterEvent("ADDON_LOADED")
        end
    end)
end
