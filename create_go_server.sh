#!/bin/bash

#############################################
############     PROMPTS      ###############
#############################################

# Prompt for project name
read -p "Project name: (Press Enter for default: my-go-server): " project_name
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

# Prompt for add_env_file selection
read -p "Would you like to add a sample .env? (Y/n) " add_env_file
add_env_file=${add_env_file:-Y}

# Prompt for Makefile selection
read -p "Would you like to add a sample Makefile? (Y/n) " add_makefile
add_makefile=${add_makefile:-Y}



#############################################
#########    INSTALLATIONS      #############
#############################################

# Generate and cd to the new directory
echo
echo "Starting installation process..."
echo
echo "Running mkdir $project_name && cd $project_name..."
mkdir $project_name
cd $project_name
echo "Done."

# Run go mod init
echo 
echo "Running go mod init $project_name..."
go mod init $project_name
echo "Done."

# init a git repository
echo 
echo "Running git init..."
git init
echo "Done."
echo


# Create .gitignore
echo "Creating sample .gitignore..."
    cat << EOF > .gitignore
# If you prefer the allow list template instead of the deny list, see community template:
# https://github.com/github/gitignore/blob/main/community/Golang/Go.AllowList.gitignore
#
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with `go test -c`
*.test

# Output of the go coverage tool, specifically when used with LiteIDE
*.out

# Dependency directories (remove the comment below to include it)
# vendor/

# Workspace file
go.work
.env
$project_name
EOF
echo "Done."

# Install Gin-Gonic if selected
if [[ $install_gin =~ ^[Yy]$ ]]; then
    echo 
    echo "Running go get -u github.com/gin-gonic/gic..."
    go get -u github.com/gin-gonic/gin
    echo "Done."
fi

# Install CompileDaemon if selected
if [[ $install_compile_daemon =~ ^[Yy]$ ]]; then
    echo 
    echo "Running go get github.com/githubnemo/CompileDaemon && go install github.com/githubnemo/CompileDaemon..."
    go get github.com/githubnemo/CompileDaemon
    go install github.com/githubnemo/CompileDaemon
    echo "Done."
fi

# Install godotenv if selected
if [[ $install_godotenv =~ ^[Yy]$ ]]; then
    echo 
    echo "Running go get github.com/joho/godotenv..."
    go get github.com/joho/godotenv
    echo "Done."
fi

#Install dbdriver
case $db_driver_option in
        1)
            echo 
            echo "Running go get go.mongodb.org/mongo-driver/mongo..."
            go get go.mongodb.org/mongo-driver/mongo
            echo "Done."
            env_file=".env"
            db_uri="MONGODB_URI"
            db_name="MONGO_DB"
            ;;
        2)
            echo 
            echo "Running go get -u gorm.io/gorm && go get -u gorm.io/driver/postgres..."
            go get -u gorm.io/gorm
            go get -u gorm.io/driver/postgres
            echo "Done."
            env_file=".env"
            db_uri="POSTGRESDB_URI"
            db_name="POSTGRES_DB"
            ;;
        3)
            env_file=""
            echo 
            echo "No database driver will be installed."
            ;;
        *)
            echo 
            echo "Invalid option. Please select a valid database driver."
            db_driver=""
            ;;
    esac

# Configure .env file if env_file is specified
if [[ $add_env_file =~ ^[Yy]$ ]]; then
    echo 
    echo "Creating sample .env..."
    # Create .env
    cat << EOF > $env_file
PRODUCTION_PORT=8080
$db_uri=YOUR_DB_URI
$db_name=YOUR_DB_NAME
EOF
    echo "Done."
fi

# Create Makefile
if [[ $add_env_file =~ ^[Yy]$ ]]; then
    echo 
    echo "Creating sample Makefile..."
    cat << EOF > Makefile
include .env

############### GLOBAL VARS ###############
COMPILEDAEMON_PATH=~/go/bin/CompileDaemon # CompileDaemon for hot reload
GO_SERVER=$project_name
#############################################
############### LOCAL BUILD #################
#############################################

# dev-mode
.phony: dev
dev: 
	@\$(COMPILEDAEMON_PATH) -command="./\$(GO_SERVER)"

# local run
.phony: go-run
go-run:
	@go run .
EOF
    echo "Done."
fi

echo 
echo "Success! Created $project_name at $(pwd)"