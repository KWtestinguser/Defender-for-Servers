#!/bin/bash
set -e

# Optional: log output to a file
exec > >(tee install_defender.log) 2>&1

REPO="KWtestinguser/Defender-for-Servers"
BRANCH="main"
INSTALLER="mde_installer.sh"
ONBOARD="MicrosoftDefenderATPOnboardingLinuxServer.py"

# Download files
curl --fail --silent --show-error -O "https://raw.githubusercontent.com/$REPO/$BRANCH/$INSTALLER"
curl --fail --silent --show-error -O "https://raw.githubusercontent.com/$REPO/$BRANCH/$ONBOARD"

# Check files exist before running
if [[ -f "$INSTALLER" && -f "$ONBOARD" ]]; then
    chmod +x "$INSTALLER"
    sudo ./"$INSTALLER" --install --onboard "./$ONBOARD" --channel prod --min_req
else
    echo "❌ One or both required files are missing after download."
    exit 1
fi

# Wait for Defender to settle
sleep 10

# Check Defender status
if command -v mdatp >/dev/null 2>&1; then
    HEALTH=$(mdatp health --field healthy 2>/dev/null)
    if [[ "$HEALTH" == "true" ]]; then
        echo "✅ Microsoft Defender for Endpoint installed and healthy!"
        # Clean up
        rm -fv "$INSTALLER" "$ONBOARD"
    else
        echo "⚠️ Microsoft Defender for Endpoint installed, but health check failed:"
        mdatp health
    fi
else
    echo "❌ Installation failed: mdatp command not found."
fi
