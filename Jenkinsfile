stage('deploy') {
    node('docker') {
        checkout(scm)
        sh("git --version")
        try {
            withCredentials([usernamePassword(
                credentialsId: "github_maidsafe_qa_user_credentials",
                usernameVariable: "GIT_USER",
                passwordVariable: "GIT_PASSWORD")]) {
                version = "0.0.2"
                sh("git tag -a ${version} -m 'Creating tag for ${version}'")
                //sh("git config --global user.name Maidsafe-QA")
                //sh("git config --global user.email qa@maidsafe.net")
                sh("git config credential.username Maidsafe-QA")
                sh("git config credential.helper '!f() { password=\$GIT_PASSWORD; }; f'")
                sh("GIT_ASKPASS=true git push origin --tags --verbose")
            }
        } finally {
            //sh("git config --unset user.name")
            //sh("git config --unset user.email")
            sh("git config --unset credential.username")
            sh("git config --unset credential.helper")
        }
    }
}
