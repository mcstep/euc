FROM ruby:2.2.2

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update && \
    apt-get install -qy nodejs postgresql-client --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/app  
WORKDIR /usr/src/app

ADD Gemfile /usr/src/app/Gemfile  
ADD Gemfile.lock /usr/src/app/Gemfile.lock  
RUN bundle install --without development test

ADD ./ /usr/src/app
RUN bundle exec rake assets:precompile