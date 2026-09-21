locals {
  // Each context is an infrastructure configuration, followed by
  // a category (e.g., vms), and one or multiple hosts.
  contexts = {
    lab = {
      vms = {
        ca = {
          vm_id = 301
          cores = 1
          memory = {
            dedicated = 1024
            floating = 1024
          }
          size = 16
        },
        proxy = {
          vm_id = 302
          cores = 2
          memory = {
            dedicated = 2048
            floating  = 2048
          }
          size = 32
        },
        data = {
          vm_id = 303
          cores = 4
          memory = {
            dedicated = 8192
            floating  = 8192
          }
          size = 100
        },
        forge = {
          vm_id = 304
          cores = 4
          memory = {
            dedicated = 6144
            floating  = 6144
          }
          size = 100
        },
      }
    }
  }
}
