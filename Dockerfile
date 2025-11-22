# ThingsBoard with Auto-Initialization
FROM thingsboard/tb-node:4.2.1

# Install PostgreSQL client for database checks
USER root
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Copy custom entrypoint script
COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/docker-entrypoint.sh

# Switch back to thingsboard user
USER thingsboard

# Expose ports
EXPOSE 8080 1883 8883 7070 5683-5688/udp

# Use custom entrypoint that auto-initializes database
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
