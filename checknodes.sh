#!/bin/bash

declare -a sList=("97.64.253.98" "185.17.27.105" "51.255.209.200" "23.96.93.180")
_port="6969"

fextract () {
    echo "$1" | grep $2 | grep -o '[0-9]\+'
}
while true; do
    printf "\n$(date):\n"
    printf "| IP ADDRESS\t\t| PING\t| DIFFICULTY\t| HASHRATE\t| HEIGHT (+/-)\t| CONNECTIONS |\n"
    for i in "${sList[@]}"; do
        _timer=$(date +%s)
        _noderesp="$(wget -qO- $i:$_port/info | jq '{difficulty, hashrate, height, network_height, status, synced, incoming_connections_count, outgoing_connections_count}')"
        #echo "$(wget -qO- $i:$_port/info | jq '{difficulty, hashrate, height, network_height, status, synced, incoming_connections_count, outgoing_connections_count}')"
        #        echo $_resplen

        if [ ${#_noderesp} -gt 0 ]; then
            _timer=$(($(date +%s)-$_timer))
            _difficulty=$(numfmt --to=si --format='%.2f' $(fextract "$_noderesp" "difficulty"))
            _hashrate="$(numfmt --to=si --format='%.3f' $(fextract "$_noderesp" "hashrate"))H/s"
            _height=$(echo "$_noderesp" | grep height | grep -o '[0-9]\+')
            _netheight=$(echo "$_noderesp" | grep network_height | grep -o '[0-9]\+')
            _heightdiff=$(awk "BEGIN {print $_netheight - $_height}")
            _incoming=$(echo "$_noderesp" | grep incoming_connections_count | grep -o '[0-9]\+')
            _outgoing=$(echo "$_noderesp" | grep outgoing_connections_count | grep -o '[0-9]\+')
            _synced=$(echo "$_noderesp" | grep synced | grep -o true)
            printf "| $i   \t| $_timer\t| $_difficulty\t| $_hashrate\t| $_netheight ($_heightdiff)\t| IN/OUT:$_incoming/$_outgoing |\n"
        else
            printf "| No response from $i\n"
        fi
    done
    echo "|_____________________________________________________________________________________________|"
    sleep 10
done