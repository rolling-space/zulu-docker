#
# SOURCE: https://github.com/tcnksm/docker-alias.git
# Docker alias and function
# ------------------------------------

# docker volume
alias dv='docker volume'

# delete all volumes
alias dvrm='docker volume rm $(docker volume ls)'
# docker-compose
alias comp='docker-compose'
# delete untagged images
alias dxut='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
# delete containers with status exited
alias dxex='docker rm $(docker ps -aqf status=exited)'

# Get latest container ID
alias dl="docker ps -l -q"

# Get container process
alias dps="docker ps"

# Get process included stop container
alias dpa="docker ps -a"

# Get images
alias di="docker images"

# Get container IP
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"

# Run deamonized container, e.g., $dkd base /bin/echo hello
alias dkd="docker run -d -P"

# Run interactive container, e.g., $dki base /bin/bash
alias dki="docker run -i -t -P"

# Execute interactive container, e.g., $dex base /bin/bash
alias dex="docker exec -i -t"


########## FUNCTIONS ############

# Stop all containers
dstop() { docker stop $(docker ps -a -q); }

# Remove all containers
drm() { docker rm $(docker ps -a -q); }

# Stop and Remove all containers
alias drmf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'

# Remove all images
dri() { docker rmi $(docker images -q); }

# Dockerfile build, e.g., $dbu tcnksm/test 
dbu() { docker build -t=$1 .; }

# Show all alias related docker
dalias() { alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }

# enter into a running container

function dent {
docker exec -i -t $1 /bin/bash
}
# complete -F _docker_exec dent

# run bash for any image
function dbash {
docker run --rm -i -t -e TERM=xterm --entrypoint /bin/bash $1
}

# docker-machine
function dmd {
docker-machine $1 $DEFAULT_DOCKER_MACHINE
}

alias dm='docker-machine'
# complete -F _docker_images dbash

# load docker env in current
function godoc {
  eval "$(docker-machine env `echo $1`)"
}

# Enter the Docker for Mac HyperVM
# Username is root
alias dockermac="screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty"

# Use `docker-cleanup --dry-run` to see what would be deleted.

function docker-cleanup {
  EXITED=$(docker ps -q -f status=exited)
  DANGLING=$(docker images -q -f "dangling=true")
  NONE=$(docker images -a | grep '<none>')

  if [ "$1"=="--dry-run" ]; then
    echo "==> Would stop containers:"
    echo $EXITED
    echo "==> And images:"
    echo $DANGLING
    echo "==> And all with <none>:"
    echo $NONE
  else
    if [ -n "$EXITED" ]; then
      docker rm $EXITED
    else
      echo "No containers to remove."
    fi
    if [ -n "$DANGLING" ]; then
      docker rmi $DANGLING
    else
      echo "No images to remove."
    fi
    if [ -n "$NONE" ]; then
      $NONE |  awk '{print $3}' | xargs docker rmi -f
    else
      echo "No untagged images to remove"
    fi
  fi
}