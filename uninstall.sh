#!/bin/bash

docker rm -f /sharemongo
docker rm -f /shareredis
docker rm -f /sharelatex
docker container prune -f
docker system prune -f

