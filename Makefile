css:
	tailwindcss -i src/styles.css -o static/css/styles.css --minify

css-watch:
	tailwindcss -i src/styles.css -o static/css/styles.css --watch

# Build the CSS, then the static site into public/
build: css
	zola build

# Live preview with Zola's dev server (run `make css-watch` alongside for CSS)
serve:
	zola serve

# Deploy = push to master. Cloudflare Pages builds and publishes
# automatically. Build locally first to catch errors before pushing.
deploy: build
	@echo "Build OK. Deploy by committing the rebuilt CSS and pushing to master:"
	@echo "    git add -A && git commit && git push"

.PHONY: css css-watch build serve deploy
