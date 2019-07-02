stage('build & test') {
    node('windows') {
        checkout(scm)
        sh("cargo test")
    }
}

stage('deploy') {
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
            git config --local credential.helper "!f() { echo username=\$GIT_USER; echo password=\\$GIT_PASSWORD; }; f"
            git push origin HEAD:${BRANCH_NAME}
        """)
    }
}
