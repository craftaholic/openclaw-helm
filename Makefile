# Makefile for OpenClaw Helm deployment

NAMESPACE := openclaw
SECRET_NAME := openclaw-env
CHART_PATH := ./charts/openclaw
DEFAULT_MODEL := minimax/MiniMax-M2.5

.PHONY: install upgrade uninstall secret deps lint help

install: deps secret
	@echo "Installing helm chart..."
	@helm upgrade --install openclaw $(CHART_PATH) -n $(NAMESPACE) --create-namespace
	@echo ""
	@echo "=============================================="
	@echo "OpenClaw installed!"
	@echo "=============================================="
	@echo ""
	@echo "Port-forward: kubectl port-forward -n $(NAMESPACE) svc/openclaw 18789:18789"
	@echo "Open: http://localhost:18789"
	@echo "Token: $$(cat .env | grep OPENCLAW_GATEWAY_TOKEN | cut -d= -f2)"

upgrade:
	@echo "Upgrading helm..."
	@helm upgrade --install openclaw $(CHART_PATH) -n $(NAMESPACE) --create-namespace

uninstall:
	@helm uninstall openclaw -n $(NAMESPACE) || true

secret:
	@if [ ! -f .env ]; then echo "ERROR: .env file not found"; exit 1; fi
	@source .env && \
		export OPENCLAW_GATEWAY_TOKEN=$${OPENCLAW_GATEWAY_TOKEN:-$$(openssl rand -hex 32)} && \
		export OPENCLAW_PRIMARY_MODEL=$${OPENCLAW_PRIMARY_MODEL:-$(DEFAULT_MODEL)} && \
		kubectl get ns $(NAMESPACE) &>/dev/null || kubectl create ns $(NAMESPACE) && \
		kubectl label ns $(NAMESPACE) pod-security.kubernetes.io/enforce=privileged pod-security.kubernetes.io/audit=privileged pod-security.kubernetes.io/warn=privileged --overwrite && \
		kubectl delete secret $(SECRET_NAME) -n $(NAMESPACE) --ignore-not-found=true 2>/dev/null || true && \
		kubectl create secret generic $(SECRET_NAME) -n $(NAMESPACE) \
			--from-literal=OPENCODE_API_KEY="$$OPENCODE_API_KEY" \
			--from-literal=OPENCLAW_GATEWAY_TOKEN="$$OPENCLAW_GATEWAY_TOKEN" \
			--from-literal=GROQ_API_KEY="$$GROQ_API_KEY" \
			--from-literal=OPENCLAW_PRIMARY_MODEL="$$OPENCLAW_PRIMARY_MODEL" \
			--from-literal=TELEGRAM_BOT_TOKEN="$$TELEGRAM_BOT_TOKEN" \
			--from-literal=TELEGRAM_ALLOW_FROM="$$TELEGRAM_ALLOW_FROM" \
			--from-literal=MINIMAX_API_KEY="$$MINIMAX_API_KEY" && \
		echo "Secret created!"

deps:
	@helm dependency build $(CHART_PATH)

lint:
	@helm lint $(CHART_PATH)

help:
	@echo "OpenClaw Helm Makefile"
	@echo ""
	@echo "  make install    - Full install"
	@echo "  make upgrade    - Upgrade helm"
	@echo "  make uninstall  - Uninstall"
	@echo "  make secret     - Create secret"
	@echo "  make deps       - Build deps"
	@echo "  make lint       - Lint chart"
