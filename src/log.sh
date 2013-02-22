let __log_currentLogLevel=1

log.setLogLevel()
{
   case "$1" in
   d*) let __log_currentLogLevel=7 ;;
   w*) let __log_currentLogLevel=5 ;;
   e*) let __log_currentLogLevel=1 ;;
   *)  echo >&2 "log: unrecognized log level $1"
       return 1
       ;;
   esac
   return 0
}

# level 7
log.debug()
{
   [ $__log_currentLogLevel -ge 7 ] && echo >&2 "D" $*
}
# level 5
log.warning()
{
   echo >&2 "W" $*
}
# level 1
log.error()
{
   echo >&2 "E" $*
}
