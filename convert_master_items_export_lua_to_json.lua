-- ##################################
-- Data
-- ##################################
-- #################
-- Imports
-- #################
local cjson = require("cjson")

local whole_master_items = dofile("master_items_export.lua")

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

-- ##################################
-- Execution
-- ##################################
for file_name, table_entry in pairs(master_items) do
    -- These are some common cases we can catch
    -- The "and true" basically means "include this"
    --  To not include it, change it to "and false"
    local entry_is_player_weapon_attachment = (table_entry.item_type == "WEAPON_ATTACHMENT (string)") and true
    local entry_is_player_trinket = (table_entry.attach_node == "ap_trinket (string)") and true
    local entry_is_grenade = (string_find(file_name, "content/items/weapons/player/grenade")) and true
    local entry_is_bullets = (string_find(file_name, "content/items/weapons/player/ranged/bullets")) and true
    local entry_is_enemy_weapon = (string_find(file_name, "content/items/weapons/minions/")) and true

    -- some weapon attachments count as chained rig
    -- so I have this section of logic to avoid that
    local entry_is_throwing_knife = table_entry.base_unit and string_find(table_entry.base_unit, "throwing_knife")
    local allow_throwing_knife = true
    local entry_is_deployable = table_entry.base_unit and string_find(table_entry.base_unit, "pickups")
    local allow_deployable = true
    local entry_is_chained_rig = table_entry.base_unit and string_find(table_entry.base_unit, "chained_rig")
    local allow_chained_rig = false
    local base_unit_contains_evil_ass_option = false
    if (entry_is_throwing_knife and not allow_throwing_knife) or
        (entry_is_deployable and not allow_deployable) or
        (entry_is_chained_rig and not allow_chained_rig)
    then
        base_unit_contains_evil_ass_option = true
    end

    if (not base_unit_contains_evil_ass_option) and 
    (entry_is_player_weapon_attachment or 
    entry_is_player_trinket or 
    entry_is_grenade or 
    entry_is_bullets or 
    entry_is_enemy_weapon) then
        lua_data[file_name] = get_string_of_keys_as_values(table_entry, desired_master_items_keys)
    --[[
    -- This would also print gear, eye color, etc.
    elseif table_entry.base_unit then
        lua_data[file_name] = get_string_of_keys_as_values(table_entry, desired_master_items_keys)
    else
        print(name.." has no base_unit")
    ]]
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