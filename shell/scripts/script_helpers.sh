#!/bin/bash

# Usage: out_message message [spaces_before] [spaces_after]
out_message() {
	message=$1
	if test "$#" -gt 2; then
		spaces_after=$3
		spaces_before=$2
	elif test "$#" -eq 2; then
		spaces_after=1
		spaces_before=$2
	else
		spaces_after=1
		spaces_before=1
	fi

	# spaces before
	out_message_repeat $spaces_before

	# body
	echo -e "${message}"

	# spaces after
	out_message_repeat $spaces_after
}

# Usage: out_message_title message [default=blue|green|red]
out_message_title() {
	local title_msg=$1;
	if test "$#" -gt 1; then
		local title_color="$2";
	else
		local title_color="blue";
	fi
	local title=`color_string "${title_color}" "${title_msg}"`;
	out_message "${title}";
}

# Usage: out_message_repeat n_repeat [default=""|repeated_message]
out_message_repeat() {
	if test "$#" -gt 1; then
		repeated_message=$2
	elif test "$#" -eq 1; then
		repeated_message=""
	else
		exit 1;
	fi	
	n_repeat=$1
	while [ $n_repeat -gt 0 ]; do
		echo $repeated_message
		let n_repeat-=1
	done
}

# Exit writing a message (if specified)
exit_with_error() {
	if [ "$1" != "" ]; then out_message "$1"; fi
	exit 1;
}

# Usage: substring_in_file source dest file
substring_in_file() {
	local source=$1;
	local dest=$2;
	local file=$3;
	sed -i -e "s/$source/$dest/" $file
}

# Usage: copy_script_with_underscore_path _path_file
copy_script_with_underscore_path() {
	source=$1;
	local basename=`basename $source`
	dirname=`dirname $source`
	dest=`echo $basename | sed -e "s/_/\//g"`;
	cp $source $dest;
	chmod 755  $dest;
}

# Usage: color_string color string
color_string() {
	str_color=$1
	str_body=$2
	if test "${str_color}" = "green"; then
		echo "\e[00;32m${str_body}\e[00m"
	elif test "${str_color}" = "red"; then
		echo "\e[00;31m${str_body}\e[00m"
	elif test "${str_color}" = "blue"; then
		echo "\e[00;34m${str_body}\e[00m"
	else
		echo ${str_body}
	fi
}

# Usage: find_command_list_or_exit "command1 [command2 [...]]"
# (no argument means ok)
find_command_list_or_exit() {
	local command_lst="$1";
	for cmd in $command_lst; do
		command -v $cmd > /dev/null
		if test $? -eq 0; then
			green_found=`color_string green found`
			out_message "command '$cmd'... $green_found" 0 0
		else
			red_not_found=`color_string red "not found"`
			out_message "command '$cmd'... $red_not_found"
			exit_with_error "Exiting..."
		fi
	done
}

# Usage: mandatory_file_or_dir_list fileordir1 [fileordir2 ...]
# (no argument means ok)
mandatory_file_or_dir_list() {
	local fileordir_list="$@";
	result=`find_file_or_dir_list $fileordir_list`
	test $? -eq 2 && exit_with_error "Exiting..."
	exit 0
}

# Usage: prohibited_file_or_dir_list fileordir1 [fileordir2 ...]
# (no argument means ok)
prohibited_file_or_dir_list() {
	local fileordir_list="$@";
	result=`find_file_or_dir_list $fileordir_list`
	test $? -eq 1 && exit_with_error "Exiting..."
	exit 0
}

# Helper function for the previous two (the last part is bad)
find_file_or_dir_list() {
	local fileordir_list="$@";
	local result='';

	for fileordir in $fileordir_list; do
		if test -d "$fileordir" || test -f "$fileordir"; then
			green_found=`color_string red found`
			out_message "file or directory '$fileordir'... $green_found" 0 0
			result='at_least_one_present';
		else
			red_not_found=`color_string green "not found"`
			out_message "file or directory '$fileordir'... $red_not_found" 0 0
			result='at_least_one_missing';
		fi
	done

	if test $result == 'at_least_one_present'; then
		exit 1;
	elif test $result == 'at_least_one_missing'; then
		exit 2;
	else
		exit 0;
	fi
}

#Usage: backup_file filename
backup_file() {
	filename="$1"
	cp -a $filename $filename.bak.`date '+%Y%m%d-%H%M%S'` > /dev/null
}

getUniqueNameBasedOnProjectName() {
	basenameSegmant=`basename $0`
	randomSegment=`getRandomNumber`
	echo "${basenameSegmant}.${randomSegment}"
}

getRandomNumber() {
	echo $RANDOM
}

createTmpDir() {
	newTmpDir="/tmp/"`getUniqueNameBasedOnProjectName`
	mkdir "${newTmpDir}"
	echo "${newTmpDir}"
}

checkArguments() {
while test $# -gt 0
do
    case "$1" in
        --?*=*) fooArg=`echo $1 | sed -e 's/--//' | sed -e 's/=.*//'`
				fooVal=`echo $1 | sed -e 's/--.*=//'`
				eval $fooArg="${fooVal}"
            ;;
        *) return 1
            ;;
    esac
    shift
done
return 0
}
