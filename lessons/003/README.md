# Deploying a Static HTML Site with Docker and Nginx

You can find tutorial [here](https://www.youtube.com/watch?v=P0FuqXlS_ow&ab_channel=DevOps).

Todeploy a piece of software, you need a virtual machine image (VM image) to store the software with its dependencies (libraries, interpreters, sub-packages, compilers, extensions, and so on). However, these images are large and unwieldy, time-consuming to build and maintain, fragile to operate, slow to download and deploy, and vastly inefficient in performance and resource footprint.

In order to solve this problem, the tech industry borrowed an idea from the shipping industry, the container: a standard packaging and distribution format that is generic and widespread, enabling the increased carrying capacity, lower costs, economies of scale, and ease of handling. The container format contains everything the application needs to run, baked into an image file that can be executed by a container runtime.

The most popular tool for building and running containers is Docker.


Photo by Kelly L: https://www.pexels.com/photo/fully-loaded-cargo-ship-sailing-on-sea-12530465/
What is Docker?
Docker is several different but related things: a container image format, a container runtime library that manages the life cycle of containers, a command-line tool for packaging and running containers, and an API for container management.

What exactly is a container image? You can think of an image as being like a ZIP file. It’s a single binary file that has a unique ID and holds everything needed to run the container. To run the container with Docker, all you need to specify is a container image ID or URL, and the system will take care of finding, downloading, unpacking, and starting the container for you.

Enough with the theory; let’s start working with Docker and containers. In this demo, we’ll build a simple containerized application (website) and deploy it with Docker and Nginx as a web server.

Step 1 — Create a Directory for the Website
I’ve created a folder to store all of the resources for this demo. You can make your own HTML files and save them in your local directory or you can download the source code from my GitHub repository. You can clone the repository using:

git clone https://github.com/zul-m/zul-m.github.io.git
cd zul-m.github.io
Step 2 — Create a file called Dockerfile
We will create a Dockerfile to build a custom image and add our commands to the file. Notice that in the directory, I have created a Dockerfile with below commands:

FROM nginx:alpine
COPY . /usr/share/nginx/html
We start building our custom image by using a base image. On line 1, you can see we do this using the FROM command to pull the nginx:alpine image to our machine and then build our custom image on top of it.

Next, we COPY the contents of the current directory into the /usr/share/nginx/html directory inside the container provided by nginx:alpine image.

You’ll notice that we did not add an ENTRYPOINT or a CMD to our Dockerfile. We will use the underlying ENTRYPOINT and CMD provided by the base NGINX image.

Step 3 — Build the Docker Image for the HTML Server
To build our image, run the following command:

docker build -t html-server-image:v1 .
The build command will tell Docker to execute the commands located in our Dockerfile. When you build an image, by default, it just gets a hexadecimal ID, which you can use to refer to it later (for example, to run it). These IDs aren’t particularly memorable or easy to type, so Docker allows you to give the image a human-readable name using the -t switch to docker build.

You will see a similar output in your terminal as below:


Docker build command to build our image
You can confirm that this has worked by running this command to check all available images:

docker images
And it should show you output something like this:


Docker images command to list available images
Step 4 — Run the Docker Container
Programs running in a container are isolated from other programs running on the same machine, which means they can’t have direct access to resources like network ports.

The demo application listens for connections on port 80, but this is the container’s own private port 80, not a port on your computer. In order to connect to the container’s port 80, you need to forward a port on your local machine to that port on the container. It could be (almost) any port, including 80, but we’ll use 8080 instead to make it clear which is your port and which is the container’s.

To tell Docker to forward a port, you can use the -p switch:

docker run -d -p 8080:80 html-server-image:v1
Once the container is running as a daemon (-d), any requests to 8080 on the local computer will be forwarded automatically to 80 on the container, which is how you’re able to connect to the app with your browser.

Note: Any port number below 1024 is considered a priviliged port, meaning that in order to use those ports, your process must run as a user with special permissions, such as root. Normal non-administrator users cannot use ports below 1024.

Step 5 — Test the Port
You’re now running your own copy of the demo application, and you can check it by browsing the URL (http://localhost:8080/).


Connect to the application on port 8080
Resources
Steps for Deploying a Static HTML Site with Docker and Nginx (dailysmarty.com)
[Free O’Reilly eBook] Cloud Native DevOps With Kubernetes, 2nd Edition (nginx.com)
How To Use the Official NGINX Docker Image — Docker
