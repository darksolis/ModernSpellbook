MODERN SPELLBOOK REBUILT
Version 2.2.0-CoA

This is a from-scratch replacement for the previous ModernSpellBook builds.
It does not load or reuse the previous addon logic, polish layer, side-navigation
code, lifecycle patches, icon repair code, or custom art assets.

FEATURES
- Fresh spell collection using GetNumSpellTabs and GetSpellTabInfo
- Direct spellbook-slot icon loading via GetSpellBookItemTexture
- Built-in question-mark fallback for missing textures
- Search by spell name, rank, or category
- Show/hide passive spells
- Show all ranks or highest rank only
- Separate Player Spells and Pet views
- Large Previous Page and Next Page controls
- Spell tooltips, chat linking, dragging, casting, and cooldown display
- Uses only Blizzard/Ascension client textures
- Leaves the Ascension sidebar alone
- Automatically yields to professions and other non-spellbook content

INSTALLATION
1. Delete the entire existing ModernSpellBook folder.
2. Copy this ModernSpellBook folder into Interface/AddOns.
3. Fully restart the WoW client.
4. Do not merge this folder with any earlier version.

COMMANDS
/msb refresh  - Rebuild the visible spell list
/msb reset    - Reset search, ranks, passive, and mode settings
/msb debug    - Print basic collection/render information

IMPORTANT
This addon targets the 3.3.5a Ascension / Conquest of Azeroth client.


2.1.0 POLISH PASS
- Fixed 3-column by 5-row grid with no overflow.
- Rebuilt header spacing so mode buttons and search never overlap.
- Enlarged, elevated footer navigation with reliable click handling.
- Added mouse-wheel page navigation.
- Expanded and restored the parent frame height cleanly.
- Preserved the working direct spell/icon collection from 2.0.0.


CATEGORY ORGANIZATION
- Learned talent abilities are mapped back to their actual talent tree.
- Every displayed page contains spells from one category only.
- Categories follow talent-tree order first, then remaining spellbook categories.
- Large page controls move between category pages without mixing unrelated abilities.
