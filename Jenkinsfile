// Pipeline: GitHub -> Build -> Test -> Package -> Deploy (local Ubuntu) -> Smoke test
// The Azure/SSH deploy version is kept in Jenkinsfile.azure
pipeline {
    agent any
    options { timestamps(); timeout(time: 20, unit: 'MINUTES') }
    triggers { pollSCM('H/2 * * * *') }
    environment { APP_DIR = "${HOME}/webapp-deploy" }
    stages {
        stage('Checkout') {
            steps { checkout scm; sh 'git log -1 --pretty="Commit: %h by %an - %s"' }
        }
        stage('Build') {
            steps {
                sh '''
                    cd app
                    python3 -m venv .venv
                    . .venv/bin/activate
                    pip install --quiet --upgrade pip
                    pip install --quiet -r requirements.txt
                '''
            }
        }
        stage('Test') {
            steps {
                sh '''
                    cd app
                    . .venv/bin/activate
                    pytest -v --junitxml=../report.xml
                '''
            }
            post { always { junit allowEmptyResults: true, testResults: 'report.xml' } }
        }
        stage('Package') {
            steps {
                sh '''
                    SHORT_SHA=$(git rev-parse --short HEAD)
                    echo "build-${BUILD_NUMBER} (${SHORT_SHA})" > app/VERSION
                    cat app/VERSION
                '''
            }
        }
        stage('Deploy') {
            steps {
                sh '''
                    mkdir -p "$APP_DIR"
                    rsync -a --delete --exclude '.venv' --exclude 'venv' --exclude '__pycache__' --exclude '.pytest_cache' --exclude 'app.pid' --exclude 'app.log' app/ "$APP_DIR/"
                    cd "$APP_DIR"
                    python3 -m venv venv
                    ./venv/bin/pip install --quiet -r requirements.txt
                    if [ -f app.pid ]; then kill $(cat app.pid) 2>/dev/null || true; sleep 1; fi
                    BUILD_ID=dontKillMe JENKINS_NODE_COOKIE=dontKillMe \
                      nohup ./venv/bin/gunicorn -b 0.0.0.0:5000 app:app > app.log 2>&1 &
                    echo $! > app.pid
                '''
            }
        }
        stage('Smoke Test') {
            steps { sh 'curl --fail --silent --show-error --retry 10 --retry-delay 3 --retry-connrefused http://localhost:5000/health' }
        }
    }
    post {
        success { echo 'Deployed. Open http://localhost:5000' }
        failure { echo 'Pipeline failed. Check the stage logs.' }
    }
}
