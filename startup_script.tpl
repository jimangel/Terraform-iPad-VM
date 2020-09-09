# install terraform repo
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# install tailscale repo
curl https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add -
sudo apt-add-repository "deb https://pkgs.tailscale.com/stable/ubuntu focal main"

# install docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# install mosh, tailscale, terraform, docker, make
sudo apt update && sudo apt -y install mosh terraform tailscale docker-ce make

tailscale up --authkey=${tailscale_key}
