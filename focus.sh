#!/bin/bash

setup() {
    iptables -F focus
    iptables -A focus -p tcp -j REJECT --reject-with tcp-reset
    iptables -A focus -j REJECT
}

block() {
    host=$1
    host $host | sed -ne 's/^.* has address //gp' | while read ip; do
        echo "block $host: $ip"
        iptables -I OUTPUT -d $ip -j focus
    done
}

clear() {
    iptables -S OUTPUT | grep -- '-j focus' | sed -e 's/^-A/-D/' | \
        while read rule; do
        echo "clear: $rule"
        iptables $rule
    done
}

mode=$1
case "$mode" in
    install)
        setup
        block reddit.com
        block news.ycombinator.com
        block techmeme.com
        block youtube.com
        block facebook.com
        ;;
    uninstall)
        clear
        ;;
    *)
        echo "usage: $0 {install|uninstall}"
        exit 1
        ;;
esac

