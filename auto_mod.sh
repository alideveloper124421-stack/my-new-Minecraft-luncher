#!/bin/bash
set -e

echo "=== GLITCH AUTO-MOD SCRIPT ==="
echo ""

echo "1/6: PLAY STORE BYPASS (buildConfigField)"
sed -i '/defaultConfig {/a\        buildConfigField "boolean", "SKIP_PLAY_STORE_CHECK", "true"' app/build.gradle
echo "   ✓ SKIP_PLAY_STORE_CHECK added"

echo ""
echo "2/6: GITHUB WORKFLOW CREATE"
mkdir -p .github/workflows
cat << 'EOF' > .github/workflows/build-apk.yml
name: Build LeviLauncher APK

on:
  push:
    branches: [ main, master, develop ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
    
    - name: Grant execute permission for gradlew
      run: chmod +x gradlew
    
    - name: Build Debug APK
      run: ./gradlew assembleDebug
    
    - name: Build Release APK
      run: ./gradlew assembleRelease
    
    - name: Upload Debug APK
      uses: actions/upload-artifact@v4
      with:
        name: LeviLauncher-Debug
        path: app/build/outputs/apk/debug/*.apk
        retention-days: 30
    
    - name: Upload Release APK
      uses: actions/upload-artifact@v4
      with:
        name: LeviLauncher-Release
        path: app/build/outputs/apk/release/*.apk
        retention-days: 30
EOF
echo "   ✓ GitHub workflow created"

echo ""
echo "3/6: GIT INIT + COMMIT"
git init -b main
git config user.email "glitch@modded.local"
git config user.name "GLITCH Modder"
git add .
git commit -m "Bypass Play Store validation - GLITCH mod

- Added SKIP_PLAY_STORE_CHECK buildConfigField
- Added GitHub Actions workflow for automated builds
- Allows running with any Minecraft APK (not just Play Store)"
echo "   ✓ Git repo initialized and committed"

echo ""
echo "4/6: VERIFY MODIFICATIONS"
echo "   app/build.gradle changes:"
grep -n "SKIP_PLAY_STORE_CHECK" app/build.gradle
echo "   GitHub workflow:"
ls -lh .github/workflows/

echo ""
echo "5/6: OPTIONAL LOCAL BUILD (skip if no Java/Gradle)"
if command -v ./gradlew &> /dev/null; then
    echo "   Attempting local build..."
    chmod +x gradlew
    ./gradlew assembleDebug 2>&1 | tail -n 20 || echo "   ⚠ Build failed (normal if dependencies missing)"
    if [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
        cp app/build/outputs/apk/debug/app-debug.apk /sdcard/Download/LeviLauncher-Modded.apk
        echo "   ✓ APK copied to /sdcard/Download/LeviLauncher-Modded.apk"
    fi
else
    echo "   ⚠ gradlew not found, skipping local build"
fi

echo ""
echo "6/6: NEXT STEPS"
echo "   ═══════════════════════════════════════════════════"
echo "   GitHub Repository Setup:"
echo "   1. GitHub par naya repo banao: LeviLauncher-Modded"
echo "   2. Run these commands:"
echo ""
echo "      git remote add origin https://github.com/YOUR_USERNAME/LeviLauncher-Modded.git"
echo "      git push -u origin main"
echo ""
echo "   3. GitHub Actions automatically build karega"
echo "   4. Artifacts section se APK download karo"
echo "   ═══════════════════════════════════════════════════"

echo ""
echo "=== ALL DONE ==="
