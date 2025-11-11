#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-ap-south-1}"
LOG_GROUP="/fail2ban/notify_ban"
TEST_STREAM="ci-smoke-$(date +%s)"
SAMPLE_IP=${1:-"203.0.113.$((RANDOM%250+1))"}
MSG="BLOCKED IP ${SAMPLE_IP} smoke-test $(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "Region: $REGION"
echo "LogGroup: $LOG_GROUP"
echo "Stream: $TEST_STREAM"
echo "Message: $MSG"

aws logs create-log-stream --log-group-name "$LOG_GROUP" --log-stream-name "$TEST_STREAM" --region "$REGION" || true

EVENT_TIME=$(python3 - <<PY
import time
print(int(time.time()*1000))
PY
)

aws logs put-log-events \
  --log-group-name "$LOG_GROUP" \
  --log-stream-name "$TEST_STREAM" \
  --log-events timestamp="$EVENT_TIME",message="$MSG" \
  --region "$REGION" >/dev/null

echo "Log event pushed. Sleeping 8s to allow metric filter evaluation..."
sleep 8

END_TIME=$(python3 - <<PY
from datetime import datetime
print(datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ'))
PY
)
START_TIME=$(python3 - <<PY
from datetime import datetime, timedelta
print((datetime.utcnow() - timedelta(minutes=15)).strftime('%Y-%m-%dT%H:%M:%SZ'))
PY
)

echo "Querying CloudWatch metric Notify_Blocks..."
aws cloudwatch get-metric-statistics \
  --namespace "Fail2Ban" \
  --metric-name "Notify_Blocks" \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --period 60 \
  --statistics Sum \
  --region "$REGION" --output json

echo
echo "Checking alarm state for Fail2Ban-Notify-Block-Alarm..."
aws cloudwatch describe-alarms \
  --alarm-names "Fail2Ban-Notify-Block-Alarm" \
  --region "$REGION" \
  --query "MetricAlarms[0].StateValue" --output text || true

echo "Done. If alarm is ALARM, SNS notifications should have been fired."
