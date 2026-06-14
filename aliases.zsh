alias k='kubectl'

alias checkout='git checkout $(git branch -a | fzf)'

# when starting a new pi session make sure that the github token is loaded

pi() {
    echo "test"
    ssh-add ~/.ssh/id_ed25519_github
    command pi "$@"
}
