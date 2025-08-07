# Working Tika deployment for Render
FROM openjdk:11-jre-slim

# Install curl for health checks
RUN apt-get update && apt-get install -y curl wget && rm -rf /var/lib/apt/lists/*

# Set Tika version
ENV TIKA_VERSION=2.9.1

# Download Tika (we know archive.apache.org works from the logs)
RUN echo "Downloading Apache Tika ${TIKA_VERSION}..." && \
    wget -O /tika-server.jar https://archive.apache.org/dist/tika/${TIKA_VERSION}/tika-server-standard-${TIKA_VERSION}.jar && \
    echo "Download complete. File size:" && \
    ls -lh /tika-server.jar

# Expose port
EXPOSE 9998

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:9998/tika || exit 1

# Memory constraints for Render Starter
ENV JAVA_OPTS="-Xmx400m -Xms256m"

# Run Tika
CMD echo "Starting Tika server..." && \
    java ${JAVA_OPTS} -jar /tika-server.jar -h 0.0.0.0 -p 9998
