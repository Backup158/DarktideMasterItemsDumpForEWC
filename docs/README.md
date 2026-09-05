The Google Sheets plan was more trouble than it was worth. Let's create a new plan.

# Hosting the Attachments Library on GitHub Pages
## Establish the Relationships Between Weapon Family and Attachments
1. Extract the game files
    - Use [limn](https://github.com/ManShanko/limn)
        - Run in command line (use wine if on Linux)
        - Or do it in Blender using the [Bitsquid tools and limn](https://gitlab.com/qasikfwn/bitsquid-blender-tools/-/wikis/home/Extracting-game-files)
    - Make sure you get the linked dictionary from the [Bitsquid Blender Tools repository](https://gitlab.com/qasikfwn/bitsquid-blender-tools)
        - Make sure you use the flag `limn --dict dictionary_hashcat_dt.txt`
        - This gives file names instead of just lxkjoiu8013fnu AAAAAAAA
    - It's the packages, so make sure you have **110 GB** of free space
    - For me, I ran limn with wine like `wine limn-0.7.2-x86_64-pc-windows-msvc/limn.exe --dict dictionary_hashcat_dt.txt -i "/mnt/data/SteamLibrary/steamapps/common/Warhammer 40,000 DARKTIDE/bundle" package`
2. Read the attachment > weapon folder (?) relationships
    1. Go through `content/weapons/player/ranged` and `melee`
    2. Check each immediate subfolder. We will use that as the Slot (with a default generic fallback slot)
    3. Inside each are the attachments?
    - pls verify I wrote this on the toilet
3. Generate a manifest or some other guide file listing these out
    1. Create the base entry for the type of attachment you want to find (e.g "Stocks")
    2. Have something to look through each weapon folder in content/weapons/player/ranged/ and see if it finds any attachment folders named "stock_*". Or something involving the folder paths
    3. if it finds any attachment folders with that name, create the weapon entry in the table based off of the weapon folder it's currently in (e.g if it's currently looking through the "autogun_rifle" folder, it'll create an entry with that name\*) 
    4. then if it makes that weapon entry, go through and add each attachment named "stock_*" as a sub-entry
    5. repeat until it's gone through each weapon folder to find stocks, then go through the next attachment category
    6. if you wanted to overcomplicate it, you could potentially even create a localisation table, so if it finds "autogun_rifle_ak" for example, it converts to "Braced Autogun"
    - I imagine this would be `attachment_to_weapon_family_manifest.json` or something
4. Upload the manifest into the repo

## Generate the Website on GitHub Pages
1. Have some basic HTML/CSS. The end result is probably something like this:

![webpage mockup](./assets/infrastructure_drafts/masteritem_dump_mockup.png)

2. Have JavaScript or something to read the manifest, then dynamically create the collapsible side bars, and create rows for each attachment in each section

## Flesh Out Each Attachment Row
1. Read the master_items dump for supplementary information on each attachment
    - Just need the base_unit, since the item address is the file address
    - The item address is how we'll find which row to edit
    - hm the attachment point (ap_stock_01) could help too
2. Dynamically add that info to each row on the GitHub Page
3. Have our separate images/notes created, with some mapping to each attachment
    - I imagine it'll be a json, mapped by the item address
    - `{ "content/items/weapons/player/ranged/stocks/plasma_rifle_stock_04" = "Notes as one big string. Could there be markdown with this? A question for later "}`
    - I'm not sure how images would go. Maybe instead of `"item address" = "notes in a string"`, it's `"item address" = {"notes" = "note", "image_urls" = ["url1"] }`
4. Also dynamically add that to each row on the page



>[!WARNING]
> 
> Getting the images will be very tedious
> 
> There should be a way to automate this, but still allow the flexibility of manually added images
> 
> The "working" plan is to somehow create a Blender script which renders all attachments --> displays them one frame at a time --> screenshots each frame and names the file after the file address --> dump that in the repo --> dynamically fill rows based on that
> 
> In theory, could this be made to have an exploded view of each part, with the nodes/sub-meshes clearly labelled?