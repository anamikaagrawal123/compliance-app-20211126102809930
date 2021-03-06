#!/usr/bin/env bash

#
# prepare data
#

export GHE_TOKEN="$(cat ../git-token)"
export COMMIT_SHA="$(cat /config/git-commit)"
export APP_NAME="$(cat /config/app-name)"

INVENTORY_REPO="$(cat /config/inventory-url)"
GHE_ORG=${INVENTORY_REPO%/*}
export GHE_ORG=${GHE_ORG##*/}
GHE_REPO=${INVENTORY_REPO##*/}
export GHE_REPO=${GHE_REPO%.git}

export APP_REPO="$(cat /config/repository-url)"
APP_REPO_ORG=${APP_REPO%/*}
export APP_REPO_ORG=${APP_REPO_ORG##*/}

if [[ -f "/config/repository" ]]; then
    REPOSITORY="$(cat /config/repository)"
    export APP_REPO_NAME=$(basename $REPOSITORY .git)
    APP_NAME=$APP_REPO_NAME
else
    APP_REPO_NAME=${APP_REPO##*/}
    export APP_REPO_NAME=${APP_REPO_NAME%.git}
fi

ARTIFACT="https://raw.github.ibm.com/${APP_REPO_ORG}/${APP_REPO_NAME}/${COMMIT_SHA}/deployment.yml"

IMAGE_ARTIFACT="$(cat /config/artifact)"
SIGNATURE="$(cat /config/signature)"
SHA_256=${IMAGE_ARTIFACT##*"@sha256:"}
if [[ -f "/config/custom-image-tag" ]]; then
    TAG="$(cat /config/custom-image-tag)"
    APP_ARTIFACTS='{ "app": "'${APP_NAME}'", "tag": "'${TAG}'" }'
else
    APP_ARTIFACTS='{ "app": "'${APP_NAME}'" }'
fi
#
# add to inventory
#

cocoa inventory add \
    --artifact="${ARTIFACT}" \
    --repository-url="${APP_REPO}" \
    --commit-sha="${COMMIT_SHA}" \
    --build-number="${BUILD_NUMBER}" \
    --pipeline-run-id="${PIPELINE_RUN_ID}" \
    --version="$(cat /config/version)" \
    --type="deployment" \
    --sha256="${SHA_256}" \
    --signature="${SIGNATURE}" \
    --name="${APP_REPO_NAME}_deployment"

cocoa inventory add \
    --artifact="${IMAGE_ARTIFACT}" \
    --repository-url="${APP_REPO}" \
    --commit-sha="${COMMIT_SHA}" \
    --build-number="${BUILD_NUMBER}" \
    --pipeline-run-id="${PIPELINE_RUN_ID}" \
    --version="$(cat /config/version)" \
    --name="${APP_REPO_NAME}" \
    --app-artifacts="${APP_ARTIFACTS}" \
    --signature="${SIGNATURE}" \
    --provenance="${IMAGE_ARTIFACT}" \
    --sha256="${SHA_256}" \
    --type="image"
