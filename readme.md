## DevOps Project 🧑‍💻

*Hugo Lhernould - Johannes Houenou - Axel Lanyan - Arouna Kanoke - Mehdi Mahoudi - Nicolas Speich*

### For AWS deployment 👊🏼

#### 0 - Necessary dependencies ✌️

 - Terraform CLI
 - AWS CLI

#### 1 - Configure yours AWS credidentials 🚗

 - Log on your AWS account
 - Make sur to be in `eu-west-3` region
 - Create **EC2 Key Pair** and download it, put it at the root of your project directory
 - Configure Security group with the following rules: 

    `Custom TCP with PORT 8080`
    `Custom TCP with port 8081`
    `SSH with port 22 and your IP`

 - Configure your AWS CLI

#### 2 - Run Terraform 🏃‍♂️

 - First, run `terraform init`
 - Secondly, run `terraform apply`
 - You have to enter the name of your keys file
 - You have to enter the path of your keys file 
**(THE FILE MUST BE IN ROOT FOLDER)**

 - Wait for deployement

 ⚠️ *The region is eu-west-3 for the AMI image, don't chnage that*

#### 3 - How to access the app 🏠

 - **Spark App**
    - Go to your `MySparkInstance`
    - Get your **Public IPv4 DNS**
    - Get to `http://<SPARK-IP>:8080` and no `https` ⚠️

 - **Mongo UI App**
    - Go to your `MyMongoInstance`
    - Get your **Public IPv4 DNS**
    - Get to `http://<MONGO-IP>:8081` and no `https` ⚠️
    - User: `admin` and password: `password`
