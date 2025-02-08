# Use an official Ruby image
FROM ruby:3.2-slim

# Install build tools (adjust if you need additional packages)
RUN apt-get update -qq && apt-get install -y build-essential

# Install the Truemail gem
RUN gem install truemail --no-document

# Set working directory
WORKDIR /app

# Option 1: Using a config.ru file
COPY config.ru /app/config.ru
EXPOSE 9292
CMD ["rackup", "-p", "9292", "--env", "production"]

# Option 2: Using the truemail executable (if available)
# Uncomment the following lines and comment out Option 1 if Truemail provides a server binary:
# EXPOSE 9292
# CMD ["truemail", "server", "-p", "9292", "--env", "production"]
