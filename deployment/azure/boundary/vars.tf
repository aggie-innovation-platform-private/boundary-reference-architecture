variable "url" {
  default = "https://boundary-3f2b995a.southcentralus.cloudapp.azure.com:9200"
}

variable "backend_team" {
  type = set(string)
  default = [
    "jim",
    "mike",
    "todd",
  ]
}

variable "frontend_team" {
  type = set(string)
  default = [
    "randy",
    "susmitha",
  ]
}

variable "leadership_team" {
  type = set(string)
  default = [
    "jeff",
    "pete",
    "jonathan",
    "malnick"
  ]
}

variable "target_ips" {
  type    = set(string)
  default = []
}

variable "tenant_id" {}

variable "vault_name" {}

variable "client_secret" {}

variable "client_id" {}
