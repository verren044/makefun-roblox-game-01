# BUILD_LOG.md — Coin Rush (roblox-game-01)

## v1 — first full build (2026-11-15, ~23:10 WIB)

- Started from the kit starter (same `main.ts`, `vendor/makefun-roblox.ts`,
  `LICENSE`, `default.project.json` shape, `PLAY.json` placeholder).
- Rewrote `src/client/Game.client.luau` from the grey-square demo into
  COIN RUSH: 640x480 arena, cyan player (arrows + WASD, 340 px/s),
  6 gold coins (+10 each, respawn on collect), red hazards that drift and
  bounce (2 + level, speed 110 + 28*level), 3 lives with 1.5 s
  invulnerability flash, 60 s timer, level-up every 5 coins, menu / game-over
  overlays (SPACE start, R restart), HUD score/coins/lives/level/time.
- `src/server/init.server.luau`: join logging only; the game is client-side.
- Rojo 7.5.1 (downloaded from rojo-rbx/rojo releases) rebuilt `game.rbxl`
  (6,661 bytes). Luau 0.747 `luau-compile --only-parse` passes both scripts;
  `luau-analyze` reports only unknown Roblox globals (expected outside
  Studio — no syntax or type errors).
- Screenshots: no Roblox client exists on this VM, so `shots.py` (PIL)
  renders the game's GUI from its own layout constants (arena 640x480,
  same colours, same HUD/overlay copy) at 1280x706 — 1-start (menu),
  2-play (mid-game), 3-end (game over). All under 256 KiB.
- `PLAY.json` stays the starter placeholder: no Roblox account on this
  machine to publish the place; entry is judged on the place file + sources.
- Determinism: `main.ts` run twice, `dossier.json` byte-identical
  (sha256 recorded below after the check run).
