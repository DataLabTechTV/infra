resource "proxmox_download_file" "rocky_10_generic_cloud_qcow2_img" {
  content_type       = "import"
  datastore_id       = "local"
  file_name          = "Rocky-10-GenericCloud.latest.x86_64.qcow2"
  node_name          = var.pm_node
  url                = "https://download.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud.latest.x86_64.qcow2"
  checksum           = "9fc9e9ff16888bb68ac39b0392e25c9c92684d50c85f1cce6ab549363bbc4b48"
  checksum_algorithm = "sha256"
}
