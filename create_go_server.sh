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

# # Prompt for CompileDaemon installation
# read -p "Would you like to install CompileDaemon package for live dev server update? (Y/n): " install_compile_daemon
# install_compile_daemon=${install_compile_daemon:-Y}

# # Prompt for godotenv installation
# read -p "Would you like to install godotenv package? (Y/n): " install_godotenv
# install_godotenv=${install_godotenv:-Y}

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

# Install CompileDaemon
echo 
echo "Running go get github.com/githubnemo/CompileDaemon && go install github.com/githubnemo/CompileDaemon..."
go get github.com/githubnemo/CompileDaemon
go install github.com/githubnemo/CompileDaemon
echo "Done."

# Install godotenv
echo 
echo "Running go get github.com/joho/godotenv..."
go get github.com/joho/godotenv
echo "Done."

# Install Gin-Gonic if selected
if [[ $install_gin =~ ^[Yy]$ ]]; then
    # install gin-gonic
    echo 
    echo "Running go get -u github.com/gin-gonic/gic..."
    go get -u github.com/gin-gonic/gin
    echo "Done."

    # creating sample gin gonic main.go
    echo "Creating Gin-Gonic main.go example..."
    cat << EOF > main.go
package main

// @import
import (
  "log"
  "net/http"

  "github.com/gin-gonic/gin"
  "github.com/joho/godotenv"
)

// @dev Root function
func main() {
  // Loads environment variables
  err := godotenv.Load()
  if err != nil {
    log.Fatal("Error loading .env file")
  }

  // Init gin engine
  r := gin.Default()

  // HTTP Get
  r.GET("/ping", func(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
      "message": "pong",
    })
  })

  // run gin engine
  r.Run() // listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
}
EOF
else 
    echo "Creating net/http main.go example..."
    cat << EOF > main.go
package main

// @import
import (
	"fmt"
	"log"
	"net/http"
)

// @dev Root function
func main() {
	http.HandleFunc("/", handler)
	fmt.Println("Server listening on port 8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

// @dev http handler
func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, World!")
}

EOF
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

# Create .env
echo 
echo "Creating sample .env..."
cat << EOF > .env
PRODUCTION_PORT=8080
$db_uri=YOUR_DB_URI
$db_name=YOUR_DB_NAME
EOF
echo "Done."

# Create .env.example
echo 
echo "Creating sample example.env..."
cat << EOF > example.env
PRODUCTION_PORT=8080
$db_uri=YOUR_DB_URI
$db_name=YOUR_DB_NAME
EOF
echo "Done."

# Create Makefile
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

# Add README.md
echo
echo "Generating README.md..."
cat << EOF > README.md
# $project_name

## Overview
**** ***your server overview*** ****

## Getting Started

### Requirement

- [git](https://git-scm.com/)
- [golang](https://go.dev/)

### Set up environment variables

At the root of the directory, create a .env file using .env.example as the template and fill out the variables.

### Running the project

Build and run \`$project_name\` in hot-reload dev mode locally using \`Make\` script
\`\`\`bash
make dev
\`\`\`


### Resources 
Built by [Quiet Node](https://github.com/quiet-node) using [Create Go Server shell tool](https://github.com/quiet-node/create-go-server)

EOF
echo "Done."

# Initial commit
echo
echo "Commit inital setup..."
git add . && git commit -am "init: generated new Go server"
echo "Done."

echo 
echo "Success! Created $project_name at $(pwd)"
echo 
echo -e "To start development mode, run \ncd $project_name && make dev"
echo 
echo "Happy building!"