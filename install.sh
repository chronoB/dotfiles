#!/usr/bin/env bash
set -e

# Stow packages to install (dotfiles)
STOW_PACKAGES=(zsh p10k git ssh oh-my-zsh)

# Apt packages to install
# Note: unzip is needed for fnm
APT_PACKAGES=(zsh curl stow unzip fzf)

install_packages() {
    echo "Installing packages via apt..."
    sudo apt update
    # Install packages defined in APT_PACKAGES
    sudo apt install -y "${APT_PACKAGES[@]}"
}

stow_dotfiles() {
    echo "Stowing dotfiles..."
    cd "$(dirname "$0")"  # go to dotfiles repo root
    stow "${STOW_PACKAGES[@]}"
}

setup_ssh() {
    echo "Setting up GitHub SSH key..."
    SSH_KEY="$HOME/.ssh/id_ed25519_github"

    # Get email from git config
    GIT_EMAIL=$(git config --global user.email)
    if [ -z "$GIT_EMAIL" ]; then
        echo "Error: git user.email not set. Make sure your .gitconfig is stowed first."
        exit 1
    fi

    # Generate SSH key if it doesn't exist
    if [ ! -f "$SSH_KEY" ]; then
        echo "Creating new SSH key..."
        ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY"
        echo "SSH key created at $SSH_KEY"

        # Output the public key for GitHub
        echo
        echo "-----------------------------------------------------"
        echo "Your GitHub SSH public key:"
        echo
        cat "$SSH_KEY.pub"
        echo
        echo "-----------------------------------------------------"
        echo "Please add this key to your GitHub account now."
        read -rp "Press ENTER after you have added it to GitHub to continue..."

        # Add entry to the allowed_signers file (https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgsshallowedSignersFile). 
        # For more info see (https://stackoverflow.com/questions/77935996/git-commit-s-silently-fails-to-sign-and-continues-to-commit-when-using-ssh)
        ALLOWED_SIGNERS="$HOME/.ssh/allowedSigners"
        mkdir -p "$(dirname "$ALLOWED_SIGNERS")"
        PUB_KEY_FILE="$SSH_KEY.pub"
        if [ ! -f "$PUB_KEY_FILE" ]; then
            echo "Warning: public key $PUB_KEY_FILE not found; skipping allowedSigners update"
        else
            if [ ! -f "$ALLOWED_SIGNERS" ]; then
                echo "# Add your public key pair you wish to trust" > "$ALLOWED_SIGNERS"
            fi
            ENTRY="$(git config --get user.email) namespaces=\"git\" $(cat "$PUB_KEY_FILE")"
            if ! grep -Fxq "$ENTRY" "$ALLOWED_SIGNERS"; then
                echo "$ENTRY" >> "$ALLOWED_SIGNERS"
                chmod 600 "$ALLOWED_SIGNERS"
                echo "Added public key to $ALLOWED_SIGNERS"
            else
                echo "Public key already present in $ALLOWED_SIGNERS"
            fi
        fi
    else
        echo "SSH key $SSH_KEY already exists, skipping"
    fi
    
    echo "Adding the key to the ssh-agent..."
        
    # Start ssh-agent if not running
    eval "$(ssh-agent -s)"

    # Add key to ssh-agent (won't duplicate)
    ssh-add -l | grep -q "$SSH_KEY" || ssh-add "$SSH_KEY"

    echo "Changing remote to git@github (ssh)..."
    git remote set-url origin git@github.com:chronob/dotfiles.git

    echo "SSH key setup complete."
    echo
}

install_oh_my_zsh() {
    echo "Installing oh-my-zsh..."
    OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
    if [ ! -d "$OH_MY_ZSH_DIR" ]; then
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "oh-my-zsh already installed"
    fi
}

install_powerlevel10k() {
    echo "Installing Powerlevel10k..."
    P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [ ! -d "$P10K_DIR" ]; then
        git clone git@github.com:romkatv/powerlevel10k.git "$P10K_DIR"
    else
        echo "powerlevel10k already installed"
    fi
}

install_fzf() {
    FZF_DIR="$HOME/.fzf"
    if [ ! -d "$FZF_DIR" ]; then
        echo "Installing full fzf via SSH..."
        git clone git@github.com:junegunn/fzf.git "$FZF_DIR"
        "$FZF_DIR/install" --all --no-bash --no-fish
    else
        echo "Full fzf already installed"
    fi
}

install_zsh_autosuggestions() {
    echo "Installing zsh-autosuggestions..."
    ZSH_AUTOSUGGESTIONS_DIR="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    if [ ! -d "$ZSH_AUTOSUGGESTIONS_DIR" ]; then
        git clone git@github.com:zsh-users/zsh-autosuggestions.git "$ZSH_AUTOSUGGESTIONS_DIR"
    else
        echo "zsh-autosuggestions already installed"
    fi
}

install_zsh_syntax_highlighting() {
    echo "Installing zsh-syntax-highlighting..."
    ZSH_SYNTAX_DIR="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    if [ ! -d "$ZSH_SYNTAX_DIR" ]; then
        git clone git@github.com:zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_DIR"
    else
        echo "zsh-syntax-highlighting already installed"
    fi
}

install_fasd (){
    echo "Installing fasd..."
  FASD_DIR="$HOME/.oh-my-zsh/custom/plugins/fasd"
  if [ ! -d "$FASD_DIR" ]; then
      git clone git@github.com:clvv/fasd.git "$FASD_DIR"
  else
      echo "fasd already installed"
  fi

}

install_fnm() {
    echo "Installing fnm (Fast Node Manager)..."
    if ! command -v fnm &>/dev/null; then
        curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    else
        echo "fnm already installed"
    fi
}


# -------------------------
# Main
# -------------------------
main() {
    install_packages
    stow_dotfiles
    setup_ssh
    install_oh_my_zsh
    install_powerlevel10k
    install_fzf
    install_zsh_autosuggestions
    install_zsh_syntax_highlighting
    install_fasd
    install_fnm

    # Ask the user if they want to make Zsh the default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        read -rp "Do you want to make Zsh your default shell? [y/N] " answer
        case "$answer" in
            [Yy]* )
                echo "Changing default shell to Zsh..."
                chsh -s "$(which zsh)"
                echo "Default shell changed. You may need to log out and log back in for it to take effect."
                # Start zsh for current session
                echo "Launching zsh..."
                exec zsh
                ;;
            * )
                echo "Skipping changing the default shell."
                ;;
        esac
    fi




    echo "Bootstrap complete!"
}

# Call main
main
