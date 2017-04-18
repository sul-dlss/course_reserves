node {
  env.RAILS_ENV = 'test'
  stage('Build') {
    checkout scm

    sh '''#!/bin/bash -l
    rvm use 2.2.4@course_reserves --create
    gem install bundler
    bundle install --without mysql
    bundle exec rake db:drop
    bundle exec rake db:migrate
    '''
  }

  stage('Test') {
    sh '''#!/bin/bash -l
    rvm use 2.2.4@course_reserves
    exit 1
    '''
  }
}
