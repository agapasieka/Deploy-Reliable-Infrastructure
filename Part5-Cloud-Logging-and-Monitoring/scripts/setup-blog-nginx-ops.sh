#!/bin/bash
## Webserver Steps ##

# Fetch the project ID 
PROJECT_ID=$(gcloud config get-value project)
# Fetch the bucket name
BUCKET=$PROJECT_ID-bucket

# Update package list and install Nginx and Google Cloud SDK
echo "Updating package list and installing Nginx and Google Cloud SDK..."
if [ -f /etc/debian_version ]; then
    sudo apt update -y && sudo apt install -y nginx google-cloud-sdk
elif [ -f /etc/redhat-release ]; then
    sudo yum update -y && sudo yum install -y nginx google-cloud-sdk
fi

# Create the web directory if it doesn't exist
echo "Setting up the Nginx HTML directory..."
sudo mkdir -p /usr/share/nginx/html

# Set permissions for the Nginx web directory
echo "Setting permissions..."
sudo chown -R www-data:www-data /usr/share/nginx/html
sudo chmod -R 755 /usr/share/nginx/html

# Change directory to the Nginx web directory
cd /usr/share/nginx/html

# Copy the blog.html and image from GCS bucket to the Nginx web directory
echo "Copying blog.html and image from GCS bucket to Nginx directory..."
sudo gsutil cp -r gs://$BUCKET/blog.html ./blog.html 
sudo gsutil cp -r gs://$BUCKET/my-dog.jpg ./my-dog.jpg 


# Ensure that the copied files have the correct permissions
sudo chmod 644 /usr/share/nginx/html/blog.html
sudo chmod 644 /usr/share/nginx/html/my-dog.jpg

# Remove the default Nginx configuration if it exists
sudo rm -f /etc/nginx/sites-enabled/default

# Configure Nginx to serve the blog page
echo "Configuring Nginx to serve the blog page..."
sudo tee /etc/nginx/sites-available/blog > /dev/null <<EOF
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
sudo ln -sf /etc/nginx/sites-available/blog /etc/nginx/sites-enabled/blog

# Test and restart Nginx
echo "Testing Nginx configuration..."
sudo nginx -t && sudo systemctl restart nginx || sudo service nginx restart

# Create status.conf in Nginx
sudo tee /etc/nginx/conf.d/status.conf > /dev/null << EOF
server {
   listen 80;
   server_name 127.0.0.1;
   location /nginx_status {
       stub_status on;
       access_log off;
       allow 127.0.0.1;
       deny all;
   }
   location / {
       root /usr/share/nginx/html;
       index blog.html;
   }
}
EOF

# Nginx reload
sudo systemctl reload nginx || sudo service nginx reload


echo "Blog setup complete! Access it at http://<your_server_ip>"


# Wait to ensure the webserver setup has completed
sleep 10


## OPS Agent steps ##

# Install Ops Agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

# Backup existing config.yaml file
sudo cp /etc/google-cloud-ops-agent/config.yaml /etc/google-cloud-ops-agent/config.yaml.bak

# Write the Ops Agent configuration for Nginx logs
sudo tee /etc/google-cloud-ops-agent/config.yaml > /dev/null << EOF
metrics:
  receivers:
    nginx:
      type: nginx
      stub_status_url: http://127.0.0.1:80/nginx_status
  service:
    pipelines:
      nginx:
        receivers:
          - nginx
logging:
  receivers:
    nginx_access:
      type: nginx_access
    nginx_error:
      type: nginx_error
  service:
    pipelines:
      nginx:
        receivers:
          - nginx_access
          - nginx_error
EOF

# Restart the Ops Agent to apply the new configuration
sudo service google-cloud-ops-agent restart

echo "Ops Agent has been installed"
