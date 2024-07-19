#!/bin/bash
ip=$(curl -s ifconfig.io)
echo "{\"ip\": \"$ip\"}"