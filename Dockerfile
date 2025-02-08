# Use the official Ruby image based on Alpine Linux
FROM ruby:3.1-alpine

# Install build tools (in case native extensions are needed)
RUN apk add --no-cache build-base

# Set the working directory inside the container
WORKDIR /app

# Copy the entire repository into the container
COPY . .

# (Optional) If your project uses Bundler and you have a Gemfile, you could install dependencies:
# RUN bundle install --deployment --without development test

# Expose the port your app listens on (adjust if necessary)
EXPOSE 9292

# Set environment variable (adjust if needed)
ENV RACK_ENV=production

# Start the Rack server; if your app uses a config.ru file, this will work
CMD ["rackup", "--host", "0.0.0.0", "--port", "9292"]
