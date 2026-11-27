locals {
  virt_vms = (
    local.contexts[var.context].hypervisor == "libvirt"
    ? {
      for name, vm in local.contexts[var.context].vms :
      name => merge({ gpu = false }, vm)
    }
    : {}
  )
}
