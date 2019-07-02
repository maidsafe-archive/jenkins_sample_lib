stage('build & test') {
    node('windows') {
        checkout(scm)
        sh("cargo test")
    }
}

stage('deploy') {
    node('windows') {
        checkout(scm)
        withCredentials([usernamePassword(
            credentialsId: "github_maidsafe_qa_user_credentials",
            usernameVariable: "GIT_USER",
            passwordVariable: "GIT_PASSWORD")]) {
            version = "0.0.1"
            sh("""
                git checkout -B ${BRANCH_NAME}
                git config user.name "Maidsafe-QA"
                git config user.email "qa@maidsafe.net"
                git tag -a ${version} -m "Creating tag for ${version}"
                git push https://${env.GIT_USER}:${env.GIT_PASSWORD}@github.com/maidsafe/jenkins_sample_lib.git --tags
            """)
        }
    }
}
