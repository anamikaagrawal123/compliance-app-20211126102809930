#!/usr/bin/env bash

set -euo pipefail

#cDOCKER_BUILDKIT=1 docker build $DOCKER_BUILD_ARGS .
docker build $DOCKER_BUILD_ARGS .
docker push "${IMAGE}"

#optional tag
set +e
TAG="$(cat /config/custom-image-tag)"
set -e
if [[ "${TAG}" ]]; then
    #see build_setup script
    IFS=',' read -ra tags <<< "${TAG}"
    for i in "${!tags[@]}"
    do
        TEMP_TAG=${tags[i]}
        TEMP_TAG=$(echo "$TEMP_TAG" | sed -e 's/^[[:space:]]*//')
        echo "adding tag $i $TEMP_TAG"
        ADDITIONAL_IMAGE_TAG="$ICR_REGISTRY_REGION.icr.io"/"$ICR_REGISTRY_NAMESPACE"/"$IMAGE_NAME":"$TEMP_TAG"
        docker tag "$IMAGE" "$ADDITIONAL_IMAGE_TAG"
        docker push "$ADDITIONAL_IMAGE_TAG"
    done
fi

DIGEST="$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE" | awk -F@ '{print $2}')"

if which save_artifact >/dev/null; then
  #
  # Save the artifact to the pipeline, 
  # so it can be scanned and signed later
  #
  save_artifact app-image \
    type=image \
    "name=${IMAGE}" \
    "digest=${DIGEST}"

  #
  # Make sure you connect the built artifact to the repo and commit
  # it was built from. The source repo asset format is:
  #   <repo_URL>.git#<commit_SHA>
  #
  # In this example we have a repo saved as `app-repo`,
  # and we've used the latest cloned state to build the image.
  #
  url="$(load_repo app-repo url)"
  sha="$(load_repo app-repo commit)"
  
  save_artifact app-image \
    "source=${url}.git#${sha}"
fi
