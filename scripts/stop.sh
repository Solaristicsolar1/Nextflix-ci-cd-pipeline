#!/bin/bash

docker stop netflix
docker rm netflix
docker image rm ojosamuel/netflix-react-app:latest 
