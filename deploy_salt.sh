#!/bin/bash
set -e

# Salt Configuration Deployment Script
# Deploys Salt states and pillars from Git repo to /srv/

REPO_DIR="${REPO_DIR:-$HOME/salt-projekt/salt-CaI}"
SOPS_KEY="${SOPS_AGE_KEY_FILE:-$HOME/sops-admin-key.txt}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root"
   exit 1
fi

# Check if repo exists
if [[ ! -d "$REPO_DIR" ]]; then
    log_error "Repository directory not found: $REPO_DIR"
    exit 1
fi

# Check if SOPS key exists
if [[ ! -f "$SOPS_KEY" ]]; then
    log_error "SOPS key not found: $SOPS_KEY"
    exit 1
fi

log_info "Starting Salt deployment from: $REPO_DIR"

# Set SOPS key for decryption
export SOPS_AGE_KEY_FILE="$SOPS_KEY"

# 1. Deploy Salt States
log_info "Deploying Salt states to /srv/salt/"
rsync -av --delete \
    "$REPO_DIR/salt/" \
    /srv/salt/

# 2. Deploy Pillar Services
log_info "Deploying Pillar services to /srv/pillar/services/"
mkdir -p /srv/pillar/services
rsync -av \
    "$REPO_DIR/pillar/services/" \
    /srv/pillar/services/

# 3. Deploy Pillar top.sls
log_info "Deploying Pillar top.sls"
cp "$REPO_DIR/pillar/top.sls" /srv/pillar/top.sls

# 4. Decrypt and deploy secrets
log_info "Processing encrypted secrets..."
mkdir -p /srv/pillar/secrets

# Process each secret file
for secret_file in "$REPO_DIR/pillar/secrets"/*.yaml; do
    if [[ -f "$secret_file" ]]; then
        filename=$(basename "$secret_file" .yaml)
        log_info "  Decrypting: $filename.yaml -> /srv/pillar/secrets/$filename.sls"
        
        # Decrypt and save as .sls
        if sops -d "$secret_file" > "/srv/pillar/secrets/$filename.sls" 2>/dev/null; then
            log_info "    ✓ Successfully decrypted $filename"
        else
            log_error "    ✗ Failed to decrypt $filename"
            exit 1
        fi
    fi
done

# 5. Set correct ownership
log_info "Setting ownership to salt:salt"
chown -R salt:salt /srv/salt/
chown -R salt:salt /srv/pillar/

# 6. Verify deployment
log_info "Verifying deployment..."

# Check critical files
CRITICAL_FILES=(
    "/srv/salt/top.sls"
    "/srv/pillar/top.sls"
    "/srv/salt/base_server/init.sls"
    "/srv/pillar/services/base_server.sls"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        log_info "  ✓ $file"
    else
        log_warn "  ✗ Missing: $file"
    fi
done

# 7. Optional: Refresh pillar on all minions
if [[ "$1" == "--refresh" ]] || [[ "$1" == "-r" ]]; then
    log_info "Refreshing pillar on all minions..."
    salt '*' saltutil.refresh_pillar
fi

# 8. Show summary
echo ""
log_info "Deployment complete!"
log_info "Deployed from: $REPO_DIR"
log_info "Salt states:   /srv/salt/"
log_info "Pillar data:   /srv/pillar/"
echo ""
log_info "Next steps:"
echo "  1. Test pillar: salt 'minion-id' pillar.items"
echo "  2. Test state:  salt 'minion-id' state.apply test=True"
echo "  3. Apply:       salt 'minion-id' state.apply"
echo ""