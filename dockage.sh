#!/bin/bash

# Function to delete dangling images
delete_dangling_images() {
    docker rmi $(docker images -f "dangling=true" -q)
}

# Function to enter web container
enter_dreamfactory_container() {
    docker exec -it dreamfactory-web-1 bash
}

# Function to stop containers matching a string
stop_containers() {
    docker ps --filter name=$1 -aq | xargs docker stop
}

# Function to build containers and log output
docker_compose_build() {
    docker-compose build --no-cache &> logs.txt
}

# Function to launch containers
docker_compose_up() {
    docker-compose up -d
}

# Function to delete all exited containers
delete_exited_containers() {
    docker ps --filter status=exited -q | xargs docker rm
}

delete_volumes() {
    docker volume rm $(docker volume ls -q)
}

# Function to display help
display_help() {
    echo "Usage: dockage [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --delete-dangling-images    Delete all dangling images"
    echo "  --dec    Delete all exited containers"
    echo "  --build     Build (but not launch) containers. Output is dumped to logs.txt"
    echo "  --launch     Launch containers"
    echo "  --dv     Delete all volumes"
    echo "  --sc     Stop all containers having a name matching argument"
    echo "  --ssh    SSH into the web container"
    echo "  --help   Display this help message"
}

# Parsing flags
if [[ "$#" -eq 0 ]]; then
    display_help
    exit 1
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dec) delete_exited_containers ;;
        --delete-dangling-images) delete_dangling_images ;;
        --sc) stop_containers $2 ;;
        --ssh) enter_dreamfactory_container ;;
        --build) docker_compose_build ;;
        --launch) docker_compose_up ;;
        --dv) delete_volumes ;;
        --help) display_help; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; display_help; exit 1 ;;
    esac
    shift
done
