# Use an official Ruby image based on Alpine Linux
FROM ruby:3.1-alpine

# Install build dependencies (e.g. for compiling native extensions)
RUN apk add --no-cache build-base

# Set working directory inside the container
WORKDIR /app

# Copy Gemfile only (since Gemfile.lock is missing)
COPY Gemfile ./

# Install gem dependencies (omit development and test groups)
RUN bundle install --deployment --without development test

# Copy the rest of your application code
COPY . .

# Expose the port your app will listen on (9292 is the default for Rack)
EXPOSE 9292

# Set the environment to production (adjust if needed)
ENV RACK_ENV=production

# Start the Rack server, binding to all interfaces
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "9292"]
