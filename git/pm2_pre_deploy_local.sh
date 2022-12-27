#!/usr/bin/env bash

function get_target_branch_name() {
  branch_name=$( git rev-parse --abbrev-ref HEAD )
#  echo "$branch_name"
}

function get_sprint_number_from_branch_name() {
  IFS='_'
  read -ra splited_strings_arr <<< "$branch_name"
  sprint_number="${splited_strings_arr[1]}"
#  echo "$sprint_number"
  return
}

function get_previous_tags_from_sprint_number() {
  tag_pattern="${sprint_number}*"
<<<<<<< HEAD
  mapfile -t previous_tags < <(git tag -l "$tag_pattern")
#  for tag in "${previous_tags[@]}"; do
#    echo "$tag"
#  done
=======
  mapfile -t previous_tags < <( git tag -l "$tag_pattern")
  for tag in "${previous_tags[@]}"; do
    echo "$tag"
  done
>>>>>>> 8a197f26 (test release tags)
  return
}

function delete_local_tags_and_fetch_tags_from_remote() {
   git tag -l | xargs git tag -d
   git fetch --tags
}

function get_last_tag_from_previous_tags() {
  if [ -z "$previous_tags" ]; then
    return
  fi
  last_tag=${previous_tags[-1]}
#  echo "$last_tag"
}

function check_if_major_minor_or_patch_tag_needed() {
  if [ -z "$last_tag" ]; then
    SEMANTIC_VERSION="major"
#  elif [  ]; then
#    SEMANTIC_VERSION="minor"
  else
    SEMANTIC_VERSION="patch"
  fi
  return
}

function get_new_patch_tag_from_last_tag() {
  IFS='.'
  read -ra splited_tags_arr <<< "$last_tag"
  major_version="${splited_tags_arr[0]}"
  minor_version="${splited_tags_arr[1]}"
  patch_version=$(( "${splited_tags_arr[2]}" + 1 ))
  new_tag="${major_version}.${minor_version}.${patch_version}"
#  echo "$major_version " " $minor_version " " $patch_version " "$new_tag"
}

function get_new_major_tag_from_last_tag() {
  new_tag="${sprint_number}.0.0"
}

function get_new_minor_tag_from_last_tag() {
  new_tag=$((  ))
}

function create_new_tag() {
  if [ $SEMANTIC_VERSION = "major" ]; then
    get_new_major_tag_from_last_tag
  elif [ "$SEMANTIC_VERSION" = "patch" ]; then
    get_new_patch_tag_from_last_tag
  elif [ "$SEMANTIC_VERSION" = "minor" ]; then
    get_new_minor_tag_from_last_tag
  fi
#  echo "$new_tag"

  if [ -z "$new_tag" ]; then
    exit 0
  fi
  git tag -a "$new_tag" -m "tag created from trucklagbe_saas pm2_pre_deploy_local"
  return
}

function push_new_tag_to_remote() {
  git push origin "$new_tag"
  echo "$new_tag"
}

get_target_branch_name
get_sprint_number_from_branch_name
# delete_local_tags_and_fetch_tags_from_remote
get_previous_tags_from_sprint_number
get_last_tag_from_previous_tags
check_if_major_minor_or_patch_tag_needed
create_new_tag
push_new_tag_to_remote
