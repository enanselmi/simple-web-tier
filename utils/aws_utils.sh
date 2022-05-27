#!/bin/bash

set -eo pipefail

ENVS_DIR=environments

if [ -z "${1}" ]; then
  echo "Usage:"
  echo -e "\t> ./aws_utils.sh prepare_deploy_links <environment>"
fi

prepare_deploy_links() {
  local environment=$1
  undo_links $environment

  cd ${ENVS_DIR}/${environment}/
  ln -s ../../common/*.tf .
  ln -s ../../templates .
  ln -s ../../keys .

  if [ -f "./.reusables" ]; then
    for tf in $(cat ./.reusables); do
      if [[ $tf == "#"* ]] ; then 
        echo "Excluding ${tf} since it's commented in .reusables"
      else 
        ln -s ../../reusables/$tf .
      fi
    done
  fi
}

undo_links() {
  links=$(find ${ENVS_DIR}/${1} -type l -path "${ENVS_DIR}/${1}/.terraform/*" -prune -o -type l -print)
  echo $links
  for file in ${links}; do
    unlink ${file}
  done
}

$@
