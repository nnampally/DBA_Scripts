#!/bin/bash

# Variables
export PATH="/usr/local/pgsql/bin:$PATH"  # Add PostgreSQL binaries to PATH
BASE_BACKUP_DIR="/path/full/backups"  # Base backup taken before recovery time
DEST_CLUSTER_DATA_DIR="/path/pitr_cluster"      # Destination directory for recovery
WAL_ARCHIVE_DIR="/path/wal_archive"             # WAL archive directory

read -ep "Enter the port for pitr instance if restoring on same server (default: 5432):" NEW_PORT
if [ -z "$NEW_PORT" ]; then
    NEW_PORT=5432                                      # Default port for the new instance
fi


# Function to print earliest and latest recoverable timestamps
get_recovery_timestamps() {
    # Get earliest and latest recoverable timestamps
    LATEST=$(find $WAL_ARCHIVE_DIR -type f ! -name "*.backup" -exec stat -f "%Sm" -t "%Y-%m-%d %H:%S" {} \; | sort | tail -n 1)
    
    # Find the earliest recoverable timestamp based on the base backup
    BASE_BACKUP_TIMESTAMP=$(basename $BASE_BACKUP_DIR )
    echo "Base backup timestamp: $BASE_BACKUP_TIMESTAMP"
    EARLIEST=$(date -j -f "%Y%m%d%H%M" "$BASE_BACKUP_TIMESTAMP" "+%Y-%m-%d %H:%M" 2>/dev/null)

    

    echo "Earliest recoverable timestamp: $EARLIEST"
    echo "Latest recoverable timestamp: $LATEST"
    exit 0
}

read -ep "Provide recovery target time (YYYY-MM-DD HH:MM:SS UTC') or press enter to get the latest restorable time: " RECOVERY_TIME
if [ -z "$RECOVERY_TIME" ]; then
    echo "No recovery target time provided, ."
fi


# If no recovery time is provided, print timestamps and exit
if [ -z "$RECOVERY_TIME" ]; then
    get_recovery_timestamps
fi


pg_ctl -D "$DEST_CLUSTER_DATA_DIR" -l "$DEST_CLUSTER_DATA_DIR/logfile" stop
# Step 1: Copy the base backup to the new directory
echo "Copying base backup to $DEST_CLUSTER_DATA_DIR..."
#rsync -av  "$BASE_BACKUP_DIR/" "$DEST_CLUSTER_DATA_DIR/"
rm -rf "$DEST_CLUSTER_DATA_DIR/*"
cp -R "$BASE_BACKUP_DIR/" "$DEST_CLUSTER_DATA_DIR/"

# Step 2: Configure recovery settings in postgresql.conf
echo "Configuring recovery..."
echo "RECOVERY TIME :  $RECOVERY_TIME"
cat >> "$DEST_CLUSTER_DATA_DIR/postgresql.conf" <<EOL
restore_command = 'cp $WAL_ARCHIVE_DIR/%f %p'
recovery_target_time = '$RECOVERY_TIME'
recovery_target_action = 'promote'
EOL

# Step 3: Create standby.signal for PostgreSQL 15+ (triggers recovery)
touch "$DEST_CLUSTER_DATA_DIR/standby.signal"

# Step 4: Update port in postgresql.conf
echo "Updating port to $NEW_PORT..."
# line could be port or #port
sed -i '' "s/^#port = .*/port = $NEW_PORT/" "$DEST_CLUSTER_DATA_DIR/postgresql.conf"
sed -i '' "s/^port = .*/port = $NEW_PORT/" "$DEST_CLUSTER_DATA_DIR/postgresql.conf"
sed -i '' "s/^archive_mode = .*/archive_mode = off/" "$DEST_CLUSTER_DATA_DIR/postgresql.conf"
sed -i '' "s/^archive_command = .*/archive_command = ''/" "$DEST_CLUSTER_DATA_DIR/postgresql.conf"


# Step 5: Start the new instance
echo "Starting new PostgreSQL instance on port $NEW_PORT..."

pg_ctl -D "$DEST_CLUSTER_DATA_DIR" -l "$DEST_CLUSTER_DATA_DIR/logfile" start
if [ $? -ne 0 ]; then
    echo "Failed to start the new instance, check the logfile $DEST_CLUSTER_DATA_DIR/logfile"
    exit 1
fi


echo "Point-in-Time Recovery completed successfully!"
