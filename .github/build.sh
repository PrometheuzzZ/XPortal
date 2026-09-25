#!/usr/bin/env bash
# Builds XPortal on Linux without a Valheim installation.
# The game assemblies are taken from the free Valheim Dedicated Server (Steam app 896660).
#
# Required: dotnet SDK on PATH, steamcmd dependencies (lib32gcc-s1), curl, unzip.
# Optional: WORK_DIR (where the server and tools are downloaded to), CONFIGURATION (Release/Debug).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${WORK_DIR:-$REPO_DIR/.build}"
CONFIGURATION="${CONFIGURATION:-Release}"
BEPINEX_VERSION="5.4.2351"
VALHEIM_INSTALL="$WORK_DIR/valheim_server"

mkdir -p "$WORK_DIR"

# Valheim Dedicated Server
if [ ! -f "$VALHEIM_INSTALL/valheim_server_Data/Managed/assembly_valheim.dll" ]; then
    mkdir -p "$WORK_DIR/steamcmd"
    curl -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar xz -C "$WORK_DIR/steamcmd"
    # steamcmd sometimes fails with "Missing configuration" on its first connection, so retry
    for attempt in 1 2 3; do
        "$WORK_DIR/steamcmd/steamcmd.sh" +force_install_dir "$VALHEIM_INSTALL" +login anonymous +app_update 896660 validate +quit && break
        if [ "$attempt" -eq 3 ]; then exit 1; fi
        echo "steamcmd failed, retrying ($attempt)..."
    done
fi
# Jotunn looks for valheim_Data, the server calls it valheim_server_Data
ln -sfn valheim_server_Data "$VALHEIM_INSTALL/valheim_Data"

# BepInEx
if [ ! -f "$VALHEIM_INSTALL/BepInEx/core/BepInEx.dll" ]; then
    curl -sSL -o "$WORK_DIR/bepinex.zip" "https://thunderstore.io/package/download/denikson/BepInExPack_Valheim/$BEPINEX_VERSION/"
    unzip -q -o "$WORK_DIR/bepinex.zip" -d "$WORK_DIR/bepinex"
    cp -r "$WORK_DIR/bepinex/BepInExPack_Valheim/BepInEx" "$VALHEIM_INSTALL/"
fi

# NuGet packages from packages.config (old-style project), plus .NET Framework reference assemblies
PACKAGES_DIR="$REPO_DIR/packages"
mkdir -p "$PACKAGES_DIR"
{
    grep -o 'id="[^"]*" version="[^"]*"' "$REPO_DIR/XPortal/packages.config" | sed -E 's/id="([^"]*)" version="([^"]*)"/\1 \2/'
    echo "Microsoft.NETFramework.ReferenceAssemblies.net462 1.0.3"
} | while read -r id version; do
    if [ ! -d "$PACKAGES_DIR/$id.$version" ]; then
        curl -sSL -o "$WORK_DIR/package.zip" "https://www.nuget.org/api/v2/package/$id/$version"
        unzip -q -o "$WORK_DIR/package.zip" -d "$PACKAGES_DIR/$id.$version"
    fi
done

dotnet msbuild "$REPO_DIR/XPortal/XPortal.csproj" \
    -p:Configuration="$CONFIGURATION" \
    -p:SolutionDir="$REPO_DIR/" \
    -p:VALHEIM_INSTALL="$VALHEIM_INSTALL" \
    -p:FrameworkPathOverride="$PACKAGES_DIR/Microsoft.NETFramework.ReferenceAssemblies.net462.1.0.3/build/.NETFramework/v4.6.2" \
    -nowarn:MSB3277 \
    -v:minimal

# Read the mod details from ModInfo.cs
mod_info() { grep -oP "const string $1 = \"\K[^\"]*" "$REPO_DIR/XPortal/ModInfo.cs"; }
NAME="$(mod_info Name)"
VERSION="$(mod_info Version)"
DESCRIPTION="$(mod_info Description)"
GITHUB_REPO="$(mod_info GitHubRepo)"
BEPINEX_PACK_VERSION="$(mod_info BepInExPackVersion)"
JOTUNN_VERSION="$(grep -oP 'id="JotunnLib" version="\K[^"]*' "$REPO_DIR/XPortal/packages.config")"

# Thunderstore package: the contents of this folder are what gets zipped and uploaded
PACKAGE_DIR="$REPO_DIR/.build/package"
PLUGIN_DIR="$PACKAGE_DIR/plugins/$NAME"
rm -rf "$PACKAGE_DIR"
mkdir -p "$PLUGIN_DIR"
cp "$REPO_DIR/XPortal/bin/$CONFIGURATION/$NAME.dll" "$PLUGIN_DIR/"
cp -r "$REPO_DIR/XPortal/Translations" "$PLUGIN_DIR/"
cp "$REPO_DIR/Thunderstore/icon.png" "$REPO_DIR/Thunderstore/README.md" "$REPO_DIR/Thunderstore/CHANGELOG.md" "$PACKAGE_DIR/"
cat > "$PACKAGE_DIR/manifest.json" <<JSON
{
  "name": "$NAME",
  "version_number": "$VERSION",
  "website_url": "https://github.com/$GITHUB_REPO",
  "description": "$DESCRIPTION",
  "dependencies": [
    "denikson-BepInExPack_Valheim-$BEPINEX_PACK_VERSION",
    "ValheimModding-Jotunn-$JOTUNN_VERSION"
  ]
}
JSON
echo "Thunderstore package: $PACKAGE_DIR"
