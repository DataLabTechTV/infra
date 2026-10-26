if [[ $- == *i* && -n "$SSH_CONNECTION" && "$PWD" == "$HOME" ]]; then
    cd /workspace
fi
