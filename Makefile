SHELL := /bin/bash
USER_ID := $(shell id -u)
GROUP_ID := $(shell id -g)
UNAME_S := $(shell uname -s)

build-container:
	rm -rf target/
	docker rmi -f maidsafe/jenkins_sample_lib:build
	docker build -f Dockerfile.build -t maidsafe/jenkins_sample_lib:build .

push-container:
	docker push maidsafe/jenkins_sample_lib:build

test:
	rm -rf artifacts
	mkdir artifacts
ifeq ($(UNAME_S),Linux)
	docker run --name "jenkins_sample_lib-${UUID}" \
		-v "${PWD}":/usr/src/jenkins_sample_lib:Z \
		-u ${USER_ID}:${GROUP_ID} \
		maidsafe/jenkins_sample_lib:build \
		/bin/bash -c "cargo test --release"
	docker cp "jenkins_sample_lib-${UUID}":/target .
	docker rm "jenkins_sample_lib-${UUID}"
else
	cargo test
endif
	find target/release -maxdepth 1 -type f -exec cp '{}' artifacts \;

publish:
	docker run --name "jenkins_sample_lib-${UUID}" \
		-v "${PWD}":/usr/src/jenkins_sample_lib:Z \
		-v ~/.cargo/credentials:/home/maidsafe/.cargo/credentials:Z \
		-u ${USER_ID}:${GROUP_ID} \
		maidsafe/jenkins_sample_lib:build \
		/bin/bash -c "cargo login && cargo package"
