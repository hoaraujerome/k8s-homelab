terraform {
  backend "s3" {
    key    = "terraformstate/main-account/ca-central-1/prod"
    region = "ca-central-1"
  }
}
