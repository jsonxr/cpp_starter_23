#!/usr/bin/env bash
#set -e
VERBOSE=0

# curl -s "https://versionhistory.googleapis.com/v1/chrome/platforms/all/channels/stable/versions"


with_verbose_trace() {
  if [[ $VERBOSE -eq 1 ]]; then
    ( set -x; "$@" )
    return $?
  fi

  "$@"
}

chrome_version_for_platform() {
  local json="$1"
  local platform="$2"

  echo "$json" |
    awk -v p="/platforms/${platform}/" '
      $0 ~ "\"name\"" && $0 ~ p { found=1; next }
      found && /"version":/ {
        line=$0
        sub(/.*"version": *"/, "", line)
        sub(/".*/, "", line)
        print line
        exit
      }
    '
}

echo_help() {
  local chrome_channel="$1"
  platforms=(
  win
  win64
  win_arm64
  mac
  mac_arm64
  linux
  android
  ios
)

  json=$(
    curl -s "https://versionhistory.googleapis.com/v1/chrome/platforms/all/channels/${chrome_channel}/versions")

  mac_version=$(chrome_version_for_platform "$json" "mac_arm64")

  echo "Latest Chrome ${chrome_channel} Versions:"
  echo "| chrome         | dawn commit hash                         | platform  |"
  echo "| -------------- | ---------------------------------------- | --------- |"
  for platform in "${platforms[@]}"; do
    version=$(chrome_version_for_platform "$json" "$platform")
    dawn_commit=$(get_dawn_commit_for_chrome "$version")
    printf "| %s | %s | %-9s |\n" "$version" "$dawn_commit" "$platform"
  done

  emsdk_version=$(curl -s "https://api.github.com/repos/emscripten-core/emsdk/tags" \
  | grep '"name"' \
  | head -n1 \
  | sed -E 's/.*"([^"]+)".*/\1/')
  echo
  echo "Latest emsdk: $emsdk_version"


  echo
  echo "Usage:  $0 --chrome=$mac_version --emsdk=$emsdk_version [--chrome-channel=$chrome_channel] [--verbose]"
}

get_dawn_commit_for_chrome() {
  local chrome_version="$1"
  local chromium_deps_base="https://chromium.googlesource.com/chromium/src.git/+/refs/tags"

  local deps_b64
  deps_b64=$(curl -s "${chromium_deps_base}/${chrome_version}/DEPS?format=TEXT")

  echo "$deps_b64" |
    base64 --decode |
    sed -nE "s/.*['\"]dawn_revision['\"]: *['\"]([0-9a-f]+)['\"].*/\1/p" |
    head -n1
}

install_dawn_at_commit() {
  local commit="$1"
  local dawn_repo_url="https://dawn.googlesource.com/dawn"

#commit="0223916e3a572e7c264d0b8da5f077556e660871"

  echo "======================================================================"
  echo "Using Dawn: $commit"
  echo "======================================================================"

  with_verbose_trace rm -rf dawn
  with_verbose_trace git init dawn
  (
    cd dawn
    with_verbose_trace git remote add origin "$dawn_repo_url"

    with_verbose_trace git fetch --depth 1 origin "$commit"
    with_verbose_trace git checkout FETCH_HEAD
  )
}

install_emsdk_version() {
  local version="$1"
  local emsdk_dir="emsdk"
  local emsdk_repo="https://github.com/emscripten-core/emsdk.git"

  echo "======================================================================"
  echo "Using Emsdk version: $version"
  echo "======================================================================"

  if [[ ! -d "$emsdk_dir" ]]; then
    echo "Cloning emsdk $version into $emsdk_dir"
    with_verbose_trace git clone --depth 1 "$emsdk_repo" "$emsdk_dir"
  else
    echo "Using existing emsdk checkout at $emsdk_dir"
  fi

  (
    cd "$emsdk_dir"
    with_verbose_trace ./emsdk install "$version"
    with_verbose_trace ./emsdk activate "$version"
  )
}

main() {
  local chrome_version=""
  local emsdk_version=""
  local verbose=0
  local chrome_channel="stable"

  for arg in "$@"; do
    case "$arg" in
      --chrome=*)
        chrome_version="${arg#--chrome=}"
        ;;
      --emsdk=*)
        emsdk_version="${arg#--emsdk=}"
        ;;
      --chrome-channel=*)
        chrome_channel="${arg#--chrome-channel=}"
        ;;
      -v|--verbose)
        verbose=1
        ;;
      -h|--help)
        echo_help "$chrome_channel"
        exit 0
        ;;
      *)
        echo "Unknown argument: $arg" >&2
        exit 1
        ;;
    esac
  done

  if [[ -z "$chrome_version" ]]; then
    echo_help "$chrome_channel"
    exit 0
  fi
  VERBOSE="$verbose"

  # 1) install dawn
  echo "Using Chrome version: $chrome_version"
  local dawn_commit=$(get_dawn_commit_for_chrome "$chrome_version")
  if [[ -z "$dawn_commit" ]]; then
    echo "Error: Could not resolve Dawn commit for Chrome $chrome_version" >&2
    exit 1
  fi
  install_dawn_at_commit "$dawn_commit"

  # 2) Install and activate emscripten
  if [[ -n "$emsdk_version" ]]; then
    install_emsdk_version "$emsdk_version"
  fi

}

main "$@"
