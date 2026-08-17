.PHONY: help dev build deploy

help:
	@echo "Targets:"
	@echo "  make dev     - run the Slidev deck locally with hot reload"
	@echo "  make build   - build the deck to slide/dist"
	@echo "  make deploy  - build the deck and publish it to gh-pages"

dev:
	cd slide && bun run dev

build:
	cd slide && bun run build

deploy:
	./slide/deploy.sh
