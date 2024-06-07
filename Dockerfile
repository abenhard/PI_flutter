# Use the base image with a Dart version >= 3.2.3
FROM cirrusci/flutter:latest

# Set the working directory
WORKDIR /app/pi

# Create a non-root user
RUN adduser --disabled-password --gecos "" appuser

# Copy the project files into the container
COPY pi /app/pi

# Change ownership of the Flutter SDK and the app directory
RUN chown -R appuser:appuser /sdks/flutter /app

# Switch to the non-root user
USER appuser

# Run flutter pub get to install dependencies
RUN flutter pub get

# Expose the necessary ports
EXPOSE 8080

# Start the Flutter app
CMD ["flutter", "run", "--web-server"]
