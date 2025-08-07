# Robust Tika deployment for Render with fallback download URLs
FROM openjdk:11-jre-slim

# Install curl and wget for downloads
RUN apt-get update && apt-get install -y curl wget && rm -rf /var/lib/apt/lists/*

# Set Tika version
ENV TIKA_VERSION=2.9.1

# Download Tika with multiple fallback URLs and verification
RUN echo "Downloading Apache Tika ${TIKA_VERSION}..." && \
    (wget -q -O /tika-server.jar https://archive.apache.org/dist/tika/${TIKA_VERSION}/tika-server-standard-${TIKA_VERSION}.jar || \
     wget -q -O /tika-server.jar https://dlcdn.apache.org/tika/${TIKA_VERSION}/tika-server-standard-${TIKA_VERSION}.jar || \
     wget -q -O /tika-server.jar https://www.apache.org/dyn/closer.lua/tika/${TIKA_VERSION}/tika-server-standard-${TIKA_VERSION}.jar?action=download || \
     (echo "Failed to download Tika from primary sources, trying older stable version..." && \
      wget -q -O /tika-server.jar https://archive.apache.org/dist/tika/2.9.0/tika-server-standard-2.9.0.jar)) && \
    echo "Download complete. Verifying JAR file..." && \
    java -jar /tika-server.jar --version && \
    echo "Tika JAR verified successfully!"

# Expose port
EXPOSE 9998

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s \
    CMD curl -f http://localhost:9998/tika || exit 1

# Memory constraints for Render Starter
ENV JAVA_OPTS="-Xmx400m -Xms256m -XX:+UseG1GC"

# Add error checking to startup
CMD if [ ! -f /tika-server.jar ]; then \
        echo "ERROR: Tika JAR not found!"; \
        exit 1; \
    fi && \
    if [ ! -s /tika-server.jar ]; then \
        echo "ERROR: Tika JAR is empty!"; \
        exit 1; \
    fi && \
    echo "Starting Tika server with options: ${JAVA_OPTS}" && \
    java ${JAVA_OPTS} -jar /tika-server.jar -h 0.0.0.0 -p 9998
