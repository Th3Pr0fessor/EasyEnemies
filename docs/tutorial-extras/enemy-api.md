---
sidebar_position: 1
---

# Enemy API

As seen in **[Getting Started](/docs/tutorial-basics/start)** there are many settings you can tinker with.

### General Overview

```lua

-- Defining Enemy Settings

local enemy_settings = {
    health = 100, -- Enemy Health
    damage = 1, -- Enemy Base Damage
    wander = false, -- Enemy Wandering

    attack_range = 20, -- Enemy Search Radius
    attack_radius = 5, -- Enemy Attack Radius

    attack_ally = false, -- Enemy Attacking Team Members
    attack_npcs = true, -- Enemy Attacking Random NPC's
    attack_players = true, -- Enemy Attacking Players

    default_animations = {8972576500}, -- Enemy Animations should be used for 'Light' Attacks // Example default_animations = {8972576500}
    default_functions = { -- Functions for said 'Light' Attacks ^
        function(target) -- functions pass the target as the first argument automatically
            print(target)
        end,
    },

    special_animations = {8972576500}, -- Enemy Animations should be used for 'Heavy' Attacks // Example special_animations = {8972576500}
    special_functions = { -- Functions for said 'Heavy' Attacks ^
        function(target) -- functions pass the target as the first argument automatically
            print('specialMove')
        end,
    },
}
```

<hr/>

## General Settings

### Health

Changes the initial health to setting's value.

> `health = 100, -- Enemy Health`

### Damage

Creates damage set to the setting's value.

> `damage = 1, -- Enemy Base Damage`

### Wander

If set to true enemy will walk around freely withing the attack_range

> `wander = false, -- Enemy Wandering`

<hr/>

## Attack Settings

### Attack Range

The search radius of initialized enemy

> `attack_range = 20, -- Enemy Search Radius`

### Attack Radius

The maximum distance of the enemy target can be in order for an enemy to attack

> `attack_radius = 5, -- Enemy Attack Radius`

### Attack Ally

Enemy will attack Humanoid Model with the same tag as itself

> `attack_ally = false, -- Enemy Attacking Team Members`

### Attack Npcs

Enemy will attack Humanoid Model that does not possess the same tags nor is a player

> `attack_npcs = true, -- Enemy Attacking Random NPC's`

### Attack Players

Enemy will attack players

> `attack_players = true, -- Enemy Attacking Players`

## Animations & Effects

Here we will encompass `default` and `special` into 2 bullet points

### default attacks

Default animations should be companied by functions, the index of the animation matches up with the index of the function, lets take the following code for example:

```lua
default_animations = {8972576500, 9039173175}, -- Enemy Animations should be used for 'Light' Attacks // Example default_animations = {8972576500}
default_functions = { -- Functions for said 'Light' Attacks ^
    function(target) -- functions pass the target as the first argument automatically
        print('move 1')
    end,

    function(target) -- functions pass the target as the first argument automatically
        print('move 2')
    end,
}
```

if the animation `8972576500` _(default_animations[2])_ at the index of 2 plays the following function will be called:

```lua
function(target) -- functions pass the target as the first argument automatically
    print('move 2')
end
```
