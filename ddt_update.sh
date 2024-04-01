#!/bin/bash

DDT_PATH="/home/code/ddt"
DDT_UPDATE_LOG="/tmp/ddt_update.log"
TOOLS_PATH="/home/code/os.linux.validation.clkv-infra/tools"

append_log()
{
	echo -e "$1" | tee -a "$DDT_UPDATE_LOG"
}

do_cmd() {
  local cmd=$*
  local ret=""

	append_log "$cmd"
  eval "$cmd"
  ret=$?
  if [[ ret -ne 0 ]]; then
    echo "Failed to execute command: $cmd, ret:$ret, please check!"
    exit 1
  fi
}

update_maintain_ddt() {
  local git_diff=""

  do_cmd "cd $DDT_PATH"

  # 1 Update lkvs and binary submodule
  echo "Update lkvs and binary submodule:"
  #echo "git submodule"
  #git submodule

  do_cmd "git submodule update --init"

  do_cmd "git submodule update --remote tools/clkv/src"

  do_cmd "git submodule update --remote utils/binaries"

  git_diff=$(git diff)
  if [[ -z "$git_diff" ]]; then
    echo -e "[WARN] Submodule clkv or binaries udpated, need a commit to push!!!!\n"
  else
    echo -e "Submodule clkv or binaries no update, do nothing.\n"
  fi


# 2 ddt-sync to data base
  echo "ddt-sync ddt to data base:"

  do_cmd "ddt-sync scenarios"

  do_cmd "ddt-sync platforms"

  do_cmd "ddt-sync tests"

  echo -e "ddt-sync to data base done!\n"

# 3  data base to LFE
  echo "data base to LFE by lfe sync:"
  do_cmd "cd $TOOLS_PATH"
  do_cmd "git fetch origin"

  # Need to manually to do lfe sync
  #do_cmd "./lfe sync"

  git_diff=$(git diff)
  if [[ -z "$git_diff" ]]; then
    echo -e "[WARN] Submodule clkv or binaries udpated, need a commit to push!!!!\n"
  else
    echo -e "Submodule clkv or binaries no update, do nothing.\n"
  fi
  echo "If want to check data base connection problem, use: jz get projects"

  echo "Next need to do lfe sync for data base to LFE."
  echo "${TOOLS_PATH}/lfe sync"
  echo "Update DDT done!"
}

update_maintain_ddt
