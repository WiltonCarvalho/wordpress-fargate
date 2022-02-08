#!/bin/bash
# https://www.getpagespeed.com/server-setup/php/cleanup-php-sessions-like-a-pro
SESSION_PATH="/var/lib/php/sessions"
date
echo "Before: $(ls -1 $SESSION_PATH | wc -l)"
php -d session.save_path=$SESSION_PATH -d session.gc_probability=1 -d session.gc_divisor=1 -d session.gc_maxlifetime=3600 -r "session_start(); session_destroy();"
echo "After: $(ls -1 $SESSION_PATH | wc -l)"
date
