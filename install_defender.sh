# Bash script to:
# - Download Microsoft Defender installer and onboarding script from GitHub
# - Onboard the device
# - Check if the installation was successful
# - Remove the installer and onboarding script after successful install
# - Remove this Bash script itself after successful install

#!/bin/bash
set -e

# Optional: log output to a file
exec > >(tee install_defender.log) 2>&1

# GitHub repository details
REPO="KWtestinguser/Defender-for-Servers"
BRANCH="main"
INSTALLER="mde_installer.sh"
ONBOARD="MicrosoftDefenderATPOnboardingLinuxServer.py"

# Download installer and onboarding script
curl --fail --silent --show-error -O "https://raw.githubusercontent.com/$REPO/$BRANCH/$INSTALLER"
curl --fail --silent --show-error -O "https://raw.githubusercontent.com/$REPO/$BRANCH/$ONBOARD"

# Verify downloads succeeded
if [[ -f "$INSTALLER" && -f "$ONBOARD" ]]; then
    chmod +x "$INSTALLER"
    sudo ./"$INSTALLER" --install --onboard "./$ONBOARD" --channel prod --min_req
else
    echo "❌ One or both required files are missing after download."
    exit 1
fi

# Give Defender some time to settle
sleep 10

# Check Defender installation health
if command -v mdatp >/dev/null 2>&1; then
    HEALTH=$(mdatp health --field healthy 2>/dev/null)
    if [[ "$HEALTH" == "true" ]]; then
        echo "✅ Microsoft Defender for Endpoint installed and healthy!"
        # Clean up installer and onboarding script
        rm -fv "$INSTALLER" "$ONBOARD"
        # Delete this script
        rm -fv -- "$0"
    else
        echo "⚠️ Microsoft Defender for Endpoint installed, but health check failed:"
        mdatp health
    fi
else
    echo "❌ Installation failed: mdatp command not found."
fi
