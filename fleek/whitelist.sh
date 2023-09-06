#!/bin/bash

# Defaults
defaultName="lgnt"
defaultLightningLogPath="/var/log/lightning"
defaultLightningDiagnosticFilename="diagnostic.log"
defaultLightningOutputFilename="output.log"
defaultLightningDiagnosticLogAbsPath="$defaultLightningLogPath/$defaultLightningDiagnosticFilename"
defaultLightningOutputLogAbsPath="$defaultLightningLogPath/$defaultLightningOutputFilename"
defaultLightningSystemdServiceName="$defaultName"
defaultLightningSystemdServicePath="/etc/systemd/system/$defaultLightningSystemdServiceName.service"

(
  exec < /dev/tty;

  while read -rp "🤖 Have you followed the onboarding process instructed in our documentation site? (yes/no) " answer; do
    if [[ "$answer" == [nN] || "$answer" == [nN][oO] ]]; then
      echo "💡 To run a Fleek Network node you'll have to request access to our testnet. Read the instructions provided in https://docs.fleek.network/docs/node/testnet-onboarding before proceeding. If you fail to request access and get the confirmation, the node will not run successfully."

      exit 1
    elif [[ "$answer" == [yY] || "$answer" == [yY][eE][sS] ]]; then
      break;
    fi

    printf "💩 Uh-oh! We expect a yes or no answer. Try again...\n"
  done

  read -rp "💡 Remember that if you have requested access to testnet, you'll need to receive the confirmation by the Fleek Network team, if you haven't received a confirmation yet please be patient. We try to onboard node operators as soon as possible. Press ENTER to continue..."

  echo

  if [[ ! -f "$defaultLightningSystemdServicePath" ]]; then
      echo "👹 Oops! The systemd unit service file for Fleek Network $defaultName was not found, meaning that you have not followed or accepted the recommendations in our installation document. Make sure you setup a systemd service https://docs.fleek.network/docs/node/Install/#systemd-service-setup"

      exit 1
  fi

  while read -rp "🤖 This process requires to clear the logs and restart the service. Should it clear the logs and restart the service? (yes/no) " answer; do
    if [[ "$answer" == [nN] || "$answer" == [nN][oO] ]]; then
      echo "👹 Oops! The whitelist verification was exited."
      
      exit 1
    elif [[ "$answer" == [yY] || "$answer" == [yY][eE][sS] ]]; then
      sudo rm "$defaultLightningOutputLogAbsPath"
      sudo rm "$defaultLightningDiagnosticLogAbsPath"

      systemctl restart "$defaultName"

      serverOutputWaitAttempts=0
      while [[ -f "$defaultLightningOutputLogAbsPath" && ! -s "$defaultLightningOutputLogAbsPath" ]]; do
        echo "🤖 Please wait for the service output logs..."
        sleep 5

        if [[ "$serverOutputWaitAttempts" -gt 10 ]]; then
          break
        fi

        ((serverOutputWaitAttempts++))
      done

      echo

      if curl -qsS localhost:4069/health 2>/dev/null | grep -q 'OK'; then
        echo "🌈 The service health check was successful! The node is healthy, thus whitelisted."

        exit 0
      else
        if tail -n 5 "$defaultLightningOutputLogAbsPath" | grep -iq "node is not whitelisted"; then
          echo "👹 Oops! According to your output log, the server and node doesn't seem to be whitelisted. Have you read the instructions to get onboarded? Find it here https://docs.fleek.network/docs/node/testnet-onboarding"
          echo
        fi

        break;
      fi
    fi

    printf "💩 Uh-oh! We expect a yes or no answer. Try again...\n"
  done

  echo "The whitelist verification has now completed. To learn more about Fleek Network check our documentation at https://docs.fleek.network"
  echo "🙏 Thank you!"
)