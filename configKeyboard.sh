﻿#!/bin/bash
#!/bin/bash
### Assistance script for configuring keyboard.

### General Script Variables & Functions
scriptDescription="Config Keyboard"
scriptMaxArgs=0
scriptMinArgs=0
scriptRequireRootUser=1
beginScript() {
  echo -e "\n Executing $0 ..."
  echo -e "------- [BEGIN] $scriptDescription ..."
  
  # Ensure root user if needed.  
  if [[ "$scriptRequireRootUser" -eq 1 ]] && [[ "$EUID" -ne 0 ]]; then
    echo " --- [Error] Must be root user."
    exitScript -1
  # Ensure scriptDescription is not empty.
  elif [[ -n "$scriptDescription" ]]; then
    echo " --- [InternalError] scriptDescription is empty."
    exitScript -1
  # Ensure scriptMinArgs > 0.
  elif [[ "$scriptMinArgs" -lt 0 ]]; then
    echo " --- [InternalError] scriptMinArgs < 0."
    exitScript -1
  # Ensure scriptMaxArgs >= scriptMinArgs.
  elif [[ "$scriptMaxArgs" -lt "$scriptMinArgs" ]]; then
    echo " --- [InternalError] scriptMaxArgs < scriptMinArgs."
    exitScript -1
  # Ensure number of args >= scriptMinArgs.
  elif [[ "$#" -lt "$scriptMinArgs" ]]; then
    echo " --- [Error] Too few parameters ($#). Expected >= $scriptMinArgs."
    exitScript -1
  # Ensure args count <= scriptMaxArgs.
  elif [[ "$#" -gt "$scriptMaxArgs" ]]; then
    echo " --- [Error] Too many parameters ($#). Expected <= $scriptMaxArgs."
    exitScript -1
  fi
}
exitScript() { # $1 -> int for this script's exit code. 0 is success.
  if [[ "$1" -eq 0 ]]; then
    echo -e " ------- [SUCCESS] $scriptDescription."
  else
    echo -e " ------- [FAILED] $scriptDescription."
  fi
  echo -e "\n Exited $0."
}

### Script-specific Variables and Functions
installDir="/etc/default"
fileName="keyboard"

### SCRIPT BEGIN
touch fileName
cat <<- EOF > ${fileName}
	XKBMODEL="pc105"
	XKBLAYOUT="us"
	XKBVARIANT=""
	XKBOPTIONS=""
	BACKSPACE="guess"
EOF
sudo mv -f ${fileName} "${installDir}${fileName}"



exitScript 0