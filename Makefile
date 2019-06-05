APP_NAME = flask-app
IMG = $(DOCKER_PUSH_REPOSITORY)$(DOCKER_PUSH_DIRECTORY)/$(APP_NAME)
TAG = $(DOCKER_TAG)

.PHONY: test
test:
	python testapp.py

.PHONY: clean
clean:		## Clear all the .pyc/.pyo files and virtual env files.
	find . -name '*.pyc' -exec rm --force {} +
	find . -name '*.pyo' -exec rm --force {} +

.PHONY: build-image
build-image:
	docker build -t $(APP_NAME):latest .

.PHONY: push-image
push-image:
	docker tag $(APP_NAME) $(IMG):$(TAG)
	docker push $(IMG):$(TAG)

.PHONY: ci-release
ci-release: build build-image push-image


.PHONY: update-config
update-config:
	kubectl create configmap config --from-file=config.yaml=prow/config.yaml --dry-run -o yaml | kubectl replace configmap config -f -

.PHONY: update-config
update-plugins:
	kubectl create configmap plugins --from-file=plugins.yaml=prow/plugins.yaml --dry-run -o yaml | kubectl replace configmap plugins -f -