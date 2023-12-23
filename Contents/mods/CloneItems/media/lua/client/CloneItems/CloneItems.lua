CloneItems = CloneItems or {}

function CloneItems.OnFillInventoryObjectContextMenu(player, context, items)
    if not (isDebugEnabled() or (isClient() and (isAdmin() or getAccessLevel() ~= ""))) then return true; end

    local container = nil
    local resItems = {}
    for i,v in ipairs(items) do
        if not instanceof(v, "InventoryItem") then
            for _, it in ipairs(v.items) do
                resItems[it] = true
            end
            container = v.items[1]:getContainer()
        else
            resItems[v] = true
            container = v:getContainer()
        end
    end

    local listItems = {}
    for v, _ in pairs(resItems) do
        table.insert(listItems, v)
    end

    local removeOption = context:addDebugOption("Clone Item")
    local subMenuRemove = ISContextMenu:getNew(context)
    context:addSubMenu(removeOption, subMenuRemove)

    subMenuRemove:addOption("once", listItems[1], CloneItems.dupeItem, player, 1)
    subMenuRemove:addOption("x10", listItems[1], CloneItems.dupeItem, player, 10)
    subMenuRemove:addOption("x50", listItems[1], CloneItems.dupeItem, player, 50)
end

function CloneItems.dupeItem(item, playerIndex, times)
    local player = getSpecificPlayer(playerIndex)
    local inventory = player:getInventory()
    for i=1,times do
        local clone = inventory:AddItem(item:getFullType())
        clone:setName(item:getName())
        if clone:isCustomWeight() then
            clone:setActualWeight(item:getActualWeight())
            clone:setCustomWeight(true)
        end
        clone:setCondition(item:getCondition())
        if item:isCustomColor() then
            clone:setColor(item:getColor())
            clone:getVisual():setTint(ImmutableColor.new(item:getColor()));
            clone:setCustomColor(true)
        elseif item:getColor() ~= nil then
            clone:setColor(item:getColor())
        elseif item:getVisual():getTint() ~= nil then
            clone:setColor(item:getVisual():getTint():toMutableColor())
            clone:getVisual():setTint(ImmutableColor.new(item:getVisual():getTint()));
        end
        if instanceof(item, "HandWeapon") then
            clone:setMinDamage(item:getMinDamage())
            clone:setMaxDamage(item:getMaxDamage())
            clone:setMinAngle(item:getMinAngle())
            if item:isRanged() then
                clone:setMinRangeRanged(item:getMinRangeRanged())
            else
                clone:setMinRange(item:getMinRange())
            end
            clone:setMaxRange(item:getMaxRange())
            clone:setAimingTime(item:getAimingTime())
            clone:setRecoilDelay(item:getRecoilDelay())
            clone:setReloadTime(item:getReloadTime())
            clone:setClipSize(item:getClipSize())
        end
        if instanceof(item, "Food") then
            clone:setAge(item:getAge())
            clone:setBaseHunger(item:getBaseHunger())
            clone:setHungChange(item:getHungChange())
            clone:setUnhappyChange(item:getUnhappyChange())
            clone:setBoredomChange(item:getBoredomChange())
            clone:setPoisonPower(item:getPoisonPower())
            clone:setOffAge(item:getOffAge())
            clone:setOffAgeMax(item:getOffAgeMax())
            clone:setCalories(item:getCalories())
            clone:setLipids(item:getLipids())
            clone:setProteins(item:getProteins())
            clone:setCarbohydrates(item:getCarbohydrates())
        end
        if instanceof(item, "DrainableComboItem") then
            clone:setUsedDelta(item:getUsedDelta())
        end

        clone:copyModData(item:getModData())
    end
end

function CloneItems.dupeItems(items, playerIndex, times)
    for i, item in ipairs(items) do
        CloneItems.dupeItem(item, playerIndex, times)
    end
end

Events.OnFillInventoryObjectContextMenu.Add(CloneItems.OnFillInventoryObjectContextMenu)