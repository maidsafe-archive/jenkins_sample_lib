stage('build') {
    node('windows') {
        checkout(scm)
        sh("cargo build")
    }
}

stage('test') {
    node('windows') {
        sh("cargo test")
    }
}
