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

## Current State (as of project start)

The project is at a very early skeleton stage:

- **`main.py`** — Entry point. Initialises pygame, opens a 1280×720 window, and runs the game loop. The loop calls `log_state()`, processes the pygame event queue (exits on `QUIT`), fills the screen black, and flips the display.
- **`constants.py`** — Module for magic-number constants. Currently defines `SCREEN_WIDTH = 1280` and `SCREEN_HEIGHT = 720`. All future magic numbers (speeds, sizes, etc.) should go here.
- **`logger.py`** — Logging utility. Exports `log_state()` (call once per game-loop tick; snapshots sprite groups to `game_state.jsonl` at ~1 fps for up to 16 s) and `log_event()` (write discrete events to `game_events.jsonl`). Not yet wired into `main.py`.
- **`pyproject.toml`** — Project metadata and dependency declaration.
- **`README.md`** — Empty.

---

## File Structure

```
asteroids/
├── main.py          # Entry point; run this to start the game
├── constants.py     # Game-wide constants (screen size, speeds, etc.)
├── logger.py        # Logging helpers: log_state(), log_event()
├── pyproject.toml   # Project config and dependencies
├── Makefile         # Convenience targets: install, run
├── .gitignore       # Excludes .venv, __pycache__, *.jsonl logs
├── README.md        # (currently empty)
└── PROJECT.md        # This file
```

---

## Architecture Assumptions & Conventions

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
- **Next step:** import and call `log_state()` from the game loop in `main.py`.

---

## Known TODOs / Next Steps

- Wire `log_state()` into the game loop. *(done)*
- Add a clock / FPS cap to the game loop.
- Create a `Player` class (sprite, movement, shooting).
- Create a `Player` class (sprite, movement, shooting).
- Create an `Asteroid` class (random spawn, splitting behaviour).
- Create a `Shot`/`Bullet` class (fired by the player).
- Add collision detection between shots, asteroids, and the player.
- Add score tracking and game-over state.
