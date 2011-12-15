# inspirated in { kolo alanpeabody nanotech }.zsh-theme
# inspirated in https://github.com/lvv/git-prompt
autoload -U colors && colors

autoload -Uz vcs_info

local localDate='%{$fg[white]%}$(date +%H:%M)%{$reset_color%}'
local userHost= #'[%n@%m] '

zstyle ':vcs_info:*' stagedstr '%F{green}●'
zstyle ':vcs_info:*' unstagedstr '%F{yellow}●'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{11}%r'
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:git*+set-message:*' hooks git-abbrv-master
function +vi-git-abbrv-master(){
    hook_com[branch]=${hook_com[branch]/#%master/M}
}

# check new commits in remote branchs
function git_remotes() {
  git_dir=$(git rev-parse --git-dir 2> /dev/null ) || return
    [[ $(git remote) == "" ]] && return
  remotes=""
  if [[ -n $git_dir ]]; then
	  if [[ $(git branch | sed -e '/^[^*]/d' | awk '{print $2}') == "master" ]]; then
	        fetchUpdate=3600 
	        remotes=()
	        for remote in $(git remote)
	        do
	                if [[ ! -e $git_dir/FETCH_HEAD ]]; then
	                        ( git fetch $remote >& /dev/null &)
	                else
							# with date (GNU coreutils)
	                        fetchDate=$(date --utc --reference=$git_dir/FETCH_HEAD +%s)
	                        now=$(date --utc +%s)
	                        delta=$(( $now - $fetchDate ))
	                        # if last update to .git/FETCH_HEAD file 
	                        if [[ $delta -gt $fetchUpdate  ]]; then
	                                ( git fetch $remote >& /dev/null &)
	                        fi
	                fi
	                if [[ $(git branch -a | grep $remote) != "" ]]; then
	                        nRemoteCommit=$(git log --oneline HEAD..$remote/master | wc -l)
	                        if [[ -f $git_dir/FETCH_HEAD && $nRemoteCommit != "0" ]]; then
	                                remotes+=" "${remote/origin/o}:$nRemoteCommit
	                        fi
	                else
	                        (git fetch $remote >& /dev/null &)
	                fi
	        done
			pushed=$(git log --oneline origin/master..HEAD | wc -l )
			[ "$pushed" -gt "0" ] && remotes+=" ↑:"$pushed
			if [[ "$git_dir" != "." ]]; then
				# submodules commits
				submod=$(git status | grep "new commits" | wc -l)
				[ "$submod" -gt "0" ] && remotes+=" _:"$submod
			fi
	  fi
  fi
  echo $remotes
}
local remotes='%B%F{green}$(git_remotes)%{$reset_color%}'

precmd () {
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
        zstyle ':vcs_info:*' formats ' [%b%c%u%B%F{green}]'
    } else {
        zstyle ':vcs_info:*' formats ' [%b%c%u%B%F{red}●%F{green}]'
    }

    vcs_info
}

setopt prompt_subst
PROMPT='%B%F{white}${userHost}%~%B%F{green}${vcs_info_msg_0_}%B%F{magenta}%{$reset_color%}$ '
RPROMPT="${remotes} ${localDate}"
