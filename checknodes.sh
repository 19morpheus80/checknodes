
#!/bin/bash
#Universal checker to see if node is up. Just run the program, enter the details when prompted. 



read -p 'IP address or node name: ' Result 
read -p 'Port number: ' Port

$i=$Result":"$Port


_hr="------------------------"

fextract () {
    echo "$1" | grep $2 | grep -o '[0-9]\+'
}

while true; do
    printf "\n$(date):\n| IP ADDRESS:PORT\t\t| PING\t| DIFFICULTY\t| HASHRATE\t| HEIGHT (+/-)\t| CONNECTIONS |\n"

    for i in "${Result}"; do

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
            if [ "${#i}" -lt "21" ]; then
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
    fi
    done
    sleep 10
done
