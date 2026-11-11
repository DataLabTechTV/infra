if [[ $- == *i* && -n "$SSH_CONNECTION" && "$PWD" == "$HOME" ]]; then
    cd /workspace
fi

# Setup npm for user-level installs
mkdir -p "$HOME/.local/share/npm" && npm config set prefix "$HOME/.local/share/npm"
export PATH="$HOME/.local/share/npm/bin:$PATH"
