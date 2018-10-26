pipeline {
  agent any
  stages {
    stage('JQL Search') {
      parallel {
        stage('Get Issues') {
          steps {
            echo 'Getting Tickets from Jira'
          }
        }
        stage('Validate') {
          steps {
            echo 'Validating File'
          }
        }
      }
    }
    stage('Resolve Ticket') {
      steps {
        echo 'Ticket Resolved'
      }
    }
  }
}