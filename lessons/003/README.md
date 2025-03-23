# Deploying a Static HTML Site with Docker and Nginx

Hello, Guys.To deploy a piece of software, you need a virtual machine image (VM image) to store the software with its dependencies (libraries, interpreters, sub-packages, compilers, extensions, and so on). However, these images are large and unwieldy, time-consuming to build and maintain, fragile to operate, slow to download and deploy, and vastly inefficient in performance and resource footprint.
In order to solve this problem, the tech industry borrowed an idea from the shipping industry, the container: a standard packaging and distribution format that is generic and widespread, enabling the increased carrying capacity, lower costs, economies of scale, and ease of handling. The container format contains everything the application needs to run, baked into an image file that can be executed by a container runtime.
The most popular tool for building and running containers is Docker.

You can find tutorial [here](https://www.youtube.com/watch?v=P0FuqXlS_ow&ab_channel=DevOps).

0:09 - Intro
0:33 - Create a Directory for the Website
0:50 - Let's create a HTML application
0:55 - Create a file called Dockerfile
1:30 - Build the Docker Image for the HTML Server
1:46 - Let's create a Repository of our image on Docker Hub
3:04 - Upload our Docker Image from Docker Hub to PC
3:19 - Run the Docker Container
3:26 - Test our site http://localhost:8080/

# console commands:
```
cd
mkdir
```

```
git init
git status
git add .
git commit -a -m "upd1"
git push
git push -u origin main
```
```
docker login
docker push
docker images
docker rmi XXXXXXXXX -f
docker build -t html-site:latest .
docker tag local-image:tagname new-repo:tagname
docker tag html-site:latest mainoceanm895/html-site:v1.0
docker push new-repo:tagname
docker push mainoceanm895/html-site:v1.0
docker run -d -p 8080:80 mainoceanm895/html-site:v1.0
docker restart modest_haslett

curl http://localhost:8080/
```
# sites:
https://shorturl.at/LrmhM
https://hub.docker.com/

Photo by Kelly L: 
https://www.pexels.com/photo/fully-loaded-cargo-ship-sailing-on-sea-12530465/
