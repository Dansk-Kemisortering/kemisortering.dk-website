# Build the static site into public/
build:
	zola build

# Live preview with Zola's dev server (http://127.0.0.1:1111)
serve:
	zola serve --interface 127.0.0.1 --port 1111

# Deploy = push to master. Cloudflare Pages builds and publishes automatically.
# Build locally first to catch template errors before pushing.
deploy: build
	@echo "Build OK. Deploy by committing and pushing to master:"
	@echo "    git add -A && git commit && git push"

.PHONY: build serve deploy
