# Use an official Ruby image – you can adjust the Ruby version if needed.
FROM ruby:3.2-slim

# Install system packages (if you need any additional ones, add them here)
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# Install the Truemail gem (this installs the Truemail server)
RUN gem install truemail --no-document

# Set the working directory
WORKDIR /app

# Copy the Rack configuration file (see below)
COPY config.ru /app/config.ru

# Expose the port that Truemail’s Rack server listens on
EXPOSE 9292

# Run the Truemail server using rackup
CMD ["rackup", "-p", "9292", "--env", "production"]
