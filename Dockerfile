FROM ghcr.io/openclaw/openclaw:latest

# gogcli version - pin for reproducibility
ARG GOGCLI_VERSION=0.12.0

# Install gogcli (Google Workspace CLI)
# https://github.com/steipete/gogcli
# URL format: gogcli_{VERSION}_linux_amd64.tar.gz
# Binary name inside tarball: gog
RUN curl -sSL "https://github.com/steipete/gogcli/releases/download/v${GOGCLI_VERSION}/gogcli_${GOGCLI_VERSION}_linux_amd64.tar.gz" | \
    tar xz -C /tmp && \
    mkdir -p /home/node/.local/bin && \
    mv /tmp/gog /home/node/.local/bin/gog && \
    chmod +x /home/node/.local/bin/gog && \
    rm -rf /tmp/gogcli_*

# Add to PATH for interactive shells
ENV PATH="/home/node/.local/bin:${PATH}"

# Ensure non-root user (UID 1000 - matches OpenClaw's node user)
USER 1000

# Default command - run OpenClaw gateway
CMD ["node", "dist/index.js", "gateway", "--bind", "lan", "--port", "18789"]
