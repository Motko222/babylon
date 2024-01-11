#!/bin/bash

sudo journalctl -u babylon.service -f --no-hostname -o cat
