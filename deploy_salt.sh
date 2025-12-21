#!/bin/bash
set -e

# Simple Salt Deployment Script
# Copies everything from Git repo to /srv/ and decrypts secrets

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Check root
if [[ $EUID -ne 0 ]]; then
   log_error "Must run as root: sudo bash $0"
   exit 1
fi

# Get repo directory (where this script is)
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

log_info "Deploying from: $REPO_DIR"

# Check if we're in the right place
if [[ ! -d "$REPO_DIR/salt" ]] || [[ ! -d "$REPO_DIR/pillar" ]]; then
    log_error "Not in salt repo! Need salt/ and pillar/ directories"
    exit 1
fi

# Check for sops-bin
SOPS_BIN="/usr/local/bin/sops-bin"
if [[ ! -x "$SOPS_BIN" ]]; then
    log_error "sops-bin not found at $SOPS_BIN"
    log_error "Install it first or secrets won't be decrypted"
    exit 1
fi

# 1. Deploy ALL salt states
log_info "Deploying ALL salt states to /srv/salt/"
rsync -av --delete \
    --exclude='.git' \
    --exclude='*.swp' \
    --exclude='*.tmp' \
    "$REPO_DIR/salt/" \
    /srv/salt/

# 2. Deploy pillar/services/
log_info "Deploying pillar services to /srv/pillar/services/"
mkdir -p /srv/pillar/services
rsync -av \
    --exclude='*.swp' \
    "$REPO_DIR/pillar/services/" \
    /srv/pillar/services/

# 3. Deploy pillar/secrets/ (.yaml -> DECRYPTED .sls)
log_info "Deploying and DECRYPTING pillar secrets to /srv/pillar/secrets/"
mkdir -p /srv/pillar/secrets

# Copy .sops.yaml if exists
if [[ -f "$REPO_DIR/.sops.yaml" ]]; then
    log_info "  Copying .sops.yaml"
    cp "$REPO_DIR/.sops.yaml" /srv/pillar/secrets/
fi

# Decrypt all .yaml files and save as .sls
for secret_file in "$REPO_DIR/pillar/secrets"/*.yaml; do
    if [[ -f "$secret_file" ]]; then
        filename=$(basename "$secret_file" .yaml)
        log_info "  Decrypting: $filename.yaml -> $filename.sls"
        
        # Decrypt with sops-bin
        if $SOPS_BIN -d "$secret_file" > "/srv/pillar/secrets/$filename.sls" 2>/dev/null; then
            log_info "    ✓ Successfully decrypted $filename"
        else
            log_error "    ✗ Failed to decrypt $filename"
            log_error "    Check SOPS_AGE_KEY_FILE or sops configuration"
            exit 1
        fi
    fi
done

# 4. Deploy pillar/top.sls
log_info "Deploying pillar/top.sls"
cp "$REPO_DIR/pillar/top.sls" /srv/pillar/top.sls

# 5. Set ownership
log_info "Setting ownership to salt:salt"
chown -R salt:salt /srv/salt/
chown -R salt:salt /srv/pillar/

# 6. Verify
log_info "Verifying deployment..."
echo ""
echo "Salt States:"
tree -L 1 /srv/salt/ 2>/dev/null || ls -la /srv/salt/
echo ""
echo "Pillar Secrets (DECRYPTED):"
ls -la /srv/pillar/secrets/
echo ""
echo "Pillar Services:"
ls -la /srv/pillar/services/
echo ""

# 7. Restart Salt Master to reload pillars
log_info "Restarting Salt Master..."
systemctl restart salt-master
sleep 3

# 8. Refresh pillar on minions
if [[ "$1" == "--refresh" ]] || [[ "$1" == "-r" ]]; then
    log_info "Refreshing pillar on all minions..."
    salt '*' saltutil.refresh_pillar
fi

# Done
echo ""
log_info "✓ Deployment complete!"
echo ""
log_info "Next steps:"
echo "  1. Refresh:  sudo salt 'mediaserver' saltutil.refresh_pillar"
echo "  2. Test:     sudo salt 'mediaserver' pillar.get mullvad_media"
echo "  3. Apply:    sudo salt 'mediaserver' state.apply media-stack"
echo ""