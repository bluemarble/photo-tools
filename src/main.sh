nulldev=/dev/null

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
__fingerprintOneFile()
{
   local fn="__fingerprintOneFile"

   local file="$1"
   log.debug $fn "generate fingerprint for: ${file}"
   getFingerprint "${file}"
}

# int
main()
{
   local folder="$1"
   if [ ! -d "${folder}" ] ; then
      log.error main "not a folder: ${folder}"
      return 1
   fi

   log.setLogLevel debug

   ftw --callback __fingerprintOneFile "${folder}"
}
