set working-directory := '..'

_default:
    @just --justfile '{{module_file()}}' --list --unsorted

build-iso:
    mkdir -p ./local/bootc
    sudo podman build -f ./bootc/Containerfile -t localhost/rockylinux-homelab:latest ./bootc
    sudo podman run --rm --privileged \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        -v ./bootc/config.toml:/config.toml:ro \
        -v ./local/bootc:/output \
        quay.io/centos-bootc/bootc-image-builder:latest \
        --type iso \
        --config /config.toml \
        localhost/rockylinux-homelab:latest
    sudo chown -R $(id -u):$(id -g) ./local/bootc
    mv ./local/bootc/bootiso/install.iso \
       ./local/bootc/bootiso/rockylinux-homelab.iso
