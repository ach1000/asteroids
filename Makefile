.DEFAULT_GOAL := run

.PHONY: sync run clean

# Sync the virtual environment and install dependencies via uv
sync:
	uv sync

# Run the game inside the uv-managed virtual environment
run:
	uv run python main.py

# Remove Python cache files, build artifacts, and generated game logs
clean:
	rm -rf __pycache__ .pytest_cache .mypy_cache .ruff_cache build dist wheels *.egg-info
	find . -type d -name __pycache__ -prune -exec rm -rf {} +
	find . -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete
	rm -f game_state.jsonl game_events.jsonl
