# Extended Weapon Customization (EWC) Plugin Creation Startup
If you've found your way to this page, you're likely interested in making an add-on plugin for [EWC](https://www.nexusmods.com/warhammer40kdarktide/mods/277). Welcome to the club! This page is an unofficial collection of knowledge from various plugin authors. Knowledge of programming is not required here; you can get a lot done with just "monkey see, monkey do" for EWC add-on plugins (I'm just going to say "plugins" now). All you need is patience and determination. Of course, I'll be assuming you're somewhat familiar with EWC as a user.

To give you a high-level overview, the process goes a bit like this:
1. Make a mod for Darktide. This will hold all your custom parts, so EWC can read it. Imagine you're making sure there's a kitchen to cook in.
2. Create a new **attachment**, which is what makes it equippable. Imagine you're designing a new dish, and you're giving it a name and putting it on the menu. 
3. Create the **kitbash**, which is giving it an actual model (sometimes multiple). Imagine you're actually grabbing ingredients and putting them together.
4. Create the **fixes**, which manipulate the models. Imagine you're serving, plating, and garnishing. Sometimes you can just slap it on there, but other cases may require some more finesse.

Some of the exact ordering can be rearranged, but the important thing is that it's all done. 

# Ultra TL;DR
1. Grab the [EWC example plugin](https://github.com/grasmann/darktide-mods/blob/main/ewc_example_plugin_2/scripts/mods/ewc_example_plugin_2/ewc_example_plugin_2.lua)
2. Copy implementations from [other plugins](https://backup158.github.io/DarktideWeaponCustomizationOwO/EWC_FAQ). *More Dakka!* and *Tools of the Omnissiah* are the easiest to learn from.
3. Ask for help in the [Darktide Modders Discord](https://discord.gg/rKYWtaDx4D)'s *#weapon-customization-mod* channel.
4. Consult the [EWC wiki](https://github.com/grasmann/darktide-mods/wiki/EWC-%E2%80%90-001-Plugin-Definition) for technical details.

# Glossary
### Discord and FAQ
Before you start, join us in the [Darktide Modders Discord](https://discord.gg/rKYWtaDx4D). This is basically the only place we congregate, and most knowledge/help on EWC is buried in there. Most discussion occurs in *#weapon-customization-mod*. 

General information on EWC (for users) is kept at the [EWC FAQ](https://backup158.github.io/DarktideWeaponCustomizationOwO/EWC_FAQ), which I may refer to at times. This includes links to all the other plugins the community has shared, for reference.

### Tables
One little thing about coding. Lua structures things as "tables" which are the curly braces: `{ ... }`. Tables are used to store multiple things stored under one name, such as: `fruits = {"apple", "banana", "tomato"}`. So when you say `fruits`, you're getting this table of three fruit. Inside tables are "key-value" pairs: `name = "Pho Khun Ramkhamhaeng the Great"`. The key is the identifier, and value is... value, which can some text or even another table. Now, you may hear that look at the earlier table, and wonder where the keys are. Under the hood, when you don't give any keys, it just goes like this:

```
fruits = {
    [1] = "apple", 
    [2] = "banana", 
    [3] = "tomato"
}
```

So you can write `fruits[2]` to get `"banana"`. You can go into the nitty gritty in the [Lua reference manual](https://lua.org/manual/5.5/), but that's really not essential for an EWC plugin. You just need to know the basics of tables, since we'll be referring to those a lot.

### MasterItems
I'll also refer to a MasterItems dump/export. This is a table containing all equipment in Darktide. You can get it by following the instructions on the [main page of this repository](README.md) (if that link doesn't work, [go here](https://backup158.github.io/DarktideMasterItemsDumpForEWC/)

### Hot-reload
~~When you change a magazine and it presses its forehead against yours.~~ Basically, making all the mods quit then act as if the game just opened again. This is like a shortcut for restarting the game in most cases, but be warned that it is not always accurate to an actual restart. Doing it too often without closing the game will also eventually leak enough memory to crash.

In Mod Options --> Darktide Mod Framework --> turn on Developer Mode. Then it'll be CTRL + SHIFT + R by default, which can be rebinded in that same menu.

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

# Kitbashes 1) Create the Kitbash for the Attachment
Kibashes are where the real work is done. These dictate which models are used in your attachment: you can have just one model, or you could have a model with other models attached to it, with specified positioning for those attached models, which we call "children." 

These are added to the `mod.extended_weapon_customization_plugin.kitbashs` table. *Note that it says "kitbashs" with no e.* These are made by putting a custom address to use as the key, then filling out the table. The actual kitbash definition can vary, either being a simple definition or a full item definition; the [EWC wiki](https://github.com/grasmann/darktide-mods/wiki/EWC-%E2%80%90-021-Kitbash-Definitions) covers the specifics (though we just about always use full items to avoid technical jank). The important takeaways are these concepts:
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

"base_unit" is the address of the actual model in the Darktide files. You can find this information by exporting the MasterItems table and/or extracting the Darktide bundles; see the glossary for a link to the specifics of this. 

To start with, copy an actual part where the "attach_node" sounds appropriate for the slot your **attachments** entry will put it in. A classic example is putting the Shredder Autopistol sights onto other guns. That'll confirm you have the attachment-to-kitbash naming relationship working. After that, you can start worrying about having children.

# Kitbashes 2) Children
When you start adding children, that's where the interesting parts can be made. You can get things done with just one part moved about, but when you have multiple put together, your options are nearly limitless.

Each child starts as its own full kitbash. You give it a model and a new name. Then when you make the parent, you can attach the children in the parent's definition.

```
    attachments = {
        autogun_p1_m1 = {
            stock = {
                attachment_name = {
                    replacement_path = _item_ranged.."/stocks/my_super_cool_stock",
                    -- snip
                },
            },
        },
    },
    kitbashs = {
        [_item_ranged.."/anything_you_want/epic_helper_01"] = {
            name = _item_ranged.."/anything_you_want/epic_helper_01", 
            base_unit = "content/weapons/player/attachments/flashlights/flashlight_02/flashlight_02",
            -- snip
        },
        [_item_ranged.."/anything_you_want/epic_helper_02"] = {
            name = _item_ranged.."/anything_you_want/epic_helper_02", 
            base_unit = "content/weapons/player/ranged/autogun_rifle_ak/attachments/grip_03/grip_03",
            -- snip
        },
        [_item_ranged.."/stocks/my_super_cool_stock"] = {
            name = _item_ranged.."/stocks/my_super_cool_stock", 
            base_unit = "content/weapons/player/attachments/flashlights/flashlight_01/flashlight_01",
            attachments = {
                -- This key is just an internal name for the child slot. Name it whatever you want.
                super_cool_stock_helper_apple = {
                    item = _item_ranged.."/anything_you_want/epic_helper_01",
                    -- snip
                },
                super_cool_stock_helper_butter = {
                    item = _item_ranged.."/anything_you_want/epic_helper_02",
                    -- snip
                },
            },
            -- snip
        },
    },
```

See how we have separate **kitbashs** entries for `epic_helper_01` and `epic_helper_02`, but no **attachments** entries? As opposed to `my_super_cool_stock`, which does have an **attachments** entry to make it equippable. Then, inside `my_super_cool_stock`'s kitbash definition, there's the "attachments" table containing each child in its own slot. Note how "item" matches the kitbash name of the item itself, not the "base_unit" model's name.

However, that exact structure isn't the only way to do that. That structure is required for items such as muzzles and flashlights, which have specific functionality tied to the "base_unit" of the main item (muzzle flash and flashlight beams, respectively). In other cases, having an actual "base_unit" can cause some inconsistencies in positioning; that's what this next structure addresses, by having the "base_unit" nothing then building the kitbash as a child:

```
    kitbashs = {
        [_item_ranged.."/anything_you_want/epic_helper_01"] = {
            name = _item_ranged.."/anything_you_want/epic_helper_01", 
            base_unit = "content/weapons/player/attachments/flashlights/flashlight_02/flashlight_02",
            -- snip
        },
        [_item_ranged.."/anything_you_want/epic_helper_02"] = {
            name = _item_ranged.."/anything_you_want/epic_helper_02", 
            base_unit = "content/weapons/player/ranged/autogun_rifle_ak/attachments/grip_03/grip_03",
            -- snip
        },
        [_item_ranged.."/stocks/my_super_cool_stock"] = {
            name = _item_ranged.."/stocks/my_super_cool_stock", 
            base_unit = "content/characters/empty_item/empty_item",
            attachments = {
                -- This is just an internal name
                super_cool_stock_slot = {
                    item = _item_ranged.."/magazines/autogun_rifle_magazine_01",
                    children = {
                        super_cool_stock_helper_apple = {
                            item = _item_ranged.."/anything_you_want/epic_helper_01",
                            -- snip
                        }.
                        super_cool_stock_helper_butter = {
                            item = _item_ranged.."/anything_you_want/epic_helper_02",
                            -- snip
                        }.
                    },
                }
            },
            -- snip
        },
    },
```

The empty item acts as a blank slate, so changes affecting the parent in this kitbash wouldn't propagate to other attachments.

# Kitbashes 3) Positioning Children
I glossed over it earlier, but there are two complications beyond just adding the children:
1. Knowing what model to use for each child
2. Knowing how to position/rotate/scale each child

This can be tedious and fun, depending on day. There are three ways of handling this: classic, Blender, and (experiment) CustomAssets. For the two typical methods, have a copy of the MasterItems dump handy; see the glossary for a link to more info.

You'll want to see what that'd look like first. In each child's table, you add a "fix" with an "offset", containing "position", "rotation", and "scale".
```
    kitbashs = {
        -- snip
        [_item_ranged.."/stocks/my_super_cool_stock"] = {
            name = _item_ranged.."/stocks/my_super_cool_stock", 
            base_unit = "content/characters/empty_item/empty_item",
            attachments = {
                -- This is just an internal name
                super_cool_stock_slot = {
                    item = _item_ranged.."/magazines/autogun_rifle_magazine_01",
                    children = {
                        super_cool_stock_helper_apple = {
                            item = _item_ranged.."/anything_you_want/epic_helper_01",
                            fix = {
                                offset = {
                                    position = vector3_box(0.0, 0.0, -0.106), 
                                    rotation = vector3_box(0, 0, 90), 
                                    scale = vector3_box(3, 3, 2.25),
                                },
                            },
                            -- snip
                        }.
                        super_cool_stock_helper_butter = {
                            item = _item_ranged.."/anything_you_want/epic_helper_02",
                            fix = {
                                offset = {
                                    -- These are the default values, which are used if you don't give anything
                                    node = 1,
                                    position = vector3_box(0.0, 0.0, 0.0), 
                                    rotation = vector3_box(0, 0, 0), 
                                    scale = vector3_box(1, 1, 1),
                                },
                            },
                            -- snip
                        }.
                    },
                }
            },
            -- snip
        },
    },
```

## Classic Kitbash Building
This is the most primitive method. The idea is that you import a bunch of models, which you'll know through vibes/experience/somewhat knowing what they look like, then manually aligning them in-game with tools, then writing that down into your plugin.

To do this, first install [Modding Tools](https://www.nexusmods.com/warhammer40kdarktide/mods/312). This will let you click and drag parts. Otherwise, you'd have to do an even more complicated song and dance with using non-kitbash fixes to move slots while hot-reloading the game. I also like disabling the weapon spinning with [PUSI](https://www.nexusmods.com/warhammer40kdarktide/mods/1348), so I have more control (shameless self plug).

1. Define the basic attachment and kitbash information, for the parent kitbash and each of the children.
    - 360 noscope which models should be used from the MasterItems. 
    - Make sure the **attachments** entry is for at least one weapon/slot, since you'll need to equip it. I find it easiest to put it on all the Infantry Autoguns.
    - To start with, I like giving each child a minorly different offset. One gets (0, 0, 0.01), another gets (0, 0, 0.02), and so on. This makes it easier to select them with Modding Tools.
2. Hop in-game and customize a weapon. 
    - It's much easier if you have a mod that lets you enter a character's loadout before loading in, such as [Psych Ward](https://www.nexusmods.com/warhammer40kdarktide/mods/89) or [Hub Shortcuts](https://www.nexusmods.com/warhammer40kdarktide/mods/947).
    - You can also install [LogMeIn](https://www.nexusmods.com/warhammer40kdarktide/mods/15) and configure it to stop at the character select screen.
3. Equip the attachment. You should see the slots from Modding Tools. Click one and mess with it. I have a demo of this (using the old EWC but it's the same idea in principle): ![Link to YouTube video showing Modding Tools in action](https://youtu.be/e4QcBg96gR8?t=35)
4. Write those fix values into the kitbash definition.

If you want to use a different model for a child, change the code and restart the game. You can also hot-reload, but that will make offsets inaccurate unless you did the dance, so I prefer just restarting and grabbing a drink.

## Blender Kitbash Building
This starts with importing parts into Blender, modeling the kitbash there, then noting the parts and offsets to write into your plugin.

I'm not white enough to know the specifics.

## (Experimental) CustomAssets
Instead of building parts out of existing parts, just import custom models into Darktide! This makes use of [CustomAssets](https://www.nexusmods.com/warhammer40kdarktide/mods/1200), and there needs to be some sort of connection between it and EWC. The only documented plugin with this is [robert attachments](https://www.nexusmods.com/warhammer40kdarktide/mods/1523).

I do not understand this implementation, so that's all you'll get here. But it does work, and further research/refinement can be done.