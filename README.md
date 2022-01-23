# Personal bash initialization scripts

This repository contains my (as called in [`bash(1)`](https://man.archlinux.org/man/bash.1)) personal bash initialization scripts.

Install them with:

```
$ ln --force --symbolic --relative -- rc.sh ~/.bashrc
$ ln --force --symbolic --relative -- profile.sh ~/.bash_profile
```

A relative symlink must be renewed if the link target (`script.sh`) is relocated, i.e., if the git repository directory is moved.
