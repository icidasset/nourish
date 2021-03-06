gen := "src/Generated"


@default: dev-build
	just dev-server


# 🛠


@clean:
	rm -rf build
	mkdir -p build


@dev-build: clean translate-schemas


@install-deps:
	pnpm install


@production-build: clean translate-schemas
	pnpx vite build src/ \
		--config vite.config.js \
		--outDir ../build/ \
		--emptyOutDir



# Pieces
# ======

@css:
	# Triggered by a custom vite plugin (see vite config)
	echo "🎨  Generating Css"
	TAILWIND_MODE=build ./node_modules/.bin/tailwind build --output {{gen}}/application.css


@translate-schemas:
	echo "🔮  Translating schemas into Elm code"
	mkdir -p src/Generated
	quicktype -s schema -o src/Generated/Ingredient.elm --module Ingredient src/Schemas/Dawn/Ingredient.json
	quicktype -s schema -o src/Generated/Meal.elm --module Meal src/Schemas/Dawn/Meal.json
	quicktype -s schema -o src/Generated/Nourishment.elm --module Nourishment src/Schemas/Dawn/Nourishment.json



# Development
# ===========

@dev-server:
	echo "🤵  Putting up a server for ya"
	echo "http://localhost:8005"

	./node_modules/.bin/vite ./src \
		--clearScreen false \
		--config vite.config.js \
		--port 8005



# Watch
# =====

@watch:
	echo "👀  Watching for changes"
	just watch-schemas


@watch-schemas:
	watchexec -p -w src/Schemas -e json -- just translate-schemas
