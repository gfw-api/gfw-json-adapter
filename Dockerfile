FROM ruby:2.3.0
RUN apt-get update -qq && apt-get install -y build-essential nodejs npm nodejs-legacy postgresql-client

RUN mkdir /gfw-json-adapter

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

ADD . /gfw-json-adapter

WORKDIR /gfw-json-adapter

EXPOSE 3000

ENTRYPOINT ["./entrypoint.sh"]
