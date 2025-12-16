#!/bin/sh
# Replace API_URL in index.html if the environment variable is set
if [ -n "$API_URL" ]; then
    echo "Updating API_URL to $API_URL"
    sed -i "s|http://localhost:5000/api|$API_URL|g" /usr/share/nginx/html/index.html
fi
