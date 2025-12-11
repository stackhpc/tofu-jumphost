data "external" "git_info" {
  program = ["${path.module}/git-info.sh"]
}

locals {
  image_name = coalesce(var.image_name, basename(coalesce(var.image_url, ".")))
  git_info = data.external.git_info.result
}

resource "openstack_images_image_v2" "jumphost" {
  for_each = toset(var.image_url != null ? [""] : [])
  name             = local.image_name
  image_source_url = var.image_url
  web_download     = true
  container_format = "bare"
  disk_format      = coalesce(var.image_format, element(split(".", var.image_url), -1))
}

data "openstack_images_image_v2" "jumphost" {
  
  name = local.image_name
  depends_on = [
    openstack_images_image_v2.jumphost
  ]
}

resource "openstack_compute_instance_v2" "jumphost" {
  image_id    = data.openstack_images_image_v2.jumphost.id
  flavor_name = var.flavor
  key_pair    = var.default_key_pair # NB: normally null
  name = var.instance_name

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

  metadata = {
    git_remote = "${local.git_info.remote}"
    git_branch = "${local.git_info.branch}"
    git_commit = "${local.git_info.commit}"
  }
}

data "openstack_networking_port_v2" "jumphost" {
  device_id = openstack_compute_instance_v2.jumphost.id
}

resource "openstack_networking_floatingip_associate_v2" "jumphost" {

  floating_ip = var.floating_ip
  # openstack_compute_instance_v2.jumphost.network[0].port = "" so instead use:
  port_id = data.openstack_networking_port_v2.jumphost.id
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

output "jumphost_vars" {
  value = {
    jumphost_ip = var.floating_ip
    jumphost_user  = var.ssh_user
  }
}
