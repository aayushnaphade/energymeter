# 🚀 Auto-Initialization Setup

## ✅ What Changed

Your ThingsBoard setup now **automatically initializes the database** on first run!

### Previous Setup (Manual):
```bash
# You had to run this manually
docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce
docker compose up -d
```

### New Setup (Automatic):
```bash
# Just start it - database initialization happens automatically!
docker compose up -d
```

---

## 🎯 How It Works

### 1. Custom Dockerfile
The `Dockerfile` now includes:
- PostgreSQL client for database checks
- Custom entrypoint script (`docker-entrypoint.sh`)

### 2. Smart Entrypoint Script
`docker-entrypoint.sh` automatically:
- ✅ Waits for PostgreSQL to be ready
- ✅ Checks if database is already initialized
- ✅ Runs installation if needed (first start only)
- ✅ Loads demo data based on `LOAD_DEMO` setting
- ✅ Starts ThingsBoard normally

### 3. Demo Data Control
In `.env` file:
```bash
LOAD_DEMO=true   # Install with demo data (default)
LOAD_DEMO=false  # Clean installation (production)
```

---

## 🔧 Deployment Steps

### First Time Setup

1. **Build and start:**
   ```bash
   docker compose up -d --build
   ```

2. **Watch the auto-initialization:**
   ```bash
   docker compose logs -f thingsboard-ce
   ```

   You'll see:
   ```
   ========================================
   ThingsBoard Auto-Initialization Script
   ========================================
   
   Waiting for PostgreSQL...
   PostgreSQL is up!
   
   Checking if database is initialized...
   Database not initialized. Running installation...
   Installing ThingsBoard with DEMO data...
   
   Installation completed successfully!
   Starting ThingsBoard...
   ```

3. **Access ThingsBoard:**
   - After logs show "Started ThingsBoard"
   - Open: `https://your-domain.com` (or `http://localhost:8080`)

---

## 📋 Configuration Options

### Load Demo Data (Testing/Development)
```bash
# .env file
LOAD_DEMO=true
```

**What you get:**
- ✅ Sample tenant account
- ✅ Demo devices and assets
- ✅ Example dashboards
- ✅ Pre-configured rule chains
- ✅ Default credentials working

### Clean Installation (Production)
```bash
# .env file
LOAD_DEMO=false
```

**What you get:**
- ✅ Clean database
- ✅ System admin account only
- ✅ No demo data
- ✅ Production-ready setup

---

## 🔄 Rebuild After Changes

If you modify the Dockerfile or entrypoint script:

```bash
# Stop containers
docker compose down

# Rebuild with no cache
docker compose build --no-cache

# Start fresh
docker compose up -d
```

---

## 🛠️ Manual Override

If you still want manual control:

### Initialize manually (disable auto-init):
```bash
# Comment out auto-init in Dockerfile
# Then run manually:
docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce
```

---

## 🎉 Benefits

1. **No manual steps** - Just `docker compose up -d`
2. **Idempotent** - Safe to restart, won't re-initialize
3. **Faster deployment** - No separate init command
4. **Dockploy friendly** - Works perfectly in Dockploy
5. **Production ready** - Control demo data with env var

---

## 📊 Comparison

| Aspect | Old Manual | New Auto |
|--------|-----------|----------|
| Steps | 2 commands | 1 command |
| First run | Manual init | Auto init |
| Restart safe | ✅ Yes | ✅ Yes |
| Demo data control | Command flag | Env variable |
| Dockploy | Manual setup | Automatic |
| Error prone | Medium | Low |

---

## 🐛 Troubleshooting

### "Database initialization failed"
Check logs:
```bash
docker compose logs thingsboard-ce
```

### "Can't connect to PostgreSQL"
Ensure PostgreSQL is healthy:
```bash
docker compose ps postgres
docker compose logs postgres
```

### Want to re-initialize?
```bash
# WARNING: Deletes all data!
docker compose down -v
docker compose up -d --build
```

### Check if database is initialized
```bash
docker compose exec postgres psql -U postgres -d thingsboard -c "\dt" | grep queue
```

If you see `queue` table, it's initialized.

---

## 🚀 Deploy to Dockploy

1. **Upload files** to Dockploy
2. **Set environment variables** in Dockploy UI:
   - `LOAD_DEMO=true` (or false for production)
   - `DOMAIN_NAME=your-domain.com`
3. **Deploy** - Everything else is automatic!

Dockploy will:
- Build the custom Docker image
- Auto-initialize database on first start
- Set up SSL and domain routing
- Start ThingsBoard

---

**That's it!** No more manual database initialization. Just deploy and go! 🎉
