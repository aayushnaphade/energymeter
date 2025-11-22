# 🗄️ Using External PostgreSQL with ThingsBoard

## 📋 Overview

This guide shows how to connect ThingsBoard to a **separate PostgreSQL instance** instead of running PostgreSQL in the same Docker Compose stack.

---

## ✅ Benefits

- **Better Isolation** - Database independent from application
- **Managed Services** - Use AWS RDS, Azure Database, Google Cloud SQL
- **Easier Backups** - Database backups independent of app
- **Scalability** - Scale database separately
- **Multi-App Access** - Multiple applications can share the database
- **Production Ready** - Standard production deployment pattern

---

## 🔧 Configuration Options

### Option 1: Separate Docker Container (Same Server)

If you have PostgreSQL in another Docker container:

```bash
# .env file
POSTGRES_HOST=postgres  # Container name or service name
POSTGRES_PORT=5432
POSTGRES_DB=thingsboard
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-password
```

**Note**: Both containers must be on the **same Docker network** or use `host.docker.internal`.

### Option 2: Separate Server / VM

If PostgreSQL is on a different server:

```bash
# .env file
POSTGRES_HOST=192.168.1.100  # IP address of PostgreSQL server
POSTGRES_PORT=5432
POSTGRES_DB=thingsboard
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-password
```

### Option 3: Managed Database (Cloud)

For AWS RDS, Azure Database, etc.:

```bash
# .env file
POSTGRES_HOST=mydb.xxxxxxxxxxxx.us-east-1.rds.amazonaws.com
POSTGRES_PORT=5432
POSTGRES_DB=thingsboard
POSTGRES_USER=admin
POSTGRES_PASSWORD=your-secure-password
```

### Option 4: Localhost PostgreSQL

If PostgreSQL is installed directly on your host machine:

```bash
# .env file
POSTGRES_HOST=host.docker.internal  # Special Docker hostname for host
POSTGRES_PORT=5432
POSTGRES_DB=thingsboard
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-password
```

---

## 🚀 Setup Steps

### Step 1: Prepare Your PostgreSQL Database

Create a database for ThingsBoard:

```sql
-- Connect to PostgreSQL
psql -h your-host -U postgres

-- Create database
CREATE DATABASE thingsboard;

-- Create user (optional, for better security)
CREATE USER tbuser WITH PASSWORD 'secure-password';
GRANT ALL PRIVILEGES ON DATABASE thingsboard TO tbuser;

-- Exit
\q
```

### Step 2: Configure Connection

**Option A: Update existing .env**

Edit your `.env` file:

```bash
# Change these:
POSTGRES_HOST=your-postgres-server.com
POSTGRES_PORT=5432
POSTGRES_DB=thingsboard
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-password
```

**Option B: Use the template**

```bash
# Copy the external postgres template
cp .env.external-postgres .env

# Edit with your details
nano .env
```

### Step 3: Use External PostgreSQL Docker Compose

**Option A: Rename files (switch to external)**

```bash
# Backup current setup
mv docker-compose.yml docker-compose.local-postgres.yml

# Use external postgres version
mv docker-compose.external-postgres.yml docker-compose.yml
```

**Option B: Specify compose file**

```bash
# Use external postgres compose file
docker compose -f docker-compose.external-postgres.yml up -d
```

### Step 4: Initialize ThingsBoard Database

```bash
# Initialize database (one time only)
docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce
```

This will:
- Connect to your external PostgreSQL
- Create all tables in the `thingsboard` database
- Load system resources and demo data

### Step 5: Start ThingsBoard

```bash
docker compose up -d
```

---

## 🔒 Security Considerations

### For Production:

1. **Use SSL/TLS** for database connection:
   ```bash
   SPRING_DATASOURCE_URL: jdbc:postgresql://host:5432/thingsboard?sslmode=require
   ```

2. **Strong passwords**:
   ```bash
   POSTGRES_PASSWORD=Use-A-Very-Strong-P@ssw0rd!
   ```

3. **Dedicated user** (not `postgres`):
   ```sql
   CREATE USER thingsboard_app WITH PASSWORD 'strong-password';
   GRANT ALL PRIVILEGES ON DATABASE thingsboard TO thingsboard_app;
   ```

4. **Firewall rules**:
   - Allow ThingsBoard server IP only
   - Block all other IPs

5. **Network isolation**:
   - Use private networks/VLANs
   - VPC peering for cloud deployments

---

## 🌐 Network Configuration

### Same Docker Network

If PostgreSQL is in another Docker container on the same server:

```yaml
# Add to docker-compose.yml
networks:
  thingsboard-network:
    external: true
    name: shared-network  # Network name where PostgreSQL is
```

### Docker Bridge to Host

If PostgreSQL is on host machine:

```bash
# Use special hostname in .env
POSTGRES_HOST=host.docker.internal
```

Or use host network mode:

```yaml
thingsboard-ce:
  network_mode: "host"
```

### External Server

Ensure firewall allows connection:

```bash
# Test connection from ThingsBoard server
psql -h your-postgres-host.com -p 5432 -U postgres -d thingsboard

# If this works, ThingsBoard can connect too
```

---

## 📊 Connection String Examples

### Basic Connection:
```
jdbc:postgresql://localhost:5432/thingsboard
```

### With SSL:
```
jdbc:postgresql://host:5432/thingsboard?sslmode=require
```

### AWS RDS:
```
jdbc:postgresql://mydb.xxxxxxxxxxxx.us-east-1.rds.amazonaws.com:5432/thingsboard?sslmode=require
```

### Azure Database:
```
jdbc:postgresql://myserver.postgres.database.azure.com:5432/thingsboard?sslmode=require
```

### Google Cloud SQL:
```
jdbc:postgresql://10.x.x.x:5432/thingsboard
```

---

## 🔍 Troubleshooting

### Connection Refused

**Cause**: PostgreSQL not accessible

**Fix**:
1. Check PostgreSQL is running:
   ```bash
   psql -h your-host -p 5432 -U postgres
   ```

2. Check `postgresql.conf`:
   ```
   listen_addresses = '*'  # Or specific IP
   ```

3. Check `pg_hba.conf`:
   ```
   host    thingsboard    postgres    0.0.0.0/0    md5
   ```

4. Restart PostgreSQL:
   ```bash
   sudo systemctl restart postgresql
   ```

### Authentication Failed

**Cause**: Wrong username/password

**Fix**:
1. Verify credentials:
   ```bash
   psql -h host -p 5432 -U postgres -d thingsboard
   ```

2. Update `.env` with correct credentials

### Network Issues

**Cause**: Docker can't reach PostgreSQL host

**Fix**:
1. Test from ThingsBoard container:
   ```bash
   docker compose exec thingsboard-ce bash
   ping your-postgres-host
   telnet your-postgres-host 5432
   ```

2. Use correct hostname:
   - `host.docker.internal` for host machine
   - Container name for same network
   - IP/domain for external server

---

## 📋 Comparison: Local vs External PostgreSQL

| Aspect | Local (docker-compose) | External |
|--------|------------------------|----------|
| **Setup** | Easier | More config needed |
| **Isolation** | Same stack | Separate service |
| **Backups** | Manual | Automated (managed) |
| **Scalability** | Limited | Better |
| **Cost** | Free | May have costs |
| **Production** | Development | Recommended ✅ |
| **Multi-app** | ❌ No | ✅ Yes |
| **Managed** | Self-managed | Cloud provider |

---

## ✅ Recommended Setup

### Development:
```yaml
# Use local PostgreSQL (current docker-compose.yml)
docker compose up -d
```

### Production:
```yaml
# Use external managed database
# - AWS RDS
# - Azure Database for PostgreSQL
# - Google Cloud SQL
# - Managed Dockploy database
```

---

## 🚀 Quick Start Commands

### With External PostgreSQL:

```bash
# 1. Configure .env with your database details
nano .env

# 2. Use external postgres compose file
docker compose -f docker-compose.external-postgres.yml down

# 3. Initialize database
docker compose -f docker-compose.external-postgres.yml run --rm \
  -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce

# 4. Start services
docker compose -f docker-compose.external-postgres.yml up -d

# 5. Check logs
docker compose -f docker-compose.external-postgres.yml logs -f thingsboard-ce
```

---

## 📝 Files Overview

| File | Purpose |
|------|---------|
| `docker-compose.yml` | **Default** - Includes local PostgreSQL |
| `docker-compose.external-postgres.yml` | External PostgreSQL setup |
| `.env` | Local PostgreSQL configuration |
| `.env.external-postgres` | Template for external PostgreSQL |

---

**Choose the setup that fits your needs!** 🎯
