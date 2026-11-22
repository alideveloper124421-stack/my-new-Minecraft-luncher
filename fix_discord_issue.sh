#!/bin/bash
set -e

echo "=== FIXING DISCORD SDK ISSUE ==="

# Step 1: app/build.gradle se Discord dependency hatao
echo "[1/4] Removing Discord dependencies from build.gradle..."
BUILD_GRADLE="app/build.gradle"

# Discord implementation lines ko comment out karo
sed -i 's/implementation.*discord.*$/\/\/ &/g' "$BUILD_GRADLE"
sed -i 's/implementation files.*libs.*discord.*$/\/\/ &/g' "$BUILD_GRADLE"

# Agar flatDir libs mention hai toh usko bhi comment karo agar sirf discord ke liye hai
if grep -q "flatDir.*libs" "$BUILD_GRADLE"; then
    echo "   ⚠ flatDir libs found - keeping it but Discord files commented"
fi

echo "   ✓ Discord dependencies commented out"

# Step 2: Discord-related Java/Kotlin files ko find karo
echo ""
echo "[2/4] Finding Discord-related source files..."
DISCORD_FILES=$(find app/src -type f \( -name "*.java" -o -name "*.kt" \) | xargs grep -l -i "discord" 2>/dev/null || true)

if [ -n "$DISCORD_FILES" ]; then
    echo "   Found Discord-related files:"
    echo "$DISCORD_FILES" | while read f; do echo "     - $f"; done
    
    # Un files mein Discord imports ko comment karo
    echo ""
    echo "[3/4] Commenting Discord imports and usage..."
    echo "$DISCORD_FILES" | while read f; do
        if [ -n "$f" ]; then
            # Discord imports comment karo
            sed -i 's/^import.*discord.*$/\/\/ &/g' "$f"
            # Discord class usage comment karo (basic attempt)
            sed -i 's/\bDiscord[A-Z][a-zA-Z]*\b/\/\/ &/g' "$f"
        fi
    done
    echo "   ✓ Discord code commented"
else
    echo "   ✓ No Discord source files found"
fi

# Step 3: AndroidManifest.xml se Discord metadata hatao
echo ""
echo "[4/4] Cleaning AndroidManifest.xml..."
MANIFEST="app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
    # Discord APP_ID metadata remove karo
    sed -i '/com.discord.*APP_ID/,+1d' "$MANIFEST"
    sed -i '/discord_partner/d' "$MANIFEST"
    echo "   ✓ Discord metadata removed from manifest"
fi

echo ""
echo "=== FIX COMPLETE ==="
echo "Next: Commit and push to GitHub"
