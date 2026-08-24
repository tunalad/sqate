# sqate

A highly customizable fork of [Kickflip Quake](https://www.moddb.com/mods/kickflip-quake), based on [Fluffacorn's KFQuake](https://github.com/Fluffacorn/KFQuake).

## Building

Compiling uses the bundled 64-bit Linux `fteqcc` binary. The resulting `progs.dat` runs in any engine.

```
git clone https://github.com/tunalad/sqate.git
cd sqate
make
```

Other targets:

```
make format   # format source with qcstyle --style=quakec
make package  # build and bundle everything into sqate/
make clean    # remove build artifacts
```

## Install

Drop the `sqate` folder into your Quake directory and launch it with `-game sqate`.

## Modes

Presets that recreate different versions of the mod. Run them from the console:

| Alias | Description |
|-------|-------------|
| `mode_kickflip` / `mode_original` | Original Kickflip Quake ruleset |
| `mode_kfquake` / `mode_fluffacorn` | KFQuake ruleset |
| `mode_sqate` | SQATE defaults |
| `mode_tvnalad` | Author's preferred setup |

## Maps

| Map | Notes |
|-----|-------|
| `kfqstart` | Included with Kickflip Quake |
| `kfq1` - `kfq10` | Included with Kickflip Quake |
| `sq_brick-world` | Port of [rayish_brick-world](https://gamebanana.com/mods/93321) with Quake textures. Ladders need `sq_skip_stair 1`. |

## Controls

Rebind in `CFG Files/Autoexec.cfg` under `// Skate Binds`. Don't touch the aliases below that.

| Command | Default key |
|---------|-------------|
| Trick 1 (Indy Grab) | Shift |
| Trick 2 (Pop Shove-it) | Q |
| Trick 3 (360 Shove-it) | E |
| Trick 4 (Backside 360) | R |
| Toggle camera | C |
| Toggle walking | F |
| Competition start | M |

## Cvars

Cvars marked **[R]** only apply after a restart.

| Cvar | Default | Description |
|------|---------|-------------|
| `sq_airstrafe` | 0 | Enables air strafing |
| `sq_fail_trick` **[R]** | 1 | Enables failing tricks |
| `sq_fail_fall` **[R]** | 1 | Enables failing from big heights |
| `sq_fail_damage` **[R]** | 0 | Failing deals damage |
| `sq_waterkill` | 0 | Deep water kills instantly |
| `sq_sidedrop` **[R]** | 0 | Drops you off the board when landing facing the wrong way |
| `sq_skip_stair` | 0 | Lets you climb stairs while skating |
| `sq_skip_water` | 1 | Stops you getting stuck in shallow water |
| `sq_walking` | 0 | Lets you get off your skates |
| `sq_monsterjump` **[R]** | 0 | Tricks off monsters score, boost, and unlock air strafing |
| `sq_stamina` **[R]** | 0 | Enables stamina |
| `sq_stamina_recovery` | 2 | Stamina recovery value |
| `sq_stamina_cost_jump` | 30 | Stamina cost of jumping while skating |
| `sq_stamina_cost_push` | 30 | Stamina cost of pushing |
| `sq_remove_items` | 35 | Bitmask of item kinds to remove |

### sq_remove_items bitmask

Item kinds are removed by summing their values:

| Value | Kind |
|-------|------|
| 1 | Weapons |
| 2 | Armor |
| 4 | Runes |
| 8 | Bio suit |
| 16 | Health |
| 32 | Ammo |

For example, `5` removes weapons and runes, `21` also removes health, and `63` removes everything.

## Acknowledgments

Michael 'Squirt' Buettner - wrote the original Kickflip Quake. The source code is on [ModDB](https://www.moddb.com/mods/kickflip-quake/downloads/source-code).

Fluffacorn - maintained the [KFQuake](https://github.com/Fluffacorn/KFQuake) fork this is based on.

Spike - FTEQuake engine and the fteqcc compiler bundled in `tools/`.

## License

GNU General Public License v2
