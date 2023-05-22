#!/bin/bash

#############################################
############     PROMPTS      ###############
#############################################

# Prompt for project name
read -p "What is your project named? (Press Enter for default: my-go-server): " project_name
project_name=${project_name:-my-go-server}

# Prompt for Gin-Gonic installation
read -p "Would you like to install Gin-Gonic web framework? (Y/n): " install_gin
install_gin=${install_gin:-Y}

# Prompt for CompileDaemon installation
read -p "Would you like to install CompileDaemon package for live dev server update? (Y/n): " install_compile_daemon
install_compile_daemon=${install_compile_daemon:-Y}

# Prompt for godotenv installation
read -p "Would you like to install godotenv package? (Y/n): " install_godotenv
install_godotenv=${install_godotenv:-Y}

# Prompt for database driver selection
db_driver=""
db_driver_option=""
while [[ ! $db_driver =~ ^(1|2|3)$ ]]; do
    read -p "Which database driver would you like to install? (1) MongoDB, (2) PostgreSQL, (3) Others: " db_driver
    case $db_driver in 
        1)
            db_driver_option="1"
            ;;
        2)
            db_driver_option="2"
            ;;
        3)
            db_driver_option="3"
            ;;
        *)
            echo "Invalid option. Please select a valid database driver."
            db_driver=""
            ;;
    esac
done
#############################################
#########    INSTALLATION      ##############
#############################################

# Generate and cd to the new directory
mkdir $project_name
cd $project_name

# Run go mod init
go mod init $project_name

# Install Gin-Gonic if selected
if [[ $install_gin =~ ^[Yy]$ ]]; then
    go get -u github.com/gin-gonic/gin
fi

# Install CompileDaemon if selected
if [[ $install_compile_daemon =~ ^[Yy]$ ]]; then
    go get github.com/githubnemo/CompileDaemon
    go install github.com/githubnemo/CompileDaemon
fi

# Install godotenv if selected
if [[ $install_godotenv =~ ^[Yy]$ ]]; then
    go get github.com/joho/godotenv
fi

#Install dbdriver
case $db_driver_option in
        1)
            go get go.mongodb.org/mongo-driver/mongo
            env_file=".env"
            db_uri="MONGODB_URI"
            db_name="MONGO_DB"
            ;;
        2)
            go get -u gorm.io/gorm
            go get -u gorm.io/driver/postgres
            env_file=".env"
            db_uri="POSTGRESDB_URI"
            db_name="POSTGRES_DB"
            ;;
        3)
            env_file=""
            echo "No database driver will be installed."
            ;;
        *)
            echo "Invalid option. Please select a valid database driver."
            db_driver=""
            ;;
    esac

