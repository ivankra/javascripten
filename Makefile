# GitHub API token (optional for <60 requests/hour)
# GitHub Settings > Developer settings > Personal access tokens
GITHUB_TOKEN := $(shell cat ~/.iac/github-public-token.txt 2>/dev/null || true)

update:
	./update.py --format $(if $(GITHUB_TOKEN),--github="$(GITHUB_TOKEN)")
