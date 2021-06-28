variable "url" {
  default = "https://boundary-a117e800.southcentralus.cloudapp.azure.com:9200"
}

variable "backend_team" {
  type = set(string)
  default = [
    "soren-back",
    "amarcontell-back",
  ]
}

variable "frontend_team" {
  type = set(string)
  default = [
    "soren-front",
    "amarcontell-front",
  ]
}

variable "leadership_team" {
  type = set(string)
  default = [
    "soren",
    "amarcontell",
  ]
}

variable "target_ips" {
  type    = set(string)
  default = []
}

// Moved to secrets.tf that isn't sync'd to github

//variable "tenant_id" {}

//variable "vault_name" {}

//variable "client_secret" {}

//variable "client_id" {}
