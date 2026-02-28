#!/bin/bash
set -e

# Define Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}   Wiretify Local Build Script         ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Move to project root
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$DIR"

echo -e "${GREEN}[+] Compiling for Linux amd64...${NC}"
GO_CMD="/home/accnet/local-go/bin/go"
if [ ! -x "$GO_CMD" ]; then
    GO_CMD="go"
fi
GOOS=linux GOARCH=amd64 $GO_CMD build -ldflags="-s -w" -o wiretify cmd/server/main.go

echo -e "${GREEN}[+] Copying frontend assets...${NC}"
# Use a temporary directory for packing
TEMP_PACK_DIR="temp_build"
rm -rf "$TEMP_PACK_DIR"
mkdir -p "$TEMP_PACK_DIR/web"
cp wiretify "$TEMP_PACK_DIR/"
cp -r web/templates "$TEMP_PACK_DIR/web/"

echo -e "${GREEN}[+] Packing into wiretify.zip...${NC}"
rm -f deploy/wiretify.zip
cd "$TEMP_PACK_DIR"
zip -r ../deploy/wiretify.zip wiretify web/
cd ..

echo -e "${GREEN}[+] Cleaning up temporary files...${NC}"
rm -rf "$TEMP_PACK_DIR"
rm -f wiretify
# Remove everything in deploy except install.sh and wiretify.zip
find deploy/ -mindepth 1 ! -name 'install.sh' ! -name 'wiretify.zip' -exec rm -rf {} +

echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}Build and packing successful!${NC}"
echo -e "Ready for deployment! Instructions:"
echo -e "1. Upload 'deploy/wiretify.zip' to your own URL (e.g. Github Releases or server)."
echo -e "2. Update DOWNLOAD_URL in 'deploy/install.sh'."
echo -e "3. Send 'deploy/install.sh' to your VPS and run it: ${BLUE}sudo bash install.sh${NC}"
echo -e "${BLUE}=======================================${NC}"
