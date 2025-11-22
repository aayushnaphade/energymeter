#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}ThingsBoard Auto-Initialization Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Wait for PostgreSQL to be ready
echo -e "${YELLOW}Waiting for PostgreSQL...${NC}"
until PGPASSWORD=$SPRING_DATASOURCE_PASSWORD psql -h "postgres" -U "$SPRING_DATASOURCE_USERNAME" -d "$POSTGRES_DB" -c '\q' 2>/dev/null; do
  echo -e "${YELLOW}PostgreSQL is unavailable - sleeping${NC}"
  sleep 2
done

echo -e "${GREEN}PostgreSQL is up!${NC}"
echo ""

# Check if database is already initialized by checking if 'queue' table exists
echo -e "${YELLOW}Checking if database is initialized...${NC}"
TABLE_EXISTS=$(PGPASSWORD=$SPRING_DATASOURCE_PASSWORD psql -h "postgres" -U "$SPRING_DATASOURCE_USERNAME" -d "$POSTGRES_DB" -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'queue');")

if [ "$TABLE_EXISTS" = "t" ]; then
    echo -e "${GREEN}Database already initialized. Skipping installation.${NC}"
    echo ""
else
    echo -e "${YELLOW}Database not initialized. Running installation...${NC}"
    echo ""
    
    # Set installation flags
    export install_tb=true
    
    if [ "$LOAD_DEMO" = "true" ]; then
        echo -e "${YELLOW}Installing ThingsBoard with DEMO data...${NC}"
        export loadDemo=true
    else
        echo -e "${YELLOW}Installing ThingsBoard WITHOUT demo data...${NC}"
        export loadDemo=false
    fi
    
    # Run ThingsBoard installation using the run-application.sh script
    echo -e "${YELLOW}Running database installation...${NC}"
    /usr/share/thingsboard/bin/install/install.sh --loadDemo
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
fi

# Start ThingsBoard normally
echo -e "${GREEN}Starting ThingsBoard...${NC}"
echo ""
exec /usr/share/thingsboard/bin/thingsboard.sh
