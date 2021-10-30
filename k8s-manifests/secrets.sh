#!/bin/bash

kubectl create secret generic backend-secrets --from-literal='db-username=$USERNAME' --from-literal='db-password=$DBPASSWORD' --from-literal='db-host=$DBHOST'
