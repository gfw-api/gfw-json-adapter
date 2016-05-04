FROM ruby:2.3.0
RUN apt-get update -qq && apt-get install -y build-essential nodejs npm nodejs-legacy postgresql-client

RUN mkdir /gfw-adapter-json

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

ADD . /gfw-adapter-json

WORKDIR /gfw-adapter-json

EXPOSE 3000

ENTRYPOINT ["./entrypoint.sh"]
