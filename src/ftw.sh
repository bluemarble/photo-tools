#
# ftw.shf -- file tree walker
#

# static int
__ftw_internal()
{
   local dir="$1"

   local callback="true"
   if [ "$2" != "" ] ; then
      callback="$2"
   fi

   for entry in "${dir}"/* ; do
      "${callback}" "${entry}"
      if [ -d "${entry}" ] ; then
         __ftw_internal "${entry}" "${callback}"
      fi
   done

   return 0
}

#
# ftw - walk a filesystem, invoking a user-supplied callback for
# each file or directory found.
#

# int
ftw()
{
   local fname="ftw"

   local startDir="."
   local callback=""
   local breadthFirst_p=t

   while [ $# -gt 0 ] ; do
      case "$1" in
         --depthfirst)
            breadthFirst_p=f
            ;;
         --breadthfirst)
            breadthFirst_p=t
            ;;
         --callback)
            callback="$2"
            shift
            ;;
         --help)
            printf "Usage: ${fname} [ --callback expression ] [ --depthfirst | --breadthfirst ] [ dir ]\n"
            return 0
            ;;
         *)
            break
            ;;
      esac
      shift
   done

   if [ $# -gt 0 ] ; then
      startDir="$1"
   fi

   if [ ! -d "${startDir}" ] ; then
      echo >&2 "${fname}: ${startDir} is not a directory"
      return 1
   fi

   __ftw_internal "${startDir}" "${callback}"

   return $?
}

#
# End of ftw.shf
#
