properties([
    parameters([
        string(name: 'ARTIFACTS_BUCKET', defaultValue: 'safe-jenkins-build-artifacts'),
        string(name: 'BRANCH_NAME', defaultValue: 'master')
    ])
])

stage('build & test') {
    parallel linux: {
        node('docker') {
            checkout(scm)
            sh("make test")
            packageBuildArtifacts('linux')
            uploadBuildArtifacts()
        }
    },
    windows: {
        node('windows') {
            checkout(scm)
            sh("make test")
            packageBuildArtifacts('windows')
            uploadBuildArtifacts()
        }
    },
    macos: {
        node('osx') {
            checkout(scm)
            sh("make test")
            packageBuildArtifacts('macos')
            uploadBuildArtifacts()
        }
    }
}

stage('deploy') {
    node('docker') {
        if (params.BRANCH_NAME == "master") {
            checkout(scm)
            retrieveBuildArtifacts()
            if (versionChangeCommit()) {
                withCredentials([string(
                    credentialsId: 'crates_io_token', variable: 'CRATES_IO_TOKEN')]) {
                    sh("make publish")
                }
            }
        }
    }
}

def packageBuildArtifacts(os) {
    withEnv(["JENKINS_SAMPLE_BRANCH=${params.BRANCH_NAME}",
             "JENKINS_SAMPLE_BUILD_NUMBER=${env.BUILD_NUMBER}",
             "JENKINS_SAMPLE_BUILD_OS=${os}"]) {
        sh("make package-build-artifacts")
    }
}

def uploadBuildArtifacts() {
    withAWS(credentials: 'aws_jenkins_build_artifacts_user', region: 'eu-west-2') {
        def artifacts = sh(returnStdout: true, script: 'ls -1 artifacts').trim().split("\\r?\\n")
        for (artifact in artifacts) {
            s3Upload(
                bucket: "${params.ARTIFACTS_BUCKET}",
                file: artifact,
                workingDir: "${env.WORKSPACE}/artifacts",
                acl: 'PublicRead')
        }
    }
}

def retrieveBuildArtifacts() {
    withEnv(["JENKINS_SAMPLE_BRANCH=${params.BRANCH_NAME}",
             "JENKINS_SAMPLE_BUILD_NUMBER=${env.BUILD_NUMBER}"]) {
        sh("make retrieve-all-build-artifacts")
    }
}

def versionChangeCommit() {
    shortCommitHash = sh(
        returnStdout: true,
        script: "git log -n 1 --pretty=format:'%h'").trim()
    message = sh(
        returnStdout: true,
        script: "git log --format=%B -n 1 ${shortCommitHash}").trim()
    return message.startsWith("Version change")
}
