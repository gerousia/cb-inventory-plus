# Cassette Beasts – Inventory Use Item Stack Mod

This mod enhances the inventory system by enabling direct use of items from stacks, replacing the default single-use behavior. It's especially useful for other mods that introduce stackable consumables.

If you're developing new items that function as stackable consumables, this mod helps streamline implementation and reduce repetitive code.

### What's Included:
- Framework for handling item stacks in the inventory.
- Reusable helper functions to support stack item behavior.

### Sample Implementation(s):
- `Olive Up!`
- `Upgrape`

### FAQ

#### Why isn't `Upgrape` included in the release `.pck`?
- Upgrape does function correctly; however, it simply does not add anything. `MonsterTape`'s grade level-up system differs from `Character`'s. It only supports one level gain per instance, whereas `Character`s can level up multiple times at once. This is a design limitation in the base game and may be addressed in future updates or through other mods.

### Metadata
- Mod ID: `mod_inventory_use_stack`
- Save File Tags: `none` (safe to remove)
- Netplay Tags: `none`
