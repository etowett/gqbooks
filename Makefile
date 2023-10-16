.PHONY: help
help: ## Display available commands.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

compile: ## Compile the app into ./gqbooks
	go build -o ./gqbooks .

run_local: compile ## Run the app locally
	./gqbooks

docker-ui: ## Docker build the ui into ektowett/gqbooks-ui:latest
	@cd ui && docker build -t ektowett/gqbooks-ui:latest . && cd ..
	## @cd ui && docker build --build-arg API_URL=https://stage-gqbooks-api.citizix.com -t ektowett/gqbooks-ui:latest . && cd ..

test_serve_ui: ## Test Serve UI
	@cd ui && rm -rf dist && VITE_API_URL=https://stage-gqbooks-api.citizix.com/api/v1 npm run build && cd dist && python3 -m http.server 5171

build: ## Docker build the app into ektowett/gqbooks:latest
	docker build -t ektowett/gqbooks:latest .

up: ## Docker Compose bring up all containers in detatched mode
	docker-compose up -d

ps: ## Docker Compose check docker processes
	docker-compose ps

logs: ## Docker Compose tail follow logs
	docker-compose logs -f

stop: ## Docker Compose stop all containers
	docker-compose stop

rm: stop ## Docker Compose stop and force remove all containers
	docker-compose rm -f
