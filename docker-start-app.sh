#! /bin/sh
rackup faye.ru -s thin -E production &
RAILS_ENV=development bundle exec rake db:create
RAILS_ENV=development bundle exec rake db:migrate
RAILS_ENV=test bundle exec rake db:create
RAILS_ENV=test bundle exec rake db:migrate
rails s -p 3000 -b '0.0.0.0'
