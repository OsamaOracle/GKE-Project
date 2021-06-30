module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on   = [module.gke]
  project_id   = var.project_id
  location     = module.gke.location
  cluster_name = module.gke.name
}
resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "kubeconfig-${var.env_name}"
}
module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 2.5"
  project_id   = var.project_id
  network_name = "${var.network}-${var.env_name}"
  subnets = [
    {
      subnet_name   = "${var.subnetwork}-${var.env_name}"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.region
    },
  ]
  secondary_ranges = {
    "${var.subnetwork}-${var.env_name}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "10.30.0.0/16"
      },
    ]
  }
}

module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id             = var.project_id
  name                   = "${var.cluster_name}-${var.env_name}"
  regional               = true
  region                 = var.region
  network                = module.gcp-network.network_name
  subnetwork             = module.gcp-network.subnets_names[0]
  ip_range_pods          = var.ip_range_pods_name
  ip_range_services      = var.ip_range_services_name
  node_pools = [
    {
      name                      = "node-pool"
      machine_type              = "e2-medium"
      #node_locations            = "europe-west1-b,europe-west1-c,europe-west1-d"
      min_count                 = 1
      max_count                 = 2
      disk_size_gb              = 30
    },
  ]
}

resource "kubernetes_deployment" "app" {
  provider = kubernetes
  metadata {
    name = "wordpress-app"
    labels = {
      App = "wordpress-app"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "wordpress-app"
      }
    }
    template {
      metadata {
        labels = {
          App = "wordpress-app"
        }
      }
      spec {
        container {
          image = "wordpress"
          name  = "wordpress-app"

          port {
            container_port = 80
          }
          env {
              name = "WORDPRESS_DB_HOST"
              value = "3.138.255.8"
              }
          env {    
              name = "WORDPRESS_DB_USER"
              value = "root"
           }
          env { 
              name = "WORDPRESS_DB_PASSWORD"
              value = "root@123"
          }
          env {
              name = "WORDPRESS_DB_NAME"
              value = "wordpress"
          }   
        }
      }
    }
  }
}

resource "kubernetes_service" "loadbalancer" {
  provider = kubernetes
  metadata {
    name = "wordpress-pp"
  }
  spec {
    selector = {
      App = kubernetes_deployment.app.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}