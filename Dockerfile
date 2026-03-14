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

# Whisper CLI - for local voice transcription
# https://github.com/ggerganov/whisper.cpp
ARG WHISPER_CLI_VERSION=1.7.0
RUN curl -sSL "https://github.com/ggerganov/whisper.cpp/releases/download/v${WHISPER_CLI_VERSION}/whisper-cli-linux-x64.tar.gz" | \
    tar xz -C /tmp && \
    mv /tmp/whisper-cli /home/node/.local/bin/whisper && \
    chmod +x /home/node/.local/bin/whisper && \
    rm -rf /tmp/whisper-*

# Download Whisper base model for offline transcription
RUN mkdir -p /home/node/.whisper && \
    curl -sSL "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin" -o /home/node/.whisper/ggml-base.bin && \
    chown -R 1000:1000 /home/node/.whisper

# Add to PATH for interactive shells
ENV PATH="/home/node/.local/bin:${PATH}"

# Ensure non-root user (UID 1000 - matches OpenClaw's node user)
USER 1000

# Default command - run OpenClaw gateway
CMD ["node", "dist/index.js", "gateway", "--bind", "lan", "--port", "18789"]
