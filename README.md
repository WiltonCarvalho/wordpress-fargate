# Apache and PHP on Ubuntu 20.04 ready for Wordpress with AWS Secrets Manager
> - Follow the readme/wordpress.txt to install and configure Wordpress <br>
> - Edit the docker-compose.yaml with the environment variables, AWS Profile and the Secrets Manager Name <br>
> - Build and Test <br>
```
docker-compose build
docker-compose up
```
> - Create ECR repositories to Apache and PHP <br>
> - Tag the images and push to the ECR <br>
> - Create an EFS file system <br>
> - Create an EFS Access Point and set the directory path with the UID and GID used in the Dockerfiles <br>and with 770 as directory permissions <br>
> - Create a Security Group without any rules and set to the EFS network interfaces <br>
> - Create a RDS database and a database user <br>
> - Store the RDS host, database name, user name and password on a Secrets Manager <br>
> - Follow the readme/aws-ecs-iam-roles.txt to create the required IAM roles for the ECS Tasks <br>
> - Create a Security Group for the ECS Service allowing connection the ports 80, 443 and 8080 <br>
> - Create a rule on the RDS Security Group Allowing the ECS Security Group as source to connect to the RDS <br>
> - Create a rule on the EFS Security Group Allowing the ECS Security Group as source to connect to the NFS <br>
> - Create an ECS Fargate Task Definition<br>
> --> Configure containers to Apache - port 8080, and PHP - no port <br>
> --> Set the EFS as volumes to both containers <br>
> --> Configure the database environment variables on the PHP container if needed <br>
