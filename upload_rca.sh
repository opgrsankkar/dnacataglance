#!/bin/bash

cxd_url=cxd.cisco.com
test_port=443

list_rca_files() {
    echo ''''''''''''''''''''''''''''''''''''''''''''''
    echo These are the rca files available:
    ls -lht /data/rca
    echo ''''''''''''''''''''''''''''''''''''''''''''''
}

configure_https_proxy() {
    echo "Configure HTTPS Proxy settings."
    echo "Hit Enter to proceed if a field is Not Applicable"
    echo ""
    read -p    "Enter Proxy URL/IP      : " proxy_url
    read -p    "Enter Proxy port number : " proxy_port
    read -p    "Enter Proxy username    : " proxy_username
    read -p -s "Enter Proxy password    : " proxy_password
    echo ""
    if [ ${#proxy_username} -le 1 ]; then
        echo "Setting proxy. No proxy credentials. Proceeding";
        export https_proxy=http://$proxy_url:$proxy_port/ ;
    else
        echo "Setting proxy with credentials. Proceeding";
        export https_proxy=http://$proxy_username:$proxy_password@$proxy_url:$proxy_port/ ;
    fi
}

echo "Testing connectivity to $cxd_url:$test_port"
if nc -zw1 $cxd_url $test_port; then
    echo "Connection Successful";
else
    echo "Connection NOT Successful.";
    read -n1 -p "Try configuring a HTTPS proxy [y/n]: " response
    echo ""
    case "$response" in
        [yY])
            configure_https_proxy
            if nc -zw1 $cxd_url $test_port; then
                echo "Connection Successful";
            else
                echo "Upload terminated";
                exit 1;
            fi
        ;;

        ?)
            echo "Upload terminated"
            exit 2;
        ;;
    esac
fi

export PYTHONWARNINGS="ignore:Unverified HTTPS request"

list_rca_files
if /opt/maglev/bin/python _main.py; then
    nohup /opt/maglev/bin/python uploadRca.py &
fi
