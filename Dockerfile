FROM truemail/truemail-rack

# Set working directory
WORKDIR /app

# Install dependencies
RUN bundle install

# Expose the correct port
EXPOSE 9292

# Start the server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
