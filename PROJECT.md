# PROJECT.md — Asteroids Project

> **Important:** This file should be updated whenever significant changes are made to the project — new files, new features, architectural decisions, or changed assumptions.

---

## Project Overview

A classic Asteroids arcade game built with Python and pygame.

---

## Tech Stack

| Tool | Version |
|------|---------|
| Python | >= 3.13 |
| pygame | 2.6.1 |

Dependencies are managed via `pyproject.toml`. A virtual environment is expected at `.venv/`.

---

## Current State

The project has basic functionality:

- **`main.py`** — Entry point. Initialises pygame, opens a 1280×720 window, and runs the game loop. Creates `updatable`, `drawable`, `asteroids`, and `shots` sprite groups. Sets class `.containers` before instantiation so objects auto-register. The loop: calls `log_state()`, processes the pygame event queue (exits on `QUIT`), fills the screen black, calls `updatable.update(dt)`, checks each asteroid vs player (game over on hit) and each asteroid vs each shot (`asteroid.split()` + `shot.kill()` on hit), draws all `drawable` objects, and flips the display.
- **`constants.py`** — Module for magic-number constants. Defines `SCREEN_WIDTH`, `SCREEN_HEIGHT`, `PLAYER_RADIUS = 20`, `LINE_WIDTH = 2`, `PLAYER_TURN_SPEED = 300`, `PLAYER_SPEED = 200`, `PLAYER_SHOOT_SPEED = 500`, `PLAYER_SHOOT_COOLDOWN_SECONDS = 0.3`, `ASTEROID_MIN_RADIUS = 20`, `ASTEROID_KINDS = 3`, `ASTEROID_SPAWN_RATE_SECONDS = 0.8`, `ASTEROID_MAX_RADIUS`, `SHOT_RADIUS = 5`. All future magic numbers should go here.
- **`logger.py`** — Logging utility. Exports `log_state()` (call once per game-loop tick; snapshots sprite groups to `game_state.jsonl` at ~1 fps for up to 16 s) and `log_event()` (write discrete events to `game_events.jsonl`). Called each frame from `main.py`.
- **`circleshape.py`** — Abstract base class `CircleShape(pygame.sprite.Sprite)`. Stores `position` (Vector2), `velocity` (Vector2), and `radius`. `collides_with(other)` returns `True` if `position.distance_to(other.position) <= self.radius + other.radius`. Subclasses must override `draw(screen)` and `update(dt)`. Uses `self.containers` to auto-register with sprite groups if set on the subclass before instantiation.
- **`player.py`** — `Player(CircleShape)`. WASD controls rotation and movement. Has a `shoot_timer` (decremented each frame by `dt`). `shoot()` is rate-limited to one shot per `PLAYER_SHOOT_COOLDOWN_SECONDS = 0.3`; it spawns a `Shot` at the player's position with velocity in the facing direction scaled by `PLAYER_SHOOT_SPEED`. Spacebar triggers `shoot()` in `update()`.
- **`asteroid.py`** — `Asteroid(CircleShape)`. Draws itself as a white circle outline (`LINE_WIDTH`). `update(dt)` moves in a straight line: `position += velocity * dt`. `split()` kills self; if radius > `ASTEROID_MIN_RADIUS`, logs `asteroid_split` and spawns two smaller asteroids at ±random angle (20–50°) with velocity scaled by 1.2; new radius = `old_radius - ASTEROID_MIN_RADIUS`.
- **`shot.py`** — `Shot(CircleShape)`. Small circle (radius `SHOT_RADIUS = 5`). Draws as white circle outline. `update(dt)` moves in a straight line: `position += velocity * dt`. Velocity is set by `Player.shoot()`.
- **`asteroidfield.py`** — `AsteroidField(pygame.sprite.Sprite)`. Manages asteroid spawning. Every `ASTEROID_SPAWN_RATE_SECONDS` it picks a random screen edge, a random speed (40–100), and a random size (1–3 × `ASTEROID_MIN_RADIUS`), then spawns an `Asteroid`. Only in `updatable` (not `drawable`).
- **`pyproject.toml`** — Project metadata and dependency declaration.
- **`Makefile`** — Convenience targets for `sync`, `run`, and `clean`. `clean` removes generated Python cache files, build artifacts, and the `game_state.jsonl` / `game_events.jsonl` log files, but leaves `.venv/` intact.
- **`README.md`** — Empty.

---

## File Structure

```
asteroids/
├── main.py             # Entry point; run this to start the game
├── constants.py        # Game-wide constants (screen size, speeds, etc.)
├── circleshape.py      # Abstract base: CircleShape(pygame.sprite.Sprite)
├── player.py           # Player(CircleShape): triangle ship, WASD controls
├── asteroid.py         # Asteroid(CircleShape): circle, moves by velocity
├── shot.py             # Shot(CircleShape): small bullet, moves by velocity
├── asteroidfield.py    # AsteroidField: spawns asteroids on a timer
├── logger.py           # Logging helpers: log_state(), log_event()
├── pyproject.toml      # Project config and dependencies
├── uv.lock             # Locked dependency versions
├── Makefile            # Convenience targets: sync, run, clean
├── .gitignore          # Excludes .venv, __pycache__, *.jsonl logs
├── .python-version     # Pins Python version for uv
├── README.md           # (currently empty)
└── PROJECT.md           # This file
```

---

## Architecture Assumptions & Conventions

- The game uses `pygame.sprite.Group` containers: `updatable` (calls `.update(dt)` each frame) and `drawable` (iterated to call `.draw(screen)`). New game object classes should set `ClassName.containers = (...)` before instantiation to auto-register.
- The game will use a standard pygame game loop (`while running: handle_events -> update -> draw`).
- All game logic should live in clearly separated classes/modules (e.g. `player.py`, `asteroid.py`, `shot.py`).
- The `main()` function in `main.py` is the single entry point and will own the game loop.
- Python 3.13+ features are fair game.

---

## Running the Project

Preferred — via `make`:

```bash
make sync      # syncs the .venv and installs dependencies (uv sync)
make run       # runs the game via uv run python main.py (default target)
make clean     # removes generated caches, build artifacts, and game logs
```

Manually:

```bash
source .venv/bin/activate
python main.py
```

> Note: `make` recipes run in a subshell, so `source .venv/bin/activate` cannot propagate to your terminal. Use `uv run` (via `make run`) or activate manually.

---

## Logging

- `log_state()` — call inside the game loop every frame. Snapshots local variables (pygame surface → screen size, sprite `Group`s, standalone sprites with a `position` attribute) to `game_state.jsonl` once per second for up to 16 seconds.
- `log_event(event_type, **details)` — call whenever a discrete game event occurs (e.g. shot fired, asteroid split). Writes to `game_events.jsonl`.
- Both `.jsonl` files are gitignored. `jq` (v1.7, system-installed) can be used to pretty-print them.
- `make clean` removes both generated log files along with common Python cache/build artifacts.

---

## Known TODOs / Next Steps

- Wire `log_state()` into the game loop. *(done)*
- Add a clock / FPS cap to the game loop. *(done — `clock.tick(60)`, `dt` tracked)*
- Create a `CircleShape` base class. *(done)*
- Create a `Player` class (sprite, draw as triangle). *(done)*
- Add player rotation (A/D keys). *(done)*
- Add player movement (W/S keys). *(done)*
- Create `Asteroid` and `AsteroidField` classes. *(done)*
- Add collision detection (player vs asteroids). *(done)*
- Add shooting (spacebar, continuous). *(done)*
- Add shot cooldown (0.3 s). *(done)*
- Add shot-asteroid collision (split/destroy asteroids). *(done)*
- Implement asteroid splitting on destruction. *(done)*
- Add starting/menu screen (so the game doesn't quit straight to desktop)
- Add a scoring system
- Implement multiple lives and respawning
- Add an explosion effect for asteroids
- Add acceleration to player movement (instead of instant speed)
- Make objects wrap around the screen edges instead of disappearing
- Add a background image
- Create different weapon types
- Make asteroids lumpy instead of perfectly round
- Give the ship a triangular hitbox instead of a circular one
- Add a shield power-up
- Add a speed power-up
- Add bombs that can be dropped
- Add alien ships that periodically appear for bonus points
