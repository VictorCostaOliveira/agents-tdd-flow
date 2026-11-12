.PHONY: cursor check

# Regenera cursor/ a partir de claude/.claude/ (fonte de verdade).
cursor:
	python3 scripts/to_cursor.py

# Falha se cursor/ estiver diferente do que claude/ gera.
check: cursor
	git diff --exit-code --stat cursor/
