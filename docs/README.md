For use with the [EWC community spreadsheet](https://docs.google.com/spreadsheets/d/13eLMZGCbE6iU02jESu1ncxSvK3E2GO5n30kPT4gf5TQ/edit?usp=sharing). This repo serves as the base for updating which entries from the MasterItems go into the spreadsheet.

This is all just thrown together while I'm procrastinating from work, so the specific process can be streamlined and optimized.

# How to Use
1. Clone this repository somewhere.
2. Export the MasterItems table with the [master_items_export](https://www.nexusmods.com/warhammer40kdarktide/mods/822) mod.
    - Contents will be dumped into the AppData folder: `%AppData%\Fatshark\Darktide\master_items_export`.
    - See [this](https://dmf-docs.darkti.de/#/faqs?id=what-is-and-where-is-the-appdata-folder) for help finding the AppData folder.
3. Move the latest MasterItems dump into this repo.
    - The file will be named something like `master_items_export_v133319_1786176329`.
    - The numbers will depend on the game version.
4. Rename the dump to `master_items_export.lua`.
    - The file itself is a lua file but has no extension by default (if there's already one, you don't need to add another).
    - This is so the script knows which one to read regardless of version. There's many ways to accomplish this, but the listed instruction is the simplest.
5. Run the script.
    - I found the easiest way was through the terminal: `lua read_master_items_for_spreadsheet.lua`
        - Make sure you have Lua installed! 
        - I had to run (on a Debian-based Linux distro) `sudo apt install lua5.4`
    - You could probably do this through an IDE or something.
6. Open the resulting `master_items_attachments_for_spreadsheet.txt` in a text editor.
7. Sort the list into alphabetical order with your text editor. There has to be a better way than this, but I'm lazy :D
8. Compare the differences between that text file and the reference text file from this repo.
    - I used [Meld](https://meldmerge.org/) to highlight differences.
    - It doesn't matter exactly how you do it.
9. Find where new items will be inserted, and add the row into the spreadsheet.
    - This pretty tedious. Feedback and contributions are welcome.
    - E.g. You find a new lasgun barrel: `content/items/weapons/player/ranged/barrels/lasgun_rifle_barrel_69`
        1. Search for `content/items/weapons/player/ranged/barrels/lasgun_rifle_barrel` in the spreadsheet
        2. You see that `content/items/weapons/player/ranged/barrels/lasgun_rifle_barrel_11` is the last one there (besides the master `ml01` one)
        3. Right click the row below where you want to insert (so here, right click the one for `barrel_ml01`)
        4. Select "Insert 1 table row above"
        5. Copy the relevant line from `master_items_attachments_for_spreadsheet.txt`
        6. On the spreadsheet, paste it into the new row, in the "Name Address" column
    - Edits you make will count as a "Suggestion" and will need me to review and approve it.

>[!Tip]
>
>It's CRITICAL to insert new rows for each new attachment instead of just copying over the whole list. 99% of the reason the spreadsheet exists is to link (pictures, name address, comments). By pasting the whole new list at once, it breaks the relationship between them, because now the pictures and comments may not match up with the correct name address!
>
>Someone may mention a database would be more suited for this. I don't know how to do that in an easily sharable and editable way. Suggestions and contributions are welcome though!
