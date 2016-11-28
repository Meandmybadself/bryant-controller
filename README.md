#Bryant-Controller

## Overview
What's the point in having an internet-controlled thermostat if it's controlled via a closed & archaic infrastructure (Flash)?

## Build notes
* System expects the environment variables to be defined –
  * _BRYANT_USERNAME_
  * _BRYANT_PASSWORD_

## Progress

* 09-12-16: Currently logging into dashboard.
* 11-28-16: OAuth signature working
* In progress: reverse engineering the POST XML calls that set temperature

## Caveats

* Only supports one thermostat at present.
