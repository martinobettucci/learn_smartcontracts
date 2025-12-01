#!/usr/bin/env bash
set -euo pipefail

env_file="$(cd "$(dirname "$0")/.." && pwd)/.env"

for i in $(seq 1 4); do
  key="DEMO_ACCOUNT_${i}_PRIVATE_KEY"
  value="0x$(openssl rand -hex 32)"
  perl -0pi -e "s/^${key}=.*$/${key}=${value}/m" "$env_file"
  printf "Updated %s -> %s\n" "$key" "$value"
done
