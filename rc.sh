# static exports
export \
	-- \
	DEB_SIGN_KEYID=32884194D7B577F098AA6E5E4BCC1BAF73B8B7E8 \
	DEBSIGN_KEYID=32884194D7B577F098AA6E5E4BCC1BAF73B8B7E8 \
	#
# $DEB_SIGN_KEYID honored by:
#   - dpkg-buildpackage(1)
# $DEBSIGN_KEYID honored by:
#   - debsign(1)
#   - dpkg-sig(1)


# This is executed by all interactive bash shells on startup,
# including some (e.g. scp and rcp) that don't expect any output.
# $- expands to the current option flags, that is:
#   · those specified upon invocation;
#   · those enabled by the `set` built-in; and
#   · those set by the shell itself (e.g. -i).
if [[ $- = *i* ]]
then
	# We're on an interactive shell

	declare \
		-r \
		-- \
		_term_color_foreground_blue="$(tput setaf 4)" \
		_term_color_foreground_dicky="$(tput setaf 46)" \
		_term_color_foreground_gray="$(tput setaf 243)" \
		_term_color_foreground_green="$(tput setaf 2)" \
		_term_color_foreground_lightblue="$(tput setaf 51)" \
		_term_color_foreground_orange="$(tput setaf 208)" \
		_term_color_foreground_red="$(tput setaf 1)" \
		_term_color_foreground_white="$(tput setaf 255)" \
		_term_reset="$(tput sgr0)" \
		_term_typeface_bold="$(tput bold)" \
		#

	function in_git_repo
	{
		git \
			rev-parse \
			--is-inside-work-tree \
			&> /dev/null \
			#
	}

	function git_prompt
	{
		if in_git_repo
		then
			git_branch="$(
				git \
					rev-parse \
					--symbolic-full-name \
					--abbrev-ref \
					HEAD \
					2> /dev/null \
					#
			)"

			alias \
				-- \
				mv='git_command_suggestion mv --no-clobber' \
				rm='git_command_suggestion rm --interactive=always' \
				#
		else
			unset \
				-- \
				git_branch \
				#

			alias \
				-- \
				mv='mv --no-clobber' \
				rm='rm --interactive=always' \
				#
		fi
	}

	last_cwd="${PWD}"
	declare \
		-i \
		-- \
		last_exit_code=0 \
		#

	function prompt_command
	{
		declare \
			-r \
			-i \
			-- \
			exit_code="$?" \
			#

		if [[ ${PWD} != ${last_cwd} ]]
		then
			# We have moved into a different directory
			# and could be inside a git directory now.
			update_git_prompt=y
			last_cwd="${PWD}"
		fi

		if [[ ${update_git_prompt} = y ]]
		then
			git_prompt
			update_git_prompt=n
		fi

		PS1='\[${_term_typeface_bold}${_term_color_foreground_green}\]\u@\h\[${_term_reset}\] \[${_term_typeface_bold}${_term_color_foreground_blue}\]\w\[${_term_reset}\]'

		if [[ -v git_branch ]]
		then
			PS1+=' \[${_term_typeface_bold}${_term_color_foreground_red}\]${git_branch}\[${_term_reset}\]'
		fi

		if [[ ${exit_code} -ne ${last_exit_code} || ! -v exit_code_padded ]]
		then
			last_exit_code=${exit_code}

			printf \
				-v exit_code_padded \
				'%3i' \
				${exit_code} \
				#

			if [[ ${exit_code} -eq 0 ]]
			then
				exit_code_format="${_term_color_foreground_green}"
			else
				exit_code_format="${_term_typeface_bold}${_term_color_foreground_red}"
			fi
		fi

		PS1+='\n\[${_term_typeface_bold}${_term_color_foreground_orange}\]\A\[${_term_reset}\] \[${exit_code_format}\]${exit_code_padded}\[${_term_reset}\] \[${_term_typeface_bold}${_term_color_foreground_blue}\]\$\[${_term_reset}\] '
	}

	function trap_debug
	{
		if [[ ${BASH_COMMAND} == git\ * ]]
		then
			update_git_prompt=y
		fi
	}

	function git_command_suggestion
	{
		local command="${1}"
		local command_arguments="${2}"

		#echo "Maybe you want ${_term_typeface_bold}${_term_color_foreground_green}git ${command}${_term_reset} instead"
		echo "To use ${_term_typeface_bold}${_term_color_foreground_blue}${command}${_term_reset}, invoke it through ${_term_typeface_bold}${_term_color_foreground_blue}command${_term_reset}:"
		echo "  $ ${_term_typeface_bold}${_term_color_foreground_lightblue}command${_term_reset} ${command} ${_term_color_foreground_gray}${command_arguments}${_term_reset} ..."
		echo '    ^^^^^^^'
	}

	{
		declare \
			-a \
			path_pre_components \
			#

		path_pre_components+=("${HOME}/.local/bin")
		if command -v -- ruby &> /dev/null
		then
			path_pre_components+=("$(ruby -e 'puts Gem.user_dir')/bin")
		fi

		path_pre=''
		for path_pre_component in "${path_pre_components[@]}"
		do
			path_pre="${path_pre}${path_pre_component}:"
		done
		PATH="${path_pre}${PATH}"
	}

	if command -v -- aws_completer &> /dev/null
	then
		complete \
			-C aws_completer \
			aws \
			#
	fi

	git_prompt

	shopt \
		-s \
		-- \
		histappend \
		#

	trap \
		trap_debug \
		DEBUG \
		#

	# Save every line on the history list
	HISTCONTROL=''
	HISTIGNORE=''
	# Do not remove any entries from the history file
	HISTFILESIZE=-1
	# Remember every command in the in-memory history list
	HISTSIZE=-1

	PROMPT_COMMAND=prompt_command

	PS2='\[${_term_color_foreground_gray}\]>\[${_term_reset}\] '


	# User functions and aliases

	alias \
		-- \
		cp='cp --no-clobber' \
		grep='grep --color=auto' \
		jqless='qless jq' \
		ls='ls --color=auto' \
		yqless='qless yq' \
		#

	function ggrep
	{
		grep \
			-i \
			-R \
			--exclude-dir .git \
			--exclude-dir .tup \
			-C 3 \
			-- \
			"$1" \
			. \
			#
	}

	function qless
	{
		# Input can be passed through stdin too (and not just from a file)
		"${1}" \
			--color-output \
			. \
			-- \
			"${@:2}" \
		|
		less \
			--RAW-CONTROL-CHARS \
			#
	}

	function smaato_aws_login
	{
		BROWSER='/usr/bin/firefox -P Smaato %s' \
			aws \
			--profile "${1}" \
			sso \
			login \
			#
	}
fi
