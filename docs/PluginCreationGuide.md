# Extended Weapon Customization (EWC) Plugin Creation Startup
If you've found your way to this page, you're likely interested in making an add-on plugin for [EWC](https://www.nexusmods.com/warhammer40kdarktide/mods/277). Welcome to the club! This page is an unofficial collection of knowledge from various plugin authors. Knowledge of programming is not required here; you can get a lot done with just "monkey see, monkey do" for EWC add-on plugins (I'm just going to say "plugins" now). All you need is patience and determination. Of course, I'll be assuming you're somewhat familiar with EWC as a user.

To give you a high-level overview, the process goes a bit like this:
1. Make a mod for Darktide. This will hold all your custom parts, so EWC can read it. Imagine you're making sure there's a kitchen to cook in.
2. Create a new **attachment**, which is what makes it equippable. Imagine you're designing a new dish, and you're giving it a name and putting it on the menu. 
3. Create the **kitbash**, which is giving it an actual model (sometimes multiple). Imagine you're actually grabbing ingredients and putting them together.
4. Create the **fixes**, which manipulate the models. Imagine you're serving, plating, and garnishing. Sometimes you can just slap it on there, but other cases may require some more finesse.

Some of the exact ordering can be rearranged, but the important thing is that it's all done. 

# Glossary
Before you start, join us in the [Darktide Modders Discord](https://discord.gg/rKYWtaDx4D). This is basically the only place we congregate, and most knowledge/help on EWC is buried in there. Most discussion occurs in *#weapon-customization-mod*. 

General information on EWC (for users) is kept at the [EWC FAQ](https://backup158.github.io/DarktideWeaponCustomizationOwO/EWC_FAQ), which I may refer to at times. This includes links to all the other plugins the community has shared, for reference.

One little thing about coding. Lua structures things as "tables" which are the curly braces: `{ ... }`. Tables are used to store multiple things stored under one name, such as: `fruits = {"apple", "banana", "tomato"}`. So when you say `fruits`, you're getting this table of three fruit. Inside tables are "key-value" pairs: `name = "Pho Khun Ramkhamhaeng the Great"`. The key is the identifier, and value is... value, which can some text or even another table. Now, you may hear that look at the earlier table, and wonder where the keys are. Under the hood, when you don't give any keys, it just goes like this:

```
fruits = {
    [1] = "apple", 
    [2] = "banana", 
    [3] = "tomato"
}
```

So you can write `fruits[2]` to get `"banana"`. You can go into the nitty gritty in the [Lua reference manual](https://lua.org/manual/5.5/), but that's really not essential for an EWC plugin. You just need to know the basics of tables, since we'll be referring to those a lot.

# Making a Mod
Make a new mod using the [Darktide Mod Builder script](https://dmf-docs.darkti.de/#/creating-mods). You need to define a table `mod.extended_weapon_customization_plugin`; just copy this [template from the wiki](https://github.com/grasmann/darktide-mods/wiki/EWC-%E2%80%90-001-Plugin-Definition) or the [example plugin](https://github.com/grasmann/darktide-mods/blob/main/ewc_example_plugin_2/scripts/mods/ewc_example_plugin_2/ewc_example_plugin_2.lua). The wiki has a lot of good information, but it's a bit technical. Starting from zero, I would avoid it for now. The example plugin, on the other hand, is written for beginners. These give a good description of what each part means. 

Going back to the analogy, the kitchen is set up. You do this once, then continue to use it to cook.

# Create an Attachment
Think of this as filling out the identification for your attachments. It doesn't matter exactly what's in it yet, but there needs to be something saying there's something you *can* equip, and on which weapons. This all goes inside `mod.extended_weapon_customization_plugin.attachments`.

Take a look at the example plugin:

```
-- Weapon
autogun_p2_m1 = {
    -- Slot name
    sight = {
        -- Attachment definition
        example_scope_01 = {
            -- This is the name of the attachment in the master items list
            -- The template defines some shortcuts earlier, so technically this means "content/items/weapons/player/ranged/sights/example_scope_01"
            replacement_path = _item_ranged.."/sights/example_scope_01",
            -- snip
        },
    },
},
```

The critical part is `replacement_path`. This is the actual part that it's pointing to, stored in the MasterItems table, which is Darktide's list of equippable things. This is the full name of what you make in the next section I'll discuss, **kitbashs**. The name you use as the key here for `attachments` is the internal name used in context of equipping, so it should be identifiable and short, ideally something similar to the full name of the kitbash. Conventionally, it's good practice to have a unique indicator in your attachment's name. For example, a scope in my plugin (OwO) may be called `"owo_telescopic_scope_01"` to make it easy to identify in the logs.

This name is inside a table indicated by the key `example_scope_01`. This could technically be whatever you want, but for simplicity, keep it the same as the last part of the attachment name. I call this the internal name. This holds the full name and some other attachment information, which I won't cover yet.

One level above, we have `sight`, containing this internal name, and subsequently the full name and information. This part specifies which slot the attachment will appear in when you're equipping it in-game. 

At the highest point inside attachments, there's the weapon name. This means that the attachment will be available for that specific weapon. Here, `autogun_p2_m1` means the first mark of the Braced Autoguns (`autogun_p2`). This is the actual code names of the weapons; figuring them out can be confusing at first, but there are other resources for this.

Ok, so that scope is on one gun. A good start, so let's get it added to other guns. To do that, just copy the whole weapon's section, paste it below, and change the key to another weapons. For reference, see some plugins such as *More Dakka!* and *Tools of the Omnissiah*, linked in the EWC FAQ. These plugins have simple structures, which makes them easy to learn from. At a more advanced level, you may see some plugins making use of `table.clone` to copy attachments to other weapons, such as with EWC Base Additions. At the end of the day, it'll look like the copy pasted result below. 

```
attachments = {
    autogun_p2_m1 = {
        sight = {
            example_scope_01 = {
                -- That full name
                replacement_path = _item_ranged.."/sights/example_scope_01",
                -- snip
            },
        },
    },
    autogun_p2_m2 = {
        sight = {
            example_scope_01 = {
                -- Same full name
                replacement_path = _item_ranged.."/sights/example_scope_01",
                -- snip
            },
        },
    },
    autogun_p2_m3 = {
        sight = {
            example_scope_01 = {
                -- Same full name
                replacement_path = _item_ranged.."/sights/example_scope_01",
                -- snip
            },
        },
    },
},
```

That assigns the same sight attachment to all of the Braced Autoguns. Thinking back on the analogy, this is like putting your dish on the breakfast, lunch, and dinner menu. You can even split those menus up into courses. So you could make it so your dish could be ordered only as dessert at dinner, or it can be ordered at any meal, any day. The world is your oyster! What matters is that it's on the menu at all, otherwise it can't be ordered\*. No matter how many times it's on the menu, it has the same name and the same ingredients (pointing to the same kitbash).

\* This analogy doesn't hold perfectly with hidden attachments, but those are still registered internally and are just not hidden.

# Create the Kitbash for the Attachment
This is where the real work is done. Kitbashes dictate what models are used in your attachment: you can have just one model, or you could have a model with other models attached to it, with specified positioning for those attached models, which we call "children." 

These are added to the `mod.extended_weapon_customization_plugin.kitbashs` table. *Note that it says "kitbashs" with no e.* These are made by putting a custom address to use as the key, then filling out the table. The actual kitbash definition can vary, either being a simple definition or a full item definition; the [EWC wiki](https://github.com/grasmann/darktide-mods/wiki/EWC-%E2%80%90-021-Kitbash-Definitions) covers the specifics (though generally, we just always use full items). The important takeaways are these concepts:
- Each kitbash will be added to the MasterItems table.
- Only kitbashes which are set as a "replacement_path" in one of the tables in **attachments** will be directly equippable.
- Kitbashes can have other kitbash parts attached to them, which are called "children."
- Each kitbash child can be individually moved/rotated/resized.

In the EWC wiki, go to the "Full item definition" section, then go back here. You need all the information there, but the highlights are here:

```
mod.extended_weapon_customization_plugin = {
    attachments = {
        autogun_p1_m1 = {
            stock = {
                attachment_name = {
                    replacement_path = _item_ranged.."/some_group/attachment_name",
                    -- snip
                },
            },
        },
    },
    kitbashs = {
        -- Kitbash name, and kitbash definition
        [_item_ranged.."/some_group/attachment_name"] = {
            -- For simplicity, let this match the key here
            name = _item_ranged.."/some_group/attachment_name", 
            base_unit = "content/weapons/player/attachments/flashlights/flashlight_01/flashlight_01",
            -- snip
        },
        [_item_ranged.."/some_group/other_attachment_name"] = {
            name = _item_ranged.."/some_group/other_attachment_name", 
            base_unit = "content/weapons/player/attachments/flashlights/flashlight_02/flashlight_02",
            -- snip
        },
    },
}
```

So this creates a new item named `_item_ranged.."/some_group/attachment_name"`, and it's using the flashlight model. The definition in **kitbashs** is what's used to add it to the MasterItems table, making it a real, distinct thing in Darktide. The corresponding definition in **attachments** makes it equippable through EWC, in this case, as an Infantry Autogun stock. That means `other_attachment_name` won't be directly equippable because there's nothing in **attachments** for it, but it'll still exist behind the scenes.

"base_unit" is the address of the actual model in the Darktide files. You can find this information by exporting the MasterItems table and/or extracting the Darktide bundles; specifics of this are covered on the [main page of this repository](README.md) (if that link doesn't work, [go here](https://backup158.github.io/DarktideMasterItemsDumpForEWC/)). 