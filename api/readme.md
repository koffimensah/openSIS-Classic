

The Development team has written the code and deployed the application locally using binaries. 
Now the Developer is asking devops to deploy the application so that the customer can use it means that the deops is asking the DevOps to containerize the application. Means that the DeOps need to use docker to containerize the application


What is containerizing an application?

Containerizing an application means packaging your application along with its dependencies, libraries, and configurations into a lightweight, portable container using Docker or other containerization tools. This ensures consistency across environments (development, testing, production).

Clone the repo = make a copy of the code on your terminal/locally then study the code folder by folder to understand it.

step by step questions to understand the code.
- on which language the code is written? what are the languages have been used? open each folde/directory and see the extensions to know the languages used
- the language is made for the frontend (what we can see) or the backend (what we cannot see = sensitive information)? 
in this case php is for both frontend and backend.
css is for frontend
pdf are documents for frontend

The database type for the backend.

The number of services = number of containers

FRONTEND = everything without MYSQL
BACKEND = everything without the frontend (database store key-pairs means something = something) 

# Dockerfile
write a Dockerfile to deploy an application written in php language.

CHATGPT: My application is written in php. how can I deploy it using docker?

A Dockerfile is a set of instructions that allow you to build an image 
FROM: use an official image: base image 
RUN: to install or enable or set file permissions
COPY: to copy the application files to the container (COPY . /var/www/htnl/)
WORKDIR: te set a working directory
EXPOSE: to expose the container port (port where the app will run on)
CMD: Command to run the app in the foreground

# Build the image 
docker build -t [Image_Name] .  
(. at the end specifies the current directory where the Dockerfile is located)

# Run the container of the image
docker run -d -p [Port_Mapping] --name [Container_Name] [Image_Name]

# check the image and container
< docker images > wil show you the image name, tag, image ID and the size
< docker ps -a > will show you the container ID, the image, command created, status, port and container names.

the browser read only the frontend. I dont need the database to see the frontend because the frontend only read everything without the backend.

You can see the image on the browser by typing < localhost:80 > 

# deploy database using docker
ex: mysql

docker run -t -p


Script to clean up my docker environment


#!/bin/bash

echo "🛑 Stopping all running containers..."
docker stop $(docker ps -aq)

echo "🗑️ Removing all containers..."
docker rm $(docker ps -aq)

echo "📦 Removing all images..."
docker rmi -f $(docker images -q)

echo "🧹 Removing all volumes..."
docker volume rm $(docker volume ls -q)

echo "🔌 Removing all unused networks..."
docker network prune -f

echo "🔥 Running full system cleanup..."
docker system prune -a --volumes -f

echo "✅ Docker cleanup complete!"


MYSQL DATABASE
Run the Db

MARIADB with port mapping
$ docker run --detach --name opensis-mariadb \
-e MARIADB_ROOT_PASSWORD=mypassword123! \
-v $PWD/MYSQL/mysql-config/strict_mode.cnf:/etc/mysql/conf.d/strict_mode.cnf \
-p 3306:3306 \
-d mariadb:10.5


MYSQL
docker run --name opensis-Db-mysql \
  -e MYSQL_ROOT_PASSWORD=mypassword123! \
  -v $PWD/MYSQL/mysql-config/strict_mode.cnf:/etc/mysql/conf.d/strict_mode.cnf \
  -d mariadb:10.5

I have deployed the frontend and the backend now I will need to log into the database.
The frontend will try to log into the DATABASE means need access to the database.
How to log into the database not inside the container but outside the container?

Step 1: Re-run the Container with Port Mapping
If the container is running, stop it and remove it using this command
" docker stop opensis-Db-mysql && docker rm opensis-Db-mysql "
Then re-run the container with the -p option exposing port 3306
NB MariaDb  -p 3306:3306

docker run --name opensis-Db-mysql \
  -e MYSQL_ROOT_PASSWORD=mypassword123! \
  -v $PWD/MYSQL/mysql-config/strict_mode.cnf:/etc/mysql/conf.d/strict_mode.cnf \
  -p 3306:3306 \
  -d mariadb:10.5

Step 2: Connect from Host Machine
Now, you can connect to MySQL from outside the container using any MySQL client (command line or GUI like MySQL Workbench).

Option 1: Using MySQL CLI
If MySQL is installed on your host machine, run: 
" mysql -h 127.0.0.1 -P 3306 -u root -p "

explanation
-h 127.0.0.1 → Connect to MySQL running inside the container.
-P 3306 → Use port 3306 (mapped from container to host).
-u root -p → Log in as root and enter the password (mypassword123!).

NB: If MYSQL is not install on the host machine, do this:

    Solution 1: Install MySQL Client
        You need to install the MySQL client (mysql command-line tool) on your system.

        For Windows (Using Chocolatey)
        If you use Chocolatey, install the MySQL client with: 
        open your poweshell and run this
        " choco install mysql "
        Then after installation, restart your terminal and try:
        " mysql --version "

        For Windows (Manual Installation)
        Download MySQL from the official site:
        MySQL Installer
        Install only the MySQL Shell or MySQL Client (no need for the server).
        Add MySQL to the system PATH so you can run mysql from any directory.


        Solution 2: Use the MySQL Client Inside the Container
        If you don’t want to install MySQL on your host machine, you can run the client inside the MySQL container:
        " docker exec -it [Db_Container_Name] mysql -uroot -p "

        Then, enter your MySQL root password when prompted.

Option 2: Using MySQL Workbench
Open MySQL Workbench.
Click + (New Connection).
Set:
Host: 127.0.0.1
Port: 3306
Username: root
Password: mypassword123! (or store it)
Click Test Connection and then Connect.

Step 3: Verify Connection
Once logged in, you can verify by running:
" SHOW DATABASES; "
NB: If everything is correct, you should see MySQL system databases (mysql, information_schema, etc.).

Troubleshooting
If you get "Can't connect to MySQL server", make sure:
The container is running:
" docker ps "

The port is properly mapped:
" docker inspect opensis-Db-mysql | grep "3306" "

MySQL is listening for external connections. Run inside the container:
< docker exec -it opensis-Db-mysql mysql -uroot -p -e "SHOW VARIABLES LIKE 'bind_address';" >

If it's 127.0.0.1, update my.cnf to bind_address = 0.0.0.0.


NB: To exit the container use < EXIT; > or < QUIT; > or just press  < Ctrl + D >

Re-start the containers then list them
Connect to the frontend locally (manually)
if you see blank page, (right click)inspect, network and refresh the page.

To connect to a database, you need: db credential to log into db
1- db port
2- db hostname
3- db user
4- db password
5- db name (inside the db there is another db)

The admin is not part of it (not to be used)

The developer gave this file 
< CREATE DATABASE openSIS DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON *.* TO 'openSIS_rw'@'%' IDENTIFIED BY 'Op3nS!S' WITH GRANT OPTION;
FLUSH PRIVILEGES; >

What should I do?
docker ps
docker exec -it [db_name] -u root -p

To allow 2 containers to talk, both need to be on the
same docker network
container name as


NB In prod you need to use docker-compose
use the command used to run the containers. add persistent volume. add the init-opensis.sql command

kill all your container docker rm -f $(dockerps -aq)
docker-compose up -d  
(docker-compose down to kill all containers)
docker-compose ps 

