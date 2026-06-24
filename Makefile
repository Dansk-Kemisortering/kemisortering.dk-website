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

# Build, then rsync the generated site to the VPS
deploy: build
	rsync -av --delete \
		public/ \
		root@hel1.x2q.net:/data/sites/kemisortering.dk/

.PHONY: css css-watch build serve deploy
