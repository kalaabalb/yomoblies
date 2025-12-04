#!/bin/bash

USERNAME="kalaabalb"
REPO="yomoblies"
TAG="v1.0.5"

echo "🔍 Checking release status for $USERNAME/$REPO"

echo "1. Checking repository..."
curl -s "https://api.github.com/repos/$USERNAME/$REPO" | grep -q '"id"' && echo "✅ Repository exists" || echo "❌ Repository not found"

echo "2. Checking latest release..."
RELEASE_INFO=$(curl -s "https://api.github.com/repos/$USERNAME/$REPO/releases/latest")
echo "$RELEASE_INFO" | grep -q '"id"' && echo "✅ Release exists" || echo "❌ No release found"

echo "3. Checking APK download..."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://github.com/$USERNAME/$REPO/releases/download/$TAG/app-release.apk")
if [ "$STATUS" = "200" ]; then
    echo "✅ APK downloadable (HTTP 200)"
    SIZE=$(curl -s -I "https://github.com/$USERNAME/$REPO/releases/download/$TAG/app-release.apk" | grep -i "content-length" | awk '{print $2}' | tr -d '\r')
    echo "   File size: $(echo "scale=2; $SIZE/1024/1024" | bc) MB"
else
    echo "❌ APK not found (HTTP $STATUS)"
fi

echo "4. Checking workflow..."
WORKFLOW=$(curl -s "https://api.github.com/repos/$USERNAME/$REPO/actions/runs")
echo "$WORKFLOW" | grep -q '"conclusion":"success"' && echo "✅ Workflow succeeded" || echo "⚠️  Workflow may have failed"

echo ""
echo "📱 Download links:"
echo "APK: https://github.com/$USERNAME/$REPO/releases/download/$TAG/app-release.apk"
echo "Page: https://github.com/$USERNAME/$REPO/releases/tag/$TAG"
echo "All: https://github.com/$USERNAME/$REPO/releases"
