# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

# scm theming
SCM_THEME_PROMPT_PREFIX="|"
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${bold_red?}✗${normal?}"
SCM_THEME_PROMPT_CLEAN=" ${green?}✓${normal?}"
SCM_GIT_CHAR="${bold_green?}±${normal?}"
SCM_SVN_CHAR="${bold_cyan?}⑆${normal?}"
SCM_HG_CHAR="${bold_red?}☿${normal?}"

VIRTUALENV_THEME_PROMPT_PREFIX="("
VIRTUALENV_THEME_PROMPT_SUFFIX=")"

# function scm_prompt_char_info() {
#   scm_char=$(scm_char)
#   if [[ -z $scm_char ]]; then
#     echo -e "" # Empty string instead of circle
#   else
#     echo -e "$scm_char"
#   fi
# }

function custom_scm_char() {
  result=$(scm_prompt_char_info)
  # Check if the result is just a circle
  if [[ "$result" == "○" ]]; then
    echo ""
  else
    echo "${result}"
  fi
}

function pure_prompt() {
  local ps_host="${bold_yellow?}\h${normal?}"
  local ps_user="${bold_yellow?}\u${normal?}"
  local ps_user_mark="${green?}\$${normal?}"
  local ps_root="${red?}\u${red?}"
  local ps_root_mark="${red?}\#${normal?}"
  local ps_path="${bold_green?}\w\n${normal?}"
  local virtualenv_prompt scm_prompt
  virtualenv_prompt="$(virtualenv_prompt)"
  scm_prompt="$(scm_prompt)"

  # make it work
  case "${EUID:-$UID}" in
    0)
      ps_user_mark="${ps_root_mark}"
      ps_user="${ps_root}"
      ;;
  esac

  PS1="${virtualenv_prompt}${ps_user}${bold_yellow?}@${normal?}${ps_host}:${ps_path}$(custom_scm_char)${ps_user_mark} → "
}

safe_append_prompt_command pure_prompt
