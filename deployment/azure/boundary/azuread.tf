//terraform {
//  required_providers {
//    boundary = {
//      source  = "hashicorp/boundary"
//      version = "1.0.2"
//    }
//  }
//}

output "auth-method-id" {
  value = boundary_auth_method_oidc.provider.id
}

resource "boundary_auth_method_oidc" "provider" {
  name                 = "Azure"
  description          = "OIDC auth method for Azure"
  //scope_id             = "o_1234567890"
  scope_id             = boundary_scope.org.id
  issuer               = "https://sts.windows.net/68f381e3-46da-47b9-ba57-6f322b8f0da1/"
  client_id            = "2e0d6b90-cee7-48b0-8fe1-16ff4c267d2e"
  client_secret        = "zx0fn9_i.buCY~~uk~6i5~w8Hi91l6XfX3"
  signing_algorithms   = ["RS256"]
  is_primary_for_scope = true
  api_url_prefix       = var.url

  depends_on = [
    module.boundary.var.url, boundary_scope.orig.id, module.azure.output.url
  ]
}

resource "boundary_account_oidc" "oidc_user" {
  name           = "soren-admin"
  description    = "OIDC account for user1"
  auth_method_id = boundary_auth_method_oidc.provider.id
  issuer  = "https://sts.windows.net/68f381e3-46da-47b9-ba57-6f322b8f0da1/"
  subject = "c00566ad-c9de-4ba0-83f1-fca637fa084a"

  depends_on = [
    boundary_auth_method_oidc.provider.id
  ]
}

