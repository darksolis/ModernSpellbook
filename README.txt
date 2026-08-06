MODERN SPELLBOOK BUILT BY DARKSOLIS
Version 2.4.6-CoA

SECURE COMBAT PAGE EDITION

WHAT CHANGED
- Spell cards use SecureActionButtonTemplate again, so a normal click casts the spell safely without calling CastSpell() from insecure Lua.
- Every category page and spell card is created and assigned before combat.
- Previous Page and Next Page use secure click handlers, so page switching works during combat.
- Dragging uses native PickupSpell/PickupPetSpell and remains available during combat on this Ascension client.
- Spell icons remain fixed on the cards while dragging.
- No direct CastSpell or CastSpellByName calls exist in the addon.

COMBAT RULES
- Click to cast: works.
- Drag spells to the action bar: attempted through the native spell pickup API.
- Previous/Next page navigation: works through secure handlers.
- Search, rank filtering, passive filtering, player/pet switching, and spell-list rebuilding are locked during combat and apply after combat. This is required because secure spell attributes cannot be rewritten during combat lockdown.

INSTALL
1. Delete the old ModernSpellBook folder.
2. Copy this ModernSpellBook folder into Interface/AddOns.
3. Fully restart the client.
4. Do not merge with an earlier version.

- Mouse-wheel page switching restored and routed through the secure Previous/Next page controls.


2.4.6 MOUSE-WHEEL FIX
- Removed insecure programmatic :Click() calls on secure page buttons.
- Mouse wheel now uses direct secure override bindings to the named Previous/Next buttons.
- Fixes SecureHandlers.lua: Invalid access of managed environments table.


2.4.6 FIX
- Removed global mouse-wheel override bindings that stole camera zoom.
- Mouse-wheel paging now activates only while the cursor is over the spellbook.
- Secure footer buttons remain available for page changes during combat.

- Custom spellbook frame is now parented to UIParent so native protected frame visibility changes cannot hide it during combat.
