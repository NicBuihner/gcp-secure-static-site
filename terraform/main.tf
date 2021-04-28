provider "google" {
  project     = "secure-static-site"
  region      = "us-central1"
}

resource "google_service_account" "storage_get" {
  account_id   = "secure-storage-get"
  display_name = "Secure storage retrieval service account."
}

resource "google_project_iam_member" "storage_get" {
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.storage_get.email}"
}

resource "google_cloud_run_service" "storage_get" {
  name     = "secure-storage-service"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/secure-static-site/cloud-storage-proxy"
        env {
          name = "BUCKET_NAME"
          value = google_storage_bucket.secure_static.name
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  name                  = "secure-storage-get-backend"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_run {
    service = google_cloud_run_service.storage_get.name
  }
}

resource "google_compute_backend_service" "secure_get_sneg" {
  name                            = "secure-storage-get-backend"
  connection_draining_timeout_sec = 10
  protocol = "HTTPS"
  backend {
    group = google_compute_region_network_endpoint_group.cloudrun_neg.self_link
  }
}

resource "google_iap_web_backend_service_iam_binding" "iap_perms" {
  project = google_compute_backend_service.secure_get_sneg.project
  web_backend_service = google_compute_backend_service.secure_get_sneg.name
  role = "roles/iap.httpsResourceAccessor"
  members = [
    "allAuthenticatedUsers",
  ]
}

resource "google_storage_bucket" "secure_static" {
  name          = "secure-static-site"
  location      = "US"
  force_destroy = true
}

resource "google_storage_bucket_object" "example_obj" {
  name   = "index.html"
  source = "resources/index.html"
  bucket = google_storage_bucket.secure_static.name
}

resource "google_compute_global_address" "secure_get" {
    name = "secure-static-address"
}

resource "google_compute_managed_ssl_certificate" "secure_get" {
  name = "secure-static-cert"
  managed {
    domains = ["secstat.example.com"]
  }
}

resource "google_compute_url_map" "secure_get" {
  name            = "secure-service-url"
  default_service = google_compute_backend_service.secure_get_sneg.id
}

resource "google_compute_target_https_proxy" "secure_get" {
  name   = "secure-static-https-proxy"

  url_map          = google_compute_url_map.secure_get.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.secure_get.id
  ]
}

resource "google_compute_forwarding_rule" "secure_get" {
  name   = "secure-get-foward"
  region = "us-central1"
  port_range = "443"
  target                = google_compute_target_https_proxy.secure_get.id
  network_tier          = "STANDARD"
}
