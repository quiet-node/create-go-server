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
