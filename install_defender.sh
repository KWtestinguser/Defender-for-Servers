#!/bin/bash

# Set variables for your GitHub repo and branch
REPO="KWtestinguser/Defender-for-Servers"
BRANCH="main"

# Filenames
INSTALLER="mde_installer.sh"
ONBOARD="MicrosoftDefenderATPOnboardingLinuxServer.py"

# Download the installer script
curl -O "https://raw.githubusercontent.com/$REPO/$BRANCH/$INSTALLER"

# Download the onboarding script
curl -O "https://raw.githubusercontent.com/$REPO/$BRANCH/$ONBOARD"

# Make the installer executable
chmod +x $INSTALLER

# Run the installer with onboarding
sudo ./$INSTALLER --install --onboard ./$ONBOARD --channel prod --min_req

# Wait a few seconds for the service to start
sleep 10

# Check if mdatp is installed and healthy
if command -v mdatp >/dev/null 2>&1; then
    HEALTH=$(mdatp health --field healthy 2>/dev/null)
    if [[ "$HEALTH" == "true" ]]; then
        echo "✅ Microsoft Defender for Endpoint installed and healthy!"
    else
        echo "⚠️  Microsoft Defender for Endpoint installed, but health check failed."
        mdatp health
    fi
else
    echo "❌ Installation failed: mdatp command not found."
fi

# Remove installer and onboarding files if they exist
for file in "$INSTALLER" "$ONBOARD"; do
    if [ -f "$file" ]; then
        rm -fv "$file"
    fi
done
