pipeline {
    agent any

    environment {
        // 하버 주소 (설정한 도메인)
        REGISTRY = 'harbor.local.net'
        // 미리 만들어두신 프로젝트 이름
        PROJECT = 'test'
        // 이미지 이름
        IMAGE_NAME = 'yezzns'
        // 1단계에서 만든 자격증명 ID
        CREDENTIAL_ID = 'harbor-login'

        // SonarQube URL 및 토큰 설정
        SONARQUBE_URL = 'http://192.168.0.204:9000'  // SonarQube 서버 주소
        SONARQUBE_TOKEN = 'sqa_ecde331e39aafd80cb15b8b2d73162017c8bef9a'  // SonarQube에서 생성한 토큰
    }

    stages {
        stage('SCM') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    // SonarQube 분석 실행
                    def scannerHome = tool 'SonarScanner'  // SonarQube Scanner 경로 설정
                    withSonarQubeEnv() {  // SonarQube 환경 설정을 가져옴
                        sh "${scannerHome}/bin/sonar-scanner"  // sonar-scanner 실행
                    }
                }
            }
        }

        stage('Calculate Version') {
            steps {
                script {
                    // 1. 현재 빌드 번호 가져오기
                    def buildNum = currentBuild.number.toInteger()

                    // 2. 0.1을 곱해서 버전 계산 (예: 1 -> v0.1)
                    def verCalc = String.format("%.1f", buildNum * 0.1)

                    // 3. 환경 변수에 저장
                    env.IMAGE_TAG = "v${verCalc}"

                    echo "🎉 이번 빌드 버전은 [ ${env.IMAGE_TAG} ] 입니다."
                }
            }
        }

        stage('Build & Push') {
            steps {
                script {
                    def fullImageName = "${REGISTRY}/${PROJECT}/${IMAGE_NAME}:${env.IMAGE_TAG}"

                    // [수정됨] ./source -> . (점 하나)
                    // 이유: 깃허브 최상위 경로에 Dockerfile이 있기 때문
                    sh "docker build -t ${fullImageName} ."

                    withCredentials([usernamePassword(credentialsId: CREDENTIAL_ID, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        // Docker 로그인
                        sh "docker login ${REGISTRY} -u \$USER -p \$PASS"
                        // Docker 이미지 푸시
                        sh "docker push ${fullImageName}"
                    }

                    echo "✅ 하버 푸쉬 완료: ${fullImageName}"
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    def fullImageName = "${REGISTRY}/${PROJECT}/${IMAGE_NAME}:${env.IMAGE_TAG}"

                    // 기존 컨테이너 삭제 후 재실행
                    sh "docker rm -f my-web-server || true"
                    sh "docker run -d -p 8081:80 --name my-web-server ${fullImageName}"
                }
            }
        }
    }
}

