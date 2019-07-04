SHELL := /bin/bash
SAFE_CLI_VERSION := 0.0.21
S3_BUCKET := safe-jenkins-build-artifacts

retrieve-all-build-artifacts:
ifndef SAFE_CLI_BRANCH
	@echo "A branch or PR reference must be provided."
	@echo "Please set SAFE_CLI_BRANCH to a valid branch or PR reference."
	@exit 1
endif
ifndef SAFE_CLI_BUILD_NUMBER
	@echo "A build number must be supplied for build artifact packaging."
	@echo "Please set SAFE_CLI_BUILD_NUMBER to a valid build number."
	@exit 1
endif
	rm -rf artifacts
	mkdir -p artifacts/linux/release
	mkdir -p artifacts/win/release
	mkdir -p artifacts/macos/release
	aws s3 cp --no-sign-request --region eu-west-2 s3://${S3_BUCKET}/${SAFE_CLI_BRANCH}-${SAFE_CLI_BUILD_NUMBER}-safe_cli-linux-x86_64.tar.gz .
	aws s3 cp --no-sign-request --region eu-west-2 s3://${S3_BUCKET}/${SAFE_CLI_BRANCH}-${SAFE_CLI_BUILD_NUMBER}-safe_cli-windows-x86_64.tar.gz .
	aws s3 cp --no-sign-request --region eu-west-2 s3://${S3_BUCKET}/${SAFE_CLI_BRANCH}-${SAFE_CLI_BUILD_NUMBER}-safe_cli-macos-x86_64.tar.gz .
	tar -C artifacts/linux/release -xvf ${SAFE_CLI_BRANCH}-${SAFE_CLI_BUILD_NUMBER}-safe_cli-linux-x86_64.tar.gz
	tar -C artifacts/win/release -xvf ${SAFE_CLI_BRANCH}-${SAFE_CLI_BUILD_NUMBER}-safe_cli-windows-x86_64.tar.gz
	tar -C artifacts/macos/release -xvf ${SAFE_CLI_BRANCH}-${SAFE_CLI_BUILD_NUMBER}-safe_cli-macos-x86_64.tar.gz
	rm ${SAFE_CLI_BRANCH}-${SAFE_CLI_BUILD_NUMBER}-safe_cli-linux-x86_64.tar.gz
	rm ${SAFE_CLI_BRANCH}-${SAFE_CLI_BUILD_NUMBER}-safe_cli-windows-x86_64.tar.gz
	rm ${SAFE_CLI_BRANCH}-${SAFE_CLI_BUILD_NUMBER}-safe_cli-macos-x86_64.tar.gz

package-artifacts-for-deploy:
	tar -C artifacts/linux/release -cvf safe_cli-linux-${SAFE_CLI_VERSION}-x86_64.tar safe
	tar -C artifacts/win/release -cvf safe_cli-win-${SAFE_CLI_VERSION}-x86_64.tar safe.exe
	tar -C artifacts/macos/release -cvf safe_cli-macos-${SAFE_CLI_VERSION}-x86_64.tar safe
