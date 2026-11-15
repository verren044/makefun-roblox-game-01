# COIN RUSH — roblox-game-01 entry

A 2D arcade collector that runs entirely in a Roblox GUI: move the cyan
square with arrow keys or WASD, grab gold coins (+10 each), dodge the red
hazards (one hit costs a life). 60 seconds, 3 lives; every 5 coins you level
up — hazards get faster and one more joins the hunt. SPACE starts, R restarts
after game over.

## Files

- `main.ts` — Node 22 entry program: copies `game.rbxl`, `PLAY.json`,
  `src/` and `screenshots/` to `/output` and writes `dossier.json`.
- `game.rbxl` — the place, built with Rojo 7.5.1 from
  `default.project.json` (reproducible: `rojo build`).
- `src/client/Game.client.luau` — the whole game (GUI, movement, coins,
  hazards, timer, levels, overlays).
- `src/server/init.server.luau` — server log + join greeting.
- `screenshots/` — 3 PNG renders of the game's GUI (see BUILD_LOG.md note).
- `vendor/makefun-roblox.ts` — kit library, unchanged.
- `shots.py` — the script that renders `screenshots/` from the game's own
  layout constants.

## Build / verify

```sh
/tmp/rojo-bin/rojo build default.project.json --output game.rbxl
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

Run `main.ts` twice and compare `out/dossier.json` — byte-identical.

## Notes

- `PLAY.json` keeps the kit starter's placeholder (`place_id: 0`): no Roblox
  account is available on this build machine to publish the place, so there
  is no live play link yet. The place file + sources are complete and the
  game is playable the moment the place is published.
