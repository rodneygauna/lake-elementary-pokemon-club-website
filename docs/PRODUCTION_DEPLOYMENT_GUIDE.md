# Lake Elementary Pokémon Club Website - Production Deployment Guide

## Overview

This guide will walk you through deploying your Rails 8 application to DigitalOcean using Kamal. This is a complete step-by-step process for first-time deployments.

## Prerequisites

- DigitalOcean account
- Domain name (recommended)
- Docker Hub account (or other container registry)
- Local development environment working

## Part 1: DigitalOcean Server Setup

### Step 1: Create a Droplet

1. **Log into DigitalOcean Dashboard**
2. **Create Droplet**
   - Choose: Ubuntu 22.04 LTS
   - Plan: Basic Plan
   - CPU: Regular Intel (2GB RAM, 1 CPU minimum - recommended: 4GB RAM, 2 CPU)
   - Datacenter: Choose closest to your users
   - Authentication: SSH Key (create one if you don't have it)
   - Hostname: `pokemon-club-prod` (or similar)

3. **Note the IP Address** - you'll need this for configuration

### Step 2: Initial Server Setup

SSH into your new droplet:
```bash
ssh root@YOUR_DROPLET_IP
```

**Update the system:**
```bash
apt update && apt upgrade -y
```

**Install Docker:**
```bash
# Install Docker's GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt update
apt install docker-ce docker-ce-cli containerd.io -y

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Verify Docker installation
docker --version
```

**Configure Docker for non-root user (optional but recommended):**
```bash
# Create a non-root user for deployment
adduser deploy
usermod -aG sudo deploy
usermod -aG docker deploy

# Set up SSH access for deploy user
mkdir -p /home/deploy/.ssh
cp /root/.ssh/authorized_keys /home/deploy/.ssh/
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys
```

### Step 3: Configure Firewall

```bash
# Install and configure UFW firewall
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw --force enable
ufw status
```

## Part 2: Domain and DNS Setup (Optional but Recommended)

### Step 1: Point Domain to Server

In your domain registrar's DNS settings:
- Create an A record pointing to your droplet's IP address
- Example: `pokemonclub.yourdomain.com` → `YOUR_DROPLET_IP`

### Step 2: Wait for DNS Propagation

Check if DNS is working:
```bash
nslookup pokemonclub.yourdomain.com
```

## Part 3: Container Registry Setup

### Option A: Docker Hub (Recommended for beginners)

1. **Create Docker Hub account** at https://hub.docker.com
2. **Create a repository**: `your-username/lake-elementary-pokemon-club-website`
3. **Generate Access Token**:
   - Go to Account Settings → Security → Access Tokens
   - Create new token with Read/Write permissions
   - **Save this token** - you'll need it for Kamal

### Option B: DigitalOcean Container Registry

1. **Create Container Registry** in DigitalOcean dashboard
2. **Generate API token** in API section
3. **Note the registry URL**

## Part 4: Local Kamal Configuration

### Step 1: Update deploy.yml

Edit `config/deploy.yml`:

```yaml
# Name of your application
service: lake_elementary_pokemon_club_website

# Container image (update with your Docker Hub username)
image: YOUR_DOCKERHUB_USERNAME/lake_elementary_pokemon_club_website

# Deploy to these servers (update with your droplet IP)
servers:
  web:
    - YOUR_DROPLET_IP

# SSL and domain configuration
proxy:
  ssl: true
  host: pokemonclub.yourdomain.com  # Update with your domain

# Container registry credentials
registry:
  username: YOUR_DOCKERHUB_USERNAME
  password:
    - KAMAL_REGISTRY_PASSWORD

# Environment variables
env:
  secret:
    - RAILS_MASTER_KEY
  clear:
    SOLID_QUEUE_IN_PUMA: true
    RAILS_ENV: production

# Storage for SQLite database and uploads
volumes:
  - "lake_elementary_pokemon_club_website_storage:/rails/storage"

# Asset handling
asset_path: /rails/public/assets

# Docker build configuration
builder:
  arch: amd64

# SSH configuration (if using deploy user)
# ssh:
#   user: deploy
```

### Step 2: Update Production Configuration

Edit `config/environments/production.rb` to update the host:

```ruby
# Set host to be used by links generated in mailer templates.
config.action_mailer.default_url_options = { host: "pokemonclub.yourdomain.com" }

# Update allowed hosts
config.hosts = [
  "pokemonclub.yourdomain.com",
  /.*\.yourdomain\.com/
]
```

### Step 3: Set Up Environment Variables

Create or update `.kamal/secrets`:

```bash
# Registry password (Docker Hub access token)
KAMAL_REGISTRY_PASSWORD=your_docker_hub_access_token

# Rails master key (already configured)
RAILS_MASTER_KEY=$(cat config/master.key)
```

**Set environment variables in your shell:**
```bash
export KAMAL_REGISTRY_PASSWORD="your_docker_hub_access_token"
```

### Step 4: Prepare Admin User for Production

Edit `db/seeds.rb` to use a secure admin email and password:

```ruby
# Create admin user for production
puts "Creating admin user..."
admin_email = ENV.fetch("ADMIN_EMAIL", "admin@pokemonclub.test")
admin_password = ENV.fetch("ADMIN_PASSWORD", "password123")

admin_user = User.find_or_create_by!(email_address: admin_email) do |user|
  user.first_name = "Club"
  user.last_name = "Administrator"
  user.password = admin_password
  user.password_confirmation = admin_password
  user.role = "admin"
  user.status = "active"
end

puts "Admin user created with email: #{admin_user.email_address}"
# Only create sample data in development
unless Rails.env.production?
  # ... rest of your seed data
end
```

## Part 5: Initial Deployment

### Step 1: Verify Configuration

```bash
# Check if Kamal can connect to your server
bin/kamal setup --verify
```

### Step 2: Deploy the Application

```bash
# Build and deploy the application
bin/kamal deploy

# This will:
# 1. Build your Docker image locally
# 2. Push it to your container registry
# 3. Set up the server environment
# 4. Deploy the application
# 5. Configure SSL with Let's Encrypt
```

### Step 3: Set Up the Database

```bash
# Create the database and run migrations
bin/kamal app exec "bin/rails db:create"
bin/kamal app exec "bin/rails db:migrate"

# Seed the database with admin user
bin/kamal app exec "bin/rails db:seed"
```

## Part 6: Post-Deployment Configuration

### Step 1: Verify Deployment

1. **Check application status:**
```bash
bin/kamal app logs
```

2. **Visit your domain:**
   - https://pokemonclub.yourdomain.com
   - Should see your application with SSL certificate

### Step 2: Login as Admin

1. **Go to login page:** `/login`
2. **Admin credentials:**
   - Email: `admin@pokemonclub.test` (or your custom email)
   - Password: `password123` (or your custom password)

### Step 3: Create Your Real Admin Account

1. **Login with seeded admin account**
2. **Go to Admin → Users**
3. **Create your real admin account** with your actual email
4. **Update the seeded admin account** or deactivate it

### Step 4: Configure Email (Optional)

If you want email notifications to work:

1. **Set up Gmail App Password** (or other SMTP service)
2. **Update Rails credentials:**
```bash
bin/rails credentials:edit
```

Add:
```yaml
smtp:
  user_name: your-gmail@gmail.com
  password: your-app-password
```

3. **Redeploy:**
```bash
bin/kamal deploy
```

## Part 7: Useful Kamal Commands

### Daily Operations

```bash
# Deploy updates
bin/kamal deploy

# Check application logs
bin/kamal app logs

# Access Rails console
bin/kamal app exec --interactive --reuse "bin/rails console"

# Access database console
bin/kamal app exec --interactive --reuse "bin/rails dbconsole"

# SSH into container
bin/kamal app exec --interactive --reuse "bash"

# Restart application
bin/kamal app boot

# Check application status
bin/kamal app details
```

### Database Operations

```bash
# Run migrations
bin/kamal app exec "bin/rails db:migrate"

# Seed database
bin/kamal app exec "bin/rails db:seed"

# Reset database (CAREFUL!)
bin/kamal app exec "bin/rails db:reset"
```

### SSL Certificate Management

```bash
# Renew SSL certificate
bin/kamal traefik reboot

# Check SSL certificate status
bin/kamal traefik logs
```

## Part 8: Monitoring and Maintenance

### Health Checks

Your application includes a health check endpoint at `/up`. You can monitor:
- Application status
- Database connectivity
- Storage availability

### Backups

**Important**: Set up regular backups of your SQLite database:

```bash
# Create backup script on server
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker cp lake_elementary_pokemon_club_website:/rails/storage/production.sqlite3 /backup/pokemon_club_$DATE.sqlite3
```

### Log Management

```bash
# View real-time logs
bin/kamal app logs -f

# View specific service logs
bin/kamal traefik logs
```

## Troubleshooting

### Common Issues

1. **SSL Certificate Issues:**
   - Ensure DNS is properly configured
   - Check firewall allows ports 80 and 443
   - Try: `bin/kamal traefik reboot`

2. **Database Issues:**
   - Check volume mounts: `bin/kamal app details`
   - Verify permissions: `bin/kamal app exec "ls -la /rails/storage"`

3. **Container Registry Issues:**
   - Verify Docker Hub credentials
   - Check token permissions
   - Try: `docker login` locally

4. **Connection Issues:**
   - Verify SSH access to server
   - Check firewall settings
   - Ensure Docker is running on server

### Getting Help

```bash
# Kamal help
bin/kamal help

# Application details
bin/kamal app details

# Server information
bin/kamal app exec "uname -a"
```

## Security Considerations

1. **Change default passwords** immediately after deployment
2. **Use strong passwords** for admin accounts
3. **Regularly update** the server and Docker images
4. **Monitor logs** for suspicious activity
5. **Set up automated backups**
6. **Use environment variables** for sensitive data

## Next Steps

After successful deployment:

1. **Create additional admin users** as needed
2. **Add students and parents** to the system
3. **Schedule events** for your Pokémon club
4. **Upload donor information** and photos
5. **Test email functionality** if configured
6. **Set up monitoring** and backup procedures

## Support

If you encounter issues:
1. Check the logs: `bin/kamal app logs`
2. Verify server status: `bin/kamal app details`
3. Review this guide's troubleshooting section
4. Check Kamal documentation: https://kamal-deploy.org/

---

**Remember**: This deployment uses SQLite, which is suitable for small to medium applications. Monitor performance and consider PostgreSQL if you need more robust database features.