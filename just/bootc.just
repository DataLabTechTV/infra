set working-directory := '..'

_default:
    @just _env_help
    @just --justfile '{{module_file()}}' --list --unsorted

[working-directory: 'bootc/']
build-iso:
    podman build -f Containerfile -t localhost/rockylinux-homelab:latest .
    image-builder build \
        --blueprint config.toml \
        --bootc-ref localhost/rockylinux-homelab:latest \
        --force-repo https://dl.rockylinux.org/pub/rocky/10/BaseOS/x86_64/os/ \
        --force-repo https://dl.rockylinux.org/pub/rocky/10/AppStream/x86_64/os/ \
        iso
