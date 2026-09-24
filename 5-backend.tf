terraform {
  backend "s3" {
    bucket       = "tfstate-benji-lambda-sns-2026"
    key          = "lambda-to-sns/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}