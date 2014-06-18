############################################################################
#
# Unit Test Function Definitions
#
############################################################################

shuSetUp() {
	message="test_message"
	thisBaseName=`basename $0`
	thisDirName=`dirname $0`

	. $thisDirName/../scripts/script_helpers.sh

	sourceFile=/tmp/$thisBaseName.$RANDOM
	sourceString="string to be changed"
	echo "dummy line" > $sourceFile
	echo "${sourceString}" >> $sourceFile # first line to be matched
	echo "dummy line" >> $sourceFile
	echo "${sourceString}" >> $sourceFile # second line to be matched
	echo "${sourceString}" >> $sourceFile # third line to be matched
	echo "dummy line" >> $sourceFile
}

shuTearDown() {
	rm -f $sourceFile
}

TestExitWithErrorShouldReturnErrorCode() {
	retVal1=`exit_with_error`
	test $? -ne 0
	shuAssert "Exit value '$?' != '0'" $?

	retVal2=`exit_with_error $message`
	test $? -ne 0
	shuAssert "Exit value '$?' != '0'" $?
}

TestExitWithErrorShouldReturnErrorMessage() {
	retVal=`exit_with_error $message`
	echo $retVal | grep $message > /dev/null
	test $? -eq 0
	shuAssert "Exit message should contain '$message'" $?
}

TestSubstringInFileShouldChangeMultipleStringInAFile() {
	substring_in_file "to be" "has been" $sourceFile
	destString="string has been changed"
	countNewStrings=`grep -c "${destString}" $sourceFile`;
	countExpectedStrings=3;
	test $countNewStrings -eq $countExpectedStrings
	shuAssert "Changed string are '$countNewStrings', '$countExpectedStrings' expected" $?
}

TestCopyScriptWithUnderscorePathShouldChangeUnderscoresInSlashes() {
	pathSegment0="tmp"
	pathSegment1=`echo $thisBaseName.$RANDOM | sed -e 's/_//g'`
	pathSegment2=$RANDOM
	pathSegment3=$RANDOM
	scriptName="script.sh"

	sourceFileUnd="/${pathSegment0}/_${pathSegment0}_${pathSegment1}_${pathSegment2}_${pathSegment3}_${scriptName}"
	touch $sourceFileUnd
	expectedFilePath="/${pathSegment0}/${pathSegment1}/${pathSegment2}/${pathSegment3}"
	expectedFile="${expectedFilePath}/${scriptName}"
	mkdir -p $expectedFilePath

	copy_script_with_underscore_path $sourceFileUnd

	file $expectedFile > /dev/null
	test $? -eq 0
	shuAssert "Copying '$sourceFileUnd' to '$expectedFile'" $?

	test -x $expectedFile
	shuAssert "'$expectedFile' is not executable" $?

	rm $sourceFileUnd
	rm -rf "/${pathSegment0}/${pathSegment1}"
}

TestCheckCommandExistsShouldSuccedForExistingCommands() {
	commandList="sh ls"
	retVal=`find_command_list_or_exit "${commandList}"`
	test $? -eq 0
	shuAssert "If '$commandList' are present in this system, should return 0" $?
}

TestCheckCommandExistsShouldExitWithErrorForUnknownCommands() {
	commandList="foobarfoo barfoobar"
	retVal=`find_command_list_or_exit "${commandList}"`
	test $? -ne 0
	shuAssert "If one of '$commandList' is absent from this system, should exit with error" $?
}

TestCheckDirectoryExistsShouldSuccedForExistingDirs() {
	tmpfile="/tmp/${RANDOM}${RANDOM}${RANDOM}"
	touch "${tmpfile}"
	directoryList="/home /tmp $tmpfile"
	retVal=`mandatory_file_or_dir_list $directoryList`
	test $? -eq 0
	shuAssert "If '$directoryList' are present in this system, should return 0" $?
	rm "${tmpfile}"
}

TestCheckDirectoryExistsShouldExitWithErrorForUnknownDirs() {
	directoryList="/foobar /barfoo"
	retVal=`mandatory_file_or_dir_list $directoryList`
	test $? -ne 0
	shuAssert "If '$directoryList' are absent in this system, should return 0" $?
}

TestCheckFileOrDirectoryMusntExistShouldSuccedForNotExistingFilesOrDirs() {
	fileOrDirectoryList="/foobar /barfoo"
	retVal=`prohibited_file_or_dir_list ${fileOrDirectoryList}`
	test $? -eq 0
	shuAssert "If one '$fileOrDirectoryList' is present in this system, should exit with error" $?
}

TestCheckFileOrDirectoryMusntExistExistsShouldExitWithErrorForAlLeastOneExistingFileOrDir() {
	fileOrDirectoryList="/foobar /home"
	retVal=`prohibited_file_or_dir_list ${fileOrDirectoryList}`
	test $? -ne 0
	shuAssert "If one of '$fileOrDirectoryList' is absent from this system, should exit with error" $?
}

TestGenerateUniqueNameBasedOnProjectName() {
	# mocking getRandomNumber()
	mockedRandomNumber="12345"
	getRandomNumber() {
		echo "${mockedRandomNumber}"
	}
	expectedUniqueName="test_script_helpers.sh.${mockedRandomNumber}";
	retVal=`getUniqueNameBasedOnProjectName`
	test "${retVal}" == "${expectedUniqueName}"
	shuAssert "Expected ${expectedUniqueName}, but was ${retVal}." $?
}

# depends on the previous test
TestCreateTmpDirWithAUniqueNameBasedOnProjectName() {
	# mocking getRandomNumber()
	mockedRandomNumber="12345"
	getRandomNumber() {
		echo "${mockedRandomNumber}"
	}
	expectedUniqueName="/tmp/test_script_helpers.sh.${mockedRandomNumber}";
	retVal=`createTmpDir`
	test -d "${retVal}"
	shuAssert "The directory ${retVal} has not been created." $?
	test "${retVal}" == "${expectedUniqueName}"
	shuAssert "Expected ${expectedUniqueName}, but was ${retVal}." $?
	rm -rf "${newTmpDir}"
}

TestShouldCheckArgumentsAndReturnZeroIfNoArguments() {
	checkArguments
	shuAssert "Should return '0' if no arguments." $?
}

TestShouldCheckArgumentsAndReturnErrorIfWrongArguments() {
	checkArguments -arg1=val1
	test $? == 1
	shuAssert "Should return '0' if wrong arguments." $?
}

TestShouldCheckArgumentsAndReturnZeroIfCorrectArguments() {
	checkArguments --arg1=val1 --arg2=val2
	shuAssert "Should return '0' if no arguments." $?
}

TestShouldCheckArgumentsAndReturnTheirValues() {
	checkArguments --arg1=val1 --arg2=val2
	test "${arg1}" == "val1"
	shuAssert "Expected arg1='val1', but the value was '${arg1}'." $?
	test "${arg2}" == "val2"
	shuAssert "Expected arg2='val2', but the value was '${arg2}'." $?
}

############################################################################
#
# Main program
#
############################################################################
PROGNAME=${0}
HELPNAME=${SHUNIT_HOME}/man.pod

# set your shell, if not already  done.
# SHELL=bash
SHELL=`ps -p $$ | tail -1  | awk '{print $NF}'`

if [ -z "${SHUNIT_HOME}" ]; then
	echo "Please set env <SHUNIT_HOME> !"
	exit 1
fi
 
# If the Script Source under test is in a different file, specify it here:
ThisBaseName=`basename $0`
SourceToTest=../scripts/${ThisBaseName:5}

# import the sh unit runtime functions
. ${SHUNIT_HOME}/shUnitRT 

# start the test 
# will collect all functions, starting with "Test"  and execute them
main_test $@

# Thats all.

