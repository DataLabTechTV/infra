set working-directory := '..'

_default:
    @just --justfile '{{module_file()}}' --list --unsorted

build-iso:
    mkdir -p ./output/bootc
    sudo podman build -f ./bootc/Containerfile -t localhost/ucore-homelab:latest ./bootc
    sudo podman run --rm --privileged \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        -v ./bootc/config.toml:/config.toml:ro \
        -v ./output/bootc:/output \
        quay.io/centos-bootc/bootc-image-builder:latest \
        --type iso \
        --rootfs xfs \
        --config /config.toml \
        localhost/ucore-homelab:latest
    sudo chown -R $(id -u):$(id -g) ./output/bootc
    mv ./output/bootc/bootiso/install.iso \
       ./output/bootc/bootiso/ucore-homelab.iso
