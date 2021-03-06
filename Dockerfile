FROM ruby:2.2.3

RUN apt-get update -qq && apt-get install -y build-essential

# for imageMagick
RUN apt-get install -y imagemagick

# for cronjobs
RUN apt-get install -y cron

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb

# for a JS runtime
RUN apt-get install -y nodejs
RUN gem install foreman

ENV APP_HOME /myapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME

# Prepare assets for production
RUN bundle exec rake assets:precompile

# Create cronjobs based on config/schedule.rb
RUN bundle exec whenever -w
