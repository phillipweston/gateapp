#!/bin/bash

cd ~/fnf/gateapi
knex seed:run

cd ~/fnf/gateapp
flutter test integration_test
