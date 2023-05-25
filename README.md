# Course Reserves
=========

[![CI](https://github.com/sul-dlss/course_reserves/actions/workflows/ruby.yml/badge.svg)](https://github.com/sul-dlss/course_reserves/actions/workflows/ruby.yml)

[https://searchworks.stanford.edu/reserves](https://searchworks.stanford.edu/reserves)

## Requirements
1. Ruby & bundler
2. nodejs & Yarn

## Local Installation
```
  $ bundle install
  $ yarn install
  $ bin/rails db:setup
```

Start the rails app
  ```
  $ bundle exec rails server
  ```

Start the rails app with an admin user logged in
  ```
  $ REMOTE_USER=test_user eduPersonEntitlement=sulair:course-resv-admins bin/dev
  ```

To load sample data:
1. To generate the JSON files under lib/course_work_content, run the "rake fetch_courses" task locally. This process will take a few hours.  Alternatively, you can copy JSON files from "lib/course_work_content" from an existing staging or production system. 
2. Restart the rails server

## Testing

Run all the tests
  ```
  $ bin/rake
  ```
