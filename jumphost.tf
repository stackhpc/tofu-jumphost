locals {
  image_name = coalesce(var.image_name, basename(var.image_url))
}

resource "openstack_images_image_v2" "jumphost" {
  name             = local.image_name
  image_source_url = var.image_url
  web_download     = true
  container_format = "bare"
  disk_format      = element(split(".", local.image_name), -1)

  properties = {
    key = "value"
  }
}

resource "openstack_compute_instance_v2" "jumphost" {
  name        = "jumphost"
  image_id    = openstack_images_image_v2.jumphost.id
  flavor_name = var.flavor
  key_pair    = var.default_key_pair # NB: normally null


  network {
    name = var.network
  }

  security_groups = var.security_group_names

  user_data = templatefile("${path.module}/cloud-config.tftpl",
    {
      debug           = var.debug
      authorised_keys = var.authorised_keys
      user            = var.ssh_user
      bantime         = var.bantime
    }
  )
}

data "openstack_networking_port_v2" "jumphost" {
  device_id = openstack_compute_instance_v2.jumphost.id
}

resource "openstack_networking_floatingip_associate_v2" "jumphost" {

  floating_ip = var.floating_ip
  # openstack_compute_instance_v2.jumphost.network[0].port = "" so instead use:
  port_id = data.openstack_networking_port_v2.jumphost.id
}

resource "local_file" "jumphost_vars" {
  filename = "${dirname(path.root)}/../site/inventory/group_vars/all/jumphost.yml"
  content  = <<-EOT
    jumphost_ip: ${var.floating_ip}
    jumphost_user: ${var.ssh_user}
  EOT
}

resource "local_file" "cloud-init" {
  for_each = toset(var.debug ? [""] : [])

  filename = "cloudinit.yaml"
  content = templatefile("${path.module}/cloud-config.tftpl",
    {
      debug           = var.debug
      authorised_keys = var.authorised_keys
      user            = var.ssh_user
      bantime         = var.bantime
    }
  )
}
