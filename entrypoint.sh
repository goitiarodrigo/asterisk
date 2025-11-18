#!/bin/bash
set -e

# Optionally: copy runtime configs, run migrations, etc.
echo "Starting Asterisk..."

# Run Asterisk in the foreground so Docker keeps container alive
exec /usr/sbin/asterisk -f -U asterisk