stage('deploy') {
    node('docker') {
        checkout(scm)
        try {
            withCredentials([usernamePassword(
                credentialsId: "github_maidsafe_qa_user_credentials",
                usernameVariable: "GIT_USER",
                passwordVariable: "GIT_PASSWORD")]) {
                version = "0.0.10"
                if (!tag_exists(version)) {
                    sh("git config --global user.name \$GIT_USER")
                    sh("git config --global user.email qa@maidsafe.net")
                    sh("git config credential.username \$GIT_USER")
                    sh("git config credential.helper '!f() { echo password=\$GIT_PASSWORD; }; f'")
                    sh("git tag -a ${version} -m 'Creating tag for ${version}'")
                    sh("GIT_ASKPASS=true git push origin --tags --verbose")
                } else {
                    echo("tag already exists")
                }
            }
        } finally {
            sh("git config --global --unset user.name")
            sh("git config --global --unset user.email")
            sh("git config --unset credential.username")
            sh("git config --unset credential.helper")
        }
    }
}

def tag_exists(version) {
    output = sh(returnStdout: true, script: "git tag -l ${version}")
    return output?.trim()
}
