pipeline {
  agent any

  options {
    timestamps()
    skipDefaultCheckout(true)
  }

  environment {
    FLUTTER_BIN = '/opt/flutter/bin/flutter'
    DART_BIN = '/opt/flutter/bin/dart'
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

    stage('Install dependencies') {
      steps {
        sh '''
          set -eux
          ${DART_BIN} pub global activate melos
          ${DART_BIN} pub get
        '''
      }
    }

    stage('Build web apps') {
      steps {
        sh '''
          set -eux
          ${FLUTTER_BIN} --version
          ${FLUTTER_BIN} config --enable-web

          ${FLUTTER_BIN} build web --release --web-renderer canvaskit --no-tree-shake-icons --target=apps/client_app/lib/main.dart --output=build/client_app
          ${FLUTTER_BIN} build web --release --web-renderer canvaskit --no-tree-shake-icons --target=apps/admin_panel/lib/main.dart --output=build/admin_panel
        '''
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
