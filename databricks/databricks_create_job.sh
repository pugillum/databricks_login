#!/bin/bash

set -e

export JOB_NAME=$1
export JOB_SCHEDULE=$2
export LOG_PATH=$3
export WHL_PATH=$4
export CONFIG_PATH=$5
export JOB_FILE_PATH=$6
export ALERT_EMAILS=$7
export JOB_CONFIG=$8


if [ -z "$JOB_NAME" ]; then
  echo "JOB_NAME not configured"
  exit 1
fi

if [ -z "$JOB_SCHEDULE" ]; then
  echo "JOB_SCHEDULE not configured"
  exit 1
fi

if [ -z "$LOG_PATH" ]; then
  echo "LOG_PATH not configured"
  exit 1
fi

if [ -z "$WHL_PATH" ]; then
  echo "WHL_PATH not configured"
  exit 1
fi

if [ -z "$CONFIG_PATH" ]; then
  echo "CONFIG_PATH not configured"
  exit 1
fi

if [ -z "$JOB_FILE_PATH" ]; then
  echo "JOB_FILE_PATH not configured"
  exit 1
fi

if [ -z "$ALERT_EMAILS" ]; then
  echo "ALERT_EMAILS not configured"
  exit 1
fi

if [ -z "$JOB_CONFIG" ]; then
  echo "JOB_CONFIG not configured"
  exit 1
fi

# Fill in values in the job configuration file
jinja2 ${JOB_CONFIG}.j2 > ${JOB_CONFIG}

RESULT=$?
if [ ${RESULT} -ne 0 ]; then
  exit 1
fi

# check if the job already exists by requesting the job ID for a job with the same name
JOB_ID=$(databricks jobs list --output json | jq -r '.jobs[] | select(.settings.name == env.JOB_NAME) | .job_id')

if [ -z "$JOB_ID" ]; then
  # if the job doesn't exist create it
  echo "Creating Job ${JOB_NAME} with content"
  JOB_ID=$(databricks jobs create --json-file ${JOB_CONFIG} | jq -r '.job_id')

  RESULT=$?
  if [ ${RESULT} -eq 0 ]; then
    echo "Job created"
  else
    exit ${RESULT}
  fi

else
  # if the job exists, update it
  echo "Modifying job ${JOB_NAME}  - with ID ${JOB_ID} with content"
  databricks jobs reset --job-id ${JOB_ID} --json-file ${JOB_CONFIG}
  RESULT=$?
  if [ ${RESULT} -eq 0 ]; then
    echo "Job modified"
  else
    exit ${RESULT}
  fi
fi
