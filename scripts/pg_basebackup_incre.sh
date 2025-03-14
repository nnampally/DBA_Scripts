#!/bin/bash

# This is the automation script to take incremental backup on PostgreSQL 17x (its new feature only supported from 17)
# Configuration

export PATH="/usr/local/pgsql-17/bin:$PATH"
ROOTDIR=""
export PGDATA="$ROOTDIR/data"
BACKUP_DIR="$ROOTDIR/backups"
INCREMENTAL_MANIFEST="$BACKUP_DIR/latest_manifest"
PG_USER="<>"
LOG_FILE="$BACKUP_DIR/pg_backup_incr.log"
DATE=$(date +"%Y%m%d_%H%M%S")

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Check if incremental backup is possible
if [ -f "$INCREMENTAL_MANIFEST" ]; then
    echo "$(date) - Attempting incremental backup..." | tee -a "$LOG_FILE"
    
    # Run incremental backup
    pg_basebackup --username=$PG_USER \
                  --pgdata="$BACKUP_DIR/backup_$DATE" \
                  --format=tar \
                  --wal-method=stream \
                  --incremental="$INCREMENTAL_MANIFEST" \
                  --verbose 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        echo "$(date) - Incremental backup successful." | tee -a "$LOG_FILE"
        ln -sf "$BACKUP_DIR/backup_$DATE/backup_manifest" "$INCREMENTAL_MANIFEST"
    else
        echo "$(date) - Incremental backup failed, attempting full backup..." | tee -a "$LOG_FILE"
        FULL_BACKUP_NEEDED=true
    fi
else
    echo "$(date) - No previous manifest found. Taking a full backup..." | tee -a "$LOG_FILE"
    FULL_BACKUP_NEEDED=true
fi

# Perform full backup if incremental is not possible
if [ "$FULL_BACKUP_NEEDED" = true ]; then
    pg_basebackup --username=$PG_USER \
                  --pgdata="$BACKUP_DIR/base_backup_$DATE" \
                  --format=tar \
                  --wal-method=stream \
                  --verbose 2>&1 | tee -a "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        echo "$(date) - Full backup successful." | tee -a "$LOG_FILE"
        ln -sf "$BACKUP_DIR/base_backup_$DATE/backup_manifest" "$INCREMENTAL_MANIFEST"
    else
        echo "$(date) - Full backup failed! Check logs for details." | tee -a "$LOG_FILE"
        exit 1
    fi
fi

# Cleanup old backups (keep last 5)
# echo "$(date) - Cleaning up old backups..." | tee -a "$LOG_FILE"
# ls -dt $BACKUP_DIR/backup_* | tail -n +6 | xargs rm -rf

echo "$(date) - Backup process completed." | tee -a "$LOG_FILE"

