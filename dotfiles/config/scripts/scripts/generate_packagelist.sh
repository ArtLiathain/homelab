#!/bin/bash

# --- Configuration ---
REPO_FILE="pkglist.txt"
AUR_FILE="pkglist_aur.txt"

# Check for a common AUR helper (paru is highly recommended)
AUR_HELPER="yay"

# --- Main Script ---

echo "Starting Arch Package List Generation..."
echo "------------------------------------------------"

# 1. GENERATE AUR PACKLIST (Foreign/AUR Packages)
echo "-> Generating AUR List: $AUR_FILE"

if command -v "$AUR_HELPER" &> /dev/null; then
    # Query explicitly installed foreign (AUR) packages (-Qme) and print only the package name (awk)
    "$AUR_HELPER" -Qme | awk '{print $1}' > "$AUR_FILE"
    echo "   [SUCCESS] AUR packages saved to $AUR_FILE"
else
    echo "   WARNING: AUR helper ($AUR_HELPER) not found. Cannot accurately generate $AUR_FILE."
    echo "   Falling back to pacman query for all foreign packages (less accurate)."
    pacman -Qmq | awk '{print $1}' > "$AUR_FILE"
fi

# 2. GENERATE REPO PACKLIST (Official Packages)
echo "-> Generating Official Repo List: $REPO_FILE"

# Query pacman for all explicitly installed packages (-Qe)
# This includes both repo and AUR packages.
pacman -Qe > "$REPO_FILE.tmp"

# Filter out the packages found in the AUR list
if [ -s "$AUR_FILE" ]; then
    # -v: Invert match (print lines NOT matching)
    # -F: Fixed strings (treat names literally)
    # -f: Get patterns from the AUR_FILE
    # Print only the package name (awk)
    grep -vFf "$AUR_FILE" "$REPO_FILE.tmp" | awk '{print $1}' > "$REPO_FILE"
    echo "   [SUCCESS] Official packages (filtered) saved to $REPO_FILE"
else
    # If the AUR file was empty or not generated, just save the full explicit list
    echo "   WARNING: AUR filter list was empty. Saving all explicit packages."
    awk '{print $1}' "$REPO_FILE.tmp" > "$REPO_FILE"
fi

# Clean up temporary file
rm "$REPO_FILE.tmp"


echo "------------------------------------------------"
echo "Package list generation complete."
echo "Files are saved in the current directory:"
echo "  - $REPO_FILE"
echo "  - $AUR_FILE"
