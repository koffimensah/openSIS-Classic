

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



# deploy database using docker
ex: mysql

$ docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag

explain the command

you can Run the Db with additional options

$ docker run \           (docker run means run a new container)
--name some-mysql \      (assign the container a name)
-e MYSQL_ROOT_PASSWORD=my-secret-pw \ (-e sets an environment variable inside the container) 
-d mysql:tag (-d runs the container in detache mode means in the background) mysql is the official image name (fron dockerhub) and the tag specifies mysql version.
-p 3306:3306 (maps Mysql's default port 3306 from the container to your host/local machine) = allow application on your host / local machine to connect to the MYSQL database running inside the Docker container.
-v mysql_data:/var/lib/mysql (to persit data) = ensure that database data is stored in the mysql_data volume = when you run a container the database data is stored insode the container. However, if you delete or create the container, all the data will be lost. Persisting data with a volume ensures the database remains even if the container is removed or restarted. (v stands for volume used for persistent storage), (mysql_data the name of the volume), (/var/lib/mysql is the path inside the container where MYSQL store its data.)
Here Docker will create a name called mysql_data, MYSQL will store all database file inside this volume, even if you delete the container, the database will not lost. when you start a new MySQL container, it can re-use the same volume.

To run a database container, you will need
--name
-e (environment variable) one or more env variable on the docker run command line
NB: I can use an env variable to to create an user, create a password, create a database. some are mandatory and other are optional.
-p (port mapping)
-v (persistent volume)
-d (detache mode)

# configuration file
/etc/mysql/conf.d/   (contains custom extra configuration) .cnf files added by users.
/etc/mysql/myaql.conf.d/ (contains default MySQL configuration file provided by MySQL)

If the developer gives a cnf you will need to mount the configuration file into the MySQL container so MySQL can load it on startup.
So run the container with a volume mount to place the file indide  /etc/mysql/conf.d/ which MySQL loads by default.    -v $PWD/MYSQL/mysql-config/strict_mode.cnf:/etc/mysql/conf.d/strict_mode.cnf \
then verify if the configuration was applied by connecting to MySQL inside the container 
(docker exec -it [Container_Name] mysql -uroot -p[password])


DATABASE


Run MARIADB with options

docker run --detach --name opensis-mariadb \
-e MARIADB_ROOT_PASSWORD=mypassword123! \
-v $PWD/MYSQL/mysql-config/strict_mode.cnf:/etc/mysql/conf.d/strict_mode.cnf \
-p 3306:3306 \
-d mariadb:10.5


MYSQL
docker run --name opensis-Db-mysql \
  -e MYSQL_ROOT_PASSWORD=mypassword123! \
  -v $PWD/MYSQL/mysql-config/strict_mode.cnf:/etc/mysql/conf.d/strict_mode.cnf \
  -d mariadb:10.5

I have deployed the frontend and the backend now I want to log into the database.
The frontend will try to log into the DATABASE means need access to the database.
How to log into the database not inside the container but from outside the container?

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
if you see blank page, (right click) inspect, network and refresh the page.

To connect to a database, you need: db credential to log in
1- db port
2- db hostname
3- db user
4- db password
5- db name (inside the db there is another db)

NEVER EXPOSE DATABASE AND NEVER RUN AS A ROOT USER (master credential). It is used in case there is a pb it is used to get inside the tool.
which account do I use? user account with some privileges.
How to get access the batabase witout exposing the port? The developer will give you the variable string (init-opensis.sql) 

The developer gave this file 
< CREATE DATABASE openSIS DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON *.* TO 'openSIS_rw'@'%' IDENTIFIED BY 'Op3nS!S' WITH GRANT OPTION;
FLUSH PRIVILEGES; >

explaination

1- Creating a database
CREATE DATABASE openSIS: creates a new database named opensis
DEFAULT CHARACTER SET utf8mb4 : sets the default character encoding for the datbase to utf8mb4 (support full Unicode including emojis)
COLLATE utf8mb4_unicode_ci : specifies the collation (rules for sorting and comparing text.) utf8mb4_unicode_ci is a case-sensitive collation that ensures proper Unicode sorting.

2- Granting privileges to a user
GRANT ALL PRIVILEGES ON *.* TO 'openSIS_rw'@'%' IDENTIFIED BY 'Op3nS!S' WITH GRANT OPTION

EXPLANATION 
GRANT ALL PRIVILEGES ON *.* grants all privileges (select, insert, update, delete etc) on all databases       ( *.*means all databases and tables)
TO 'openSIS_rw'@'%' : creates or modifies user openSIS_rw that can connect any host ('%' means any IP address)
IDENTIFIED BY 'Op3nSIS' : sets the password for openSIS_rw to Op3nS!S
WITH GRANT OPTION : allows the user openSIS_rw to grant privileges to other users

To connect to a database, you need: db credential to log inThe developer will give you the database type
1- db port
2- db hostname
3- db user
4- db password
5- db name (inside the db there is another db)

In our case here, to spin the database, we have

- the password  
- the hostname

what is missing here?
- the user
- the port
- the name 


What should I do?
docker ps
docker exec -it [db_name] mysql -u root -p

Here you need the root password to log in to be able to create other user 
password: (provide the root password)

Execute the SQL script once inside the MySQL 

CREATE DATABASE openSIS DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON *.* TO 'openSIS_rw'@'%' IDENTIFIED BY 'Op3nS!S' WITH GRANT OPTION;
FLUSH PRIVILEGES;

4- Verify that everything works
SHOW DATABASES; 

Check if the user exists
SELECT user, host FROM mysqluser WHERE user = 'opensSIS_rv';

5- Ensure the application can connect 
mysql -h mysql-conatiner -u openSIS_rw -p 

The developer will need the following to connect the app
* Host (use localhist or the container IP)
* Database name  (openSIS)
* Username (openSIS_rw)
* Password (Op3nS!S)
* Port (3306 default mysql port)

Exit the container then run this 
mysql -h localhost:3306 -u openSIS_rw -p 
enter the password: 
NB if there is error means you cannot login using the localhost 

Use the container name instead 
mysql -h [mysql-conatiner-name] -u openSIS_rw -p 

If does not work, get into the frontend container
docker exec -it [frontent_container] bash

NB difference between  itd vs it ....bash
"itd" without bash means working in detached mode without getting inside. response with numbers
"it ....bash" at the end means interactive mode with getting inside. response with nothing

Ex: docker run -itd name koffi ubuntu   response 2452136dhtgshkdyhj3201546
    docker exec -it opnsis-ui bash      response nothing (means inside the container)

mysql (to check if mysql is installed if not install it)
apt update
apt install mysql-client -y

To allow 2 containers to communicate, both need to be on the
same docker network and the container name becomes the DNS

1- Verify running Containers 
docker ps 

2- Check Docker Network
docker network ls

if your containers are not on the same network, create a custom network and attach them.
docker network create opensis-network 
docker network connect opensis-network [backend_container]
docker network connect opensis-network [frontend_container]
docker network connect opensis-network ubuntu

Instead of using localhost, use the container name as the hostname.
curl -v [frontend_container]:8081
curl -v [backend_container]:3306

or ping both containers
ping [frontend_container] then
ping [backend_container]

If ping works it means both frontend and backend are on the same network. 

NB: If MySQL is not install, you need to exec in the container then install MySQL inside that container the create a network and specify a port using mysql -h [database_container] - P 3306 -u [user_name] -p

Accordig to all information we had let's add options and rebuild using this command below 

NB To connect to a database, you need: db credential to log in. The developer will give you the database type
1- db port
2- db hostname
3- db user
4- db password
5- db name (inside the db there is another db)

docker run -d \
--name opensis-db \
--network opensis-network \
-e MYSQL_ROOT_PASSWORD=1234! \
-e MYSQL_DATABASE=openSIS \
-e MYSQL_USER=openSIS_rw \
-e MYSQL_PASSWORD='Op3nS!S' \
-p 3306:3306 \
-v ./MYSQL/mysql-config/strict_mode.cnf:/etc/mysql/conf.d/strict_mode.cnf \
-d mariadb:10.5

1- run this command to create the frontend container
docker run -d --name opensis-ui --network opensis-network -p 8081:80 opensis-ui 

2- run the backend / database container
docker run -d \
--name opensis-db \
--network opensis-network \
-e MYSQL_ROOT_PASSWORD=1234! \
-e MYSQL_DATABASE=openSIS \
-e MYSQL_USER=openSIS_rw \
-e MYSQL_PASSWORD='Op3nS!S' \
-p 3306:3306 \
-v ./MYSQL/mysql-config/strict_mode.cnf:/etc/mysql/conf.d/strict_mode.cnf \   # $PWD/MYSQL = ./MYSQL
-d mariadb:10.5

If access denied, use this:
1- docker exec -it opensis-db bash 
2- mysql -u root -p                   [root password]
3- copy paste [init-opensis.sql] content and run
< CREATE DATABASE openSIS DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON *.* TO 'openSIS_rw'@'%' IDENTIFIED BY 'Op3nS!S' WITH GRANT OPTION;
FLUSH PRIVILEGES; >

NB Database use internal port (3306) means the default port not the external port.

Go back to the image on the browawer. At this point the application belongs to the developer who will be putting in all informations. 

Now the application is deployed. This cannot be taken to the production. 


NB: In prod you need to deploy this application using docker-compose
To do so:

NB. In production you will always need additional considerations
- persist volumes
- networking to allow communication between each other.
- add sql file if any
and run it at runtime

Using docker-compose simplifies the management of your containers and allows you to define and run multi-containers application easily.

CHATGPT 
<< I want to deploy this in the production level using docker-compose.
<copy and paste commands used to create the frontend and the backend containers.> 

I want to persist volumes. add the init-opensis.sql command to it to run at runtime. >>

NB the docker-compose file is ok.
`
kill all containers
docker rm -f $(docker ps -aq)   then 
docker-compose up -d  
docker-compose ps to list your containers

if one failed kill all (< docker-compose down > containers)

recall 
docker-compose up -d  
docker-compose ps to list your containers 

If nay error, copy and ask CHATGPT.
Possible solution
***run sql script with different container and make it part of the compose file 
To do so 
- The database container is named opensis-db
- The sql script is named init.sql
- The sql script is located in the same directory as your docker compose file 




NB Any time you have a repository, do not scare about the lenght of the code. 
worry about where are the DevOps codes/scripts?
1- Dockerfile (Try t understand every single line)
2- Look for any package called DEVOPS if any. Go inside and see all scripts and understand them.




DOCKER COMPOSE FILE STRUCTURED?

version:

services:
  connect-frontend:
    image: ******(same aws image)****************************:${FRONTEND_TAG}
    container_name:
    restart: always
    ports:
      - "3000:3000"
    networks:
      - connect_network
    volumes: 
      - connect-frontend:/app
    environment: 
      - NODE_ENV=stage
    depends_on: 
      - connect-backend

  connect-backend:
    image: ******(same aws image)****************************:${BACKEND_TAG}
    container_name: connect-backend
    restart: always
    ports:
      - "8080:80"
    networks:
      - connect_network
    volumes:
      - connect-backend:/var/www/connect-backend
    environment:
      - APP_ENV=stage
      - APP_DEBUG=false

networks:
  connect_network:
    driver: bridge

volumes:
  connect_frontend:
  connect_backend: