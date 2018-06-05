Valley Library Room Reservation System
============================
[![Build Status](https://travis-ci.org/osulp/Room-Reservation.png)](https://travis-ci.org/osulp/Room-Reservation)
[![Coverage Status](https://coveralls.io/repos/osulp/Room-Reservation/badge.png?branch=develop)](https://coveralls.io/r/osulp/Room-Reservation?branch=develop)

This repository contains the source code for the Room Reservation system which will be in use at the Oregon State
University Libraries & Press' Valley Library.

Status
----------------------------
This application is in active development and not ready for use in production.

Usage Outside OSU L&P
----------------------------
Currently this system relies upon a variety of systems only in use at OSU's Valley Library. The assumptions made
are as follows:

* There is an external database containing information regarding when the library is open.
* Logins are managed via a CAS (Central Authentication Service.)
* There is extra information regarding users stored in an external database, which can be accessed via their username.
  *  This database stores encrypted student ID numbers.

Work towards generalizing these assumptions may be done at a later date. Pull requests accepted.

Caching
----------------------------
This application makes heavy use of caching via memcached for available times. However, it should be fast enough
without the caching for general use. Implementing caching requires the following:

* Memcached running locally
* A database server which supports sub-second timestamps.
  * Required to avoid race conditions in which two records are updated at the same time.
  * Currently we use MariaDB 5.5 for this. Postgresql should also work.
  
## Development Setup using Docker ##

### 1. Install Notes using Docker ###

* Disable gems: 
  - `unicorn`
  - `capistrano`
  - `sprockets-digest-assets-fix`
  - `guard`
  - `guard-rspec`
  - `better_errors`
  - `debugger2`
  - `pry`
  - `pry-byebug`
* Add gem eventmachine: 
  - `gem 'eventmachine', :git => 'git://github.com/eventmachine/eventmachine.git', :branch => 'master'`
* Set mysql2 gem to: 
  - `gem 'mysql2', '~> 0.3.20'`
* Set jquery-ui-rails gem to: 
  - `gem 'jquery-ui-rails', '~>4.2'`

### 2. Update sidekiq initializer and set redis url to `redis://redis:6379`
`config/initializers/sidekiq.rb`:
```
Sidekiq.configure_server do |config|
  config.redis = {:url => 'redis://redis:6379',:namespace => "roomreservation"}
end

Sidekiq.configure_client do |config|
  config.redis = {:url => 'redis://redis:6379',:namespace => "roomreservation"}
end
```

### 2. Build and install

```
cp docker-compose.override.example.yml docker-compose.override.yml
docker-compose build
docker-compose up
```

### 3. Run rake tasks in the libraryfind_web container ###

Run db migrations 
```
docker-compose rub web bash
> RAILS_ENV=development bundle exec rake db:create
> RAILS_ENV=development bundle exec rake db:migrate
```
