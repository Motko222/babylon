#!/bin/bash

sudo systemctl start babylon.service
sudo journalctl -u babylon.service -f --no-hostname -o cat

