<!-- Overview -->
# Overview
Deploy Blog to Google Managed Instance Group for reliability and scalability. 

<!-- Task1 -->
## Deploy infrastructure
1. Clone repo with config code
  ```sh
git clone https://github.com/agapasieka/Deploy-Reliable-Infrastructure.git
  ```

2. Change directory 
  ```sh
  cd Deploy-Reliable-Infrastructure/Part3-Deploy-App-to-Mig/
  ```

3. Initialise Terraform and apply ther configuration 
  ```sh
  terraform init
  terraform apply -auro-approve
  ``` 
You will be prompted to enter Project ID.

When deployment completes, terraform outputs the external IP of load balancer. You can test the blog in browser by typing the IP in search bar. 

<!-- Task3 -->
## Lab Clean-up
  ```sh
  terraform destroy
  ```