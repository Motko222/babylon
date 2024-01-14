#!/bin/bash

sudo systemctl restart babylon.service
sudo journalctl -u babylon.service -f --no-hostname -o cat

