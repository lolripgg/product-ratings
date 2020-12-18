.PHONY: build console db db.create db.drop db.migrate db.rollback db.seed down logs test up

db:
	@docker-compose run --rm api rake db:create db:migrate db:seed

db.create:
	@docker-compose run --rm api rake db:create

db.drop:
	@docker-compose run --rm api rake db:drop

db.migrate:
	@docker-compose run --rm api rake db:migrate

db.rollback:
	@docker-compose run --rm api rake db:rollback

db.seed:
	@docker-compose run --rm api rake db:seed

docker.build:
	@docker-compose build

docker.down:
	@docker-compose down

docker.logs:
	@docker-compose logs --follow

docker.up:
	@docker-compose up -d

rails.console:
	@docker-compose run --rm api rails console

rails.routes:
	@docker-compose run --rm api rails routes

rails.spring.stop:
	@docker-compose run --rm api bin/spring stop

test:
	@docker-compose run --rm api rails test
