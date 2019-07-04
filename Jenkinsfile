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
        version = "0.0.12"
        create_tag(version)
        create_github_release(version)
    }
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
        sh("""
            github-release release \
                --user maidsafe \
                --repo safe-cli \
                --tag ${version} \
                --name "safe-cli" \
                --description "Command line interface for the SAFE Network"
        """)
    }
}
