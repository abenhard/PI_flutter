# Use the base image from fischerscode/flutter
FROM fischerscode/flutter:latest

# Set the working directory
WORKDIR /app/pi/

# Copy necessary files excluding Git-related files and directories
COPY . .

# Set permissions for the necessary files
RUN find /app/pi/ -type f -not -path "/app/pi/.git/*" -not -path "/app/pi/.vscode/*" -exec chmod 644 {} \;
RUN find /app/pi/ -type d -not -path "/app/pi/.git/*" -not -path "/app/pi/.vscode/*" -exec chmod 755 {} \;

# Navigate to the appropriate directory
WORKDIR /app/pi/pi

# Install dependencies
RUN flutter pub get

# Expose the necessary ports
EXPOSE 8080

# Start the Flutter app on the specified emulator
CMD ["flutter", "run", "-d", "emulator-5554"]
