# Building Docker Image with Local Changes

## Quick Build

To build the Docker image with your local code changes:

```bash
# Build the image (this will take a while the first time)
docker build -f containers/Dockerfile -t strix-sandbox:local .

# Set environment variable to use your local image
export STRIX_IMAGE=strix-sandbox:local

# Now run Strix - it will use your local image
poetry run strix --target https://example.com
```

## What Gets Copied

The Dockerfile copies these files into the image:
- `strix/tools/executor.py` ✅ (your changes are here)
- `strix/tools/registry.py`
- `strix/tools/argument_parser.py`
- All tool directories (browser, file_edit, notes, python, terminal, proxy)
- Runtime files

**Note:** `agents_graph_actions.py` runs on the **host** (not in the container), so those changes work immediately without rebuilding.

## Using Your Local Image

After building, you can either:

### Option 1: Set Environment Variable (Recommended)
```bash
export STRIX_IMAGE=strix-sandbox:local
strix --target https://example.com
```

### Option 2: Set in Your Shell Profile
Add to `~/.zshrc` or `~/.bashrc`:
```bash
export STRIX_IMAGE=strix-sandbox:local
```

## Verifying Your Changes

To verify your changes are in the image:

```bash
# Build the image
docker build -f containers/Dockerfile -t strix-sandbox:local .

# Check the executor.py file in the image
docker run --rm strix-sandbox:local cat /app/strix/tools/executor.py | grep -A 5 "asyncio.gather"
```

You should see your parallel execution code with `asyncio.gather()`.

## Development Workflow

For active development:

1. **Make code changes** to files that run in the container (like `executor.py`)
2. **Rebuild the image**: `docker build -f containers/Dockerfile -t strix-sandbox:local .`
3. **Test your changes**: `export STRIX_IMAGE=strix-sandbox:local && strix --target ...`

For changes to host-side code (like `agents_graph_actions.py`), no rebuild needed!

## Troubleshooting

If you see old behavior after rebuilding:
- Make sure you're using the local image: `echo $STRIX_IMAGE` should show `strix-sandbox:local`
- Check if Docker is using a cached layer: add `--no-cache` to build command
- Verify the file in the image: `docker run --rm strix-sandbox:local cat /app/strix/tools/executor.py`

