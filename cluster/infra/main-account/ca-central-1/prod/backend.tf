terraform {
  backend "s3" {
    bucket = "hoaraujerome-k8s-homelab"
    key    = "terraformstate/main-account/ca-central-1/prod"
    region = "ca-central-1"
  }
}
