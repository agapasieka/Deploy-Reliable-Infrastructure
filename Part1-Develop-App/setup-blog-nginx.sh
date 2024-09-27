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
