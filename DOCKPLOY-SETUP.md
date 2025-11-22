# 🎯 Dockploy Setup Guide - Port Configuration

## Port You MUST Point Your Domain To

### In Dockploy UI:
**Point your domain to port: `8080`**

```
Your Domain (e.g., iot.example.com) → Port 8080
```

This gives you:
- ✅ Web UI (dashboard)
- ✅ REST API
- ✅ WebSocket connections
- ✅ Device HTTP connections

---

## Complete Port Reference

### 🌐 Port 8080 - WEB UI (REQUIRED)
**Point your domain to this port in Dockploy**

```yaml
ports:
  - "8080:8080"  # ← Point your domain here
```

**What you get:**
- Web interface: `https://iot.example.com`
- REST API: `https://iot.example.com/api/v1/...`
- WebSocket: `wss://iot.example.com/...`

**In Dockploy:**
1. Go to your ThingsBoard app
2. Under "Domains" → Add domain
3. Domain: `iot.example.com`
4. Port: `8080` ← **THIS IS THE KEY**
5. SSL: Auto (Dockploy handles it)

---

### 📡 Port 1883 - MQTT (Optional - for device connections)
**Expose this port if you have MQTT devices**

```yaml
ports:
  - "1883:1883"  # MQTT (unencrypted)
```

**When to expose:**
- You have IoT devices using MQTT protocol
- Devices connect directly (not via HTTP)

**How devices connect:**
```bash
mosquitto_pub -h iot.example.com -p 1883 \
  -t "v1/devices/me/telemetry" \
  -u "YOUR_TOKEN" \
  -m '{"temperature":25}'
```

**In Dockploy:**
- This port is exposed **directly** (no domain routing)
- Just ensure port 1883 is accessible in firewall

---

### 🔒 Port 8883 - MQTTS (Recommended for secure MQTT)
**Expose this for encrypted MQTT connections**

```yaml
ports:
  - "8883:8883"  # MQTT over SSL
```

**When to expose:**
- You want secure MQTT connections
- Production deployments

**In Dockploy:**
- Expose port 8883 directly
- No domain routing needed

---

### 📋 Other Ports (Advanced - Usually Not Needed)

#### Port 7070 - Edge RPC
```yaml
ports:
  - "7070:7070"  # ThingsBoard Edge
```
Only needed if using ThingsBoard Edge servers.

#### Ports 5683-5688 - CoAP/LwM2M
```yaml
ports:
  - "5683-5688:5683-5688/udp"
```
Only for CoAP and LwM2M protocol devices (rare).

---

## 🎬 Step-by-Step Dockploy Setup

### Step 1: Upload docker-compose.yml to Dockploy
Upload your `docker-compose.yml` file to Dockploy.

### Step 2: Initialize Database (First Time Only)
In Dockploy console:
```bash
docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce
```

### Step 3: Configure Domain in Dockploy
**This is where you point the port!**

1. Click on your ThingsBoard app
2. Go to **"Domains"** tab
3. Click **"Add Domain"**
4. Fill in:
   - **Domain**: `iot.example.com` (your domain)
   - **Port**: `8080` ← **POINT TO THIS**
   - **SSL**: Enable (automatic via Let's Encrypt)
   - **Redirect HTTP to HTTPS**: Enable

### Step 4: (Optional) Expose MQTT Ports
If you need MQTT device connectivity:

1. Go to **"Ports"** or **"Network"** tab in Dockploy
2. Expose these ports:
   - `1883` for MQTT (unencrypted)
   - `8883` for MQTTS (encrypted) - recommended

These are **NOT** routed through domain - they're direct connections.

### Step 5: Start Application
Start the stack in Dockploy.

---

## 🔍 Quick Test

After setup, test access:

### Web UI (via domain routing)
```
https://iot.example.com
```
Should show ThingsBoard login page.

### MQTT (direct port access)
```bash
# Test MQTT connection
mosquitto_pub -h iot.example.com -p 1883 \
  -t "test" -m "hello"
```

### REST API (via domain routing)
```bash
curl https://iot.example.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"tenant@thingsboard.org","password":"tenant"}'
```

---

## 📊 Summary

| Port | Protocol | Domain Routing? | How to Configure in Dockploy |
|------|----------|-----------------|------------------------------|
| **8080** | **HTTP/WS** | **✅ YES** | **Point domain to this port** |
| 1883 | MQTT | ❌ No | Expose port directly |
| 8883 | MQTTS | ❌ No | Expose port directly |
| 7070 | TCP | ❌ No | Expose if using Edge |
| 5683-5688 | UDP | ❌ No | Expose if using CoAP |

**TL;DR: In Dockploy, point your domain to port 8080. Done!** 🎉

---

## 🛠️ Troubleshooting

### "Can't access web UI"
- ✅ Check domain points to port **8080**
- ✅ Verify DNS is pointing to server
- ✅ Check Dockploy SSL is enabled
- ✅ View logs: `docker compose logs thingsboard-ce`

### "Devices can't connect via MQTT"
- ✅ Ensure port 1883 (or 8883) is exposed in Dockploy
- ✅ Check firewall allows MQTT ports
- ✅ Verify device token is correct

### "SSL certificate error"
- Wait 5-10 minutes for Let's Encrypt
- Check Dockploy SSL settings
- Verify domain DNS is correct

---

**Need help?** Check logs:
```bash
docker compose logs -f thingsboard-ce
```
