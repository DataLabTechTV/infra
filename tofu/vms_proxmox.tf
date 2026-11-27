locals {
  pm_vms = (
    local.contexts[var.context].hypervisor == "proxmox"
    ? {
      for name, vm in local.contexts[var.context].vms :
      name => merge({ gpu = false }, vm)
    }
    : {}
  )
}

resource "proxmox_download_file" "rocky_10_generic_cloud_qcow2_img" {
  count = length(local.pm_vms) > 0 ? 1 : 0

  content_type       = "import"
  datastore_id       = "local"
  file_name          = local.vm_os.filename
  node_name          = var.proxmox_node
  url                = local.vm_os.url
  checksum           = local.vm_os.sha256
  checksum_algorithm = "sha256"
}

resource "proxmox_virtual_environment_file" "vm_cfg" {
  for_each = local.pm_vms

  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("cloud-config.yaml.tftpl", {
      hostname            = each.key
      hashed_passwd       = data.external.hashed_passwd[each.key].result.hash
      ssh_authorized_keys = [file(var.vm_ssh_public_key_path)]
      extra_cmds          = []
    })

    file_name = "${each.key}.cloud-config.yaml"
  }
}

resource "proxmox_hardware_mapping_pci" "gpu_vga" {
  count = length(local.pm_vms) > 0 ? 1 : 0

  name = "gpu_vga"
  map = [
    {
      node         = var.proxmox_node
      path         = "0000:01:00.0"
      id           = "10de:1f15"
      subsystem_id = "17aa:3a47"
      iommu_group  = 9
    }
  ]
}

resource "proxmox_hardware_mapping_pci" "gpu_audio" {
  count = length(local.pm_vms) > 0 ? 1 : 0

  name = "gpu_audio"
  map = [
    {
      node         = var.proxmox_node,
      path         = "0000:01:00.1",
      id           = "10de:10f9",
      subsystem_id = "10de:10f9"
      iommu_group  = 9
    }
  ]
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = local.pm_vms

  node_name = var.proxmox_node
  vm_id     = local.pm_vms[each.key].vm_id
  tags      = ["infra"]

  started = true
  on_boot = false

  agent {
    enabled = true
    wait_for_ip {
      ipv4 = true
    }
  }

  cpu {
    cores = try(local.pm_vms[each.key].cpu.cores, 1)
    hotplugged = try(local.pm_vms[each.key].cpu.hotplugged, 1)
    type  = "host"
    numa = true
  }

  memory {
    dedicated = try(local.pm_vms[each.key].memory.dedicated, 1024)
    floating  = try(local.pm_vms[each.key].memory.floating, 1024)
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "virtio0"
    size         = try(local.pm_vms[each.key].size, 20)
    file_id      = proxmox_download_file.rocky_10_generic_cloud_qcow2_img[0].id
  }

  operating_system {
    type = "l26"
  }

  machine = "q35"
  hotplug = "network,disk,usb,memory,cpu"

  dynamic "hostpci" {
    for_each = try(local.pm_vms[each.key].gpu, false) ? [
      proxmox_hardware_mapping_pci.gpu_vga[0].name,
      proxmox_hardware_mapping_pci.gpu_audio[0].name
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
    ignore_changes = [
      initialization[0].user_data_file_id,
    ]
  }
}
