#!/usr/bin/env bash
set -euo pipefail

# Upload artifacts to S3 under directory with the commit SHA (GITHUB_SHA)
: "${S3_BUCKET:?Need to set S3_BUCKET (from GitHub secret)}"
: "${AWS_REGION:='ap-south-1'}"

COMMIT="${GITHUB_SHA:-manual-$(date -u +%Y%m%dT%H%M%SZ)}"
DEST_PREFIX="fail2ban-artifacts/${COMMIT}"

echo "Uploading fail2ban artifacts to s3://${S3_BUCKET}/${DEST_PREFIX}/ (region=${AWS_REGION})"

aws s3 cp fail2ban-dashboard.json "s3://${S3_BUCKET}/${DEST_PREFIX}/" --region "${AWS_REGION}"
aws s3 cp cloudwatch-agent/amazon-cloudwatch-agent.json "s3://${S3_BUCKET}/${DEST_PREFIX}/" --region "${AWS_REGION}"
aws s3 cp scripts/notify_ban.sh "s3://${S3_BUCKET}/${DEST_PREFIX}/" --region "${AWS_REGION}"

echo "Upload complete. Objects uploaded to s3://${S3_BUCKET}/${DEST_PREFIX}/"
