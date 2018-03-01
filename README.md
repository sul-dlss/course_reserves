# Course Reserves
=========

[![Build Status](https://travis-ci.com/sul-dlss/course_reserves.svg?token=CqUnNp8DCwBNAp6k6tMP&branch=master)](https://travis-ci.com/sul-dlss/course_reserves)

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
  ```
  $ bundle exec rails server
  ```

Start the rails app with an admin user logged in
  ```
  $ REMOTE_USER=test_user WEBAUTH_LDAPPRIVGROUP=sulair:course-resv-admins bundle exec rails server
  ```

See consul for information on [sample course data](https://consul.stanford.edu/display/SYSTEMS/Registry+Course+Harvesting)

## Testing

Run all the tests
  ```
  $ bundle exec rake
  ```
