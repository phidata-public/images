#!/bin/bash

############################################################################
#
# Entrypoint script for the Airflow image
# This script:
#   - Waits for services to be available if needed
#   - Installs libraries
#
############################################################################

if [[ "$PRINT_ENV_ON_LOAD" = true || "$PRINT_ENV_ON_LOAD" = True ]]; then
  echo "=================================================="
  printenv
  echo "=================================================="
fi

############################################################################
# Wait for Services
############################################################################

if [[ "$WAIT_FOR_DB" = true || "$WAIT_FOR_DB" = True ]]; then
  dockerize \
    -wait tcp://$DB_HOST:$DB_PORT \
    -timeout 300s
fi

if [[ "$WAIT_FOR_REDIS" = true || "$WAIT_FOR_REDIS" = True ]]; then
  dockerize \
    -wait tcp://$REDIS_HOST:$REDIS_PORT \
    -timeout 300s
fi

############################################################################
# Wait for git sync
############################################################################

if [[ "$MOUNT_WORKSPACE" = true || "$MOUNT_WORKSPACE" = True ]]; then
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "ls -l $PHI_WORKSPACE_PARENT : $(ls -l $PHI_WORKSPACE_PARENT)"
  echo "ls -l $PHI_WORKSPACE_ROOT : $(ls -l $PHI_WORKSPACE_ROOT)"
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
fi

############################################################################
# Install dependencies
############################################################################

if [[ "$INSTALL_REQUIREMENTS" = true || "$INSTALL_REQUIREMENTS" = True ]]; then
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "Installing requirements from $REQUIREMENTS_FILE_PATH"
  pip3 install -r $REQUIREMENTS_FILE_PATH
  echo "Sleeping for 5 seconds..."
  sleep 5
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
fi

############################################################################
# Install workspace
############################################################################

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Installing workspace"
pip3 install --no-deps --editable $PHI_WORKSPACE_ROOT
echo "Sleeping for 5 seconds..."
sleep 5
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

############################################################################
# Init database
############################################################################

init_airflow_db() {
  airflow db init
}
if [[ "$INIT_AIRFLOW_DB" = true || "$INIT_AIRFLOW_DB" = True ]]; then
  echo "Initializing Airflow DB"
  init_airflow_db
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
fi

if [[ "$CREATE_AIRFLOW_TEST_USER" = true || "$CREATE_AIRFLOW_TEST_USER" = True ]]; then
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "Creating test user"
  airflow users create \
    --username test \
    --password test \
    --firstname Test \
    --lastname Test \
    --role User \
    --email test@test.com
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
fi

############################################################################
# Start the container
############################################################################

case "$1" in
  chill)
    ;;
  webserver)
    airflow webserver
    ;;
  scheduler)
    airflow scheduler
    ;;
  *)
    exec "$@"
    ;;
esac


echo ">>> Welcome to Airflow!"
while true; do sleep 18000; done
