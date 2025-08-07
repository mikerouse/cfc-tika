# Simple Tika deployment for Render
FROM openjdk:11-jre-slim

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Download pre-built Tika server
RUN curl -L https://dlcdn.apache.org/tika/2.9.1/tika-server-standard-2.9.1.jar -o /tika-server.jar

# Expose port
EXPOSE 9998

# Health check
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost:9998/tika || exit 1

# Memory constraints for Render Starter
ENV JAVA_OPTS="-Xmx400m -Xms256m"

# Run Tika
CMD java ${JAVA_OPTS} -jar /tika-server.jar -h 0.0.0.0
