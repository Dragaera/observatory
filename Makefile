.PHONY: test build push

IMAGE_NAME = lavode/observatory
COMMIT_ID := $(shell git rev-parse HEAD)

build:
	@echo "Building container for commit ${COMMIT_ID}"
	echo ${COMMIT_ID} > image_version
	echo ${IMAGE_NAME} > image_name
	docker build -t ${IMAGE_NAME}:${COMMIT_ID} .
	docker build -t ${IMAGE_NAME}:latest .

test: build
	COMMIT_ID=${COMMIT_ID} docker-compose -f docker-compose.ci.yml down
	COMMIT_ID=${COMMIT_ID} docker-compose -f docker-compose.ci.yml up --abort-on-container-exit --exit-code-from observatory-ci

push: build
	IMAGE_NAME=${IMAGE_NAME} util/push_container.sh
