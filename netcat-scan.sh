#!/bin/bash

# Define color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
LIGHTRED='\033[1;91m'
LIGHTGREEN='\033[1;92m'
LIGHTBLUE='\033[1;94m'
LIGHTMAGENTA='\033[1;95m'
LIGHTCYAN='\033[1;96m'
WHITE='\033[1;97m'
NC='\033[0m' # No Color

# Array of ports to check
declare -a ports=("22" "23" "53" "80" "443" "8000" "8080" "9000" "9090" "135" "137" "139" "445" "2869" "5040")

# Array of colors to use
declare -a colors=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA" "$CYAN" "$LIGHTRED" "$LIGHTGREEN" "$LIGHTBLUE" "$LIGHTMAGENTA" "$LIGHTCYAN" "$WHITE" "$WHITE" "$WHITE" "$WHITE")

# Associative array for response codes to colors
declare -A response_colors=([200]=$YELLOW [300]=$BLUE [400]=$RED [500]=$RED)

while true; do
    # Request the domain name or IP address
    read -p "Enter the target domain name or IP address: " hostname

    for i in ${!ports[@]}; do
        (if nc -z -v -w5 $hostname ${ports[$i]} &> /dev/null
        then
            echo -e "${colors[$i]}Port ${ports[$i]} is open${NC}"
        else
            echo -e "${colors[$i]}Port ${ports[$i]} is not open${NC}"
        fi) &
    done

    # Wait for all port scanning operations to finish
    wait

    count=0
    while [ $count -lt 3 ]; do
        # Send request and get the response code
        response=$(curl -s -o /dev/null -w "%{http_code}" http://$hostname)

        # Output in different colors based on the response
        if [[ $response -eq 400 || $response -eq 500 ]]; then
            echo -e "${response_colors[$response]}HTTP response: $response OK${NC}"
            break
        elif [[ ! -z ${response_colors[$response]} ]]; then
            echo -e "${response_colors[$response]}HTTP response: $response OK${NC}"
        else
            echo "HTTP response: $response"
        fi

        # Increase the count
        count=$((count + 1))

        # Wait for 5 seconds
        sleep 5
    done
done
