# Use an official Ruby image as the base
FROM ruby:3.1-alpine

# Install build dependencies
RUN apk add --no-cache build-base

# Set the working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock first for dependency caching
COPY Gemfile Gemfile.lock ./

# Install gem dependencies (omit development and test groups)
RUN bundle install --deployment --without development test

# Copy the rest of the application code
COPY . .

# Expose port 9292 so Render can route HTTP traffic
EXPOSE 9292

# Set environment variable for production (adjust if needed)
ENV RACK_ENV=production

# Start the Rack server (ensure it binds to 0.0.0.0 so external requests are accepted)
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "9292"]
