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

# int
main()
{
   getFingerprint "$*"
}
