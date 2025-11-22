# 🚀 Quick Start - Simple Manual Setup

The auto-initialization was causing permission issues. Here's the **simple, reliable way** to deploy ThingsBoard:

## ✅ Simple 2-Step Deployment

### Step 1: Initialize Database (First Time Only)
```bash
docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce
```

**What this does:**
- Creates all database tables
- Loads system resources (widgets, rule chains, etc.)
- Optionally loads demo data (set `LOAD_DEMO=true` for testing, `false` for production)

**Wait for:**
```
Installation finished successfully!
```

### Step 2: Start Services
```bash
docker compose up -d
```

**That's it!** ✅

---

## 📊 For Dockploy Users

### Option A: Using Dockploy Console

1. **Deploy the stack** in Dockploy
2. **Open console** for thingsboard-ce container
3. **Run initialization:**
   ```bash
   /usr/share/thingsboard/bin/install/install.sh --loadDemo
   ```
4. **Restart** the container in Dockploy UI

### Option B: Pre-initialize Before Upload

1. **Run locally first:**
   ```bash
   docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce
   ```
2. **Upload to Dockploy** (volumes will be created with initialized data)
3. **Start in Dockploy**

---

## 🔧 Common Commands

### Initialize with Demo Data (Testing)
```bash
docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce
```

### Initialize WITHOUT Demo Data (Production)
```bash
docker compose run --rm -e INSTALL_TB=true thingsboard-ce
```

### Start Services
```bash
docker compose up -d
```

### View Logs
```bash
docker compose logs -f thingsboard-ce
```

### Stop Services
```bash
docker compose down
```

### Complete Reset (⚠️ Deletes All Data)
```bash
docker compose down -v
docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce
docker compose up -d
```

---

## 🎯 Port Configuration

Since you changed your PostgreSQL port, the `docker-compose.yml` now uses:
```yaml
SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:${POSTGRES_PORT:-5432}/...
```

This reads from your `.env` file's `POSTGRES_PORT` variable.

---

## ✅ Why Manual Init is Better

| Aspect | Auto-Init | Manual Init |
|--------|-----------|-------------|
| Complexity | High | **Low** |
| Reliability | Issues with permissions | **Always works** |
| Debugging | Hard | **Easy** |
| Official method | No | **Yes** ✅ |
| Works in Dockploy | Sometimes | **Always** ✅ |

---

## 🚀 Deploy Now

```bash
# 1. Stop any running containers
docker compose down

# 2. Initialize database
docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce

# 3. Start services  
docker compose up -d

# 4. Watch logs
docker compose logs -f thingsboard-ce
```

Access at: `https://your-domain.com` (or `http://localhost:8080`)

**Default credentials:**
- Admin: `sysadmin@thingsboard.org` / `sysadmin`
- Tenant: `tenant@thingsboard.org` / `tenant`

---

## 🐛 If You See Errors

### "relation 'queue' does not exist"
You forgot to initialize! Run:
```bash
docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce
```

### Connection refused to PostgreSQL
Check your `POSTGRES_PORT` in `.env` matches the exposed port.

### Can't access web UI
- Wait 1-2 minutes after starting
- Check logs: `docker compose logs -f thingsboard-ce`
- Ensure port 8080 is accessible

---

**Simple. Reliable. Works every time.** 🎉
