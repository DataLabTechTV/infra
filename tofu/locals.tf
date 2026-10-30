locals {
  // Each context is an infrastructure configuration, followed by
  // a category (e.g., vms), and one or multiple hosts.
  contexts = {
    lab = {
      vms = {
        core = {
          vm_id = 301
          cpu = {
            cores = 4
            hotplugged = 2
          }
          memory = {
            dedicated = 2048
            floating = 2048
          }
          size = 16
        },
        proxy = {
          vm_id = 302
          cpu = {
            cores = 8
            hotplugged = 4
          }
          memory = {
            dedicated = 2048
            floating  = 2048
          }
          size = 200
        },
        data = {
          vm_id = 303
          cpu = {
            cores = 16
            hotplugged = 4
          }
          memory = {
            dedicated = 6144
            floating  = 6144
          }
          size = 100
        },
        forge = {
          vm_id = 304
          cpu = {
            cores = 16
            hotplugged = 8
          }
          memory = {
            dedicated = 7168
            floating  = 7168
          }
          size = 200
        },
        gpu = {
          vm_id = 305
          cpu = {
            cores = 16
            hotplugged = 8
          }
          memory = {
            dedicated = 10240
            floating = 10240
          }
          size = 150
          gpu = true
        },
        dev = {
          vm_id = 306
          cpu = {
            cores = 16
            hotplugged = 4
          }
          memory = {
            dedicated = 2048
            floating = 2048
          }
        }
      }
    }
  }
}
