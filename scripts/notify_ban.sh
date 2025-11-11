#!/usr/bin/env bash
# notify_ban.sh — publishes Fail2Ban notifications to AWS SNS
# Usage (testing as non-root): ./scripts/notify_ban.sh "203.0.113.99" "ban" "sshd"

set -euo pipefail

IP="${1:-}"
ACTION="${2:-}"
JAIL="${3:-}"

# use /tmp for non-root testing; change to /var/log/notify_ban.log when running as root
LOG_FILE="/tmp/notify_ban.log"
SNS_TOPIC_ARN="arn:aws:sns:ap-south-1:<AWS_ACCOUNT_ID>:fail2ban-topic-final"
AWS_REGION="${AWS_REGION:-ap-south-1}"

if [[ -z "$IP" || -z "$ACTION" || -z "$JAIL" ]]; then
  echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") ERROR: Missing arguments" | tee -a "$LOG_FILE"
  exit 1
fi

echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") SCRIPT: notify_ban called with: $IP $ACTION $JAIL" | tee -a "$LOG_FILE"

if aws sns publish \
     --topic-arn "$SNS_TOPIC_ARN" \
     --message "Fail2Ban: IP $IP has been $ACTION in jail $JAIL" \
     --region "$AWS_REGION" >/dev/null 2>&1; then
  echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") AWS: sns publish OK" | tee -a "$LOG_FILE"
else
  echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") ERROR: sns publish failed" | tee -a "$LOG_FILE"
fi
