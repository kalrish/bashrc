# Personal bash initialization script

This repository contains my (as called in [`bash(1)`](https://man.archlinux.org/man/bash.1)) personal bash initialization script.

Install it with:

```
$ ln --force --symbolic --relative -- script.sh ~/.bashrc
```

A relative symlink must be renewed if the link target (`script.sh`) is relocated, i.e., if the git repository directory is moved.
