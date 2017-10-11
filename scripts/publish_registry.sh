#!/bin/bash
set -e

# Environnment variables:
#   COZY_BUILD_URL: the URL of the deployed tarball for your application
#   COZY_APP_VERSION: the version string of the deployed version

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
    echo "No deployment: in pull-request"
    exit 0
fi

if [ "${TRAVIS_BRANCH}" != "build" ] && [ "${TRAVIS_BRANCH}" != "${TRAVIS_TAG}" ]; then
    printf 'No deployment: not in build branch nor tag (TRAVIS_BRANCH=%s TRAVIS_TAG=%s)\n' "${TRAVIS_BRANCH}" "${TRAVIS_TAG}"
    exit 0
fi

if [ -z "${COZY_APP_VERSION}" ]; then
    if [ -n "${TRAVIS_TAG}" ]; then
        COZY_APP_VERSION="${TRAVIS_TAG}"
    else
        COZY_APP_VERSION="$(jq -r '.version' < "${TRAVIS_BUILD_DIR}/manifest.webapp")-dev.${TRAVIS_COMMIT}"
    fi
fi

if [ -z "${COZY_BUILD_URL}" ]; then
    url="https://github.com/${TRAVIS_REPO_SLUG}/archive"
    if [ -n "${TRAVIS_TAG}" ]; then
        COZY_BUILD_URL="${url}/${TRAVIS_TAG}.tar.gz"
    else
        COZY_BUILD_URL="${url}/${TRAVIS_COMMIT}.tar.gz"
    fi
fi

shasum=$(curl -sSL --fail "${COZY_BUILD_URL}" | shasum -a 256 | cut -d" " -f1)

printf 'Publishing version "%s" from "%s" (%s)\n' "${COZY_APP_VERSION}" "${COZY_BUILD_URL}" "${shasum}"

curl -sS --fail -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Token ${REGISTRY_TOKEN}" \
    -d "{\"version\": \"${COZY_APP_VERSION}\", \"url\": \"${COZY_BUILD_URL}\", \"sha256\": \"${shasum}\"}" \
    "https://registry.cozy.io/registry/versions"
