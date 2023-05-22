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
