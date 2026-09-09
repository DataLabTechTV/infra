locals {
  vms = {
    proxy = {
      vm_id = 301
      cores = 2
      memory = {
        dedicated = 2048
        floating  = 2048
      }
      size = 32
    },
    data = {
      vm_id = 302
      cores = 4
      memory = {
        dedicated = 8096
        floating  = 8096
      }
      size = 100
    },
    forge = {
      vm_id = 303
      cores = 4
      memory = {
        dedicated = 6144
        floating  = 6144
      }
      size = 100
    }
  }
}

resource "proxmox_download_file" "rocky_10_generic_cloud_qcow2_img" {
  content_type       = "import"
  datastore_id       = "local"
  file_name          = "Rocky-10-GenericCloud.latest.x86_64.qcow2"
  node_name          = var.pm_node
  url                = "https://download.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud.latest.x86_64.qcow2"
  checksum           = "9fc9e9ff16888bb68ac39b0392e25c9c92684d50c85f1cce6ab549363bbc4b48"
  checksum_algorithm = "sha256"
}

resource "random_password" "vm" {
  for_each = local.vms
  length  = 20
  special = false
}

resource "proxmox_virtual_environment_file" "vm_cfg" {
  for_each = local.vms

  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.pm_node

  source_raw {
    data = templatefile("cloud-config.yaml.tftpl", {
      hostname   = each.key
      password   = random_password.vm[each.key].result
      extra_cmds = []
    })

    file_name = "${each.key}.cloud-config.yaml"
  }
}

resource "proxmox_hardware_mapping_pci" "gpu_vga" {
  name = "gpu_vga"
  map = [
    {
      node         = var.pm_node
      path         = "0000:01:00.0"
      id           = "10de:1f15"
      subsystem_id = "17aa:3a47"
      iommu_group  = 10
    }
  ]
}

resource "proxmox_hardware_mapping_pci" "gpu_audio" {
  name = "gpu_audio"
  map = [
    {
      node         = var.pm_node,
      path         = "0000:01:00.1",
      id           = "10de:10f9",
      subsystem_id = "10de:10f9"
      iommu_group  = 10
    }
  ]
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = local.vms

  node_name = var.pm_node
  vm_id     = local.vms[each.key].vm_id
  tags      = ["infra"]

  started = false
  on_boot = false

  agent {
    enabled = true
  }

  cpu {
    cores = try(local.vms[each.key].cores, 1)
    type  = "host"
  }

  memory {
    dedicated = try(local.vms[each.key].memory.dedicated, 1024)
    floating  = try(local.vms[each.key].memory.floating, 1024)
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    size         = try(local.vms[each.key].size, 20)
    file_id      = proxmox_download_file.rocky_10_generic_cloud_qcow2_img.id
  }

  operating_system {
    type = "l26"
  }

  machine = "q35"

  dynamic "hostpci" {
    for_each = try(local.vms[each.key].gpu, false) ? [
      proxmox_hardware_mapping_pci.gpu_vga.name,
      proxmox_hardware_mapping_pci.gpu_audio.name
    ] : []

    content {
      device  = "hostpci${hostpci.key}"
      mapping = hostpci.value
      pcie    = true
    }
  }

  name = each.key

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.vm_cfg[each.key].id
  }

  lifecycle {
    prevent_destroy = true
  }
}
