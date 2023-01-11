# syntax=docker/dockerfile:1
FROM ruby:3.1.3
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /TODO: directory_name
WORKDIR /TODO: directory_name
COPY Gemfile* .ruby-version /TODO: directory_name/
RUN bundle install
COPY . /TODO: directory_name

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]