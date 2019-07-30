SHELL := /bin/bash
USER_ID := $(shell id -u)
GROUP_ID := $(shell id -g)
UNAME_S := $(shell uname -s)
UUID := $(shell uuidgen | sed 's/-//g')
S3_BUCKET := safe-jenkins-build-artifacts

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
	cargo test --release
endif
	find target/release -maxdepth 1 -type f -exec cp '{}' artifacts \;

package-build-artifacts:
ifndef JENKINS_SAMPLE_BRANCH
	@echo "A branch or PR reference must be provided."
	@echo "Please set JENKINS_SAMPLE_BRANCH to a valid branch or PR reference."
	@exit 1
endif
ifndef JENKINS_SAMPLE_BUILD_NUMBER
	@echo "A build number must be supplied for build artifact packaging."
	@echo "Please set JENKINS_SAMPLE_BUILD_NUMBER to a valid build number."
	@exit 1
endif
ifndef JENKINS_SAMPLE_BUILD_OS
	@echo "A value must be supplied for JENKINS_SAMPLE_BUILD_OS."
	@echo "Valid values are 'linux' or 'windows' or 'macos'."
	@exit 1
endif
	$(eval ARCHIVE_NAME := ${JENKINS_SAMPLE_BRANCH}-${JENKINS_SAMPLE_BUILD_NUMBER}-jenkins_sample-${JENKINS_SAMPLE_BUILD_OS}-x86_64.tar.gz)
	tar -C artifacts -zcvf ${ARCHIVE_NAME} .
	rm artifacts/**
	mv ${ARCHIVE_NAME} artifacts

retrieve-all-build-artifacts:
ifndef JENKINS_SAMPLE_BRANCH
	@echo "A branch or PR reference must be provided."
	@echo "Please set JENKINS_SAMPLE_BRANCH to a valid branch or PR reference."
	@exit 1
endif
ifndef JENKINS_SAMPLE_BUILD_NUMBER
	@echo "A build number must be supplied for build artifact packaging."
	@echo "Please set JENKINS_SAMPLE_BUILD_NUMBER to a valid build number."
	@exit 1
endif
	rm -rf artifacts
	mkdir -p artifacts/linux/release
	mkdir -p artifacts/win/release
	mkdir -p artifacts/macos/release
	aws s3 cp --no-sign-request --region eu-west-2 s3://${S3_BUCKET}/${JENKINS_SAMPLE_BRANCH}-${JENKINS_SAMPLE_BUILD_NUMBER}-jenkins_sample-linux-x86_64.tar.gz .
	aws s3 cp --no-sign-request --region eu-west-2 s3://${S3_BUCKET}/${JENKINS_SAMPLE_BRANCH}-${JENKINS_SAMPLE_BUILD_NUMBER}-jenkins_sample-windows-x86_64.tar.gz .
	aws s3 cp --no-sign-request --region eu-west-2 s3://${S3_BUCKET}/${JENKINS_SAMPLE_BRANCH}-${JENKINS_SAMPLE_BUILD_NUMBER}-jenkins_sample-macos-x86_64.tar.gz .
	tar -C artifacts/linux/release -xvf ${JENKINS_SAMPLE_BRANCH}-${JENKINS_SAMPLE_BUILD_NUMBER}-jenkins_sample-linux-x86_64.tar.gz
	tar -C artifacts/win/release -xvf ${JENKINS_SAMPLE_BRANCH}-${JENKINS_SAMPLE_BUILD_NUMBER}-jenkins_sample-windows-x86_64.tar.gz
	tar -C artifacts/macos/release -xvf ${JENKINS_SAMPLE_BRANCH}-${JENKINS_SAMPLE_BUILD_NUMBER}-jenkins_sample-macos-x86_64.tar.gz
	rm ${JENKINS_SAMPLE_BRANCH}-${JENKINS_SAMPLE_BUILD_NUMBER}-jenkins_sample-linux-x86_64.tar.gz
	rm ${JENKINS_SAMPLE_BRANCH}-${JENKINS_SAMPLE_BUILD_NUMBER}-jenkins_sample-windows-x86_64.tar.gz
	rm ${JENKINS_SAMPLE_BRANCH}-${JENKINS_SAMPLE_BUILD_NUMBER}-jenkins_sample-macos-x86_64.tar.gz

publish:
ifndef CRATES_IO_TOKEN
	@echo "A login token for crates.io must be provided."
	@exit 1
endif
	docker run --rm -v "${PWD}":/usr/src/jenkins_sample_lib:Z \
		-u ${USER_ID}:${GROUP_ID} \
		maidsafe/jenkins_sample_lib:build \
		/bin/bash -c "cargo login ${CRATES_IO_TOKEN} && cargo package && cargo publish"
