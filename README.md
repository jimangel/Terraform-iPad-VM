# Terraform iPad VM

Create a VM on Google Cloud to do dev work on an iPad.

Why anyone wants to do this:

- Traveling with two laptops (work and personal) is clunky
- I can use the iPad as my social consumption device *and* developer laptop
- It's fun to play with tech and push the limits

## Assumptions

- The following CLI tools installed on a **non-iPad** Linux workstation:
  - [terraform](https://www.terraform.io/downloads.html)
  - [gcloud](https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu)
- A (free) [Tailscale](https://tailscale.com/) account setup for WireGuard VPN management.
- An iPad
  - with the (free) [Tailscale](https://tailscale.com/kb/1020/install-ios?q=ipad) client installed for VPN access.
  - with the ($20) [blink.sh](https://blink.sh/) app installed for terminal access.

## Overview

![](/img/banner.jpg)

## Setup

On your non-iPad Linux workstation clone the repo

```
git clone git@github.com:jimangel/Terraform-iPad-VM.git
cd Terraform-iPad-VM
```

### Get a one-off Tailscale authorization key

Navigate to https://login.tailscale.com/admin/authkeys. Choose 'Create a new key' > 'One-off key'

Export the key as a Terraform variable; replacing `YOUR_KEY` with the key provided.

```
export TF_VAR_tailscale_key=YOUR_KEY
```

The key auto-authenticates your server to Tailscale upon creation. It uses GCP's startup scripts and Terraform's template (see `startup_script.tpl` for more info).

The startup script does a lot of stuff specific to my use case. Please review before deploying.

### Create the VM

Setup the `gcloud` cli; replacing `PROJECT_ID` with your project ID.

```
gcloud auth login

gcloud config set project PROJECT_ID
```

Export the project ID as a Terraform variable

```
export TF_VAR_project_id=$(gcloud config get-value core/project 2>/dev/null)
```

Export GCP auth token (valid for 1 hour) and project for Terraform

```
export GOOGLE_OAUTH_ACCESS_TOKEN="$(gcloud auth print-access-token)"
export GOOGLE_PROJECT="$(gcloud config get-value project)"
```

Dry-run to initialize and plan the deployment

```
terraform init && terraform plan
```

Create the VM*

```
terraform apply
```

*It might take a few minutes for the startup script (provisioning Tailscale) to run after the VM starts.


## Setup GCP SSH access from the iPad

On your iPad, use Blink to create an ssh key. `ssh-keygen` is available, so we can create our SSH keys.

Replace `USERNAME` with your preferred username.

```
ssh-keygen -t rsa -b 4096 -C “USERNAME”

# press 'Enter' to take defaults

# copy to clipboard
cat ~/.ssh/id_rsa.pub | pbcopy
```

### Add SSH public key to GCP

Swipe out of blink.sh and open a browser and log in to [console.cloud.google.com](https://console.cloud.google.com). Navigate to:

- Compute Engine
- VM instances
- click on `ipad-cloud` > Edit
- Under "You have 0 SSH keys" > "Show and edit"
- Paste content of public key by taping in the box and long holding > "Paste"
- Save (at the bottom)

### Add SSH private key to blink.sh

Add the key:
- type `cat ~/.ssh/id_rsa | pbcopy`
- type `config`
- Keys > "+"
- Import from clipboard
- (enter a name for the key) > Save

### Add GCP host to blink.sh

Use the VM's IP from [Tailscale](https://login.tailscale.com/admin/machines) to replace the `IP_ADDRESS`.

- Hosts > "+"
- Host: gcp-vm
- HostName: `IP_ADDRESS`
- Key: (switch None to your key) > Go back and Save

## Test connectivity

Log in to the server using [mosh](https://mosh.org/) (a mobile friendly SSH terminal supported by blink.sh):

```
mosh gcp-vm

# accept fingerprint if asked
# accept disk write access if asked
```

You *should* be in! 🎉

## Extra stuff

Any parameter in this Terraform file can be overwritten by exporting a variable.

### Run in a different zone

Find the region closest to you with http://www.gcping.com/ and set the Terraform zone variable. Tip: find the zones with `gcloud compute zones list --filter=region:REGION_ID`

```
export TF_VAR_availability_zone=YOUR_ZONE
```

### Use a different VM name

```
export TF_VAR_vm_name=YOUR_NAME
```

### Use a different machine type

Search machine types with `gcloud compute machine-types list --zones=YOUR_ZONE`

```
# Defaults to: e2-medium
export TF_VAR_machine_type=YOUR_TYPE

# e2 instances from cheapest to more expensive:
# - e2-micro (2x1GB shared CPU)
# - e2-small (2x2GB shared CPU)
# - e2-medium (2x4GB shared CPU)
# - e2-standard-2 (2x8GB dedicated CPU)
```

## Troubleshooting

- Check the output of `startup_script`.

    ```
    sudo journalctl -u google-startup-scripts.service
    ```

- Delete Hosts or Keys in blink.sh navigate to them by typing `config` and then swipe left > `Delete`.

- Expose kubectl commands over tailscale:

    ```
    kubectl port-forward deployment/kubernetes-dashboard -n kube-system 8443:8443 --address `Tailscale_IP`
    ```

    Navigate to: `Tailscale_IP`:8443

- Forward / tunnel ports to your ipad

    Use two fingers to tap your blink.sh shell (opens a new terminal). Change between the terminals by swiping right or left. Run:

    ```
    ssh -L LOCALPORT:localhost:REMOTEPORT <REMOTE IP>
    # ex: ssh -L 1313:localhost:1313 192.168.1.250
    ```

    As long as that terminal session is open, the tunnel will exist.
