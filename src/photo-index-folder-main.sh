# public string
normalizeFilename()
{
   local varname="${1}"
   local varvalue=
   eval varvalue="${PWD}/\${${varname}}"
   while true ; do
      case "${varvalue}" in
      *//*) varvalue="${varvalue%//*}/${varvalue##*//}" ;;
      *)   break ;;
      esac
   done
   eval ${varname}="${varvalue}"
}

# public string
getFingerprint()
{
   local fn="getFingerprint"

   local file="$1"
   if [ -f "${file}" ] ; then
      # todo: write gensignature(1) loadable for bash - generates hash directly
      dd if="${file}" bs=1k count=1 2>${nulldev} | md5sum --binary | sed -e 's/ \*-//'
   else
      log.error $fn "not a regular file: ${file}"
      false
   fi
   return $?
}

# void callback
__progressIndicator()
{
   spinner --next
}

# void callback
__fingerprintOneFile()
{
   local fn="__fingerprintOneFile"
   eventpool.fireEvent "fingerprint"

   if [ ! -f "$1" ] ; then
      return
   fi

   # normalize file names: replace // -> /
   local file="$1"
   normalizeFilename file

   local contentsHash="$(getFingerprint "${file}")"
   local filenameHash="$(echo "${file}" | md5sum | sed -e 's/ \*-//')"

   if [ $checkOnly = y ] ; then
      local entry="$(db.entry "${contentsHash}" "${filenameHash}")"
      if [ -d "${entry}" ] ; then
         printf "E %s\n" "${file}"
      else
         printf "N %s\n" "${file}"
      fi
      return
   fi

   log.debug $fn "generate fingerprint for: ${file}, ${contentsHash}"
   echo "${file}"
   echo "   contents-hash: ${contentsHash}"
   echo "   filename-hash: ${filenameHash}"

   echo "${file}" | db.create "${contentsHash}" "${filenameHash}"
}

# int
photo.index()
{
   #spinner --start
   ftw --callback __fingerprintOneFile "${folder}"
   #spinner --end
   return 0
}

# void
error()
{
   echo >&2 "error: $*"
}

# void
usage()
{
   echo "
Usage: ${_cmdname} [ options ] directory [ directory ... ]
Index images and videos found in the specified folders.

   -h, --help     show this message and exit
   --checkonly    do not index files, just list whether they exist in the index
   --index <dir>  specify .dbphoto folder.  Default is $HOME/.dbphoto
   --debug        debug logging
   "
}

# globals
checkOnly=n

# int
main()
{
   dbRoot="${HOME}"/.dbphoto

   while [ $# -gt 0 ] ; do
      case "${1}" in
      --help|-h)
         usage 
	 return 0 ;;
      --debug)
         log.setLogLevel debug ;;
      --checkonly)
         checkOnly=y ;;
      --index)
         dbRoot="${2}"
	 shift ;;
      -*) 
	 error "unknown option: ${1}"
         usage ; return 1 ;;
      *)
         break ;;
      esac
      shift
   done

   db.init "${dbRoot}"

   local rc
   local folder
   while [ $# -gt 0 ] ; do
      folder="${1}"
      if [ ! -d "${folder}" ] ; then
         log.error main "not a folder: ${folder}"
      else
         photo.index "${folder}"
	 rc=$?
      fi
      shift
   done

   return $rc
}

# vim: set ai
