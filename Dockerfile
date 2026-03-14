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

# whisper.cpp version - pin for reproducibility
ARG WHISPER_VERSION=commit_3d42463

RUN curl -sSL "https://github.com/dscripka/whisper.cpp_binaries/releases/download/${WHISPER_VERSION}/whisper-bin-linux-x64.tar.gz" | \
    tar xz -C /tmp && \
    mkdir -p /home/node/.local/bin && \
    mkdir -p /home/node/.openclaw/whisper/models && \
    mv /tmp/build/bin/main /home/node/.local/bin/whisper && \
    chmod +x /home/node/.local/bin/whisper && \
    curl -sSL "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin" -o /home/node/.openclaw/whisper/models/ggml-base.bin && \
    rm -rf /tmp/whisper-bin-linux-x64*

# Add to PATH for interactive shells
ENV PATH="/home/node/.local/bin:${PATH}"

# Ensure non-root user (UID 1000 - matches OpenClaw's node user)
USER 1000

# Default command - run OpenClaw gateway
CMD ["node", "dist/index.js", "gateway", "--bind", "lan", "--port", "18789"]
