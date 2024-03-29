# static exports
export \
	-- \
	DEBSIGN_KEYID=E0C3497126B72CA47975FC322953BB8C16043B43 \
	#
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
		_term_color_foreground_yellow="$(tput setaf 3)" \
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

		if [[ -v AWS_PROFILE ]]
		then
			PS1+='  \[${_term_color_foreground_yellow}\]AWS:\[${_term_typeface_bold}\]${AWS_PROFILE}\[${_term_reset}\]'
			if [[ -v AWS_DEFAULT_REGION ]]
			then
				PS1+='\[${_term_color_foreground_yellow}\]@\[${_term_typeface_bold}\]${AWS_DEFAULT_REGION}\[${_term_reset}\]'
			fi
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

	set \
		-o ignoreeof \
		#

	shopt \
		-s \
		-- \
		histappend \
		#

	trap \
		trap_debug \
		DEBUG \
		#

	# Save all lines except those that begin with a space character on the history list
	HISTCONTROL=ignorespace
	HISTIGNORE=''
	# XDG
	HISTFILE="${XDG_STATE_HOME:-${HOME}/.local/state}/bash/history"
	# Do not remove any entries from the history file
	HISTFILESIZE=-1
	# Remember every command in the in-memory history list
	HISTSIZE=-1
	# Display dates in history entries according to ISO 8061
	HISTTIMEFORMAT='%FT%T%z '

	PROMPT_COMMAND=prompt_command

	PS2='\[${_term_color_foreground_gray}\]>\[${_term_reset}\] '


	# Load bash-completion
	# Loading bash-completion in the personal initialization script is not necessary on distributions that:
	#  - build Bash with `-DSYS_BASHRC=`, by which Bash loads the script at the specified path, often `/etc/bash.bashrc`, in addition to the personal initialization script; and
	#  - ship a system initialization script at the specified path that loads bash-completion.
	# Arch does this.
	# For a Bash initialization script to be compatible with all distributions, however, it must load bash-completion itself.
	if [[ -r /usr/share/bash-completion/bash_completion ]]
	then
		source \
			-- \
			/usr/share/bash-completion/bash_completion \
			#
	fi


	# exports

	# The AWS CLI loads its "less sensitive configuration options" from `${HOME}/.aws/config` by default. It can be made to follow the XDG Base Directory Specification[1] and load its configuration from `${XDG_CONFIG_HOME}` instead with the environment variable `AWS_CONFIG_FILE`, according to its documentation[2].
	# 1: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest
	# 2: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files#cli-configure-files-where
	AWS_CONFIG_FILE="${XDG_CONFIG_HOME:-${HOME}/.config}/aws/config.ini"

	# The Kubernetes CLI, `kubectl`, loads its configuration from `${HOME}/.kube/config` by default. It can be made to follow the XDG Base Directory Specification[1] and load its configuration from `${XDG_CONFIG_HOME}` instead with the environment variable `KUBECONFIG`.
	# It can, in fact, load its configuration from multiple files, whereby "[t]he first file to set a particular value or map key wins", according to the documentation[2]. That makes it possible to keep configuration for different sites in separate files.
	# 1: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest
	# 2: https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/
	# Keep ~/.kube/config for system-specific configuration
	KUBECONFIG="${HOME}/.kube/config"
	KUBECONFIG+="$(
		find \
			"${XDG_CONFIG_HOME:-${HOME}/.config}/k8s/" \
			-type f \
			-name '*.yaml' \
			-printf ':%p' \
			#
	)"

	npm_config_userconfig="${XDG_CONFIG_HOME:-${HOME}/.config}/npm/npmrc"

	SSH_AUTH_SOCK="$(
		gpgconf \
			--list-dirs \
			-- \
			agent-ssh-socket \
			#
	)"

	export \
		-- \
		AWS_CONFIG_FILE \
		KUBECONFIG \
		npm_config_userconfig \
		SSH_AUTH_SOCK \
		#


	# User functions and aliases
	# These should be made available only to interactive sessions, because scripts usually should not rely on non-standard functionality.

	alias \
		-- \
		cp='cp --no-clobber' \
		grep='grep --color=auto' \
		jqless='qless jq' \
		ls='ls --color=auto' \
		yqless='qless yq' \
		#

	function evoila_Kostenabrechnung
	{
		declare \
			-r \
			-- \
			year="${1}" \
			month="${2}" \
			#
		pdfunite \
			-- \
			"${HOME}/documents/Arbeitgeber/evoila/Kostenabrechnungen/${year}/${month}/Abrechnung.pdf" \
			"${HOME}/documents/Arbeitgeber/evoila/Kostenabrechnungen/${year}/${month}/Beleg"-*.pdf \
			"${HOME}/documents/Arbeitgeber/evoila/Kostenabrechnungen/${year}/${month}.pdf" \
			#
	}

	function ggrep
	{
		grep \
			-i \
			-R \
			--exclude-dir .git \
			--exclude-dir .tup \
			--exclude-dir=node_modules \
			-C 3 \
			-- \
			"$1" \
			. \
			#
	}

	function GnuPG_publish
	{
		declare \
			-A \
			-- \
			keys=( \
				[own]=E0C3497126B72CA47975FC322953BB8C16043B43 \
				[evoila]=EA44799B216D935609758EA027630D6641272649 \
			) \
			#

		# Upload public keys to configured keyserver
		gpg \
			--send-keys \
			-- \
			${keys[@]} \
			#

		# Upload public keys to keys.openpgp.org
		for fingerprint in ${keys[@]}
		do
			{
				gpg \
					--export \
					-- \
					${fingerprint} \
					#
			} \
			|
			{
				curl \
					--upload-file - \
					-- \
					https://keys.openpgp.org/ \
					#
			}
		done

		# Upload public keys to GitHub
		for label in ${!keys[@]}
		do
			gh \
				gpg-key \
				delete \
				--yes \
				-- \
				${keys[${label}]: -16}
			{
				gpg \
					--export \
					--armor \
					-- \
					${keys[${label}]} \
					#
			} \
			|
			{
				gh \
					gpg-key \
					add \
					--title=${label} \
					#
			}
		done

		# TODO: gitlab.com
		# TODO: gitlab.freedesktop.org
		# TODO: Keybase
	}

	function mkcd
	{
		mkdir \
			--parents \
			-- \
			"$1" \
			#
		cd \
			-- \
			"$1" \
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
			--profile "${AWS_PROFILE:-${1}}" \
			sso \
			login \
			#
	}
fi
