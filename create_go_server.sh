#!/bin/bash

#############################################
############     PROMPTS      ###############
#############################################

# Prompt for project name
read -p "What is your project named? (Press Enter for default: my-go-server): " project_name
project_name=${project_name:-my-go-server}
#############################################
#########    INSTALLATION      ##############
#############################################

# Generate and cd to the new directory
mkdir $project_name
cd $project_name

# Run go mod init
go mod init $project_name
