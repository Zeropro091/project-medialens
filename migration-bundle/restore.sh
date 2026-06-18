#!/bin/bash
# ============================================================
#  LIN — Data Restore Script (Linux/New Server)
#  Run AFTER: git clone, npm install, supabase start
# ============================================================

set -e

DB_CONTAINER="supabase_db_lin"
SUPABASE_URL="http://127.0.0.1:54821"

echo ""
echo "  ========================================"
echo "   LIN Data Restore"
echo "  ========================================"
echo ""

# Step 1: Auth users (must go first — FKs depend on these)
echo "[1/4] Restoring auth users..."
docker cp auth_users.sql $DB_CONTAINER:/tmp/auth_users.sql
docker exec $DB_CONTAINER psql -U postgres -d postgres -f /tmp/auth_users.sql 2>&1 | tail -1
echo "       ✓ auth users restored"

# Step 2: Public data (articles, categories, profiles, gallery, etc.)
echo "[2/4] Restoring public data..."
docker cp public_data.sql $DB_CONTAINER:/tmp/public_data.sql
docker exec $DB_CONTAINER psql -U postgres -d postgres --set ON_ERROR_STOP=off -f /tmp/public_data.sql 2>&1 | tail -3
echo "       ✓ public data restored"

# Step 3: Storage metadata
echo "[3/4] Restoring storage metadata..."
docker cp storage_meta.sql $DB_CONTAINER:/tmp/storage_meta.sql
docker exec $DB_CONTAINER psql -U postgres -d postgres --set ON_ERROR_STOP=off -f /tmp/storage_meta.sql 2>&1 | tail -1
echo "       ✓ storage metadata restored"

# Step 4: Upload storage files via API
echo "[4/4] Restoring storage files..."
ANON_KEY=$(grep VITE_SUPABASE_ANON_KEY ../.env | cut -d= -f2)
if [ -z "$ANON_KEY" ]; then
    echo "       ⚠ Could not read ANON_KEY from .env — set manually"
    ANON_KEY="YOUR_ANON_KEY"
fi

# Ensure bucket exists
curl -s -X POST "$SUPABASE_URL/storage/v1/bucket" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "apikey: $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":"images","name":"images","public":true}' > /dev/null 2>&1 || true

for file in storage/api-files/*; do
    filename=$(basename "$file")
    echo "       Uploading: $filename"
    curl -s -X POST "$SUPABASE_URL/storage/v1/object/images/$filename" \
      -H "Authorization: Bearer $ANON_KEY" \
      -H "apikey: $ANON_KEY" \
      -H "Content-Type: application/octet-stream" \
      --data-binary "@$file" > /dev/null 2>&1
done
echo "       ✓ storage files restored"

echo ""
echo "  ========================================"
echo "   ✅ Restore Complete!"
echo "  ========================================"
echo ""
echo "  Next steps:"
echo "    1. Update .env with correct Supabase keys"
echo "    2. npm run dev:ssr (or npm run build:ssr && npm run serve)"
echo ""
