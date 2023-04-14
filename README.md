# Course Reserves
=========

[![CI](https://github.com/sul-dlss/course_reserves/actions/workflows/ruby.yml/badge.svg)](https://github.com/sul-dlss/course_reserves/actions/workflows/ruby.yml)

[https://searchworks.stanford.edu/reserves](https://searchworks.stanford.edu/reserves)

## Requirements
1. Ruby
2. Rails
3. PhantomJS

## Local Installation
```
  $ bundle install
  $ bundle exec rake db:setup
```

Start the rails app
   There are two methods to starting the rails app.  One is to run this command directly which will take care of some of the extra steps you would have to do otherwise:
  ```
  $ bin/dev
  ```
  OR run the following commands:
  
  ```
  $ yarn install
  $ yarn build:css
  $ bundle exec rails server
  ```

Start the rails app with an admin user logged in
  ```
  $ REMOTE_USER=test_user eduPersonEntitlement=sulair:course-resv-admins bundle exec rails server
  ```

To load sample data:
1. You will need sample course data from the current term or future terms.  Older terms will be ignored.  [For reference, you can see older course data XML here](https://consul.stanford.edu/display/SYSTEMS/Registry+Course+Harvesting)
2. Move files to `/lib/course_work_xml/`
3. Restart the rails server

## Testing

Run all the tests
  ```
  $ bundle exec rake
  ```
