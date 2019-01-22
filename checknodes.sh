#!/bin/bash
#Edit this array with the list of nodes you want to watch
#11898 = TurtleCoin
#6969  = DeroGold

declare -a sList=("-DeroGold" "97.64.253.98:6969" "185.17.27.105:6969" "51.255.209.200:6969" "23.96.93.180:6969"
                  "-TurtleCoin" "turtlenode.online:11898" "cuveetrtl.czech.cloud:11898" "91.139.116.6:11898" "nodes.hashvault.pro:11898"
                  "-Testnet" "turtlenode.online:29802" "vpn.llama.horse:29802" "seed1.xlscoin.info:29802" "seed2.xlscoin.info:29802")

_hr="------------------------"

fextract () {
    echo "$1" | grep $2 | grep -o '[0-9]\+'
}

while true; do
    printf "\n$(date):\n| IP ADDRESS:PORT\t\t| PING\t| DIFFICULTY\t| HASHRATE\t| HEIGHT (+/-)\t| CONNECTIONS |\n"

    for i in "${sList[@]}"; do

				if [ ${i:0:1} = "-" ]; then
				    printf "\n$i$_hr\n"
				else

        _timer=$(date +%s)
        _noderesp="$(wget -qO- $i/info | jq '{difficulty, hashrate, height, network_height, status, synced, incoming_connections_count, outgoing_connections_count}')"
        #echo "$(wget -qO- $i:$_port/info | jq '{difficulty, hashrate, height, network_height, status, synced, incoming_connections_count, outgoing_connections_count}')"
        #        echo $_resplen

        if [ ${#_noderesp} -gt 0 ]; then
            _timer=$(($(date +%s)-$_timer))
            _difficulty=$(numfmt --to=si --format='%.2f' $(fextract "$_noderesp" "difficulty"))
            if [ "${#_difficulty}" -lt "6" ]; then
								_difficulty+=" "
						fi
            _hashrate="$(numfmt --to=si --format='%.3f' $(fextract "$_noderesp" "hashrate"))H/s"
            _height=$(echo "$_noderesp" | grep height | grep -o '[0-9]\+')
            _netheight=$(echo "$_noderesp" | grep network_height | grep -o '[0-9]\+')
            _heightdiff=$(awk "BEGIN {print $_netheight - $_height}")
            _incoming=$(echo "$_noderesp" | grep incoming_connections_count | grep -o '[0-9]\+')
            _outgoing=$(echo "$_noderesp" | grep outgoing_connections_count | grep -o '[0-9]\+')
            _synced=$(echo "$_noderesp" | grep synced | grep -o true)
            if [ "${#i}" -lt "22" ]; then
                i+="\t"
            fi
            printf "| $i\t| $_timer\t| $_difficulty\t| $_hashrate\t| $_netheight ($_heightdiff)\t| IN/OUT:$_incoming/$_outgoing |\n"
        else
            printf "| No response from $i\n"
        fi
    fi
    done
    sleep 10
done
