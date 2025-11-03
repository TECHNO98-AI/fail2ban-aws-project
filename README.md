# fail2ban-aws-project

Small project to integrate Fail2Ban with AWS:
- fail2ban notifications -> SNS (email)
- Stream Fail2Ban logs to CloudWatch Logs via CloudWatch Agent
- Publish host metrics to CloudWatch (CWAgent)
- Terraform for IAM / SNS / CloudWatch (optional)
- Scripts to deploy and configure on EC2 instances

Status: initial repo scaffold created locally.

Next steps:
1. Add scripts/notify_ban.sh (Fail2Ban SNS publisher).
2. Add cloudwatch-agent/amazon-cloudwatch-agent.json (agent config).
3. Add terraform/ for infra (SNS topic, IAM role).
4. Add policies/ AWS IAM JSON snippets used by the role.
5. Commit and push to GitHub.

Author: Rishikesh Jogdand
