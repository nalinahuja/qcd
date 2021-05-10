# Display Prompt
command echo -e "qcd: Currently running ${__B}${QCD_RELEASE_VER}${__N}"

# Prompt User For Confirmation
command read -p "→ Confirm update [y/n]: " confirm

# Determine Action
if [[ ${confirm//Y/${__YES}} == ${__YES} ]]
then
  # Clear Previous Outputs
  _clear_output 1

  # Verify Curl Dependency
  if [[ -x "$(command -v curl)" ]]
  then
    # Display Prompt
    command echo -e "→ Curl dependency not installed"

    # Terminate Program
    return ${__ERR}
  fi

  # Display Prompt
  command echo -en "→ Downloading update "

  # Get Download URL
  local download_url=$(command curl --connect-timeout ${__DELAY} -sL "${QCD_RELEASE_URL}" 2> /dev/null | command egrep -s -o "https.*zipball.*" 2> /dev/null)

  # Verify Download URL
  if [[ ${?} -ne ${__OK} || -z ${download_url} ]]
  then
    # Display Prompt
    command echo -e "\r→ Failed to resolve download source for update"

    # Terminate Program
    return ${__ERR}
  fi

  # Download Release Contents
  command curl --connect-timeout ${__DELAY} -sL "${download_url%\",}" > "${QCD_RELEASE}"

  # Error Check Release Contents
  if [[ ${?} -ne ${__OK} || ! -f "${QCD_RELEASE}" ]]
  then
    # Display Prompt
    command echo -e "\r→ Failed to download update"

    # Terminate Program
    return ${__ERR}
  fi

  # Display Prompt
  command echo -en "\r→ Installing updates  "

  # Extract And Install Program Files
  command unzip -o -j "${QCD_RELEASE}" -d "${QCD_FOLD}" &> /dev/null

  # Error Check Installation
  if [[ ${?} -ne ${__OK} ]]
  then
    # Display Prompt
    command echo -e "\r→ Failed to install update"

    # Terminate Program
    return ${__ERR}
  fi

  # Display Prompt
  command echo -en "\r→ Configuring updates "

  # Update Terminal Environment
  command source "${QCD_EXEC}" 2> /dev/null

  # Error Check Installation
  if [[ ${?} -ne ${__OK} ]]
  then
    # Display Prompt
    command echo -e "\r→ Failed to configure update "

    # Terminate Program
    return ${__ERR}
  fi

  # Cleanup Installation
  command rm "${QCD_RELEASE}" "${QCD_INSTALL}" 2> /dev/null

  # Display Prompt
  command echo -e "\r→ Update complete     "

  # Clear Previous Outputs
  _clear_output 2

  # Display Prompt
  command echo -e "qcd: Updated to ${__B}${QCD_RELEASE_VER}${__N}"
else
  # Clear All Outputs
  _clear_output 2
fi

# Terminate Program
return ${__OK}
