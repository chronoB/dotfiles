# dotfiles

To setup on a new machine

```sh
sudo apt update
sudo apt install git
git clone https://github.com/chronoB/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

# Commit signing for github
To make sure your commits are correctly signed for github, you must add the ssh pub key both as an authentication as well as a signing key to github.

Your commits won't be shown as verified locally because I have not setup a allowedsignersfile (https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgsshallowedSignersFile). For more info see (https://stackoverflow.com/questions/77935996/git-commit-s-silently-fails-to-sign-and-continues-to-commit-when-using-ssh)
