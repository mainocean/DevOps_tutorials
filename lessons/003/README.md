
![alt text](image.png)
# Deploying a Static HTML Site with Docker and Nginx
Hello, Guys. Today the tech industry borrowed an idea from the shipping industry, the container: a standard packaging and distribution format that is generic and widespread, enabling the increased carrying capacity, lower costs, economies of scale, and ease of handling. It`s a Docker. So I create Docker Image of my HTML site on DockerHub.

To deploy a piece of software, you need a virtual machine image (VM image) to store the software with its dependencies (libraries, interpreters, sub-packages, compilers, extensions, and so on). However, these images are large and unwieldy, time-consuming to build and maintain, fragile to operate, slow to download and deploy, and vastly inefficient in performance and resource footprint.

In order to solve this problem, the tech industry borrowed an idea from the shipping industry, the container: a standard packaging and distribution format that is generic and widespread, enabling the increased carrying capacity, lower costs, economies of scale, and ease of handling. The container format contains everything the application needs to run, baked into an image file that can be executed by a container runtime.
The most popular tool for building and running containers is Docker.

You can find tutorial [here](https://www.youtube.com/watch?v=wgMnbZw5Rh8&ab_channel=DevOps).


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
Medium.com:   https://shorturl.at/LrmhM \
DockerHub:    https://hub.docker.com \
Photo by Kelly L: https://shorturl.at/QSnCo
