MODERN SPELLBOOK REBUILT
Version 2.3.4-CoA-DarkSolis

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


COMBAT-SAFE REWORK
- Spell cards are now ordinary addon buttons, not SecureActionButtonTemplate frames.
- Pages, categories, search, and visibility may update during combat.
- Spells cast from the player's real left-click using CastSpell(slot, bookType).
- Native Ascension protected frames are never hidden, shown, resized, or mouse-toggled during combat lockdown.
- Deferred native state is applied automatically after PLAYER_REGEN_ENABLED.


2.3.1 COMBAT DRAG UPDATE
- Removed the addon-side combat check that prevented PickupSpell/PickupPetSpell from starting while fighting.
- The WoW client may still block dropping or replacing an action-bar slot during combat because action bars are protected secure frames.


V2.3.2 SHELL FIX
- Rebuilt frame now lives on UIParent rather than inside the Ascension shell.
- Native spellbook becomes transparent while the rebuilt view is active.
- Native visuals restore when closing or switching to Professions.
- No protected native Hide calls are used during combat.
- Added a dedicated close button to the rebuilt frame.


VERSION 2.3.4
- Updated in-game branding to Modern Spellbook Built by DarkSolis.
- Added movement-threshold drag detection as a fallback to OnDragStart.
- PickupSpell and PickupPetSpell are attempted during combat without addon-side blocking.
- Prevents a completed drag from also casting the spell on mouse release.


2.3.4 FIXES
- Removed all CastSpell/CastSpellByName calls to eliminate secure-cast taint.
- Spell cards are drag-only.
- Keeps source icons visible while a spell is on the cursor.
- Defers redraws while dragging so cards are not recycled mid-drag.
