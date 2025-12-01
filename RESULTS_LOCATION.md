# Where Strix Stores Results and Evidence

## Summary

Strix uses **two separate locations** for data:

1. **`/workspace`** - Inside the Docker container (where agents work)
2. **`strix_runs/<run-name>/`** - On your host machine (where results are saved)

## Host Machine Results Location

**Location:** `strix_runs/<run-name>/` (in the current working directory where you ran Strix)

**What gets saved here:**
- ✅ Vulnerability reports (markdown files in `vulnerabilities/` subdirectory)
- ✅ Vulnerability index (`vulnerabilities.csv`)
- ✅ Final penetration test report (`penetration_test_report.md`)
- ✅ Run metadata and agent execution traces

**Example structure:**
```
strix_runs/
└── your-run-name/
    ├── penetration_test_report.md
    ├── vulnerabilities.csv
    └── vulnerabilities/
        ├── vuln-001.md
        ├── vuln-002.md
        └── ...
```

## Container Workspace Location

**Location:** `/workspace` inside the Docker container

**What's stored here:**
- Source code (if scanning local code or repositories)
- Files created by agents during testing
- Evidence files, screenshots, logs created during the scan
- Temporary files and working data

## ⚠️ Important Limitation

**Evidence files created by agents in `/workspace` are NOT automatically copied back to the host machine.**

Currently, only vulnerability reports (text-based findings) are saved to `strix_runs/`. Any files, screenshots, or evidence that agents create in the container's `/workspace` directory remain inside the container and are not accessible on your host machine unless you manually extract them.

## How to Access Container Workspace Files

### Option 1: Use the Helper Script (Easiest)

```bash
# Run the extraction helper script
./extract_workspace.sh

# Or specify container name directly
./extract_workspace.sh strix-scan-app-dev-complynova-us-orbitronai_eebc
```

The script will:
- List all Strix containers
- Let you select which one to extract from
- Copy files to `strix_runs/<run-name>/evidence/`

### Option 2: Manual Docker Commands

**Step 1: Find your container**

```bash
# List all Strix containers
docker ps -a --filter "label=strix-scan-id" --format "table {{.Names}}\t{{.Status}}"

# Or find by name pattern
docker ps --format "{{.Names}}" | grep strix-scan
```

**Step 2: Copy files (IMPORTANT: destination directory must exist!)**

```bash
# First, create the destination directory
mkdir -p strix_runs/<run-name>/evidence

# Copy entire workspace
docker cp <container-name>:/workspace strix_runs/<run-name>/evidence/workspace

# Or copy specific file/directory
docker cp <container-name>:/workspace/specific-file.txt strix_runs/<run-name>/evidence/

# Example with actual container name:
docker cp strix-scan-app-dev-complynova-us-orbitronai_eebc:/workspace strix_runs/app-dev-complynova-us-orbitronai_eebc/evidence/workspace
```

**Common Issues:**
- ❌ `docker cp` fails if destination directory doesn't exist - create it first!
- ❌ Container name must match exactly (use `docker ps` to see exact name)
- ✅ Container can be running or stopped (will auto-start if stopped)

### Option 3: Access Container Shell

```bash
# Access the container shell
docker exec -it <container-name> bash

# Navigate to workspace
cd /workspace
ls -la

# Then use docker cp from another terminal to copy files out
```

### Option 3: Mount Workspace as Volume (Future Enhancement)

This would require code changes to mount the workspace directory as a Docker volume, making it directly accessible on the host.

## Finding Your Results

### Quick Check

```bash
# See all Strix runs
ls -la strix_runs/

# View a specific run's results
cat strix_runs/<run-name>/penetration_test_report.md

# List all vulnerabilities found
cat strix_runs/<run-name>/vulnerabilities.csv
```

### Full Path

The results are saved relative to where you ran the `strix` command:

```bash
# If you ran: strix --target https://example.com
# From: /Users/ashu/Github/strix
# Results will be at: /Users/ashu/Github/strix/strix_runs/<run-name>/
```

## Container Information

To find which container belongs to your scan:

```bash
# List containers with their labels
docker ps --filter "label=strix-scan-id" --format "table {{.Names}}\t{{.Labels}}"

# Or check container names (format: strix-scan-<scan-id>)
docker ps --format "{{.Names}}" | grep strix-scan
```

## Recommended Workflow

1. **Check `strix_runs/` first** - This has all the vulnerability reports and findings
2. **If you need evidence files** - Access the container using `docker exec` or `docker cp`
3. **Save important evidence** - Copy files you need to `strix_runs/<run-name>/evidence/` manually

## Future Improvements

Potential enhancements:
- Automatic extraction of evidence files from container to host
- Volume mounting for direct workspace access
- Evidence collection and organization in results directory
- Automatic cleanup or archival of container workspaces

