# Test the blog website using a Docker container

## Step 1: Create the Blog HTML File

1. Create a directory for your project
   ```
   mkdir nginx-blog
   cd nginx-blog
   ```
2. Create the blog.html file
   ```
   nano blog.html
   ```
3. Add the following HTML content
   ```
      <!DOCTYPE html>
   <html>
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>My Blog Page</title>
       <style>
           body {
               font-family: Arial, sans-serif;
               margin: 40px;
               background-color: #f4f4f9;
               color: #333;
           }
           header {
               text-align: center;
               margin-bottom: 40px;
           }
           article {
               max-width: 800px;
               margin: 0 auto;
               padding: 20px;
               background-color: #fff;
               box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
           }
           h1 {
               color: #3b5998;
           }
           footer {
               text-align: center;
               margin-top: 40px;
               font-size: 0.8em;
           }
       </style>
   </head>
   <body>
       <header>
           <h1>Welcome to My Blog</h1>
       </header>
       <article>
           <h2>First Blog Post</h2>
           <p>This is a sample blog post content. Here, you can write about anything you like. This is a simple HTML template to help you get started with your Nginx web server.</p>
           <h2>Second Blog Post</h2>
           <p>This is a second blog post content, where I have added my dog's photo.</p>
           <img src="my-dog.jpg" alt="Blog Image" style="max-width:80%; height:auto; display:block; margin: 20px auto;">
       </article>
       <footer>
           &copy; 2024 My Blog
       </footer>
   </body>
   </html>       
   ```
4. Save and close the file (CTRL + X, then Y, and ENTER)

## Step 2. Create a Dockerfile
1. Create a Dockerfile in the same directory
   ```
   nano Dockerfile
   ```
2. Add the following content to the Dockerfile
   ```
    # Use the official Nginx image from Docker Hub
   FROM nginx:latest

    # Copy the blog.html to the default Nginx web directory
   COPY blog.html /usr/share/nginx/html/index.html
   ```
This Dockerfile uses the official Nginx image and copies your blog.html file into the container's default web directory, renaming it to index.html so that it is served as the home page.

## Step 3: Build and Run the Docker Container

1. Build the Docker image
   ```
   docker build -t nginx-blog .
   ```
2. Run the Docker container
   ```
   docker run -d -p 8080:80 --name nginx-blog-container nginx-blog
   ```

## Step 4: Test the Blog Page

  Open your web browser and go to
   ```
   http://localhost:8080
   ```

## Step 5: Delete continer
   ```
   docker rm -f nginx-blog-container
   ```

After testing our website code, we will create and test a startup script using the same html code. This script will be later used to deploy our blog on Google Compute Engine (GCE)
## Step 6: Setup and test startup script
setup-blog-nginx.sh
    ```
    #!/bin/bash

    # Update package list and install Nginx
    echo "Updating package list and installing Nginx..."
    if [ -f /etc/debian_version ]; then
        apt update -y && apt install -y nginx
    elif [ -f /etc/redhat-release ]; then
        yum update -y && yum install -y nginx
    fi

    # Create project directory and blog HTML file
    echo "Setting up the blog directory and HTML file..."
    mkdir -p /usr/share/nginx/html
    cat <<EOL > /usr/share/nginx/html/blog.html
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>My Blog Page</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f4f9; color: #333; }
            header { text-align: center; margin-bottom: 40px; }
            article { max-width: 800px; margin: 0 auto; padding: 20px; background-color: #fff; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); }
            h1 { color: #3b5998; }
            footer { text-align: center; margin-top: 40px; font-size: 0.8em; }
            img { max-width: 100%; height: auto; display: block; margin: 20px auto; }
        </style>
    </head>
    <body>
        <header><h1>Welcome to My Blog</h1></header>
        <article>
            <h2>First Blog Post</h2>
            <p>This is a sample blog post content.</p>
            <h2>Second Blog Post</h2>
            <p>This is a second blog post content, where I have added my dog's photo.</p>
            <img src="my-dog.jpg" alt="Blog Image" style="max-width:80%; height:auto; display:block; margin: 20px auto;">
        </article>
        <footer>&copy; 2024 My Blog</footer>
    </body>
    </html>
    EOL

    # Copy the image to Nginx web directory
    echo "Copying image to Nginx directory..."
    cp /temp/my-dog.jpg /usr/share/nginx/html/my-dog.jpg || { echo "Image not found. Please make sure '/temp/my-dog.jpg' exists."; exit 1; }

    # Set permissions for Nginx web directory
    echo "Setting permissions..."
    chown -R www-data:www-data /usr/share/nginx/html
    chmod -R 755 /usr/share/nginx/html

    # Configure Nginx to serve the blog page
    echo "Configuring Nginx..."
    cat <<EOF > /etc/nginx/sites-available/blog
    server {
        listen 80;
        server_name _;
        root /usr/share/nginx/html;
        index blog.html;
        location / {
            try_files \$uri \$uri/ =404;
        }
    }
    EOF

    # Enable the blog configuration
    ln -sf /etc/nginx/sites-available/blog /etc/nginx/sites-enabled/blog
    rm -f /etc/nginx/sites-enabled/default

    # Test and restart Nginx
    echo "Testing Nginx configuration..."
    nginx -t && systemctl restart nginx || service nginx restart

    echo "Blog setup complete! Access it at http://<your_server_ip>"
    ```
The script can be run on Debian-based systems like Ubuntu and Debian itself and Red Hat-based distributions like CentOS, Red Hat Enterprise Linux (RHEL), and older versions of Fedora.
1. Save the script into the same directory as your blog.html and my-dog.jpg image.
2. Run the following command to run and execute Debian container. 
    ```
    docker run -p 8080:80 -v $(pwd):/temp/ -it debian:latest /bin/bash
    ```
    This command also mounts the local directory with the script and exposes port 8080 on the Docker Host so we can test it in browser.
3. Inside the container access the mounted directory and run the script
    ```
    cd temp/
    chmod u+x setup-blog-nginx.sh   # Make script executable
    ./setup-blog-nginx.sh
    ```
4. Once the script finishes, head over to your browser and type: 
    ```
    localhost:8080
    ```

## The End


