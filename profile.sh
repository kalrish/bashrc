declare \
	-r \
	newline=$'\n' \
	profile="${1}" \
	term_reset="$(tput sgr0)" \
	term_typeface_bold="$(tput bold)" \
	#

declare \
	-r \
	-A \
	colors_foreground=(
		[blue]=4
		[dicky]=46
		[gray]=243
		[green]=2
		[lightblue]=51
		[orange]=208
		[red]=1
		[white]=255
	) \
	suggestions=(
		[sl]=ls
		[SL]=ls
		[GIT]=git
		[got]=git
	) \
	#


function command_available
{
	command -v -- "${1}" &> /dev/null
}


function declare_color_foreground
{
	declare \
		-r \
		-g \
		"term_color_foreground_${1}=$(tput setaf "${2}")" \
		#
}


function in_git_repo
{
	git \
		rev-parse \
		--is-inside-work-tree \
		&> /dev/null \
		#
}


function get_git_branch
{
	git \
		rev-parse \
		--symbolic-full-name \
		--abbrev-ref \
		HEAD \
		2> /dev/null \
		#
}


function update_git_branch
{
	if in_git_repo
	then
		branch="$(get_git_branch)"
	else
		unset \
			branch \
			#
	fi
}


last_cwd="${PWD}"
declare \
	-i \
	last_exit_code=0 \
	#

function prompt_command
{
	declare \
		-r \
		-i \
		exit_code="$?" \
		#

	if [[ ${PWD} != ${last_cwd} ]]
	then
		should_update_git_branch=y
		last_cwd="${PWD}"
	fi

	if [[ ${should_update_git_branch} = y ]]
	then
		update_git_branch
		should_update_git_branch=n
	fi

	PS1='\[${term_typeface_bold}${term_color_foreground_green}\]\u@\h\[${term_reset}\] \[${term_typeface_bold}${term_color_foreground_blue}\]\w\[${term_reset}\]'

	if [[ -v branch ]]
	then
		PS1+=' \[${term_typeface_bold}${term_color_foreground_red}\]${branch}\[${term_reset}\]'

		if [[ ${profile} == smaato ]]
		then
			if issue_sequence="$(gira_get_sequence "${branch}")"
			then
				PS1+=' \[${term_color_foreground_white}${issue_sequence}${term_reset}\]'
			fi
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
			exit_code_format="${term_color_foreground_green}"
		else
			exit_code_format="${term_typeface_bold}${term_color_foreground_red}"
		fi
	fi

	PS1+='\n\[${term_typeface_bold}${term_color_foreground_orange}\]\A\[${term_reset}\] \[${exit_code_format}\]${exit_code_padded}\[${term_reset}\] \[${term_typeface_bold}${term_color_foreground_blue}\]\$\[${term_reset}\] '
}


function trap_debug
{
	if [[ ${BASH_COMMAND} =~ ^[[:space:]]*git[[:space:]][[:space:]]*checkout[[:space:]].*$ ]]
	then
		should_update_git_branch=y
	fi
}


function command_not_found_handle
{
	declare \
		-r \
		cmd="${1}" \
		#

	{
		echo "${term_color_foreground_red}${cmd}${term_reset}: command not found"
		if [[ -v suggestions[${cmd}] ]]
		then
			suggestion="${suggestions[${cmd}]}"
			echo "Maybe you meant ${term_typeface_bold}${term_color_foreground_green}${suggestion}${term_reset} instead"
			declare tildes=''
			for (( i=0 ; i < ${#suggestion} ; ++i ))
			do
				tildes="${tildes}^"
			done
			echo "                ${tildes}"
		fi
	} >&2

	return 127
}


function setup_common
{
	:
}


function setup_smaato
{
	PATH="${HOME}/.local/bin:${PATH}"

	if command_available ponysay
	then
		ponysay -f raccoon "${term_typeface_bold}${term_color_foreground_blue}Otto${term_reset} ~ ${term_typeface_bold}${term_color_foreground_lightblue}ponies and raccoons${term_reset} ~ all hail the ${term_typeface_bold}${term_color_foreground_dicky}dickbird${term_reset}${newline}sand ${term_typeface_bold}${term_color_foreground_red}sharks${term_reset}, mountain ${term_typeface_bold}${term_color_foreground_red}sharks${term_reset}, snow ${term_typeface_bold}${term_color_foreground_red}sharks${term_reset}, atomic ${term_typeface_bold}${term_color_foreground_red}sharks${term_reset}"
	fi

	source ~/dev/personal/gira/gira.sh
}


function setup
{
	for name in "${!colors_foreground[@]}"
	do
		declare_color_foreground "${name}" "${colors_foreground[${name}]}"
	done

	setup_common

	case "${profile}" in
		smaato)
			setup_smaato
			;;
	esac

	complete -C aws_completer aws

	update_git_branch

	trap trap_debug DEBUG

	PROMPT_COMMAND=prompt_command

	PS2='\[${term_color_foreground_gray}\]>\[${term_reset}\] '
}


setup


function ggrep
{
	grep \
		-i \
		-R \
		--exclude-dir .git \
		-- \
		"$1" \
		. \
		#
}
