resource "boundary_host_catalog" "backend_servers" {
  name        = "backend_servers"
  description = "Web servers for backend team"
  type        = "static"
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_host" "backend_servers" {
  for_each        = var.target_ips
  type            = "static"
  name            = "backend_server_${each.value}"
  description     = "Backend server #${each.value}"
  address         = each.key
  host_catalog_id = boundary_host_catalog.backend_servers.id
}

resource "boundary_host_set" "backend_servers" {
  type            = "static"
  name            = "backend_servers"
  description     = "Host set for backend servers"
  host_catalog_id = boundary_host_catalog.backend_servers.id
  host_ids        = [for host in boundary_host.backend_servers : host.id]
}


resource "boundary_host_catalog" "tamu" {
  name        = "tamu-catalog"
  description = "tamu catalog"
  scope_id    = boundary_scope.core_infra.id
  type        = "static"
}

resource "boundary_host" "net" {
  name            = "net"
  host_catalog_id = boundary_host_catalog.tamu.id
  //scope_id        = boundary_scope.core_infra.id
  address         = "128.194.177.50"
  type            = "static"
}

resource "boundary_host" "bastion" {
  name            = "bastion"
  host_catalog_id = boundary_host_catalog.tamu.id
  //scope_id        = boundary_scope.core_infra.id
  address         = "128.194.177.7"
  type            = "static"
}

resource "boundary_host_set" "tamu-set" {
  name            = "tamu-set"
  host_catalog_id = boundary_host_catalog.tamu.id
  type            = "static"

  host_ids = [
    boundary_host.net.id,
    boundary_host.bastion.id,
  ]
}

resource "boundary_target" "tamu-target" {
  name         = "tamu-target"
  description  = "tamu target"
  default_port = "22"
  scope_id     = boundary_scope.core_infra.id
  type         = "tcp"

  host_set_ids = [
    boundary_host_set.tamu-set.id
  ]
}
