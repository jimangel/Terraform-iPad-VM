# Setup Google provider
########################
provider "google" {
  project = var.project_id
}

# Deny all ingress traffic firewall rule based on "yolo" tag
#############################################################
resource "google_compute_firewall" "default" {
  name    = "yolo-deny"
  network = "default"

  deny {
    protocol = "all"
  }

  source_tags = ["yolo"]
}

# Allow IAP ssh from gcloud only to this GCE instance
###############################################################
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "iap-allow"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags = ["yolo"]
}

# Create GCP VM
################
resource "google_compute_instance" "default" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.availability_zone

  tags = ["yolo"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    // comment out if you don't want an external IP (will break external connectivity too)
    access_config {
    // Ephemeral IP
    }

  }

  metadata_startup_script = templatefile("${path.module}/startup_script.tpl",
    {
       tailscale_key = var.tailscale_key
    })

  // metadata_startup_script = file("boot-script.sh")

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
