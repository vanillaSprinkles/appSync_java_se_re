#!/bin/bash
## appSync_java_se_re.sh
## https://github.com/vanillaSprinkles/appSync_java_se_re
## build 2

repo="/tmp/JAVA REPO"

LINUX=0
MACOSX=0
WINDOWS=1
SOLARIS=0

APP="appSync_java_se_re"
APPf="appSync: java se re"
checksumFile="checksums.md5"


## NO EMAIL YET
email_on_new=1
email_who="admin@localhost"
#  ctime="$(datime ns)"   ## https://github.com/vanillaSprinkles/rc/tree/master/HOME/.bscripts
  ctime="$(date '+%Y.%m.%d_%H.%M.%S')"
  em_sub_prefix="${APPf}: "
  # em_sub_custom= ( 0 | "<custom text>" )
  em_sub_custom=0
  em_bdy_prefix="${APP} "
  # em_bdy_custom= ( 0 | "<custom text>" )
  em_bdy_custom=0


# Working Directory
TWDIR="/tmp/${APP}"


AGENT="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:18.0) Gecko/20100101 Firefox/18.0"
REFERER="http://www.oracle.com/technetwork/java/javase/downloads/index.html"
URL="http://www.oracle.com/technetwork/java/javase/downloads/index.html"



### where the work begins ###
# coder's debug
DEBUG=0


# create work dir
mkdir -p ${TWDIR}
if ! [ -d ${TWDIR} ] || ! [ -w ${TWDIR} ]; then
    echo "cannot write to ${TWDIR}; premature exit"
    exit
fi




function send_email() {
    file="${1}"
    SUB="${em_sub_prefix} ${em_sub_custom}"
    [[ $em_sub_custom == 0 ]] && SUB="${em_sub_prefix} ${file}"
    BDY="${em_bdy_prefix} \n${em_bdy_custom}"
#    [[ $em_bdy_custom == 0 ]] && BDY="${em_bdy_prefix} \n${ctime} \n${file} \n${repo//\/\\} \n${2}"
    [[ $em_bdy_custom == 0 ]] && BDY="${em_bdy_prefix} \n${ctime} \n\n${file} \n$(echo "${repo}" | sed 's/\//\\\\/g')\\\\${file} \n\n${2}"
    echo -e "${BDY}" > "${TWDIR}/em_msg.txt"
    /bin/mail -s "$SUB" "$email_who" < "${TWDIR}/em_msg.txt"
}

# test if repo folder cannot be accessed
TR=$(touch "${repo}"'/touch.file' 2>&1)
if [[ "${TR}" =~ "cannot touch" ]]; then
  echo "folder not accessible: \"${repo}\""
  exit
fi
rm -f "${repo}/touch.file"



DLFILE=${TWDIR}/${APP}.grepme

# start ripping the site
rm -f ${DLFILE}
#wget --quiet -q  --user-agent="${AGENT}" --referer=${REFERER}  --header "X-Requested-With: XMLHttpRequest"  --header "Cookie: ${COOKIE}"  ${URL} -O ${DLFILE}  2>/dev/null
wget --no-check-certificate  --quiet -q  --user-agent="${AGENT}" --referer=${REFERER}   ${URL} -O ${DLFILE}  2>/dev/null


newURL="http://www.oracle.com"$(/bin/grep -Eo "/technetwork/java/javase/downloads/jre[0-9]*-downloads-[0-9]*\.html" ${DLFILE})
COOKIE=$( echo "gpw_e24=${newURL}" | sed 's/\//%2F/g' | sed 's/:/%3A/g' )
## is newURL but HTML encoded 
### COOKIE+="gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjre7-downloads-1880261.html"

if [[ $DEBUG -eq 1 ]]; then
  echo ${newURL}
fi
rm -f ${DLFILE}
#wget --quiet -q  --user-agent="${AGENT}" --referer=${REFERER}  --header "X-Requested-With: XMLHttpRequest"  --header "Cookie: ${COOKIE}"  ${newURL} -O ${DLFILE}  2>/dev/null
wget --no-check-certificate  --quiet -q  --user-agent="${AGENT}" --referer=${REFERER}   ${newURL} -O ${DLFILE}  2>/dev/null

##  downloads['jre-7u25-oth-JPR']['title'] = "Java SE Runtime Environment 7u25";
TITLE=$( /bin/grep -Eo "\['title'\].*Runtime Env.*\"" ${DLFILE} | /bin/grep -Eo "Java.*[0-9]{1,2}u[0-9]{1,2}")
if [[ $DEBUG -eq 1 ]]; then
  echo $TITLE
fi
VER=$(echo ${TITLE} | /bin/grep -Eo "[0-9]{1,2}u[0-9]{1,2}$")

urlBIN=($( grep -Eo "http.*jre-${VER}.*\"" ${DLFILE} | sed 's/"//g'  ))

DLP="${TWDIR}/jre-${VER}"
mkdir -p "${DLP}"
CHKFILE="${DLP}/${checksumFile}"

REFERER="${newURL}"
### checksums
# /technetwork/java/javase/downloads/java-se-binaries-checksum-1956892.html
newURL="http://www.oracle.com"$(/bin/grep -Eo "/technetwork/java/javase/downloads/java-se-binaries-checksum-[0-9]*\.html" ${DLFILE})
wget --no-check-certificate --quiet -q "${newURL}" -O ${DLFILE}

APPnMD5=($(grep -s -E -A1 ">jre-[0-9]*u[0-9]*-.*\.[0-9a-z]*[0-9.a-z]*<" "${DLFILE}" | grep -v "\-\-" | sed 's/<[/]*td>//g'))
APPnMD5_sz=${#APPnMD5[@]}
APPnMD5_ls=""
rm -f "${CHKFILE}"
for (( i=0; i<APPnMD5_sz; i++ )); do
  if (( i%2 == 0 )); then
#    echo "${APPnMD5[$i]} ${APPnMD5[$((i+1))]} " >> "${CHKFILE}"
    echo "${APPnMD5[$((i+1))]} ${APPnMD5[$i]}" >> "${CHKFILE}"
    if [[ $DEBUG -eq 1 ]]; then
      echo "${APPnMD5[$((i+1))]} ${APPnMD5[$i]}"
    fi
  fi
done
### end checksums

### download binaries
for dlurl in ${urlBIN[@]}; do 
  WskipRegEx='windows-.*\.tar\.gz$'
  MskipRegEx='macosx-.*\.tar\.gz$'
  LskipRegEx='linux-.*\.tar\.gz$'
  SskipRegEx='solaris-SKIPNOTATHING'
  if [[ $WINDOWS -eq 0 ]]; then WskipRegEx='windows'; fi
  if [[ $MACOSX  -eq 0 ]]; then MskipRegEx='macosx';  fi
  if [[ $LINUX   -eq 0 ]]; then LskipRegEx='linux';   fi
  if [[ $SOLARIS -eq 0 ]]; then SskipRegEx='solaris'; fi
  if [[ ${dlurl} =~ ${WskipRegEx} || ${dlurl} =~ ${MskipRegEx} || ${dlurl} =~ ${LskipRegEx} || ${dlurl} =~ ${SskipRegEx} ]]; then
    continue
  fi
  if [[ $DEBUG -eq 1 ]]; then
    echo "${dlurl}   ${dlurl##*/}"
    #echo -e "wget --no-check-certificate  --quiet -q --user-agent=\"${AGENT}\" --referer=${REFERER}   --header \"Cookie: ${COOKIE}\"   ${dlurl}  -O \"${DLP}/${dlurl##*/}\"\n"
  else
    ## literally download binary file
    if [ ! -e "${DLP}/${dlurl##*/}" ]; then
      wget --no-check-certificate  --quiet -q --user-agent="${AGENT}" --referer=${REFERER}   --header "Cookie: ${COOKIE}"   ${dlurl}  -O "${DLP}/${dlurl##*/}"
    else
      echo "exists: ${DLP}/${dlurl##*/}"
    fi
  fi
  ## md5 check section
  # if BIN file exists, continue to checksum
  if [ -e "${DLP}/${dlurl##*/}" ]; then
    # get index of MD5 for current file, export to md5 temp-file
    for (( i=0 ; i<APPnMD5_sz; i++ )); do
      if (( i%2 == 0 )); then
        if [[ "${APPnMD5[$i]}" == "${dlurl##*/}" ]]; then
          echo "${APPnMD5[$((i+1))]} ${DLP}/${dlurl##*/}" > "${TWDIR}/curBin.md5"
          continue
        fi
      fi
    done
    echo "md5 checking"
    md5sum -c "${TWDIR}/curBin.md5" 2>&1 | /bin/grep -Eoq "OK"
    # if md5 check is not okay, remove the file
    if [[  $? -eq 1 ]]; then
      rm -f "${DLP}/${dlurl##*/}"
      if [[ $DEBUG -eq 1 ]]; then
        echo "checksum failed, removing binary: ${DLP}/${dlurl##*/}"
      fi
    fi
    echo "end md5 check section"
  fi
  ## end md5 check
done
### end download binaries


### cleanup
if [[ $DEBUG -eq 0 ]]; then
  # move binaries from temp to repo
  mv "${DLP}" "${repo}"/.
  # cleanup
  rm -f ${DLFILE}
  rm -rf ${TWDIR}
fi



exit
DLURL="http://download.oracle.com/otn-pub/java/jdk/7u25-b17/jre-7u25-windows-i586-iftw.exe"
wget -s --no-check-certificate  --quiet -q --user-agent="${AGENT}" --referer=${REFERER}   --header "Cookie: ${COOKIE}"   ${DLURL}  -O ${TWDIR}/not.one.meg.exe
echo $COOKIE
