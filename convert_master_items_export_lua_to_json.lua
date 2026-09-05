-- ##################################
-- Data
-- ##################################
-- #################
-- Imports
-- #################
local cjson = require("cjson")

-- arg[1] is the second cli argument (the one after the name)
-- Lua is 1-indexed elsewhere, but not here
local master_items_file_name = arg[1] or "master_items_export.lua"
local whole_master_items = dofile(master_items_file_name)

-- #################
-- Performance
-- #################
local string = string
local string_regex_sub = string.gsub
local string_find = string.find

local master_items = whole_master_items.master_items

local lua_data = {}
local desired_master_items_keys = {"base_unit", "attach_node"}

-- #################
-- Helper Functions
-- #################
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

local function get_string_of_keys_as_values(master_item_table_entry, array_of_keys)
    local keys_return_table = {}
    for i = 1, #array_of_keys do
        local key_name = array_of_keys[i]
        if master_item_table_entry[key_name] then
            keys_return_table[key_name] = get_string_without_label(master_item_table_entry[key_name])
        else
            keys_return_table[key_name] = "nil"
        end
    end
    return keys_return_table
end

local function check_if_table_entry_should_be_logged(file_name, table_entry)
    -- ================
    -- Configuration
    -- Change these to true/false to include/disclude them
    -- I'm not doing a table for this since it shouldn't be recreated all the time
    -- ================
    -- Common Cases
    local allow_cc_player_weapon_attachment = true
    local allow_cc_player_trinket = true
    local allow_cc_grenade = true
    local allow_cc_bullets = true
    local allow_cc_enemy_weapon = true
    -- Evil Ass Base Unit
    --   These get accepted under common cases, but may be considered exceptions
    local allow_ea_throwing_knife = true
    local allow_ea_deployable = true
    local allow_ea_chained_rig = false
    --   There is a lot of overlap inside of these, so the check for them is separate
    -- This would also print gear, eye color, etc.
    local allow_body_parts = false

    -- ================
    -- Logic Execution
    -- ================
    -- Common Cases
    local entry_is_player_weapon_attachment = (table_entry.item_type == "WEAPON_ATTACHMENT (string)") 
    local entry_is_player_trinket = (table_entry.attach_node == "ap_trinket (string)") 
    local entry_is_grenade = (string_find(file_name, "content/items/weapons/player/grenade")) 
    local entry_is_bullets = (string_find(file_name, "content/items/weapons/player/ranged/bullets")) 
    local entry_is_enemy_weapon = (string_find(file_name, "content/items/weapons/minions/")) 
    local final_entry_is_valid = (
        (entry_is_player_weapon_attachment and allow_cc_player_weapon_attachment) or 
        (entry_is_player_trinket and allow_cc_player_trinket) or 
        (entry_is_grenade and allow_cc_grenade) or 
        (entry_is_bullets and allow_cc_bullets) or 
        (entry_is_enemy_weapon and allow_cc_enemy_weapon)
    ) -- Indenting like this makes me a psycho

    -- Evil Ass Base Unit
    --   Some weapon attachments count as chained rig
    --   so I have this section of logic to avoid that
    local entry_is_throwing_knife = table_entry.base_unit and string_find(table_entry.base_unit, "throwing_knife")
    local entry_is_deployable = table_entry.base_unit and string_find(table_entry.base_unit, "pickups")
    local entry_is_chained_rig = table_entry.base_unit and string_find(table_entry.base_unit, "chained_rig")
    local base_unit_contains_evil_ass_option = false
    if (entry_is_throwing_knife and not allow_ea_throwing_knife) or
        (entry_is_deployable and not allow_ea_deployable) or
        (entry_is_chained_rig and not allow_ea_chained_rig)
    then
        base_unit_contains_evil_ass_option = true
    end

    if final_entry_is_valid and (not base_unit_contains_evil_ass_option) then
        return true
    elseif allow_body_parts and table_entry.base_unit then
        return true
    else
        return false
    end
end

-- ##################################
-- Execution
-- ##################################
for file_name, table_entry in pairs(master_items) do
    local should_write_data = check_if_table_entry_should_be_logged(file_name, table_entry)
    if should_write_data then
        lua_data[file_name] = get_string_of_keys_as_values(table_entry, desired_master_items_keys)
    end
end

-- Convert to json
local json_output = cjson.encode(lua_data)
local file = io.open("master_items_export.json", "w")
if file then 
    file:write(json_output)
    file:close()
else
    print("Failed to create Json file. All your work was for naught.")
end
-- print("content/items/weapons/minions/melee/chaos_ogryn_executor_2h_club_02\t"..get_string_of_keys_as_values(master_items["content/items/weapons/minions/melee/chaos_ogryn_executor_2h_club_02"]))