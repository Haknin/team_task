#!/bin/bash

action=$1

if [[ -z "$action" ]]; then
  echo "Please provide an action parameter: --stop, --start, or --destroy."
  exit 1
fi

case $action in
  --stop)
    echo "Stopping running instances..."
    instance_ids=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId' --output text)
    ;;
  --start)
    echo "Starting stopped instances..."
    instance_ids=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=stopped" --query 'Reservations[].Instances[].InstanceId' --output text)
    ;;
  --destroy)
    read -p "Are you sure you want to destroy all instances? This action is irreversible. (y/n): " confirmation
    if [[ "$confirmation" != "y" ]]; then
      echo "Action canceled."
      exit 0
    fi
    echo "Destroying instances..."
    instance_ids=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running,stopped" --query 'Reservations[].Instances[].InstanceId' --output text)
    ;;
  *)
    echo "Invalid action parameter. Please use --stop, --start, or --destroy."
    exit 1
    ;;
esac

if [[ -z "$instance_ids" ]]; then
  echo "No instances found for the specified action."
  exit 0
fi

for instance_id in $instance_ids; do
  echo "Instance ID: $instance_id"
  case $action in
    --stop)
      echo "Stopping instance: $instance_id"
      aws ec2 stop-instances --instance-ids "$instance_id"
      ;;
    --start)
      echo "Starting instance: $instance_id"
      aws ec2 start-instances --instance-ids "$instance_id"
      ;;
    --destroy)
      echo "Terminating instance: $instance_id"
      aws ec2 terminate-instances --instance-ids "$instance_id"
      ;;
  esac
done

echo "Action completed."
