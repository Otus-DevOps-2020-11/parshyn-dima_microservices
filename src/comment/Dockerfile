FROM ruby:2.4-alpine3.7
RUN apk --no-cache --update add build-base

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
COPY . $APP_HOME

RUN bundle update --bundler && \
    bundle install && \
    apk del build-base

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
