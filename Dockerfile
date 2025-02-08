# Use the official Ruby image on Alpine Linux
FROM ruby:3.1-alpine

# Install build dependencies (needed for native extensions)
RUN apk add --no-cache build-base

# Set the working directory
WORKDIR /app

# Copy the application source code into the container.
# (If you use Bundler and have Gemfile and Gemfile.lock, uncomment the two COPY lines below.)
# COPY Gemfile Gemfile.lock ./
# RUN bundle install --deployment --without development test

# If you do not have a Gemfile, simply copy all files.
COPY . .

# Expose the port your app listens on (adjust if needed)
EXPOSE 9292

# Set the environment variable for production
ENV RACK_ENV=production

# Start the Rack server (this assumes your repository includes a config.ru).
# Ensure the command does not exit immediately.
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "9292"]
