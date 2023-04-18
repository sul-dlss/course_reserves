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
1. [Download course data XML](https://consul.stanford.edu/display/SYSTEMS/Registry+Course+Harvesting)
2. Move files to `/lib/course_work_xml/`
3. Restart the rails server

## Testing

Run all the tests
  ```
  $ bin/rake
  ```
