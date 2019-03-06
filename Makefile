.PHONY: test build push clean environment

IMAGE_NAME = lavode/observatory
SENTRY_PROJECT = observatory
SENTRY_ORGANIZATION = dragaera
COMMIT_ID := $(shell git rev-parse HEAD)

build:
	@echo "Building container for commit ${COMMIT_ID}"
	echo ${COMMIT_ID} > image_version
	echo ${IMAGE_NAME} > image_name
	docker build -t ${IMAGE_NAME}:${COMMIT_ID} .
	docker build -t ${IMAGE_NAME}:latest .

# TODO: Should be able to use variables to clean up this duplication.
build_test:
	@echo "Building testing container for commit ${COMMIT_ID}"
	echo ${COMMIT_ID} > image_version
	echo ${IMAGE_NAME} > image_name
	docker build -t ${IMAGE_NAME}:${COMMIT_ID} --build-arg BUNDLE_EXCLUDE_GROUPS=development .
	docker build -t ${IMAGE_NAME}:latest --build-arg BUNDLE_EXCLUDE_GROUPS=development .

test: build_test
	COMMIT_ID=${COMMIT_ID} docker-compose -f docker-compose.ci.yml down
	COMMIT_ID=${COMMIT_ID} docker-compose -f docker-compose.ci.yml up --abort-on-container-exit --exit-code-from observatory-ci

push: build
	IMAGE_NAME=${IMAGE_NAME} util/push_container.sh

tag:
	@echo 'Checking for unstashed changes.'
	! git status --porcelain 2>/dev/null | grep '^ M '
	@echo 'None found.'
	
	@echo 'Checking for untracked files'
	! git status --porcelain 2>/dev/null | grep '^?? '
	@echo 'None found.'
	
	@echo "Building release: ${VERSION}"
	sed -E -i "s/VERSION = '([0-9.]+)'/VERSION = '${VERSION}'/" lib/observatory/version.rb
	vim CHANGELOG.md
	git add lib/observatory/version.rb CHANGELOG.md
	git commit -m "Bump version to '${VERSION}'."
	git tag -a ${VERSION}
	git push
	git push --tags

	SENTRY_ORG=${SENTRY_ORGANIZATION} sentry-cli releases new -p ${SENTRY_PROJECT} ${VERSION}
	@echo "Be sure to now associate the commits with the release, by executing something like: "
	@echo "SENTRY_ORG=${SENTRY_ORGANIZATION} sentry-cli releases set-commits --commit '${SENTRY_ORGANIZATION}/${SENTRY_PROJECT}@COMMIT_HASH' ${VERSION}"

release: tag push

clean:
	@echo "Cleaning environment"
	docker-compose down -v
