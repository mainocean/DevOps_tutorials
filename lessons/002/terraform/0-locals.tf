locals {
  project_id = "Your_progect_ID" # rename to Your progect ID
  region     = "us-central1"
  apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com",
    "secretmanager.googleapis.com"
  ]
}
