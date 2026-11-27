locals {
  lv_vms = (
    local.contexts[var.context].hypervisor == "libvirt"
    ? {
      for name, vm in local.contexts[var.context].vms :
      name => merge({ gpu = false }, vm)
    }
    : {}
  )

  gpu_pci = [
    { domain = 0, bus = 1, slot = 0, function = 0 }, # vga   10de:1f15
    { domain = 0, bus = 1, slot = 0, function = 1 }, # audio 10de:10f9
  ]
}

resource "libvirt_volume" "rocky_10_base" {
  count = length(local.lv_vms) > 0 ? 1 : 0

  name = local.vm_os.filename
  pool = var.libvirt_pool

  target = {
    format = {
      type = "qcow2"
    }
  }

  create = {
    content = {
      url = local.vm_os.url
    }
  }
}

resource "libvirt_volume" "vm_disk" {
  for_each = local.lv_vms

  name = "${each.key}.qcow2"
  pool = var.libvirt_pool

  capacity      = try(each.value.size, 20)
  capacity_unit = "GiB"

  target = { format = { type = "qcow2" } }

  backing_store = {
    path   = libvirt_volume.rocky_10_base[0].path
    format = { type = "qcow2" }
  }
}

# 0.9.x: cloudinit_disk only renders a local ISO; upload it as a volume
resource "libvirt_cloudinit_disk" "vm_cfg" {
  for_each = local.lv_vms

  name = "${each.key}-cloudinit"

  user_data = templatefile("cloud-config.yaml.tftpl", {
    hostname            = each.key
    hashed_passwd       = data.external.hashed_passwd[each.key].result.hash
    ssh_authorized_keys = [file(var.vm_ssh_public_key_path)]
    extra_cmds          = []
  })

  meta_data = yamlencode({
    instance-id    = each.key
    local-hostname = each.key
  })

  lifecycle {
    ignore_changes = [user_data, meta_data] # was: ignore user_data_file_id
  }
}

resource "libvirt_volume" "vm_cfg" {
  for_each = local.lv_vms

  name = "${each.key}-cloudinit.iso"
  pool = var.libvirt_pool

  target = { format = { type = "raw" } }

  create = {
    content = { url = libvirt_cloudinit_disk.vm_cfg[each.key].path }
  }
}

resource "libvirt_domain" "vm" {
  for_each = local.lv_vms

  name      = each.key
  type      = "kvm"
  running   = true
  autostart = false

  vcpu        = try(each.value.cpu.cores, 1)

  memory      = try(each.value.memory.dedicated, 1024)
  memory_unit = "MiB"

  current_memory      = try(each.value.memory.floating, 1024)
  current_memory_unit = "MiB"

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    boot_devices = [{ dev = "hd" }]
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool = var.libvirt_pool,
            volume = libvirt_volume.vm_disk[each.key].name
          }
        }

        target = {
          dev = "vda",
          bus = "virtio"
        }

        driver = {
          type = "qcow2"
        }
      },

      {
        device = "cdrom"

        source = {
          volume = {
            pool = var.libvirt_pool,
            volume = libvirt_volume.vm_cfg[each.key].name
          }
        }

        target = {
          dev = "sda",
          bus = "sata"
        }

        driver = {
          type = "raw"
        }
      },
    ]

    interfaces = [
      {
        type   = "bridge"

        model  = {
          type = "virtio"
        }

        source = {
          bridge = {
            bridge = var.libvirt_bridge
          }
        }

        wait_for_ip = {
          timeout = 300
          source  = "agent"
        }
      }
    ]

    channels = [
      {
        source = {
          unix = {}
        }

        target = {
          virt_io = {
            name = "org.qemu.guest_agent.0"
          }
        }
      }
    ]

    hostdevs = each.value.gpu ? [
      for address in local.gpu_pci : {
        subsys_pci = {
          managed = true
          source  = { address = address }
        }
      }
    ] : null
  }
}
