#!/bin/bash
# notify_ban.sh — publishes Fail2Ban notifications to AWS SNS

# Usage:
#   sudo /usr/local/bin/notify_ban.sh "<IP>" "<action>" "<jail>"
# Example:
#   sudo /usr/local/bin/notify_ban.sh "203.0.113.99" "ban" "sshd"

IP="$1"
ACTION="$2"
JAIL="$3"

LOG_FILE="/var/log/notify_ban.log"
SNS_TOPIC_ARN="arn:aws:sns:ap-south-1:113436413547:fail2ban-topic-final"

if [[ -z "$IP" || -z "$ACTION" || -z "$JAIL" ]]; then
  echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") ERROR: Missing arguments" | tee -a "$LOG_FILE"
  exit 1
fi

echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") SCRIPT: notify_ban called with: $IP $ACTION $JAIL" | tee -a "$LOG_FILE"

aws sns publish \
  --topic-arn "$SNS_TOPIC_ARN" \
  --message "Fail2Ban: IP $IP has been $ACTION in jail $JAIL" \
  --region ap-south-1 \
  && echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") AWS: sns publish OK" | tee -a "$LOG_FILE" \
  || echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") ERROR: sns publish failed" | tee -a "$LOG_FILE"
