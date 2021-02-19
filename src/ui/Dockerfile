FROM alpine:latest
RUN apk --no-cache --update add ruby-full && \
    apk --no-cache --update add ruby-dev && \
    apk --no-cache --update add build-base && \
    gem install bundler

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
COPY . $APP_HOME
RUN bundle update --bundler && \
    bundle install && \
    apk del build-base

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
ENV GEM_HOME /usr/lib/ruby/gems/2.7.0

CMD ["puma"]
