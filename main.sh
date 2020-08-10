#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TEMP_FILE="/tmp/temp.html"
TRACKING_FILE="track.csv"

function main() {
    init
    check_errs $? "Init did not succeed"
    parseArgs "$@"
    check_errs $? "Parse args did not succeed"
    checkArgs
    downloadPage
    check_errs $? "Download page did not succeed"
    extractRating
    check_errs $? "extractRating did not succeed"
    echoColour "GREEN" "Rating is ${RATING}"
    appendToCSVFile
    check_errs $? "Unable to write to file"
}

function init() {
    echo "Importing common.sh"
    . $DIR/common.sh
    echoColour "GREEN" "Starting..."
}

function usage() {
    cat <<EOF
This is used for grabbing app store rating

Available options:
    -u / --url              The app store URL to parse - example https://apps.apple.com/gb/app/hsbc-kinetic/id1457310350
    -t / --type             The category of the app in the appstore - example Finance
    --tracking-file         The name of the csv file to write to
    -h / --help             This message
EOF
    exit 0
}

function parseArgs() {
    echoColour "YELLOW" "Parsing args"
    while (( "$#" )); do
        case "$1" in
            -h|--help)
                usage
                exit 0
                shift
                ;;
            -u|--url)
                APPSTORE_URL=$2
                echoColour "GREEN" "APPSTORE_URL is ${APPSTORE_URL}"
                shift
                ;;
            -t|--type)
                TYPE=$2
                echoColour "GREEN" "TYPE is ${TYPE}"
                shift
                ;;
            --tracking-file)
                TRACKING_FILE=$2
                echoColour "GREEN" "TRACKING FILE is ${TRACKING_FILE}"
                shift
                ;;
            --) # end argument parsing
                shift
                break
                ;;
            -*|--*=) # unsupported flags
                echo "Error: Unsupported flag $1" >&2
                exit 1
                ;;
            *) # preserve positional arguments
                PARAMS="$PARAMS $1"
                shift
                ;;
        esac
    done
}

function checkArgs() {
     echoColour "YELLOW" "Checking args"
    if [[ -z ${APPSTORE_URL+x} ]]; then
        echoColour "RED" "App store url is not set"
        usage
        exit 1
    fi

    if [[ -z ${TYPE+x} ]]; then
        echoColour "RED" "App type is not set"
        usage
        exit 1
    fi
}

function downloadPage() {
    echoColour "YELLOW" "Removing temp file"
    removeTempFile

    echoColour "YELLOW" "Downloading page ${APPSTORE_URL} to ${TEMP_FILE} "
    curl --url "${APPSTORE_URL}" --output $TEMP_FILE 
}

function extractRating() {
    echoColour "YELLOW" "Extracting rating"
    RATING=$(grep "in ${TYPE}" temp.html | sed -e 's/^[[:space:]]*//' | sed 's/ /,/g' | awk -F"," '{print $1}' | awk -F "#" '{print $2}')
}

function appendToCSVFile() {
    echoColour "YELLOW" "Writing to file"
    local timestamp=$(date '+%Y%m%d, %H:%M:%S')
    echo "${timestamp}, ${RATING}" >> $TRACKING_FILE
}

function removeTempFile() {
    rm -f $TEMP_FILE
}

main "$@"