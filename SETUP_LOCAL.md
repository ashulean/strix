# Running Strix Locally

## Quick Setup Guide

### Option 1: Using Poetry (Recommended)

If Poetry isn't working, reinstall it first:

```bash
# Reinstall Poetry with current Python
curl -sSL https://install.python-poetry.org | python3 -
# Or if you have pipx:
pipx install poetry
```

Then install dependencies:

```bash
cd /Users/ashu/Github/strix
poetry install --with=dev
```

### Option 2: Using pip directly

```bash
cd /Users/ashu/Github/strix
python3 -m pip install -e .
```

For development dependencies:

```bash
python3 -m pip install -e ".[dev]"
```

## Prerequisites Check

1. **Docker Desktop** - Should be running (we fixed the connection issue!)
2. **Python 3.12+** - You have Python 3.13.3 ✅
3. **LLM API Key** - You'll need to set this up

## Configuration

Set up your LLM provider environment variables:

```bash
# Required
export STRIX_LLM="openai/gpt-5"  # or "anthropic/claude-sonnet-4-5"
export LLM_API_KEY="your-api-key-here"

# Optional (for local models like Ollama)
# export LLM_API_BASE="http://localhost:11434"

# Optional (for web search capabilities)
# export PERPLEXITY_API_KEY="your-perplexity-key"
```

## Running Strix

### Using Poetry:

```bash
poetry run strix --target https://app.dev.complynova.us.orbitronai.com/landing
```

### Using pip installation:

```bash
# If installed with -e flag, you can run directly:
python3 -m strix.interface.main --target https://app.dev.complynova.us.orbitronai.com/landing

# Or create an alias:
alias strix='python3 -m strix.interface.main'
strix --target https://app.dev.complynova.us.orbitronai.com/landing
```

### Development Mode (with editable install):

```bash
# Install in editable mode
python3 -m pip install -e .

# Then run directly
strix --target https://app.dev.complynova.us.orbitronai.com/landing
```

## Example Commands

```bash
# Scan a web application
strix --target https://example.com

# Scan a local directory
strix --target ./my-app

# Scan with custom instructions
strix --target https://example.com --instruction "Focus on authentication vulnerabilities"

# Non-interactive mode (for CI/CD)
strix -n --target https://example.com
```

## Troubleshooting

### Docker Connection Issues
- ✅ Already fixed! The code now automatically detects Docker Desktop on macOS.

### Poetry Issues
- If Poetry has wrong Python interpreter, reinstall it or use pip directly

### Missing Dependencies
- Run: `python3 -m pip install -e .` to install all dependencies

### LLM Connection Issues
- Verify your API key is correct
- Check if you need to set `LLM_API_BASE` for local models
- Test with: `python3 -c "import litellm; print('LiteLLM installed')"`

## Next Steps

1. Set your `STRIX_LLM` and `LLM_API_KEY` environment variables
2. Make sure Docker Desktop is running
3. Run your first scan!

