<!-- Overview -->
# Overview
Deploy blog to Google Compute Instance 

<!-- Task1 -->
## Deploy infrastructure
1. Clone repo with config code
  ```sh
git clone https://github.com/agapasieka/Deploy-Reliable-Infrastructure.git
  ```

2. Change directory 
  ```sh
  cd Deploy-Reliable-Infrastructure/Part2-Deploy-App-to-VM
  ```

3. Initialise Terraform and apply ther configuration 
  ```sh
  terraform init
  terraform apply -auro-approve
  ``` 
You will be prompted to enter Project ID. 

When deployment completes, terraform outputs the external IP of our blog server. You can test the blog in browser by typing the IP or use the curl command
  ```sh
  curl -s http://EXTERNAL_IP | awk -F'<h1>|</h1>' '/<h1>/ {print $2}'
  ```

<!-- Task3 -->
## Lab Clean-up
  ```sh
  terraform destroy
  ```

## The End
