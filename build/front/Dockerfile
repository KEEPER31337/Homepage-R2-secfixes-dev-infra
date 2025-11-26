# Multi-stage build:
# - Stage 1 (builder): 빌드는 호스트 플랫폼에서 빠르게 수행
# - Stage 2 (runner): BuildKit TARGETPLATFORM 기반으로 servekit 다운로드

# ---- Stage 1: Build React bundle (on BUILDPLATFORM) ----
FROM --platform=${BUILDPLATFORM:-linux/amd64} node:18-bullseye-slim AS builder

# 빌드 시 불필요한 CI 체크 비활성화
ENV CI=false

# 빌드 아규먼트 (런타임과 분리)
ARG PUBLIC_API_URL=

# 환경 변수 설정 (HTTPS는 빌드와 무관 → 제거 권장)
ENV PUBLIC_API_URL=${PUBLIC_API_URL}

WORKDIR /app

# 1. 의존성 파일만 먼저 복사 → 캐시 최대화
COPY Homepage-Front-R2-secfixes/package*.json ./

# 2. npm 설정: 캐시 디렉토리와 보안 강화
RUN npm config set cache /root/.npm --global

# 3. BuildKit 캐시 마운트로 node_modules 설치
# Dev-only tools like craco are required for the build, so include dev deps
RUN --mount=type=cache,id=npm-cache,target=/root/.npm \
    --mount=type=cache,id=node-modules,target=/app/node_modules \
    npm ci --include=dev

# 4. 소스 코드 복사
COPY Homepage-Front-R2-secfixes/ ./

# 5. 프로덕션 빌드 (node_modules 캐시 재사용)
RUN --mount=type=cache,id=node-modules,target=/app/node_modules \
    npm run build


# ---- Stage 2: Serve with Servekit (target platform) ----
FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:3.13 AS runner

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

RUN set -eux; \
    apk add --no-cache ca-certificates libstdc++ wget tar; \
    servekit_arch=''; \
    case "${TARGETARCH}" in \
        amd64) servekit_arch='amd64' ;; \
        arm64) servekit_arch='arm64' ;; \
        arm) \
            case "${TARGETVARIANT}" in \
                v5) servekit_arch='armv5' ;; \
                v6) servekit_arch='armv6' ;; \
                v7|'') servekit_arch='armv7' ;; \
                *) echo >&2 "error: unsupported ARM variant: ${TARGETVARIANT}"; exit 1 ;; \
            esac ;; \
        ppc64le) servekit_arch='ppc64le' ;; \
        s390x) servekit_arch='s390x' ;; \
        *) echo >&2 "error: unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    servekit_os="${TARGETOS:-linux}"; \
    wget -O /tmp/servekit.tar.gz "https://github.com/cjaewon/servekit/releases/download/v2.0.0/servekit_2.0.0_${servekit_os}_${servekit_arch}.tar.gz"; \
    tar xzf /tmp/servekit.tar.gz -C /usr/local/bin servekit; \
    rm -f /tmp/servekit.tar.gz; \
    chmod +x /usr/local/bin/servekit

# 보안: 루트 외 사용자로 실행할 수 있는 경우 아래 라인을 활성화
# USER nonroot

WORKDIR /app

# 빌더 스테이지에서 빌드 결과 복사
COPY --from=builder /app/build ./static

# SPA 설정
ENV SERVEKIT_SERVER_404=index.html
EXPOSE 3000

CMD ["servekit"]
