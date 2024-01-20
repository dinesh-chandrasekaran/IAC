The Problem Statement

Create an AWS autoscaling group based on the load average of the instances (note - it is load average, not CPU utilization). Deliverable is a terraform code, which does the following:

1. Create an autoscaling group in AWS with min 2 and max five instances.
   aws_autoscaling_group and its template aws_launch_template created with specified configurations
   aws_autoscaling_policies to add and delete nodes 
   aws_cloudwatch_metric_alarms for the 75% and 50% load average

2. When the 5 mins load average of the machines reaches 75%, add a new instance.
   When the 5-minute load average of the machines reaches 50%, remove a machine.
   load average to be monitored with uptime tool
   A program (lambda function or bash ) is required to loop and monitor each and every instance of the autoscaling group.
   loadMonitor.sh is written to handle this case.
   null_resource will cron the script frequently and trigger the autoscaling group instance refresh
   When the load average breaches 75%, the aws cli(aws autoscaling) is using to increase the instance and publish the message on sns topic.Also the metric is recorded in cloudwatch. Likewise for the instance decrease as well.

4. Everyday at UTC 12am, refresh all the machines in the group (remove all the old machines and add new machines).
   
   aws_autoscaling_schedule can be used map an autoscaling group and schedule the cron for specified time
   start-instance-refresh will refresh the instances of the given autoscaling group

5. Sends email alerts on the scaling and refresh events.
   sns module: topic and email subscription
   Once the refresh is performed the event is sent to the sns topic
