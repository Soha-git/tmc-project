#!/bin/bash

token=$TELEGRAM_BOT_TOKEN 
chat_id=$TELEGRAM_USER_ID    
WEBHOOKURL="https://api.telegram.org/bot${token}/sendMessage"

FAILURE=1
SUCCESS=0

function print_telegram_summary_build() {

msg_header=":x: *Build to ${CI_COMMIT_BRANCH} failed*"

if [[ "${EXIT_STATUS}" == "${SUCCESS}" ]]; then
        msg_header=":heavy_check_mark: *Build to ${CI_COMMIT_BRANCH} succeeded*"
        id_channel="$chat_id"
    fi
cat <<-SLACK
            {
                "blocks": [
                    {
                        "type": "section",
                        "text": {
                            "type": "mrkdwn",
                            "text": "${msg_header}"
                        }
                    },
                    {
                        "type": "divider"
                    },
                    {
                        "type": "section",
                        "fields": [
                            {
                                "type": "mrkdwn",
                                "text": "*Stage:*\n${CI_JOB_STAGE}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Pushed By:*\n${GITLAB_USER_NAME}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Job URL:*\nGITLAB_REPO_URL/${CI_JOB_ID}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Commit Branch:*\n${CI_COMMIT_REF_NAME}"
                            }
                        ]
                    },
                    {
                        "type": "divider"
                    }
                ]
}
SLACK
}

function share_telegram_update_build() {
telegram_webhook="$WEBHOOKURL"
curl -X POST                                           \
        --data-urlencode "payload=$(print_telegram_summary_build)"  \
        "${telegram_webhook}" \ chat_id\":${chat_id}
}