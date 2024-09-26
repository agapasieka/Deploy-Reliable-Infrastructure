# Test the blog page using a Docker container

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
           <p>Feel free to modify this page and add more blog posts as needed.</p>
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

# Step 5: Delete continer
   ```
   docker rm -f nginx-blog-container
   ```

## The End


