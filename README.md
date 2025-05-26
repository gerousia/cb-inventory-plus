<p align="center">
  <img src="https://www.cassettebeasts.com/wp-content/uploads/2021/10/CassetteBeasts_Logo.png" alt="Cassette Beasts Official Logo" width="330" height="200">
</p>

<h3 align="center">Cassette Beasts – Inventory Plus Mod</h3>

<p align="center">
  <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3483351047" target="_blank">
    <img src="https://steamcommunity.com/favicon.ico" width="16" style="vertical-align:middle;"> <span>Steam Workshop</span>
  </a> 
  • 
  <a href="https://modworkshop.net/mod/52047" target="_blank">
    <img src="https://modworkshop.net/favicon.ico" width="16" style="vertical-align:middle;"> <span>ModWorkshop</span>
  </a>
</p>

<p align="center">
  Utility mod that replaces single-use item behavior with <strong>bulk-use</strong> logic—ideal for <em>stackable consumables</em>.
</p>

---

## Features

- **Bulk-use system**  
  Replaces single-use actions with a flexible bulk-use mechanic.

- **Helper functions**  
  Includes utility methods to simplify integration.

- **Minimal boilerplate**  
  Clean, modular design speeds up implementation.

- **Non-intrusive**  
  Does not modify core gameplay or existing save data.

## Examples

- [`Olive Up!`](https://youtu.be/JBI7GNNjtnw)
- [`Upgrape`](https://youtu.be/YV2lx3icAe8)
- [`Reodorant`](https://youtu.be/AGULnHuuURw)

## Implementation

### Prompting the Player for Stack Quantity
   
Integrate the `MenuHelper.show_stack_box` method within the item's `custom_use_menu`. This will present a stack selection dialog and return the player's chosen quantity `amount`.

```python
func custom_use_menu(_node, _context_kind: int, _context, arg = null):
    
    ...

    # The selection range is defined by min_value (default: 1) and max_value (default: item_amount).
    # The selected amount will be returned once the player confirms their choice.
    var amount: int = yield(MenuHelper.show_stack_box(self, max_value, min_value), "completed")

    # Return any provided arguments, including the amount selected for consumption.
    return { "arg": arg, "amount": amount }
```

### Consuming Items Based on Player Selection

Once the quantity is selected, consume the specified number of items by calling `MenuHelper.consume_item` in either the `_use_in_world` or `_use_in_battle`. The selected `amount` is passed as an argument.

```python
func _use_in_world(_node, _context, arg):

    ...

    # Consumes the specified amount of the item.
    # A boolean flag controls whether a MessageDialog is displayed during the process.
    return MenuHelper.consume_item(self, arg["amount"], false)
```

## Metadata

- **Mod ID:** `mod_inventory_plus`
- **Save File Tags:** `none`
- **Netplay Tags:** `none`
