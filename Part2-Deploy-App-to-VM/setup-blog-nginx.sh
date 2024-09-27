#!/bin/bash

# Update package list and install Docker
echo "Updating package list and installing Docker..."
if [ -f /etc/debian_version ]; then
    sudo apt update -y
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
elif [ -f /etc/redhat-release ]; then
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Create a directory for the blog project
echo "Creating project directory..."
mkdir -p /opt/nginx-blog
cd /opt/nginx-blog

# Create the blog HTML file
echo "Creating blog.html..."
cat <<EOL > blog.html
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
        img {
            max-width: 100%;
            height: auto;
            display: block;
            margin: 20px auto;
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
EOL


# Copy the image to the default Nginx web directory
cp my-dog.jpg /usr/share/nginx/html/my-dog.jpg

# Adjust permissions for the web directory
echo "Setting file permissions..."
sudo chown -R www-data:www-data /var/www/html/blog
sudo chmod -R 755 /var/www/html/blog

# Enable the new site and disable the default site
sudo ln -s /etc/nginx/sites-available/blog /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Test Nginx configuration and restart the service
echo "Testing Nginx configuration..."
sudo nginx -t && sudo systemctl restart nginx

echo "Blog setup complete! Access it at http://<your_server_ip>:8080"