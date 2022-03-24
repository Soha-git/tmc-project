#!/bin/bash

token=$TELEGRAM_BOT_TOKEN 
chat_id=$TELEGRAM_USER_ID    
parse_mode=$PARSE_MODE
$MESSAGE

if [[ -z $token ]]
then
    echo 'Not passed required BOT_TOKEN environment variable' >&2
    exit 1
fi

if [[ -z $chat_id ]]
then
    echo 'Not passed required CHAT_ID environment variable' >&2
    exit 2
fi

if [[ -z $message ]]
then
    echo 'Not passed required MESSAGE environment variable' >&2
    exit 3
fi

if [[ -z $parse_mode ]]
then
    parse_mode='Markdown'
fi


request="{\"text\":\"${message}\",\"parse_mode\":\"${parse_mode}\",\"chat_id\":${chat_id}}"

curl -X POST \
     -H "Content-Type: application/json" \
     -d "${request}" \
     "https://api.telegram.org/bot${token}/sendMessage"