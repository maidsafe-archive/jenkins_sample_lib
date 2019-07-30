SHELL := /bin/bash
USER_ID := $(shell id -u)
GROUP_ID := $(shell id -g)

build-container:
	rm -rf target/
	docker rmi -f maidsafe/jenkins_sample_lib:build
	docker build -f Dockerfile.build -t maidsafe/jenkins_sample_lib:build .

push-container:
	docker push maidsafe/jenkins_sample_lib:build
