# Quick Guide: Extract Workspace Files

## The Problem

The `docker cp` command requires the **destination directory to exist first**. If it doesn't exist, the command will fail silently or with an error.

## Solution: Use This Exact Command

For your current container, run:

```bash
# 1. Create the destination directory first
mkdir -p strix_runs/app-dev-complynova-us-orbitronai_eebc/evidence

# 2. Copy the workspace
docker cp strix-scan-app-dev-complynova-us-orbitronai_eebc:/workspace strix_runs/app-dev-complynova-us-orbitronai_eebc/evidence/workspace
```

## Or Use the Helper Script

```bash
./extract_workspace.sh strix-scan-app-dev-complynova-us-orbitronai_eebc
```

## Why Your Command Failed

The command `docker cp <container-name>:/workspace/evidence.png ./strix_runs/<run-name>` likely failed because:

1. **Destination directory doesn't exist** - `./strix_runs/<run-name>` must exist first
2. **Wrong container name** - Use exact name from `docker ps`
3. **File doesn't exist** - The specific file path might not exist

## Correct Format

```bash
# Format: docker cp <container>:<source-path> <destination-path>
# Destination must be a directory that EXISTS, or a new filename

# ✅ CORRECT - Copy to existing directory
mkdir -p strix_runs/my-run/evidence
docker cp container-name:/workspace/file.txt strix_runs/my-run/evidence/

# ✅ CORRECT - Copy entire directory to existing parent
mkdir -p strix_runs/my-run/evidence
docker cp container-name:/workspace strix_runs/my-run/evidence/workspace

# ❌ WRONG - Destination directory doesn't exist
docker cp container-name:/workspace/file.txt strix_runs/my-run/evidence/

# ✅ FIX - Create directory first
mkdir -p strix_runs/my-run/evidence
docker cp container-name:/workspace/file.txt strix_runs/my-run/evidence/
```

## Find Your Container Name

```bash
# List all Strix containers
docker ps --format "{{.Names}}" | grep strix-scan

# Or with more details
docker ps -a --filter "label=strix-scan-id" --format "table {{.Names}}\t{{.Status}}"
```

## Find Your Run Name

The run name matches the scan-id, which is in the container label:

```bash
CONTAINER="strix-scan-app-dev-complynova-us-orbitronai_eebc"
SCAN_ID=$(docker inspect "$CONTAINER" --format '{{index .Config.Labels "strix-scan-id"}}')
echo "Run directory: strix_runs/$SCAN_ID"
```

