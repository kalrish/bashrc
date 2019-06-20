PATH="${HOME}/.local/bin:${PATH}"
export GPG_TTY="$(tty)"

declare \
	-r \
	newline=$'\n' \
	term_color_blue="$(tput setaf 4)" \
	term_color_dicky="$(tput setaf 46)" \
	term_color_gray="$(tput setaf 243)" \
	term_color_green="$(tput setaf 2)" \
	term_color_lightblue="$(tput setaf 51)" \
	term_color_orange="$(tput setaf 208)" \
	term_color_red="$(tput setaf 1)" \
	term_reset="$(tput sgr0)" \
	term_typeface_bold="$(tput bold)" \
	#

if command -v -- ponysay &> /dev/null
then
	ponysay -f raccoon "${term_typeface_bold}${term_color_blue}Otto${term_reset} ~ ${term_typeface_bold}${term_color_lightblue}ponies and raccoons${term_reset} ~ all hail the ${term_typeface_bold}${term_color_dicky}dickbird${term_reset}${newline}sand ${term_typeface_bold}${term_color_red}sharks${term_reset}, mountain ${term_typeface_bold}${term_color_red}sharks${term_reset}, snow ${term_typeface_bold}${term_color_red}sharks${term_reset}, atomic ${term_typeface_bold}${term_color_red}sharks${term_reset}"
fi

source ~/dev/gira/gira.sh

function prompt_command
{
	declare \
		-r \
		-i \
		exit_code="$?" \
		#
	
	PS1='\[${term_typeface_bold}${term_color_green}\]\u@\h\[${term_reset}\] \[${term_typeface_bold}${term_color_blue}\]\w\[${term_reset}\]'
	
	if git rev-parse --is-inside-work-tree &> /dev/null
	then
		branch="$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)"
		
		PS1+=' \[${term_color_red}\]${branch}\[${term_reset}\]'
		
		if issue_sequence="$(gira_get_sequence "${branch}")"
		then
			PS1+=' \[${issue_sequence}\]'
		fi
	fi
	
	printf \
		-v exit_code_padded \
		'%3i' \
		${exit_code} \
		#
	
	case ${exit_code} in
		0)
			exit_code_format="${term_color_green}"
			;;
		*)
			exit_code_format="${term_typeface_bold}${term_color_red}"
			;;
	esac
	
	PS1+='\n\[${term_typeface_bold}${term_color_orange}\]\A\[${term_reset}\] \[${exit_code_format}\]${exit_code_padded}\[${term_reset}\] \[${term_typeface_bold}${term_color_blue}\]\$\[${term_reset}\] '
}

PROMPT_COMMAND=prompt_command

PS2='\[${term_color_gray}\]>\[${term_reset}\] '

#function cd
#{
#	if [[ -d "${1}/.git" ]]
#	then
#		branch="$(
#			git \
#				-C "${1}" \
#				rev-parse \
#				--symbolic-full-name \
#				--abbrev-ref \
#				HEAD \
#				#
#		)"
#	else
#		unset \
#			-v \
#			branch \
#			#
#	fi
#	builtin cd "$@"
#}

declare \
	-A \
	suggestions \
	#

suggestions[sl]=ls
suggestions[SL]=ls
suggestions[GIT]=git

function command_not_found_handle
{
	declare \
		-r \
		cmd="${1}" \
		#

	{
		echo "${term_color_red}${cmd}${term_reset}: command not found"
		if [[ -v suggestions[${cmd}] ]]
		then
			suggestion="${suggestions[${cmd}]}"
			echo "Maybe you meant ${term_typeface_bold}${term_color_green}${suggestion}${term_reset} instead"
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
