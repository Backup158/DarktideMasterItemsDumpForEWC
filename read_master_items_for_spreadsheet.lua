local string = string
local string_regex_sub = string.gsub
local string_find = string.find

local whole_master_items = dofile("master_items_export.lua")
local master_items = whole_master_items.master_items

local function get_string_without_label(given_string)
    if not type(given_string) == "string" then
        print("not a string: "..tostring(given_string))
        return "nil"
    end
    -- Regex removes the " (string)" at the end of each string
    -- There's the space and literal parantheses at the end of the string, and whatever text is inside the parantheses
    local trimmed_string = string_regex_sub(given_string, " %(.*%)$", "")
    if trimmed_string == "" then
        trimmed_string = "nil"
    end
    return trimmed_string
end

local function get_string_of_base_unit_and_slot(master_item_table_entry)
    local base_unit = get_string_without_label(master_item_table_entry.base_unit)
    local attach_node = master_item_table_entry.attach_node
    if attach_node then
        attach_node = get_string_without_label(attach_node)
    else
        attach_node = "nil"
    end
    return base_unit.."\t"..attach_node
end

file = io.open("master_items_attachments_for_spreadsheet.txt", "w")
for name, table_entry in pairs(master_items) do
    -- These are some common cases we can catch
    -- The "and true" basically means "include this"
    --  To no include it, change it to "and false" like I have for chained rig
    local entry_is_player_weapon_attachment = (table_entry.item_type == "WEAPON_ATTACHMENT (string)") and true
    local entry_is_player_trinket = (table_entry.attach_node == "ap_trinket (string)") and true
    local entry_is_grenade = (string_find(name, "content/items/weapons/player/grenade")) and true
    local entry_is_bullets = (string_find(name, "content/items/weapons/player/ranged/bullets")) and true
    local entry_is_throwing_knife = (table_entry.base_unit and string_find(table_entry.base_unit, "throwing_knife")) and true
    local entry_is_deployable = (table_entry.base_unit and string_find(table_entry.base_unit, "pickups")) and true
    local entry_is_chained_rig = (table_entry.base_unit and string_find(table_entry.base_unit, "chained_rig")) and false
    local entry_is_enemy_weapon = (string_find(name, "content/items/weapons/minions/")) and true

    if entry_is_player_weapon_attachment or 
    entry_is_player_trinket or 
    entry_is_grenade or 
    entry_is_bullets or 
    entry_is_throwing_knife or 
    entry_is_deployable or 
    entry_is_chained_rig or 
    entry_is_enemy_weapon then
        file:write(name.."\t"..get_string_of_base_unit_and_slot(table_entry).."\n")
    --[[
    -- This would also print gear, eye color, etc.
    elseif table_entry.base_unit then
        file:write(name.."\t"..get_string_of_base_unit_and_slot(table_entry).."\n")
    else
        print(name.." has no base_unit")
    ]]
    end
end
file:close()
-- print("content/items/weapons/minions/melee/chaos_ogryn_executor_2h_club_02\t"..get_string_of_base_unit_and_slot(master_items["content/items/weapons/minions/melee/chaos_ogryn_executor_2h_club_02"]))