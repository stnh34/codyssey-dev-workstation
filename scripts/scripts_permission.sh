#!/usr/bin/env bash
r(){ echo "\$ $*"; eval "$@" 2>&1; echo; }
cd ~/codyssey/practice
r 'touch perm_file.txt && mkdir -p perm_dir'
r 'ls -l perm_file.txt && ls -ld perm_dir'
r 'stat -c "%A %a %n" perm_file.txt perm_dir'
r 'chmod 755 perm_file.txt'
r 'chmod 700 perm_dir'
r 'stat -c "%A %a %n" perm_file.txt perm_dir'
r 'chmod u=rw,g=r,o=r perm_file.txt'
r 'chmod 755 perm_dir'
r 'stat -c "%A %a %n" perm_file.txt perm_dir'
r 'chmod 600 perm_file.txt && ls -l perm_file.txt'
r 'chmod 644 perm_file.txt && ls -l perm_file.txt'
r 'umask'
