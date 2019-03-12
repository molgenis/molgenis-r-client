pipeline {
    agent {
        kubernetes {
            label 'r-3.5.2'
        }
    }
    environment {
        REPOSITORY = 'molgenis/molgenis-r-client'
        REGISTRY = 'https://registry.molgenis.org/repository/r-hosted'
    }
    stages {
        stage('Prepare') {
            when {
                not {
                    changelog 'Increment version number'
                }
            }
            steps {
                container('vault') {
                    script {
                        env.GITHUB_TOKEN = sh(script: 'vault read -field=value secret/ops/token/github', returnStdout: true)
                        env.CODECOV_TOKEN = sh(script: 'vault read -field=molgenis-r-client secret/ops/token/codecov', returnStdout: true)
                        env.NEXUS_USER = sh(script: 'vault read -field=username secret/ops/account/nexus', returnStdout: true)
                        env.NEXUS_PASS = sh(script: 'vault read -field=password secret/ops/account/nexus', returnStdout: true)
                    }
                }
                script {
                    env.GIT_COMMIT = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                }
                script {
                    env.PACKAGE = sh(script: "grep Package DESCRIPTION | head -n1 | cut -d':' -f2", returnStdout: true).trim()
                }
                sh "git remote set-url origin https://${GITHUB_TOKEN}@github.com/${REPOSITORY}.git"
                sh "git fetch --tags"
                container('r') {
                    sh "Rscript -e \"git2r::config(user.email = 'molgenis+ci@gmail.com', user.name = 'MOLGENIS Jenkins')\""
                    sh "Rscript -e \"install.packages(c('rjson','ff','httptest','usethis'), repos='https://registry.molgenis.org/repository/R')\""
                }
            }
        }
        stage('Install and test: [ PR ]') {
            when {
                changeRequest()
            }
            steps {
                container('r') {
                    script {
                        env.TAG = sh(script: "grep Version DESCRIPTION | head -n1 | cut -d':' -f2", returnStdout: true).trim()
                    }
                    sh "R CMD build ."
                    sh "R CMD check ${PACKAGE}_${TAG}.tar.gz"
                }
            }
            post {
                always {
                    container('r') {
                        sh "Rscript -e 'library(covr);codecov()'"
                    }
                }
            }
        }
        stage('Install and test: [ master ]') {
            when {
                allOf {
                    branch("master")
                    not {
                        changelog 'Increment version number'
                    }
                }
            }
            steps {
                container('r') {
                    sh "Rscript -e \"usethis::use_version('dev')\""
                    script {
                        env.TAG = sh(script: "grep Version DESCRIPTION | head -n1 | cut -d':' -f2", returnStdout: true).trim()
                    }
                    sh "echo 'Building ${PACKAGE} v${TAG}'"
                    sh "R CMD build ."
                    sh "R CMD check ${PACKAGE}_${TAG}.tar.gz"
                }
            }
            post {
                always {
                    container('r') {
                        sh "Rscript -e 'library(covr);codecov()'"
                    }
                }
            }
        }
        stage('Release dev: [master]'){
            when {
                allOf {
                    branch("master")
                    not {
                        changelog 'Increment version number'
                    }
                }
            }
            steps {
                container('curl') {
                    sh "curl -v --user '${NEXUS_USER}:${NEXUS_PASS}' --upload-file ${PACKAGE}_${TAG}.tar.gz ${REGISTRY}/src/contrib/${PACKAGE}_${TAG}.tar.gz"
                }
                sh "git tag v${TAG}"
                sh "git push --tags origin master"
            }
        }
        stage('Release: [ master ]') {
            when {
                allOf {
                    branch("master")
                    not {
                        changelog 'Increment version number'
                    }
                }
            }
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    script {
                        env.RELEASE_SCOPE = input(
                                message: 'Do you want to release?',
                                ok: 'Release',
                                parameters: [
                                        choice(choices: 'patch\nminor\nmajor', description: '', name: 'RELEASE_SCOPE')
                                ]
                        )
                    }
                }
                milestone 2
                sh "git diff"
                container('r') {
                    sh "Rscript -e \"usethis::use_version('${RELEASE_SCOPE}')\""
                    script {
                        env.TAG = sh(script: "grep Version DESCRIPTION | head -n1 | cut -d':' -f2", returnStdout: true).trim()
                    }
                    sh "echo \"Releasing ${PACKAGE} v${TAG}\""
                    sh "R CMD build ."
                    sh "R CMD check ${PACKAGE}_${TAG}.tar.gz"
                    container('curl') {
                        sh "curl -v --user '${NEXUS_USER}:${NEXUS_PASS}' --upload-file ${PACKAGE}_${TAG}.tar.gz ${REGISTRY}/src/contrib/${PACKAGE}_${TAG}.tar.gz"
                    }
                    sh "git tag v${TAG}"
                    sh "git push --tags origin master"
                }
            }
            post {
                success {
                    slackSend(channel: '#releases', color: '#00FF00', message: ":confetti_ball: Released ${PACKAGE} v${TAG}. See https://github.com/${REPOSITORY}/releases/tag/v${TAG}")
                }
            }
        }
    }
}
