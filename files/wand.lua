--[[ Spawn the Bad Apple!! wand ]]

dofile_once("data/scripts/lib/utilities.lua")
EZWand = dofile_once("mods/badapple/files/lib/EZWand.lua")
dofile_once("mods/badapple/files/utility.lua")

---Spawns a shiny new Bad Apple!! wand
---@param wand_x number
---@param wand_y number
function spawn_badapple_wand(wand_x, wand_y)
    local wand = EZWand({
        shuffle = false,
        spellsPerCast = 1,
        castDelay = 20,
        rechargeTime = 40,
        manaMax = 100,
        mana = 100,
        manaChargeSpeed = 50,
        capacity = 1,
        spread = 0,
        speedMultiplier = 1,
    }, wand_x, wand_y)
    wand:AddSpells("BAD_APPLE")
    wand:PlaceAt(wand_x, wand_y)
    wand:SetSprite("mods/badapple/files/wand/scepter_01.xml", 3, 4, 17, 5)
    wand:SetName("$item_wand_badapple", true)
    wand:SetFrozen(true, true)
end

---Spawn just the Bad Apple!! spell
---@param xpos number
---@param ypos number
function spawn_spell(xpos, ypos)
    if xpos == nil or ypos == nil then
        local player = get_players()[1]
        if not player then return end
        local px, py = EntityGetTransform(player)
        if not px or not py then return end
        if xpos == nil then xpos = px end
        if ypos == nil then ypos = py end
    end
    CreateItemActionEntity("BAD_APPLE", xpos, ypos)
end

-- vim: set ts=4 sts=4 sw=4 et:
