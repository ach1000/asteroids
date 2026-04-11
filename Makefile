.DEFAULT_GOAL := run

.PHONY: sync run

# Sync the virtual environment and install dependencies via uv
sync:
	uv sync

# Run the game inside the uv-managed virtual environment
run:
	uv run python main.py
