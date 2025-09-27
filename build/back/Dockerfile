# syntax=docker/dockerfile:1.7-labs
# 멀티아키텍처 빌드시 BuildKit 기능을 활용하기 위해 labs 문법 사용

# ------------------------------------------------------------
# 빌드 스테이지 (builder) - 호스트 아키텍처에서 빠르게 빌드
# ------------------------------------------------------------
ARG BUILDPLATFORM
ARG TARGETPLATFORM

FROM --platform=${BUILDPLATFORM:-linux/amd64} eclipse-temurin:17-jdk-jammy AS builder

ENV GRADLE_USER_HOME=/root/.gradle \
    # Gradle/Java 빌드 성능 및 안정화
    JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75" \
    # Gradle가 지원하면 재시작 간 구성 캐시 활용
    GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.caching=true"

WORKDIR /src/app

# 1) wrapper/스クリپ트/빌드 정의만 먼저 복사 → 의존성 캐시 고정
COPY Homepage-Back-R2-secfixes/gradle ./gradle
COPY Homepage-Back-R2-secfixes/gradlew Homepage-Back-R2-secfixes/gradlew.bat ./
COPY Homepage-Back-R2-secfixes/build.gradle.kts Homepage-Back-R2-secfixes/settings.gradle.kts ./
# gradle.properties is optional; create a placeholder so Gradle commands do not fail before the full source copy
RUN test -f gradle.properties || touch gradle.properties
RUN chmod +x ./gradlew || true

# 2) wrapper/의존성 메타데이터 프라임 (캐시 마운트)
RUN --mount=type=cache,target=${GRADLE_USER_HOME}/caches \
    --mount=type=cache,target=${GRADLE_USER_HOME}/wrapper \
    ./gradlew --no-daemon --build-cache help

# 선택: 의존성 해상만 먼저 수행(캐시에 유리)
RUN --mount=type=cache,target=${GRADLE_USER_HOME}/caches \
    --mount=type=cache,target=${GRADLE_USER_HOME}/wrapper \
    ./gradlew --no-daemon --build-cache dependencies || true

# 3) 실제 소스 복사 (BuildKit의 --link로 레이어 낭비 최소화)
COPY --link Homepage-Back-R2-secfixes/ ./

# 4) 필요한 산출물만 생성: bootJar (test/doc 제외, clean 제거)
RUN --mount=type=cache,target=${GRADLE_USER_HOME}/caches \
    --mount=type=cache,target=${GRADLE_USER_HOME}/wrapper \
    ./gradlew --no-daemon --build-cache --parallel --configuration-cache \
      -x test -x asciidoctor bootJar

# 5) 최신 bootJar 자동 탐색 후 layertools로 레이어 추출
RUN set -eux; \
    JAR_PATH="$(find build/libs -type f -name '*.jar' ! -name '*-plain.jar' -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2-)"; \
    test -n "$JAR_PATH"; \
    java -Djarmode=layertools -jar "$JAR_PATH" extract; \
    mkdir -p /out/layers; \
    mv dependencies snapshot-dependencies spring-boot-loader application /out/layers

# ------------------------------------------------------------
# 런타임 스테이지 (runtime) - 타깃 아키텍처(arm64)로 경량 이미지 생성
# ------------------------------------------------------------
FROM --platform=${TARGETPLATFORM:-linux/arm64} eclipse-temurin:17-jre-jammy

WORKDIR /app

# 레이어 순서대로 복사하여 캐시 적중률 극대화
COPY --link --from=builder /out/layers/dependencies/ ./
COPY --link --from=builder /out/layers/snapshot-dependencies/ ./
COPY --link --from=builder /out/layers/spring-boot-loader/ ./
COPY --link --from=builder /out/layers/application/ ./

# 외부 설정 마운트
RUN mkdir -p /app/config
VOLUME ["/app/config"]

# 포트/옵션
EXPOSE 8080
ENV JAVA_OPTS=""

# (개발 편의) DB 초기화를 위한 짧은 대기. 운영에서는 제거 권장.
ENTRYPOINT ["sh", "-c", "sleep 10 && exec java $JAVA_OPTS org.springframework.boot.loader.JarLauncher --spring.config.additional-location=optional:file:/app/config/"]
