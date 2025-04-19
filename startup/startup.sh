#!/bin/bash
if [ -f "/etc/oglach/oglach.run" ]; then

    token=$(curl -s -k -X POST http://localhost:8081/fledge/login -d'
    {
        "username" : "admin",
        "password" : "fledge"
    }' | jq -r '.token')

    curl -H "authorization: $token" -s -k -X PUT http://localhost:8081/fledge/category/rest_api -d '
    {"enableHttp":"false"}'
    rm /etc/oglach/oglach.run
    systemctl restart fledge
    echo "Intialization completed."

else
    echo "Initialization not required."
fi

