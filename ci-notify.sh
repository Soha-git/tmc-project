#!/bin/bash
set -euo pipefail
FAILURE=1
SUCCESS=0
SLACKWEBHOOKURL="https://hooks.slack.com/services/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"

function print_slack_summary_build() {
# Populate header and message 
slack_msg_header=":x: ${CI_JOB_STAGE} to ${CI_COMMIT_BRANCH} failed*"
if [[ "${EXIT_STATUS}" == "${SUCCESS}" ]]; then
        slack_msg_header=":heavy_check_mark: ${CI_JOB_STAGE} to ${CI_COMMIT_BRANCH} succeeded*"
    fi
cat <<-SLACK
            {
                "blocks": [
                    {
                        "type": "section",
                        "text": {
                            "type": "mrkdwn",
                            "text": "${slack_msg_header}"
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
                                "text": "*Stage:*\n ${CI_JOB_STAGE}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Pushed By:*\n ${GITLAB_USER_NAME}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Job URL:*\n $CI_REPOSITORY_URL/${CI_JOB_URL}"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Commit URL:*\n $CI_REPOSITORY_URL$(git rev-parse HEAD)"
                            },
                            {
                                "type": "mrkdwn",
                                "text": "*Commit Branch:*\n ${CI_COMMIT_REF_NAME}"
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
function share_slack_update_build() {
slack_webhook="$SLACKWEBHOOKURL"
curl -X POST                                           \
        --data-urlencode "payload=$(print_slack_summary_build)"  \
        "${slack_webhook}"
}