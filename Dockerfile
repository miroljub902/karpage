FROM ruby:2.3.1

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
      apt-key add -

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && apt-get install -qq -y --fix-missing --no-install-recommends \
  build-essential \
  git \
  nodejs \
  postgresql-client-9.6

# Set an environment variable to store where the app is installed to inside
# of the Docker image.
ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

# Ensure gems are cached and only get updated when they change. This will
# drastically increase build times when your gems do not change.
#COPY Gemfile Gemfile

ADD Gemfile* $INSTALL_PATH/

ENV BUNDLE_GEMFILE=$INSTALL_PATH/Gemfile \
    BUNDLE_JOBS=2 \
    BUNDLE_PATH=/bundle

RUN bundle install

# Copy in the application code from your work station at the current directory
# over to the working directory.
COPY . .

# Expose a volume so that nginx will be able to read in assets in production.
VOLUME ["$INSTALL_PATH/public"]

# Start with remote debugging
CMD rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 -- bin/rails s -b 0.0.0.0 -p 3000
