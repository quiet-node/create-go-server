#!/bin/bash

#############################################
############     PROMPTS      ###############
#############################################

# Prompt for project name
read -p "Project name: (Press Enter for default: my-go-server): " project_name
project_name=${project_name:-my-go-server}

# Prompt for database driver selection
db_driver=""
db_driver_option=""
while [[ ! $db_driver =~ ^(1|2|3)$ ]]; do
    read -p "Which database driver would you like to install? (1) MongoDB, (2) PostgreSQL: " db_driver
    case $db_driver in 
        1)
            db_driver_option="1"
            ;;
        2)
            db_driver_option="2"
            ;;
        *)
            echo "Invalid option. Please select a valid database driver."
            db_driver=""
            ;;
    esac
done

#############################################
#########    Install Packages      ##########
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

# Install CompileDaemon
echo 
echo "Running go get github.com/githubnemo/CompileDaemon && go install github.com/githubnemo/CompileDaemon..."
go get github.com/githubnemo/CompileDaemon
go install github.com/githubnemo/CompileDaemon
echo "Done."

# Install Gin-Gonic if selected
# install gin-gonic
echo 
echo "Running go get -u github.com/gin-gonic/gic..."
go get -u github.com/gin-gonic/gin
echo "Done."


#Install dbdriver
case $db_driver_option in
        1)
            # install mongo-driver packages
            echo 
            echo "Running go get go.mongodb.org/mongo-driver/mongo..."
            go get go.mongodb.org/mongo-driver/mongo
            echo "Done."
            env_file=".env"
            db_uri="MONGODB_URI"
            db_name="MONGO_DB"

            # construct db directory
            mkdir db
            cd db
            cat << EOF > db.go
// @package
package db

// @import
import (
	"context"
	"log"
	"os"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// @dev Creates a MongoDB instance
//
// @return *mongo.Client
func EstablishMongoClient(ctx context.Context) *mongo.Client {
	// get the mongoDB uri
	mongoUri := os.Getenv("MONGODB_URI")
	if mongoUri == "" {log.Fatal("!MONGODB_URI - uri is not defined.")}

	// Establish the connection
	mongoClient, err := mongo.Connect(ctx, options.Client().ApplyURI(mongoUri))
	if err != nil {
    log.Fatal("!MongoDB Connection - Cannot conenct to MongoDB server")
  }

	// return mongo client
	log.Println("MongoDB connected...")
	return mongoClient
}

// @dev Gets a mongdb collection based on colectionName
// 
// @param mongoClient *mongo.Client
//  
// @param collectionName string
// 
// @return *mongo.Collection
func GetMongoCollection(mongoClient *mongo.Client, collectionName string) *mongo.Collection {
	// get the collection
	collection := mongoClient.Database(os.Getenv("MONGO_DB")).Collection(collectionName)

	// return the collection
	return collection
}

EOF
            cd ..
            echo "Done."
            ;;
        2)
            # install gorm packages
            echo 
            echo "Running go get -u gorm.io/gorm && go get -u gorm.io/driver/postgres..."
            go get -u gorm.io/gorm
            go get -u gorm.io/driver/postgres
            echo "Done."
            env_file=".env"
            db_uri="POSTGRESDB_DSN"
            db_name="POSTGRES_DB"

            # construct db directory
            echo
            echo "Constructing db dir..."
            mkdir db
            cd db
            cat << EOF > db.go
package db

import (
	"log"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// @dev Create a PostgresQL instance
//
// @return *gorm.DB
func EstablishPostgresClient() *gorm.DB {
	// prepare dsn
	dsn := os.Getenv("POSTGRESDB_DSN")
	if dsn == "" {
		log.Fatal("!POSTGRESDB_DSN - dsn is not defined.")
	}

	// Open connection
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("!PostgresQL Connection - Cannot conenct to PostgresQL server")
	}

	// return db
	log.Println("PostgresQL connected...")
	return db
}
EOF
            cd ..
            echo "Done."
            ;;
        *)
            echo 
            echo "Invalid option. Please select a valid database driver."
            db_driver=""
            ;;
    esac

# Install godotenv
echo 
echo "Running go get github.com/joho/godotenv..."
go get github.com/joho/godotenv
echo "Done."

#############################################
#########    Project codebase      ##########
#############################################

# Add .env
echo 
echo "Generating sample .env..."
cat << EOF > .env
LOCAL_DEV_PORT=127.0.0.1:41125
HOME_ROUTER=192.168.1.2
PRODUCTION_PORT=8080
$db_uri=YOUR_DB_URI
$db_name=YOUR_DB_NAME
EOF
echo "Done."

# Add .env.example
echo 
echo "Generating sample example.env..."
cat << EOF > example.env
LOCAL_DEV_PORT=127.0.0.1:41125
HOME_ROUTER=192.168.1.2
PRODUCTION_PORT=8080
$db_uri=YOUR_DB_URI
$db_name=YOUR_DB_NAME
EOF
echo "Done."

# Add .gitignore
echo
echo "Generating sample .gitignore..."
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

# Add Makefile
echo 
echo "Generating sample Makefile..."
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

# Generate LoadEnvVars() in utils dir
echo
echo "Constructing LoadEnvVars() initializer..."
mkdir utils
cd utils
cat << EOF > utils.go
package utils

import (
	"log"

	"github.com/joho/godotenv"
)

// @dev Loads environment variables
func LoadEnvVars() {
	err := godotenv.Load();
	if err != nil {
		log.Fatal("Error loading .env file")
	}
}

EOF
cd ..
echo "Done."

# Generate Router directory
echo
echo "Constructing Router Handlers..."
mkdir routers
cd routers
cat << EOF > routers.go
package routers

import "github.com/gin-gonic/gin"

// @dev Declares list of endpoints
func ServerRouter (rg *gin.RouterGroup) {
	rg.GET("/ping", func(gc *gin.Context) {
		gc.JSON(200, "pong")
	})
}
EOF
cd ..
echo "Done."

# Generating sample gin gonic main.go
echo
echo "Constructing Gin Gonic main.go example..."
cat << EOF > main.go
package main

// @import
import (
	"$project_name/db"
	"$project_name/utils"
	"$project_name/routers"
	"os"

	"github.com/gin-gonic/gin"
EOF

if [[ $db_driver_option == "1" ]]; then
    cat << EOF >> main.go
  "context"
  "go.mongodb.org/mongo-driver/mongo"
EOF
elif [[ $db_driver_option == "2" ]]; then
    cat << EOF >> main.go
  "gorm.io/gorm"
EOF
fi
cat << EOF >> main.go
)

// @notice: global variables
var (
  server			*gin.Engine
EOF
if [[ $db_driver_option == "1" ]]; then 
  cat << EOF >> main.go
  ctx			context.Context
	mongoClient		*mongo.Client
	mongoCollection		*mongo.Collection
EOF
elif [[ $db_driver_option == "2" ]]; then
  cat << EOF >> main.go
  postgresClient		*gorm.DB
EOF
fi
cat << EOF >> main.go
)

// @dev Runs before main()
func init() {
  // load env variables
	if (os.Getenv("GIN_MODE") != "release") {utils.LoadEnvVars()}
  
  // set up gin engine
  server = gin.Default()

  // Gin trust all proxies by default and it's not safe. Set trusted proxy to home router to to mitigate 
  server.SetTrustedProxies([]string{os.Getenv("HOME_ROUTER")})

EOF
if [[ $db_driver_option == "1" ]]; then
  cat << EOF >> main.go
	// init context
	ctx = context.TODO()

	// init mongo client
	mongoClient = db.EstablishMongoClient(ctx)

	// get mongoCollection
	mongoCollection = db.GetMongoCollection(mongoClient, "your-mongo-collection")
EOF

elif [[ $db_driver_option == "2" ]]; then
  cat << EOF >> main.go
  // init postgres client
  postgresClient = db.EstablishPostgresClient()
EOF
fi

cat << EOF >> main.go
}

// @dev Root function
func main() {
  // Catch all unallowed HTTP methods sent to the server
  server.HandleMethodNotAllowed = true

EOF
if [[ $db_driver_option == "1" ]]; then
  cat << EOF >> main.go
  // defer a call to `Disconnect()` after instantiating client
	defer func() {if err := mongoClient.Disconnect(ctx); err != nil {panic(err)}}()
EOF
fi
cat << EOF >> main.go

  // init basePath
  basePath := server.Group("/v1")

  // init Handler
  routers.ServerRouter(basePath)

  // run gin server engine
  if (os.Getenv("GIN_MODE") != "release") {
    server.Run(os.Getenv("LOCAL_DEV_PORT"))
  } else {
    server.Run(":"+os.Getenv("PRODUCTION_PORT"))
  }
}

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