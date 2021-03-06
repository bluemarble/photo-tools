nulldev=/dev/null

# public string
normalizeFilename()
{
   local varname="${1}"
   local varvalue=
   eval varvalue="\${${varname}}"
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
      # todo: write rtrim(1) tool - trims something from the end of a string
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

   log.debug $fn "generate fingerprint for: ${file}, ${contentsHash}"
   echo "${file}"
   echo "   contents-hash: ${contentsHash}"
   echo "   filename-hash: ${filenameHash}"

   echo "${file}" | db.create "${contentsHash}" "${filenameHash}"
}

# int
main()
{
   local folder="$1"
   if [ ! -d "${folder}" ] ; then
      log.error main "not a folder: ${folder}"
      return 1
   fi

   #log.setLogLevel debug
   #eventpool.subscribe fingerprint __progressIndicator

   db.init .dbphoto

   #spinner --start
   ftw --callback __fingerprintOneFile "${folder}"
   #spinner --end
}
