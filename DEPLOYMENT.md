# CallCraft - Production Deployment Guide

Complete guide for deploying CallCraft to production.

---

## Pre-Deployment Checklist

### Backend
- [ ] All tests passing (`pytest tests/`)
- [ ] Environment variables configured
- [ ] Database migrations up to date
- [ ] LLM model downloaded
- [ ] SSL certificates ready
- [ ] Monitoring configured
- [ ] Backup strategy defined

### Mobile
- [ ] All Flutter tests passing
- [ ] App icons configured (all sizes)
- [ ] Splash screen configured
- [ ] Privacy policy added
- [ ] Terms of service added
- [ ] Backend URL updated to production
- [ ] API keys secured

---

## Backend Deployment (Railway - Recommended)

### Step 1: Prepare Repository

```bash
# Ensure code is pushed to GitHub
git add .
git commit -m "Prepare for production deployment"
git push origin main
```

### Step 2: Deploy to Railway

1. **Create Railway account**: https://railway.app
2. **Create new project**:
   ```bash
   railway login
   railway init
   ```

3. **Add PostgreSQL database**:
   - Go to Railway dashboard
   - Click "New" → "Database" → "PostgreSQL"
   - Copy connection string

4. **Configure environment variables**:
   ```bash
   railway variables set SECRET_KEY="your-secret-key-here"
   railway variables set DATABASE_URL="your-postgres-url"
   railway variables set OLLAMA_BASE_URL="http://localhost:11434"
   railway variables set DEBUG="False"
   ```

5. **Deploy backend**:
   ```bash
   cd backend
   railway up
   ```

6. **Run migrations**:
   ```bash
   railway run alembic upgrade head
   ```

7. **Get deployment URL**:
   ```bash
   railway domain
   ```

### Step 3: Set Up Ollama (LLM Service)

**Option A: Run on same server**
```bash
# SSH into Railway container
railway shell

# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Pull model
ollama pull qwen2.5:7b-instruct
```

**Option B: Separate GPU instance (Recommended for scale)**
1. Deploy to GPU-enabled server (AWS g4dn.xlarge, DO GPU droplet)
2. Install Ollama and pull model
3. Update `OLLAMA_BASE_URL` environment variable

### Step 4: Configure Custom Domain

```bash
# Add custom domain in Railway dashboard
railway domain add api.callcraft.app

# Update DNS records:
# CNAME api.callcraft.app -> your-railway-url.railway.app
```

### Step 5: Enable HTTPS

Railway automatically provisions SSL certificates. No action needed!

---

## Backend Deployment (DigitalOcean Alternative)

### Step 1: Create Droplet

```bash
# Create Ubuntu 22.04 droplet (min $12/month)
doctl compute droplet create callcraft-api \
  --region nyc3 \
  --size s-2vcpu-4gb \
  --image ubuntu-22-04-x64
```

### Step 2: Install Dependencies

```bash
# SSH into droplet
ssh root@your-droplet-ip

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install docker-compose -y
```

### Step 3: Deploy Application

```bash
# Clone repository
git clone https://github.com/yourusername/CallCraft.git
cd CallCraft

# Configure environment
cp backend/.env.example backend/.env
nano backend/.env  # Edit with production values

# Start services
docker-compose -f docker-compose.prod.yml up -d
```

### Step 4: Configure Nginx (Reverse Proxy)

```bash
# Install Nginx
apt install nginx -y

# Configure Nginx
nano /etc/nginx/sites-available/callcraft
```

Add configuration:
```nginx
server {
    listen 80;
    server_name api.callcraft.app;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
# Enable site
ln -s /etc/nginx/sites-available/callcraft /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

### Step 5: Enable HTTPS (Let's Encrypt)

```bash
# Install Certbot
apt install certbot python3-certbot-nginx -y

# Get SSL certificate
certbot --nginx -d api.callcraft.app

# Auto-renewal is configured automatically
```

---

## Database Management

### Backups

**Automated backups (Railway)**:
- Configured automatically
- 7-day retention
- Point-in-time recovery

**Manual backup**:
```bash
# Export database
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql

# Restore database
psql $DATABASE_URL < backup_20240302.sql
```

### Migrations

```bash
# Create new migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

---

## Monitoring & Logging

### Set Up Sentry (Error Tracking)

1. **Create Sentry account**: https://sentry.io
2. **Add Sentry SDK**:
   ```bash
   pip install sentry-sdk[fastapi]
   ```

3. **Configure in main.py**:
   ```python
   import sentry_sdk

   sentry_sdk.init(
       dsn="your-sentry-dsn",
       traces_sample_rate=1.0,
   )
   ```

### Set Up Uptime Monitoring

**Better Uptime** (recommended):
1. Create account: https://betteruptime.com
2. Add monitor for https://api.callcraft.app/health
3. Set alert channels (email, Slack, etc.)

---

## Mobile App Deployment

### Android (Google Play Store)

#### Step 1: Prepare Release Build

```bash
cd mobile

# Update version in pubspec.yaml
# version: 1.0.0+1  (version_name+build_number)

# Build release APK
flutter build apk --release

# OR build App Bundle (recommended)
flutter build appbundle --release
```

#### Step 2: Sign APK

```bash
# Generate keystore (one-time)
keytool -genkey -v -keystore ~/callcraft-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias callcraft

# Configure signing in android/key.properties
storePassword=your-password
keyPassword=your-password
keyAlias=callcraft
storeFile=~/callcraft-release-key.jks
```

#### Step 3: Create Play Store Listing

1. **Create developer account**: https://play.google.com/console ($25 one-time)
2. **Create app**: Click "Create app"
3. **Fill app details**:
   - App name: CallCraft
   - Default language: English
   - App/Game: App
   - Free/Paid: Free

4. **Upload assets**:
   - Icon: 512x512px
   - Feature graphic: 1024x500px
   - Screenshots: 5-8 images (phone + tablet)

5. **Content rating**:
   - Complete questionnaire
   - Get PEGI/ESRB rating

6. **Upload APK/AAB**:
   - Go to "Release" → "Production"
   - Upload app bundle
   - Complete release notes

7. **Submit for review**:
   - Review typically takes 1-3 days

### iOS (App Store)

#### Step 1: Prepare Release Build

```bash
cd mobile

# Build iOS release
flutter build ios --release
```

#### Step 2: Configure Xcode

```bash
# Open Xcode
open ios/Runner.xcworkspace

# Configure signing:
# 1. Select Runner target
# 2. Go to "Signing & Capabilities"
# 3. Select your Team
# 4. Check "Automatically manage signing"
```

#### Step 3: Archive & Upload

1. **Archive app**: Product → Archive
2. **Validate archive**: Click "Validate App"
3. **Distribute**: Click "Distribute App"
4. **Upload to App Store Connect**

#### Step 4: Create App Store Listing

1. **Create developer account**: https://developer.apple.com ($99/year)
2. **App Store Connect**: https://appstoreconnect.apple.com
3. **Create new app**:
   - Name: CallCraft
   - Primary language: English
   - Bundle ID: com.callcraft.app
   - SKU: callcraft-001

4. **App information**:
   - Category: Business / Productivity
   - Content rights: Own or licensed
   - Age rating: 4+

5. **Pricing**: Free

6. **App Review Information**:
   - Contact info
   - Demo account (if needed)
   - Notes for reviewer

7. **Submit for review**:
   - Typically 1-7 days

---

## Post-Deployment

### Health Checks

```bash
# Check backend health
curl https://api.callcraft.app/health

# Check database connection
psql $DATABASE_URL -c "SELECT 1"

# Check LLM service
curl http://localhost:11434/api/tags
```

### Monitoring Dashboards

1. **Railway Dashboard**: Monitor CPU, memory, requests
2. **Sentry**: Track errors and performance
3. **Better Uptime**: Monitor uptime and response times

### Performance Testing

```bash
# Load test API
ab -n 1000 -c 10 https://api.callcraft.app/health

# Or use k6
k6 run loadtest.js
```

---

## Scaling Considerations

### Backend Scaling

**Vertical scaling (increase resources)**:
- Railway: Upgrade plan
- DigitalOcean: Resize droplet

**Horizontal scaling (add instances)**:
- Add load balancer
- Deploy multiple backend instances
- Use Redis for shared cache

### Database Scaling

- Enable connection pooling (pgBouncer)
- Add read replicas
- Implement query optimization
- Add database indexes

### LLM Scaling

- Deploy on GPU instance
- Use vLLM for batching
- Implement request queuing
- Add model caching

---

## Rollback Procedure

### Backend Rollback

**Railway**:
```bash
railway rollback
```

**Docker**:
```bash
# Pull previous image
docker pull your-registry/callcraft:previous-tag

# Restart with previous version
docker-compose up -d
```

### Database Rollback

```bash
# Rollback migration
alembic downgrade -1

# Or restore from backup
psql $DATABASE_URL < backup_previous.sql
```

### Mobile Rollback

- Not possible once published
- Submit urgent update with fixes
- Use staged rollout (gradual % of users)

---

## Security Best Practices

1. **Environment variables**: Never commit .env files
2. **API keys**: Rotate regularly
3. **Database**: Use SSL connections
4. **HTTPS**: Always use SSL/TLS
5. **Rate limiting**: Implement on all endpoints
6. **Input validation**: Validate all user inputs
7. **Dependencies**: Keep up to date
8. **Secrets**: Use secrets manager (Railway Secrets, AWS Secrets Manager)

---

## Cost Optimization

### Current Costs (100 users)

- Backend (Railway): $20-50/month
- Database (Railway): $10-25/month
- LLM (Self-hosted): $0-200/month
- Monitoring (Sentry): Free tier
- **Total**: ~$30-275/month

### Cost at Scale (1000+ users)

- Backend (multiple instances): $100-200/month
- Database (managed, replica): $50-100/month
- LLM (GPU instance): $200-400/month
- CDN (Cloudflare): $20/month
- Monitoring: $20/month
- **Total**: ~$390-740/month

---

## Support & Maintenance

### Regular Tasks

**Daily**:
- Check error logs (Sentry)
- Monitor uptime (Better Uptime)
- Review user feedback

**Weekly**:
- Database backup verification
- Performance metrics review
- Security updates

**Monthly**:
- Dependency updates
- Cost analysis
- User analytics review

---

## Troubleshooting

### Backend not starting
```bash
# Check logs
railway logs

# Check environment variables
railway variables

# Check database connection
railway run python -c "from app.core.database import engine; print(engine)"
```

### High response times
- Check database query performance
- Review LLM response times
- Check server resources
- Enable caching

### Database connection errors
- Verify DATABASE_URL
- Check connection pool settings
- Review max connections limit

---

## Additional Resources

- [Railway Docs](https://docs.railway.app)
- [DigitalOcean Docs](https://docs.digitalocean.com)
- [Flutter Deployment](https://flutter.dev/docs/deployment)
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)

---

**Need help?** Check the main [README.md](README.md) or open an issue on GitHub.
