set working-directory := '..'

_default:
    @just _env_help
    @just --justfile '{{module_file()}}' --list --unsorted

[working-directory: 'bootc/']
build-iso:
    mkdir -p {{justfile_directory()}}/output/bootc
    sudo podman build -f Containerfile -t localhost/rockylinux-homelab:latest .
    sudo podman run --rm --privileged \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        -v {{justfile_directory()}}/output/bootc:/output \
        quay.io/centos-bootc/bootc-image-builder:latest \
        --type iso \
        localhost/rockylinux-homelab:latest
