include ${PWD}/docker/docker-monolith/.env
DOCKER_IMAGES = $(shell docker images -q)
DOCKER_CONTAINERS=$(shell docker ps -a -q)

# Выводит описание целей - все, что написано после двойного диеза (##) через пробел
help:
	@fgrep -h "##" $(MAKEFILE_LIST) | sed -e 's/\(\:.*\#\#\)/\:\ /' | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

#===================================================== DOCKER BUILD =====================================================================


build-all: build-prometheus build-ui build-comment build-post build-mongodb-exporter build-blackbox-exporter ## Создать все docker образы проекта

build-prometheus: ## Создание docker-образа для контейнера prometheus
	cd monitoring/prometheus && \
	docker image build -t $(USER_NAME)/prometheus:$(PROMETHEUS_TAG) .
build-ui: ## Создание docker-образа для контейнера ui
	cd src/ui && \
	USER_NAME=$(USER_NAME) bash docker_build.sh
build-comment: ## Создание docker-образа для контейнера comment
	cd src/comment && \
	USER_NAME=$(USER_NAME) bash docker_build.sh
build-post: ## Создание docker-образа для контейнера post
	cd src/post-py && \
	USER_NAME=$(USER_NAME) bash docker_build.sh
build-mongodb-exporter: ## Создание docker-образа для контейнера mongodb-exporter
	cd monitoring/mongodb_exporter && \
	docker image build -t $(USER_NAME)/mongodb-exporter:$(MONGOEXP_TAG) .
build-blackbox-exporter: ## Создание docker-образа для контейнера blackbox-exporter
	cd monitoring/blackbox_exporter && \
	docker image build -t $(USER_NAME)/blackbox-exporter:$(BLKBOXEXP_TAG) .

#===================================================== DELETE =====================================================================

delete-container-all: ## Остановить и удалить все запущенные контейнеры
	docker stop $(DOCKER_CONTAINERS) && \
	docker rm $(DOCKER_CONTAINERS)

delete-image-all: ## Удалить все docker образы
	docker image rm -f $(DOCKER_IMAGES)

#===================================================== REGESTRY =====================================================================

docker-login:
	docker login -u $(USER_NAME)

push-all: push-prometheus push-ui push-comment push-post push-mongodb-exporter push-blackbox-exporter

push-prometheus: ## Сохранение docker-образа prometheus в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/prometheus:$(PROMETHEUS_TAG)
push-ui: ## Сохранение docker-образа ui в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/ui:$(UI_TAG)
push-comment: ## Сохранение docker-образа comment в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/comment:$(COMMENT_TAG)
push-post: ## Сохранение docker-образа post в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/post:$(POST_TAG)
push-mongodb-exporter: ## Сохранение docker-образа mongodb-exporter в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/mongodb-exporter:$(MONGOEXP_TAG)
push-blackbox-exporter: ## Сохранение docker-образа blackbox-exporter в DockerHub (образ должен быть уже собран)
	docker push $(USER_NAME)/blackbox-exporter:$(BLKBOXEXP_TAG)


#===================================================== DOCKER-COMPOSE =====================================================================

docker-compose-up: ## Запуск контейнеров с помощью docker-compose
	cd docker/docker-monolith && \
	docker-compose up -d

docker-compose-down: ## Остановка контейнеров с помощью docker-compose
	cd docker/docker-monolith && \
	docker-compose down
