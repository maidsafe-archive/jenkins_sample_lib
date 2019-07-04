stage('deploy') {
    node('docker') {
        //checkout(scm)
        checkout([
            $class: 'GitSCM',
            branches: scm.branches,
            doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
            extensions: scm.extensions + [[$class: 'CloneOption', noTags: false, reference: '', shallow: true]],
            submoduleCfg: [],
            userRemoteConfigs: scm.userRemoteConfigs])
        version = "0.0.23"
        retrieve_build_artifacts()
        package_artifacts_for_deploy()
        create_tag(version)
        create_github_release(version)
    }
}

def retrieve_build_artifacts() {
    command = "SAFE_CLI_BRANCH=113 "
    command += "SAFE_CLI_BUILD_NUMBER=10 "
    command += "make retrieve-all-build-artifacts"
    sh(command)
}

def package_artifacts_for_deploy() {
    sh("make package-artifacts-for-deploy")
}

def create_tag(version) {
    withCredentials([usernamePassword(
        credentialsId: "github_maidsafe_qa_user_credentials",
        usernameVariable: "GIT_USER",
        passwordVariable: "GIT_PASSWORD")]) {
        sh("git config --global user.name \$GIT_USER")
        sh("git config --global user.email qa@maidsafe.net")
        sh("git config credential.username \$GIT_USER")
        sh("git config credential.helper '!f() { echo password=\$GIT_PASSWORD; }; f'")
        sh("git tag -a ${version} -m 'Creating tag for ${version}'")
        sh("GIT_ASKPASS=true git push origin --tags")
    }
}

def create_github_release(version) {
    withCredentials([usernamePassword(
        credentialsId: "github_maidsafe_token_credentials",
        usernameVariable: "GITHUB_USER",
        passwordVariable: "GITHUB_TOKEN")]) {
        sh("make deploy-github-release")
    }
}
