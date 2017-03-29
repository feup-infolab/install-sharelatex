#!/bin/bash

SHARELATEX_ADMIN_EMAIL="lolada@test.com"
PORT=7000


sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install docker-ce

#steps to allow running docker without sudo

sudo groupadd docker

echo "Adding $USER to docker group" 
sudo gpasswd -a ${USER} docker

echo "Restarting docker"
sudo service docker restart

echo "Changing user $USER to group docker" 
newgrp docker &

echo "Starting sharelatex docker container"

docker run -d --name sharemongo -e AUTH=no tutum/mongodb

docker run -d --name shareredis -v /var/redis:/var/lib/redis redis

docker run -d -P -p $PORT:80 -v /var/sharelatex_data:/var/lib/sharelatex --env SHARELATEX_MONGO_URL=mongodb://mongo/sharelatex --env SHARELATEX_REDIS_HOST=redis --env SHARELATEX_ADMIN_EMAIL=$SHARELATEX_ADMIN_EMAIL --link sharemongo:mongo --link shareredis:redis --name sharelatex sharelatex/sharelatex

docker exec sharelatex /bin/bash -c "cd /var/www/sharelatex/; grunt user:create-admin --email $SHARELATEX_ADMIN_EMAIL" &&  echo "Installed sharelatex" || echo "Failed to install the sharelatex container"

#install some extra packages (float, etc..)
 docker exec sharelatex /bin/bash -c "sudo apt-get -y install texlive-generic-extra"
