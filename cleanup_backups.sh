#!/bin/bash
cd /mnt/ssd4to/ha || exit 1
ls -1t *.tar 2>/dev/null | tail -n +11 | xargs -r rm --
