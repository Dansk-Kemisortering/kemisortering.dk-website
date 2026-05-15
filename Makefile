build:
	tailwindcss -i src/styles.css -o css/styles.css --minify

watch:
	tailwindcss -i src/styles.css -o css/styles.css --watch

deploy: build
	rsync -av --relative \
		index.html \
		css/styles.css \
		root@hel1.x2q.net:/data/sites/kemisortering.dk/

.PHONY: build watch deploy
