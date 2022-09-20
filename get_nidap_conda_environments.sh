#!/bin/bash

source ~/.nidaprc
function get_nidap_env {

    read -d  '' usage <<- EOF
    usage: get_nidap_env <env_rid> <branch> <resolvedEnvironment|environmentv2>
    Retrieves the environment for a specific workbook
EOF

    if [ -z "$1" ]
    then
        echo "Missing argument: env_rid" >&2
        echo "$usage" >&2
        exit 1
    else   
        nidap_env="$1"
    fi

    if [ -z "$2" ]
    then
        echo "Missing argument: branch" >&2
        echo "$usage" >&2
        exit 1
    else   
        branch="$2"
    fi

    if [ -z "$3" ]
    then
        echo "Missing argument: environment_type" >&2
        echo "$usage" >&2
        exit 1
    else   
        env_type="$3"
    fi



    if [ -z "$nidap_token" ]
    then
        echo "ERROR: The environment variable nidap_env is undefined">&2 
        exit 1
    fi
    
    curl --request GET "https://nidap.nih.gov/vector/api/workbooks/$nidap_env/branches/$branch/$env_type" --header "Authorization: Bearer $nidap_token" | python -mjson.tool 



}

function get_nidap_resolved_env {

    get_nidap_env $@ resolvedEnvironment

}

function get_nidap_main_env {

    get_nidap_env $@ environmentv2

}


function get_nidap_available_env {

    read -d  '' usage <<- EOF
    usage: get_nidap_available_env <env_rid>     
    Retrieves all the available environments for a specific workbook
EOF

    if [ -z "$1" ]
    then
        echo "Missing argument: env_rid" >&2
        echo "$usage" >&2
        exit 1
    else   
        nidap_env="$1"
    fi

    if [ -z "$nidap_token" ]
    then
        echo "ERROR: The environment variable nidap_env is undefined">&2 
        exit 1
    fi
    
    curl --request GET "https://nidap.nih.gov/vector/api/workbooks/$nidap_env/availableVectorEnvironmentsV2" --header "Authorization: Bearer $nidap_token" | python -mjson.tool 



}

function get_all_nidap_templates {

    read -d  '' usage <<- EOF
    usage: get_all_nidap_templates 
    Retrieves all the templates available in NIDAP
EOF

    if [ -z "$nidap_token" ]
    then
        echo "ERROR: The environment variable nidap_env is undefined">&2 
        exit 1
    fi
    
    curl --request GET 'https://nidap.nih.gov/vector/api/templates' --header "Authorization: Bearer $nidap_token" | python -mjson.tool 

}
