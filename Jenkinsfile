stage('build & test') {
    node('windows') {
        checkout(scm)
        sh("cargo test")
    }
}

stage('deploy') {
    node('windows') {
        checkout(scm)
        sh("git --version")
        try {
            withCredentials([usernamePassword(
                credentialsId: "github_maidsafe_qa_user_credentials",
                usernameVariable: "GIT_USER",
                passwordVariable: "GIT_PASSWORD")]) {
                version = "0.0.1"
                //sh("git tag -a ${version} -m 'Creating tag for ${version}'")
                sh("git config credential.username Maidsafe-QA")
                sh("git config credential.helper '!f() { password=\$GIT_PASSWORD; }; f'")
                sh("GIT_ASKPASS=true git push origin --tags")
            }
        } finally {
            sh("git config --unset credential.username")
            sh("git config --unset credential.helper")
        }
    }
}
