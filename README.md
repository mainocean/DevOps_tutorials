<p dir="auto">
  <a target="_blank" rel="noopener noreferrer" href="/mainocean/blob/main/profile_pic.png">
    <img src="https://media.licdn.com/dms/image/v2/D4E16AQHqSJ60mFunew/profile-displaybackgroundimage-shrink_350_1400/profile-displaybackgroundimage-shrink_350_1400/0/1723568090509?e=1746662400&v=beta&t=3_F2iKrQ0dQtDa6g-gBTyaMPp5vPe3QsIiS6jjSJIHA" alt="My profile picture" style="max-width: 100%;">
  </a>
</p>

# DevOps tutorials

Hello. Welcome to my collection of DevOps tutorials! This repository is designed to guide my through essential DevOps concepts, tools, and workflows, providing practical insights and hands-on examples. Whether you're a beginner or an experienced practitioner, there's something here for everyone.

https://www.youtube.com/watch?v=I4UKAeKV4WQ

# Need for install:

```
Google Cloud SDK    https://shorturl.at/oXVka
kubectl             https://shorturl.at/WR2Q9
                    https://kubernetes.io/releases/download/#binaries
```

# Console commands:

```
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

sudo apt-get -y install apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

sudo apt update
sudo apt-get install -y google-cloud-sdk
gcloud init
sudo apt install kubectl
kubectl version --client
gcloud services enable container.googleapis.com
gcloud container clusters create alex1 --zone europe-west3-a
gcloud container clusters get-credentials alex1 --zone europe-west3-a

gcloud container node-pools create np1 --cluster alex1 --zone europe-west3-a --machine-type e2-medium

gcloud container clusters create alex1 --zone europe-west3-a --machine-type e2-micro

gcloud container clusters create alex1 --zone europe-west3-a --machine-type e2-micro

gcloud container clusters delete my-first-cluster-1 --zone europe-west3-a
```

# Social

🎥 - [YouTube](https://www.youtube.com/@devopseng/playlists)  
💼 - [LinkedIn](https://www.linkedin.com/in/alex-kochenko-732900177/)  
🛠️ - [Twitter/X](https://x.com/)  
📨 - mainoceanm@gmail.com
