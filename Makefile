.PHONY: help install dev-install format lint type-check test test-cov clean pre-commit setup-dev docker-build docker-build-no-cache docker-push

help:
	@echo "Available commands:"
	@echo "  setup-dev     - Install all development dependencies and setup pre-commit"
	@echo "  install       - Install production dependencies"
	@echo "  dev-install   - Install development dependencies"
	@echo ""
	@echo "Code Quality:"
	@echo "  format        - Format code with ruff"
	@echo "  lint          - Lint code with ruff and pylint"
	@echo "  type-check    - Run type checking with mypy and pyright"
	@echo "  security      - Run security checks with bandit"
	@echo "  check-all     - Run all code quality checks"
	@echo ""
	@echo "Testing:"
	@echo "  test          - Run tests with pytest"
	@echo "  test-cov      - Run tests with coverage reporting"
	@echo ""
	@echo "Development:"
	@echo "  pre-commit    - Run pre-commit hooks on all files"
	@echo "  clean         - Clean up cache files and artifacts"
	@echo ""
	@echo "Docker:"
	@echo "  docker-build  - Build Docker image with local code changes"
	@echo "  docker-build-no-cache - Build Docker image without cache"
	@echo "  docker-push   - Push Docker image to registry (requires auth)"

install:
	uv sync --no-dev

dev-install:
	uv sync

setup-dev: dev-install
	uv run pre-commit install
	@echo "✅ Development environment setup complete!"
	@echo "Run 'make check-all' to verify everything works correctly."

format:
	@echo "🎨 Formatting code with ruff..."
	uv run ruff format .
	@echo "✅ Code formatting complete!"

lint:
	@echo "🔍 Linting code with ruff..."
	uv run ruff check . --fix
	@echo "📝 Running additional linting with pylint..."
	uv run pylint strix/ --score=no --reports=no
	@echo "✅ Linting complete!"

type-check:
	@echo "🔍 Type checking with mypy..."
	uv run mypy strix/
	@echo "🔍 Type checking with pyright..."
	uv run pyright strix/
	@echo "✅ Type checking complete!"

security:
	@echo "🔒 Running security checks with bandit..."
	uv run bandit -r strix/ -c pyproject.toml
	@echo "✅ Security checks complete!"

check-all: format lint type-check security
	@echo "✅ All code quality checks passed!"

test:
	@echo "🧪 Running tests..."
	uv run pytest -v
	@echo "✅ Tests complete!"

test-cov:
	@echo "🧪 Running tests with coverage..."
	uv run pytest -v --cov=strix --cov-report=term-missing --cov-report=html
	@echo "✅ Tests with coverage complete!"
	@echo "📊 Coverage report generated in htmlcov/"

pre-commit:
	@echo "🔧 Running pre-commit hooks..."
	uv run pre-commit run --all-files
	@echo "✅ Pre-commit hooks complete!"

clean:
	@echo "🧹 Cleaning up cache files..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete 2>/dev/null || true
	find . -name ".coverage" -delete 2>/dev/null || true
	@echo "✅ Cleanup complete!"

dev: format lint type-check test
	@echo "✅ Development cycle complete!"

docker-build:
	@echo "🐳 Building Docker image with local code changes..."
	@echo "   This will tag the image as 'strix-sandbox:local'"
	@echo "   Set STRIX_IMAGE=strix-sandbox:local to use it"
	docker build -f containers/Dockerfile -t strix-sandbox:local .
	@echo "✅ Docker image built successfully!"
	@echo "   To use this image, run: export STRIX_IMAGE=strix-sandbox:local"

docker-build-no-cache:
	@echo "🐳 Building Docker image without cache (fresh build)..."
	@echo "   This will take longer but ensures all changes are included"
	docker build --no-cache -f containers/Dockerfile -t strix-sandbox:local .
	@echo "✅ Docker image built successfully!"
	@echo "   To use this image, run: export STRIX_IMAGE=strix-sandbox:local"

docker-push:
	@echo "🚀 Pushing Docker image to registry..."
	@echo "   Note: This requires authentication and proper image tag"
	@echo "   Current image tag: strix-sandbox:local"
	@echo "   Update the tag below to match your registry"
	@echo "   Example: docker tag strix-sandbox:local ghcr.io/usestrix/strix-sandbox:0.1.11"
	@echo "   Then: docker push ghcr.io/usestrix/strix-sandbox:0.1.11"
	@echo "⚠️  This command is a placeholder - customize the tag as needed"
