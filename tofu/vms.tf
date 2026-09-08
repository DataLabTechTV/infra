resource "proxmox_download_file" "rocky_10_generic_cloud_qcow2_img" {
  content_type       = "import"
  datastore_id       = "local"
  file_name          = "Rocky-10-GenericCloud.latest.x86_64.qcow2"
  node_name          = var.pm_node
  url                = "https://download.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud.latest.x86_64.qcow2"
  checksum           = "3c35f0e2960e6062bda80ffd8a62ad35e185807b4747126acc7868a8ecafce3e"
  checksum_algorithm = "sha256"
}
