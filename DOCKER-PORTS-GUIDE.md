# 🔧 Docker Port Configuration Explained

## 📌 Understanding Docker Ports

### Two Types of Ports:

1. **Internal Port** (inside Docker network)
2. **External Port** (accessible from your host machine)

---

## 🏗️ How It Works

### PostgreSQL Example:

```yaml
postgres:
  ports:
    - "5432:5432"
    #  ^      ^
    #  |      |
    # HOST  CONTAINER
```

- **Container Port (Right)**: `5432` - Always the same (PostgreSQL default)
- **Host Port (Left)**: `5432` - Can be changed to avoid conflicts

---

## ✅ Current Setup

### PostgreSQL:
```yaml
ports:
  - "${POSTGRES_PORT:-5432}:5432"
  #  External (8428)  : Internal (5432)
```

**Inside Docker Network:**
- ThingsBoard connects to: `postgres:5432` ✅
- NOT `postgres:8428` ❌

**From Your Computer:**
- You connect to: `localhost:5432` (or whatever POSTGRES_PORT is set to)

---

## 🔍 Key Rule

**Inside Docker Network** → Always use **container port** (right side)
**From Host Machine** → Use **host port** (left side)

### Examples:

| Service | Internal (Docker) | External (Host) | From ThingsBoard | From Your PC |
|---------|-------------------|-----------------|------------------|--------------|
| PostgreSQL | `postgres:5432` | `localhost:5432` | `postgres:5432` | `localhost:5432` |
| Kafka | `kafka:9092` | `localhost:9092` | `kafka:9092` | `localhost:9092` |
| ThingsBoard | `thingsboard-ce:8080` | `localhost:8080` | - | `localhost:8080` |

---

## 🚨 Common Mistake

### ❌ WRONG:
```yaml
SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:${POSTGRES_PORT}/thingsboard
# This tries to use host port inside Docker network - FAILS!
```

### ✅ CORRECT:
```yaml
SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/thingsboard
# Always use container port (5432) for internal Docker network
```

---

## 📋 If You Want to Change PostgreSQL External Port

### In `.env`:
```bash
POSTGRES_PORT=8428  # External port (from your computer)
```

### In `docker-compose.yml`:
```yaml
postgres:
  ports:
    - "${POSTGRES_PORT:-5432}:5432"
    #  Your custom port    :  Container port (don't change)
```

### Connection Strings:
```bash
# From your computer (psql, DBeaver, etc.)
psql -h localhost -p 8428 -U postgres -d thingsboard

# From ThingsBoard container (always 5432)
jdbc:postgresql://postgres:5432/thingsboard
```

---

## 🎯 Summary

| Scenario | Port to Use | Example |
|----------|-------------|---------|
| **Container → Container** | Internal (container) port | `postgres:5432` |
| **Host → Container** | External (mapped) port | `localhost:8428` |
| **Dockploy domain → Container** | Internal port | Set domain to `8080` |

---

## 🔧 Your Fixed Setup

### `.env` file:
```bash
POSTGRES_PORT=5432  # External access from host
```

### `docker-compose.yml`:
```yaml
# PostgreSQL service
postgres:
  ports:
    - "${POSTGRES_PORT:-5432}:5432"
    
# ThingsBoard service
thingsboard-ce:
  environment:
    # Always use 5432 for internal Docker network
    SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/thingsboard
```

**This is now correct!** ✅

---

## 🐛 Troubleshooting

### Error: "Connection refused to postgres:8428"
**Cause:** ThingsBoard trying to use external port inside Docker network

**Fix:** Change datasource URL to use `postgres:5432`

### Can't connect from host machine
**Cause:** Wrong external port or port not exposed

**Fix:** Check `POSTGRES_PORT` in `.env` and `ports:` mapping in docker-compose.yml

### Port conflict error
**Cause:** Port already in use on host machine

**Fix:** Change `POSTGRES_PORT` in `.env` to a different port (e.g., 5433)

---

**Remember:** Internal Docker network communication **always** uses the container port! 🎯
