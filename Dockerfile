# Use official Ruby image
FROM ruby:3.2

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# Copy the application code
COPY . .

# Expose port (default for Puma)
EXPOSE 3000

# Run the application
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
