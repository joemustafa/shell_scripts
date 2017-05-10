#!/usr/bin/env bash


string="sda sdb sdc"
DEV="sda"

if [[ $string != *"$DEV"* ]]; then
  echo "It's not there!"
else
    echo "Its there skip"
fi