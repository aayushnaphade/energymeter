# 🚨 Common ThingsBoard Errors & Solutions

## Error: "relation 'queue' does not exist"

**Full Error:**
```
ERROR: relation "queue" does not exist
Position: 246
org.postgresql.util.PSQLException: ERROR: relation "queue" does not exist
```

**Cause:** Database tables haven't been created yet.

**Solution:**
```bash
# 1. Stop containers
docker compose down

# 2. Initialize database (creates all tables)
docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce

# 3. Start normally
docker compose up -d
```

---

## Error: Database connection refused

**Error:**
```
Connection refused: postgres:5432
```

**Solution:**
```bash
# Wait for PostgreSQL to be ready
docker compose logs postgres

# Restart if needed
docker compose restart postgres
docker compose restart thingsboard-ce
```

---

## Error: Kafka connection issues

**Error:**
```
Failed to connect to Kafka: kafka:9092
```

**Solution:**
```bash
# Check Kafka is running
docker compose ps kafka

# Restart Kafka and ThingsBoard
docker compose restart kafka
docker compose restart thingsboard-ce
```

---

## Error: Port already in use

**Error:**
```
Bind for 0.0.0.0:8080 failed: port is already allocated
```

**Solution:**

Option 1 - Change port in `.env`:
```bash
TB_HTTP_PORT=8081
```

Option 2 - Find and stop the conflicting service:
```bash
# Windows PowerShell
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Then restart
docker compose up -d
```

---

## Error: Out of memory

**Error:**
```
java.lang.OutOfMemoryError: Java heap space
```

**Solution:**
Add memory limits to docker-compose.yml:

```yaml
thingsboard-ce:
  # ... other config
  environment:
    # ... other env vars
    JAVA_OPTS: "-Xms2G -Xmx4G"
  deploy:
    resources:
      limits:
        memory: 6G
      reservations:
        memory: 4G
```

---

## Can't Login / Wrong Credentials

**Default Credentials:**
- System Admin: `sysadmin@thingsboard.org` / `sysadmin`
- Tenant Admin: `tenant@thingsboard.org` / `tenant`
- Customer: `customer@thingsboard.org` / `customer`

**Reset Password:**
1. Access ThingsBoard
2. Click "Forgot Password?"
3. Or reset via database:
```bash
docker compose exec postgres psql -U postgres -d thingsboard
# Then run SQL commands to reset password
```

---

## ThingsBoard Won't Start

**Check logs:**
```bash
docker compose logs -f thingsboard-ce
```

**Common fixes:**

1. **Ensure initialization was completed:**
   ```bash
   docker compose run --rm -e INSTALL_TB=true thingsboard-ce
   ```

2. **Check all services are healthy:**
   ```bash
   docker compose ps
   ```

3. **Restart everything:**
   ```bash
   docker compose down
   docker compose up -d
   ```

4. **Nuclear option (WARNING: Deletes all data):**
   ```bash
   docker compose down -v
   docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce
   docker compose up -d
   ```

---

## Devices Can't Connect

**MQTT Connection Issues:**

1. **Check port is exposed:**
   ```bash
   docker compose ps
   # Should show 1883:1883
   ```

2. **Test MQTT locally:**
   ```bash
   # Install mosquitto clients
   mosquitto_pub -h localhost -p 1883 -t "test" -m "hello"
   ```

3. **Check firewall:**
   - Ensure port 1883 is open
   - Check cloud provider security groups

4. **Verify device token:**
   - Go to Devices in ThingsBoard UI
   - Copy the correct access token
   - Use it in device connection

---

## SSL/HTTPS Issues in Dockploy

**Certificate not working:**

1. **Wait 5-10 minutes** for Let's Encrypt
2. **Check DNS** points to server:
   ```bash
   nslookup iot.example.com
   ```
3. **Verify Dockploy SSL settings** are enabled
4. **Check Traefik logs:**
   ```bash
   docker logs traefik
   ```

---

## Upgrade Issues

**After upgrade, ThingsBoard won't start:**

1. **Run upgrade migration:**
   ```bash
   docker compose stop thingsboard-ce
   docker compose run --rm -e UPGRADE_TB=true thingsboard-ce
   docker compose up -d
   ```

2. **Check logs for errors:**
   ```bash
   docker compose logs -f thingsboard-ce
   ```

---

## Permission Denied Errors

**Volume mount errors:**

```bash
# Fix volume permissions
docker compose down
docker volume rm tb-postgres-data tb-ce-kafka-data tb-ce-data tb-ce-logs
docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce
docker compose up -d
```

---

## Getting Help

**Collect diagnostic info:**

```bash
# Container status
docker compose ps

# ThingsBoard logs
docker compose logs --tail=100 thingsboard-ce > tb-logs.txt

# PostgreSQL logs
docker compose logs --tail=50 postgres > postgres-logs.txt

# Kafka logs
docker compose logs --tail=50 kafka > kafka-logs.txt

# System info
docker info
docker compose version
```

Then share these log files when asking for help.

---

## Quick Diagnostic Commands

```bash
# Check if database is initialized
docker compose exec postgres psql -U postgres -d thingsboard -c "\dt" | grep queue

# Check ThingsBoard container health
docker compose exec thingsboard-ce curl -f http://localhost:8080/login || echo "Not ready"

# Check Kafka topics
docker compose exec kafka kafka-topics.sh --bootstrap-server localhost:9092 --list

# Check PostgreSQL connection
docker compose exec postgres pg_isready -U postgres
```

---

**Still having issues?** 
1. Check [ThingsBoard Community Forum](https://groups.google.com/forum/#!forum/thingsboard)
2. Search [GitHub Issues](https://github.com/thingsboard/thingsboard/issues)
3. Review full logs: `docker compose logs -f`
