### PRE-REQUISITES:
# *Enable the Notebooks API before running this TF (https://console.cloud.google.com/marketplace/product/google/notebooks.googleapis.com)
## Error: Error creating Instance: googleapi: Error 403: Notebooks API has not been used in project 665604794145 before or it is disabled. 
### 
locals {
  # CHANGEME
  project_name = "tutorial-344120" # The project
}

# Note this requires running a gcloud auth application-default login
provider "google" {
  project = locals.project_name
}



##1. Create a Service Account
resource "google_service_account" "analyst_notebook" {
  account_id   = "analyst-notebook"
  display_name = "SA for analysts to access BQ datasets via Vertex notebook"
}

##2. Create a User Managed Notebook that uses that Service Account
resource "google_notebooks_instance" "analyst_notebook" {
  name     = "analyst-rstudio-notebook"
  location = "us-west1-a"
  #CHANGEME
  machine_type = "e2-medium"
  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "r-latest-cpu-experimental"
  }

  service_account = google_service_account.analyst_notebook.email
}

##3A ALlow ability to run BQ jobs on all datasets in project
resource "google_project_iam_member" "project" {
  project = locals.project_name #CHANGEME if the target datasets are in diff project.
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.analyst_notebook.email}"
}


##3B Allow ability to READ on a SPECIFIC BQ dataset.
resource "google_bigquery_dataset_iam_member" "analyst_notebook_data_viewer" {
  project    = locals.project_name #CHANGEME, if the target datasets are in diff project.
  dataset_id = "rick_morty"
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.analyst_notebook.email}"
}


##4. Allow only  the intended user to use the SA and by extension, the notebook
resource "google_service_account_iam_binding" "analyst_notebook_service_account_binding-iam" {
  service_account_id = google_service_account.analyst_notebook.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    #CHANGEME - who should have access to assume the Service Account (and access the Notebook)
    "user:thilina.ratnayake1@gmail.com",
  ]
}
