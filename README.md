# ThingsBoard for Dockploy - Quick Start Guide

Complete ThingsBoard IoT platform setup optimized for **Dockploy** deployment.

## � Deploy in 3 Steps

### 1. Upload to Dockploy
- Import this `docker-compose.yml` into Dockploy
- Dockploy handles all SSL and domain routing automatically

### 2. Initialize Database
Run this command once before first start:

```bash
docker compose run --rm -e INSTALL_TB=true -e LOAD_DEMO=true thingsboard-ce
```

### 3. Configure Domain in Dockploy
- In Dockploy UI, point your domain to port **8080**
- Dockploy + Traefik will automatically:
  - ✅ Obtain SSL certificate
  - ✅ Enable HTTPS
  - ✅ Redirect HTTP → HTTPS

## 🔐 Default Login

Access via your domain (e.g., https://iot.yourdomain.com)

**Credentials:**
- System Admin: `sysadmin@thingsboard.org` / `sysadmin`
- Tenant Admin: `tenant@thingsboard.org` / `tenant`
- Customer: `customer@thingsboard.org` / `customer`

⚠️ **Change passwords immediately after login!**

## ⚙️ Configuration (.env file)

| Variable | Default | Description |
|----------|---------|-------------|
| `TB_VERSION` | 4.2.1 | ThingsBoard version |
| `POSTGRES_PASSWORD` | postgres | **Change this!** |
| `TB_HTTP_PORT` | 8080 | Port to expose in Dockploy |
| `TB_MQTT_PORT` | 1883 | MQTT for devices |
| `TB_MQTT_SSL_PORT` | 8883 | MQTTS for devices |

## � Ports in Dockploy

Configure these ports in Dockploy:

| Port | Protocol | Purpose | Required? |
|------|----------|---------|-----------|
| **8080** | HTTP | **Web UI & API** | **✅ Yes - map to your domain** |
| 1883 | MQTT | Device connectivity (unencrypted) | Optional |
| 8883 | MQTTS | Device connectivity (encrypted) | Recommended |
| 7070 | TCP | Edge RPC | Optional |
| 5683-5688 | UDP | CoAP & LwM2M | Optional |

### In Dockploy UI:
1. **Domain**: Set your domain (e.g., `iot.example.com`)
2. **Port**: Point to `8080`
3. **SSL**: Dockploy enables this automatically

## 📊 Architecture

```
[Your Domain] → [Dockploy/Traefik] → [ThingsBoard:8080] → [Kafka] → [PostgreSQL]
                      ↓
              Automatic SSL & routing
```

## 🔄 Common Commands

### View Logs
```bash
docker compose logs -f thingsboard-ce
```

### Restart
```bash
docker compose restart thingsboard-ce
```

### Upgrade Version
1. Change `TB_VERSION` in `.env`
2. Run:
```bash
docker pull thingsboard/tb-node:4.2.1
docker compose stop thingsboard-ce
docker compose run --rm -e UPGRADE_TB=true thingsboard-ce
docker compose up -d
```

## 🌐 Connect IoT Devices

### MQTT
```bash
mosquitto_pub -h iot.example.com -p 1883 \
  -t "v1/devices/me/telemetry" \
  -u "YOUR_DEVICE_TOKEN" \
  -m '{"temperature":25}'
```

### HTTPS REST API
```bash
curl -X POST https://iot.example.com/api/v1/YOUR_DEVICE_TOKEN/telemetry \
  -H "Content-Type: application/json" \
  -d '{"temperature":25}'
```

## �️ Security Checklist

- [ ] Change default passwords
- [ ] Change `POSTGRES_PASSWORD` in `.env`
- [ ] Enable 2FA for admin accounts
- [ ] Use MQTTS (8883) instead of MQTT (1883)
- [ ] Regularly update ThingsBoard version
- [ ] Monitor logs for suspicious activity

## � Resources

- [ThingsBoard Docs](https://thingsboard.io/docs/)
- [Getting Started](https://thingsboard.io/docs/getting-started-guides/helloworld/)
- [Connect Devices](https://thingsboard.io/docs/guides#AnchorIDConnectYourDevice)
- [Create Dashboards](https://thingsboard.io/docs/user-guide/visualization/)

## 💾 Data Persistence

Data is stored in Docker volumes:
- `tb-postgres-data` - Database
- `tb-ce-kafka-data` - Message queue
- `tb-ce-data` - Application data
- `tb-ce-logs` - Logs

Volumes persist across restarts and updates.

## 🆘 Troubleshooting

### Can't access ThingsBoard
1. Check Dockploy domain settings
2. Verify port 8080 is mapped
3. Check container logs: `docker compose logs thingsboard-ce`

### Database errors
```bash
docker compose restart postgres
docker compose logs postgres
```

### Device connection issues
1. Ensure MQTT ports (1883/8883) are exposed
2. Verify device token is correct
3. Check firewall settings

---

**Ready for Dockploy!** 🚀 Just upload and point your domain to port 8080.
