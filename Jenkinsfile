pipeline {
  agent any

  options {
    timestamps()
    skipDefaultCheckout(true)
  }

  environment {
    APP_USER = 'www-data'
    APP_GROUP = 'www-data'

    WEBAPP_DOMAIN = 'webapp.igorglushkov.ru'
    ADMINAPP_DOMAIN = 'adminapp.igorglushkov.ru'

    WEBAPP_TARGET_DIR = '/var/www/webapp.igorglushkov.ru/current'
    ADMINAPP_TARGET_DIR = '/var/www/adminapp.igorglushkov.ru/current'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Setup Flutter SDK') {
      steps {
        sh '''
          set -eux
          FLUTTER_HOME="${WORKSPACE}/.flutter-sdk"
          FLUTTER_BIN="${FLUTTER_HOME}/bin/flutter"
          DART_BIN="${FLUTTER_HOME}/bin/dart"

          if [ ! -x "${FLUTTER_BIN}" ]; then
            rm -rf "${FLUTTER_HOME}"
            git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "${FLUTTER_HOME}"
          fi

          "${FLUTTER_BIN}" --version
          "${FLUTTER_BIN}" config --enable-web
          "${FLUTTER_BIN}" precache --web
          "${DART_BIN}" --version
        '''
      }
    }

    stage('Install dependencies') {
      steps {
        sh '''
          set -eux
          DART_BIN="${WORKSPACE}/.flutter-sdk/bin/dart"
          "${DART_BIN}" pub get
        '''
      }
    }

    stage('Build client app') {
      steps {
        dir('apps/client_app') {
          sh '''
            set -eux
            FLUTTER_BIN="${WORKSPACE}/.flutter-sdk/bin/flutter"
            "${FLUTTER_BIN}" build web --release --no-tree-shake-icons --output="${WORKSPACE}/build/client_app"
          '''
        }
      }
    }

    stage('Build admin app') {
      steps {
        dir('apps/admin_panel') {
          sh '''
            set -eux
            FLUTTER_BIN="${WORKSPACE}/.flutter-sdk/bin/flutter"
            "${FLUTTER_BIN}" build web --release --no-tree-shake-icons --output="${WORKSPACE}/build/admin_panel"
          '''
        }
      }
    }

    stage('Deploy to server') {
      steps {
        sshagent(credentials: ['prod-server-ssh']) {
          sh '''
            set -eux

            ./scripts/deploy_flutter_web.sh \
              --host "${DEPLOY_HOST}" \
              --user "${DEPLOY_USER}" \
              --source "build/client_app" \
              --target "${WEBAPP_TARGET_DIR}" \
              --owner "${APP_USER}:${APP_GROUP}"

            ./scripts/deploy_flutter_web.sh \
              --host "${DEPLOY_HOST}" \
              --user "${DEPLOY_USER}" \
              --source "build/admin_panel" \
              --target "${ADMINAPP_TARGET_DIR}" \
              --owner "${APP_USER}:${APP_GROUP}"

            ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} 'sudo nginx -t && sudo systemctl reload nginx'
          '''
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'build/**', allowEmptyArchive: true
    }
  }
}
