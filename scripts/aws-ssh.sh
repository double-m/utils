#!/bin/bash

REGION="eu-west-1"
IDENTITY_FILE=~/.ssh/MYFILE.pem
AWS_EC2_COMMAND=`which ec2-describe-instances`
SSH_DEFAULT_USER='ec2-user'

if test ! -r "$IDENTITY_FILE"; then
        echo
	if test ${#IDENTITY_FILE} -eq 0; then
		echo "Error: variable 'IDENTITY_FILE' not set."
	else
		echo "Error: identity file '$IDENTITY_FILE' not found or not readable."
	fi
	echo "Edit '$0' (this script) and set 'IDENTITY_FILE' correctly."
	echo
        exit 1
fi

if test ! -x "$AWS_EC2_COMMAND"; then
	echo
	echo "Error: command '$AWS_EC2_COMMAND' not found or not executable."
	echo "Install the 'Amazon EC2 Command Line Interface Tools'."
	echo
	exit 1
fi

do_ssh() {
	SSHUSER=$SSH_DEFAULT_USER
	SSHUSERECHO=''
	if test "x$2" != "x"; then
		SSHUSER=$2
		SSHUSERECHO=" and user=$SSHUSER"
	fi
	echo
	echo "Connecting to AWS instance having name=$1$SSHUSERECHO..."
	server_ip=`$AWS_EC2_COMMAND --region $REGION --filter "tag-value=$1" | grep NICASSOCIATION | awk '{print $2}' 2>&1`

	if [[ "$server_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		command="ssh -i $IDENTITY_FILE $SSHUSER@$server_ip"
		echo $command
		$command
		test $? -eq 0 && exit 0
		do_describe
	fi

	if test "x$server_ip" == "x"; then
		do_describe
		exit 1
	fi

	exit 1
}

do_describe() {
	this_basename=`basename $0`
	echo
	echo "Usage: $this_basename INSTANCE_NAME [ SSH_USER ]"
	echo
	echo "INSTANCE_NAME"
	echo -n "loading... "
	instance_list=`$AWS_EC2_COMMAND --region $REGION | grep TAG | grep Name | grep -v AWSEBAutoScalingGroup | awk '{print $5}'`
	for i in $instance_list; do
		echo -e "\e[0K\r - $i"
	done
	echo
}

case $# in
	1|2) do_ssh $@;;
	*) do_describe;;
esac

