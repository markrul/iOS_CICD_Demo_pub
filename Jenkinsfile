pipeline {
    agent any
    
    environment {
        // 项目相关配置
        PROJECT_DIR = 'CICD_iOS'
        WORKSPACE_FILE = 'CICD_iOS.xcworkspace'
        SCHEME_NAME = 'CICD_iOS'
        CONFIGURATION = 'Release'
        SDK = 'iphoneos'
    }
    
    stages {
        stage('检查环境') {
            steps {
                echo '检查Xcode和必要工具版本'
                sh 'xcodebuild -version'
                sh 'pod --version || echo "CocoaPods未安装"'
            }
        }
        
        stage('安装依赖') {
            steps {
                echo '安装项目依赖'
                dir("${PROJECT_DIR}") {
                    sh 'pod install --repo-update'
                }
            }
        }
        
        stage('构建') {
            steps {
                echo '构建iOS应用'
                dir("${PROJECT_DIR}") {
                    sh '''
                    xcodebuild \
                        -workspace ${WORKSPACE_FILE} \
                        -scheme ${SCHEME_NAME} \
                        -configuration ${CONFIGURATION} \
                        -sdk ${SDK} \
                        -derivedDataPath build \
                        CODE_SIGN_IDENTITY="" \
                        CODE_SIGNING_REQUIRED=NO \
                        CODE_SIGNING_ALLOWED=NO
                    '''
                }
            }
        }
        
        stage('运行测试') {
            steps {
                echo '运行单元测试'
                dir("${PROJECT_DIR}") {
                    sh '''
                    xcodebuild \
                        -workspace ${WORKSPACE_FILE} \
                        -scheme ${SCHEME_NAME} \
                        -configuration ${CONFIGURATION} \
                        -sdk ${SDK} \
                        -only-testing:CICD_iOSTests \
                        test || true
                    '''
                }
            }
        }
        
        stage('归档构建产物') {
            steps {
                echo '归档构建产物'
                archiveArtifacts artifacts: "${PROJECT_DIR}/build/Build/Products/${CONFIGURATION}-${SDK}/${SCHEME_NAME}.app/**/*", fingerprint: true
            }
        }
    }
    
    post {
        success {
            echo '构建成功！'
        }
        failure {
            echo '构建失败！'
        }
        always {
            echo '清理工作空间'
            cleanWs(cleanWhenNotBuilt: false, 
                   deleteDirs: true, 
                   disableDeferredWipeout: true, 
                   notFailBuild: true)
        }
    }
}