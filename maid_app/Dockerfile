# Stage 1: Build the Flutter application
# We use a Flutter image that already has the Flutter SDK to build the project.
FROM cirrusci/flutter:latest as build

# Move to the /app folder
WORKDIR /app

# Copy the pubspec.* files and get dependencies first to use Docker's cache.
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of the project files.
COPY . .

# Build the Flutter web app.
# The result will be in /app/build/web
RUN flutter build web --release

# Stage 2: Serve the built files with Nginx
# We use a small web server (Nginx) to display the built web page.
FROM nginx:alpine

# Copy the built web files from Stage 1 to Nginx's folder.
COPY --from=build /app/build/web /usr/share/nginx/html

# Tell the container to open port 80 to receive traffic.
EXPOSE 80

# The command to run Nginx when the container starts.
CMD ["nginx", "-g", "daemon off;"]