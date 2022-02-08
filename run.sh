#!/bin/sh
ln -sf /proc/self/fd/1 /tmp/stdout.log
ln -sf /proc/self/fd/2 /tmp/stderr.log
>/tmp/stdout.log 2>/tmp/stderr.log "$@" &
pid="$!"
echo "[ Started PID $pid ]"
trap "echo '[ Stopping PID $pid ]' && kill -$STOPSIGNAL $pid && sleep 5" INT TERM WINCH QUIT
wait $pid
return_code="$?"
exit $return_code
