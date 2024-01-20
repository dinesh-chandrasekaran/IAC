#!/bin/bash

asg_name=$1
aws_region=$2
sns_topic_arn=$3
namespace="CustomMetrics"
metric_name="LoadAverage"

instance_ids=($(aws autoscaling describe-auto-scaling-groups \
  --region $aws_region \
  --auto-scaling-group-names $asg_name \
  --query "AutoScalingGroups[0].Instances[*].InstanceId" \
  --output text))

for instance_id in "${instance_ids[@]}"; do
  load_average=$(aws cloudwatch get-metric-statistics \
    --region $aws_region \
    --namespace $namespace \
    --metric-name $metric_name \
    --dimensions "Name=InstanceId,Value=$instance_id" \
    --start-time $(date -u -d '5 minutes ago' '+%Y-%m-%dT%H:%M:%SZ') \
    --end-time $(date -u '+%Y-%m-%dT%H:%M:%SZ') \
    --period 300 \
    --statistics Average \
    --output json | jq -r '.Datapoints[0].Average')

  aws cloudwatch put-metric-data \
    --region $aws_region \
    --namespace $namespace \
    --metric-name $metric_name \
    --value $load_average \
    --dimensions "InstanceId=$instance_id"

  if [ $(echo "$load_average >= 75" | bc -l) -eq 1 ]; then
    aws autoscaling set-desired-capacity \
      --region $aws_region \
      --auto-scaling-group-name $asg_name \
      --desired-capacity +1
    echo "Scaling up: Load average on instance $instance_id exceeded 75%"
    
    aws sns publish \
      --region $aws_region \
      --topic-arn $sns_topic_arn \
      --subject "Scaling Up" \
      --message "Load average exceeded 75% on instance $instance_id. Scaling up."
  elif [ $(echo "$load_average <= 50" | bc -l) -eq 1 ]; then
    aws autoscaling set-desired-capacity \
      --region $aws_region \
      --auto-scaling-group-name $asg_name \
      --desired-capacity -1
    echo "Scaling down: Load average on instance $instance_id dropped below 50%"
    
    aws sns publish \
      --region $aws_region \
      --topic-arn $sns_topic_arn \
      --subject "Scaling Down" \
      --message "Load average dropped below 50% on instance $instance_id. Scaling down."
  fi
done

aws autoscaling start-instance-refresh \
  --region $aws_region \
  --auto-scaling-group-name $asg_name

aws sns publish \
  --region $aws_region \
  --topic-arn $sns_topic_arn \
  --subject "AutoScaling Group Instances Refreshed" \
  --message "Instances refreshed for Auto Scaling Group $asg_name."
