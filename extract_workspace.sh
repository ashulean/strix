#!/bin/bash
# Helper script to extract workspace files from Strix Docker container to host

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Strix Workspace Extraction Helper${NC}"
echo "=================================="
echo ""

# Find Strix containers
echo "Looking for Strix containers..."
CONTAINERS=$(docker ps -a --filter "label=strix-scan-id" --format "{{.Names}}")

if [ -z "$CONTAINERS" ]; then
    echo -e "${RED}No Strix containers found.${NC}"
    exit 1
fi

# Display containers
echo -e "${GREEN}Found Strix containers:${NC}"
echo "$CONTAINERS" | nl -w2 -s'. '
echo ""

# If container name provided as argument, use it
if [ -n "$1" ]; then
    CONTAINER_NAME="$1"
else
    # Ask user to select
    echo -e "${YELLOW}Enter container number or name:${NC}"
    read -r SELECTION

    # Check if it's a number
    if [[ "$SELECTION" =~ ^[0-9]+$ ]]; then
        CONTAINER_NAME=$(echo "$CONTAINERS" | sed -n "${SELECTION}p")
    else
        CONTAINER_NAME="$SELECTION"
    fi
fi

if [ -z "$CONTAINER_NAME" ]; then
    echo -e "${RED}No container selected.${NC}"
    exit 1
fi

# Require a Strix scan container (must have strix-scan-id label)
if ! echo "$CONTAINERS" | grep -qxF "$CONTAINER_NAME"; then
    echo -e "${RED}Container '${CONTAINER_NAME}' is not a Strix scan container.${NC}"
    echo -e "${YELLOW}Only containers with the strix-scan-id label are allowed.${NC}"
    echo ""
    echo -e "${GREEN}Valid Strix containers:${NC}"
    echo "$CONTAINERS" | nl -w2 -s'. '
    exit 1
fi

# Get scan-id from container label
SCAN_ID=$(docker inspect "$CONTAINER_NAME" --format '{{index .Config.Labels "strix-scan-id"}}')

if [ -z "$SCAN_ID" ]; then
    echo -e "${RED}Container '${CONTAINER_NAME}' is missing the strix-scan-id label.${NC}"
    exit 1
fi

# Determine destination directory
RUN_DIR="strix_runs/${SCAN_ID}"
if [ ! -d "$RUN_DIR" ]; then
    echo -e "${YELLOW}Run directory '$RUN_DIR' doesn't exist. Creating it...${NC}"
    mkdir -p "$RUN_DIR"
fi

EVIDENCE_DIR="${RUN_DIR}/evidence"
mkdir -p "$EVIDENCE_DIR"

echo ""
echo -e "${GREEN}Container:${NC} $CONTAINER_NAME"
echo -e "${GREEN}Scan ID:${NC} $SCAN_ID"
echo -e "${GREEN}Destination:${NC} $EVIDENCE_DIR"
echo ""

# Check if container is running
if ! docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}Container is not running. Starting it...${NC}"
    docker start "$CONTAINER_NAME"
    sleep 2
fi

# List workspace contents
echo -e "${GREEN}Workspace contents:${NC}"
docker exec "$CONTAINER_NAME" ls -lah /workspace
echo ""

# Ask what to copy
echo -e "${YELLOW}What would you like to copy?${NC}"
echo "1. Entire /workspace directory"
echo "2. Specific file or directory"
echo "3. List files and choose interactively"
read -r CHOICE

case $CHOICE in
    1)
        echo -e "${GREEN}Copying entire workspace...${NC}"
        docker cp "${CONTAINER_NAME}:/workspace" "${EVIDENCE_DIR}/workspace"
        echo -e "${GREEN}✓ Copied to: ${EVIDENCE_DIR}/workspace${NC}"
        ;;
    2)
        echo -e "${YELLOW}Enter file or directory path (relative to /workspace):${NC}"
        read -r SOURCE_PATH
        docker cp "${CONTAINER_NAME}:/workspace/${SOURCE_PATH}" "${EVIDENCE_DIR}/"
        echo -e "${GREEN}✓ Copied to: ${EVIDENCE_DIR}/${SOURCE_PATH}${NC}"
        ;;
    3)
        echo -e "${YELLOW}Enter file or directory paths (one per line, empty line to finish):${NC}"
        while IFS= read -r SOURCE_PATH; do
            [ -z "$SOURCE_PATH" ] && break
            echo "Copying: $SOURCE_PATH"
            docker cp "${CONTAINER_NAME}:/workspace/${SOURCE_PATH}" "${EVIDENCE_DIR}/"
        done
        echo -e "${GREEN}✓ Files copied to: ${EVIDENCE_DIR}${NC}"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✓ Extraction complete!${NC}"
echo -e "Files are available at: ${EVIDENCE_DIR}"

