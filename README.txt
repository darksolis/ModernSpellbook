MODERN SPELLBOOK BUILT BY DARKSOLIS
Version 2.5.1-CoA

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


2.5.1 MOUSE-WHEEL FIX
- Removed insecure programmatic :Click() calls on secure page buttons.
- Mouse wheel now uses direct secure override bindings to the named Previous/Next buttons.
- Fixes SecureHandlers.lua: Invalid access of managed environments table.


2.5.1 FIX
- Removed global mouse-wheel override bindings that stole camera zoom.
- Mouse-wheel paging now activates only while the cursor is over the spellbook.
- Secure footer buttons remain available for page changes during combat.

- Custom spellbook frame is now parented to UIParent so native protected frame visibility changes cannot hide it during combat.


2.5.1 COMBAT VISIBILITY FIX
- Defers native spellbook OnHide handling briefly to distinguish a real user close from Ascension hiding its protected shell as combat begins.
- Keeps the UIParent-hosted Modern Spellbook visible through that combat transition.


2.5.1 COMBAT VISIBILITY
- Native Ascension OnHide no longer closes Modern Spellbook.
- Once opened, the secure custom frame remains shown through combat transitions.
- Custom visibility is owned by Modern Spellbook instead of the native protected frame.


2.5.1 COMBAT VISIBILITY FIX
- Never reanchors the protected custom book during combat.
- Ignores transient Ascension UpdateSpells/currentContent changes during combat.
- Prevents combat-time alpha changes that could make the secure book disappear.
- Leaves the already-built secure page tree frozen for the duration of combat.


2.5.1 COMBAT CLOSE FIX
- Secure X button can hide the protected Modern Spellbook during combat.
- Native Ascension shell restoration is deferred until combat ends.
- Fixed RestoreNativeSpellContent lexical scope regression.
- No combat-time repositioning or insecure Hide() call is used for the custom book.


2.5.1
- Restored normal spellbook key toggle closing out of combat.
- Native combat-driven OnHide events are still ignored so the secure custom book remains visible in combat.
