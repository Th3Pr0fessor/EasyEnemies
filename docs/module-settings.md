---
sidebar_position: 4
---

# EasyEnemies Settings

Here are a list of EasyEnemies features that can be changed in the settings. (found in `EasyEnemies.Settings` Module)

```lua
local SETTINGS = {}

SETTINGS.MODULE_NAME = script.Parent.Name

SETTINGS.DEBUG_MODE = true
SETTINGS.VISUALIZE = false

SETTINGS.GENERATE_ANIMATOR = false -- For non-humanoid rigs (Beta Setting not fully functional)
SETTINGS.GENERATE_TEAMS = true
SETTINGS.GENERATE_ATTACK_RADIUS = true


return SETTINGS
```

## Debugging

### DEBUG_MODE

`SETTINGS.DEBUG_MODE` Prints warnings to the console.

### VISUALIZE

`SETTINGS.VISUALIZE` Creates path-finding visuals.

<hr/>
# Generation

### GENERATE_ANIMATOR

`SETTINGS.GENERATE_ANIMATOR` will create an [animator](https://developer.roblox.com/en-us/api-reference/class/Animator) instance for non-humanoid objects, this setting is incomplete.

### GENERATE_TEAMS

`SETTINGS.GENERATE_TEAMS` will automatically create teams for the enemies you make, it works through model names. If two models have the same name and `GENERATE_TEAMS` is enabled it will create a new team setup with said model name.

### GENERATE_ATTACK_RADIUS

`SETTINGS.GENERATE_ATTACK_RADIUS` will create an attack radius for the enemy via math using the Enemy's model size
