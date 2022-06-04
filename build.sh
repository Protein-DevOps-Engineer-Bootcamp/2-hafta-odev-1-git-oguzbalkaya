#! /bin/bash
#########################
## Author : Oguz BALKAYA <oguz.balkaya@gmail.com>
## Description : This script takes some parameters from the user and build the application. 
## Date : 02-06-2022
## Version : 1.0
#########################

#Base directory of the script
SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")


#Import configurations
source "$BASEDIR/build.conf"


usage(){
	#This function shows usage of the script.
	echo "Usage:"
	echo "     -b <branch_name>    Branch name(default=Current branch)"
	echo "     -n <new_branch>     Create a new branch"
	echo "     -f <zip|tar>        Compress format tar=tar.gz, zip=zip (default=tar)"
	echo "     -p <artifact_path>  Copy artifact to specific path(default=current directory)"
	echo "     -d <false|true>     Debug mode (default=false)"
	echo "     -s <false|true>     Skip test (default=false)"
	echo "     -r <false|true>     Remove target directory after compressing."
	exit 1
}


does_branch_exist(){
        #This function checks if branch is exist or not.
        branch=`git branch --list $1`
        if [[ $branch ]]
        then
                #Branch exists
                return 1
        else
                #Branch does not exist
                return 0
        fi
}


check_compress_format(){
	#This function checks compression format.It can be zip or tar.
	if [[ "$1" != "tar" ]] && [[ "$1" != "zip" ]]
	then
		echo "Compress format(-f) must be tar or zip"
		exit 1
	fi
}

check_remove_target_dir(){
	#This function checks -r flag.It can be true or false.
	if [[ "$1" != "true" ]] && [[ "$1" != "false" ]]
	then
		echo "Remove target dir(-r) must be true or false"
		exit 1
	fi
}

check_debug_mode(){
	#This function checks debug mode. It can be false or true.
	if [[ "$1" != "false" ]] && [[ "$1" != "true" ]]
	then
		echo "Debug mode(-d) must be false or true"
		exit 1
	fi
}

check_skip_test(){
	#This function checks skip_test parameter.It can be false or true.
	if [[ "$1" != "false" ]] && [[ "$1" != "true" ]]
	then
		echo "Skip test(-s) must be false or true"
		exit 1
	fi
}	

create_branch(){
	#This function creates branch.
	standart_output=`git branch $1 2>&1`
	if [[ $standart_output = "" ]]
	then
		echo "Branch \"$1\" created."
	else
		echo $standart_output
	fi
}

check_branch_name(){
	#This function checks branch name.There is a list of important branch names in configuration file.
	#Checks if the given branch is in the list.
	#Also it checks if branch exists or not.
	for i in "${IMPORTANT_BRANCHES[@]}"
	do
		if [[ "$1" = "$i" ]]
		then
			echo "[WARNING] You are building $1 branch.."
		fi
	done
	
	does_branch_exist $1

	if [[ "$?" = "0" ]]
	then
		echo "Branch \"$branch_name\" not found. Creating..."
		create_branch $branch_name
	fi
}

check(){
	#This function checks parameters.

	#If remove target directory(-r) flag was written, set it false.
	if [[ -z "$remove_target_dir" ]]
	then
		remove_target_dir="false"
	else
		check_remove_target_dir $remove_target_dir
	fi	

	#If n flag was written, create branch
	if [[ -n "$new_branch_name" ]]
	then
        	create_branch $new_branch_name
		exit 1
	fi

	#If debug mode was not written, set it false. If it was written, check it.It can be false or true.
	if [[ -z "$debug_mode" ]]
	then
        	debug_mode="false"
	else
        	check_debug_mode $debug_mode
	fi


	#If skip parameter was not written, set it false.If it was written, check it. It can be false or true.
	if [[ -z "$skip_test" ]]
	then
		skip_test="false"
	else
		check_skip_test $skip_test
	fi

	#Check compression format.If it was not written, set it tar.If it was written, check it.It can be true or false.
	if [[ -z "$format" ]]
	then
		format="tar"
	else
        	check_compress_format $format
	fi

	#Check branch name.If it was not written, set it current branch. If it was written, check it.
	if [[ -z "$branch_name" ]]
	then
		current_branch=`git branch | sed -n -e 's/^\* \(.*\)/\1/p'`
		branch_name=$current_branch
	else
        	check_branch_name $branch_name
	fi

	#Check artifact path.If it was not written, set it current directory.
	if [[ -z "$artifact_path" ]]
	then
        	artifact_path=`pwd`
	fi

}


build(){
	#This function sets maven parameters and build the application.

	#If debug mode is true, add -X flag. 
	if [[ "$debug_mode" = "true" ]]
	then
		BUILD_COMMAND+=" -X"
	fi

	#If skip_test is true, add -Dmaven.test.skip
	if [[ "$skip_test" = "true" ]]
	then
		BUILD_COMMAND+=" -Dmaven.test.skip"
	fi

	#get current branch
	current_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
	#If current branch is not equel branch_name, change branch to branch_name
	if [[ "$current_branch" !=  "$branch_name" ]]
	then
		git checkout $branch_name
	fi

	#build the application with maven
	echo "Build..."
	eval "$BUILD_COMMAND"
	echo "Build finished."
	
	#If target directory was created, create archive file
	echo "Compress..."
	target_directory="$BASEDIR/target/"
	if [[ -d "$target_directory" ]]
	then
		if [[ "$format" = "tar" ]]
		then
			#Format is tar.
			file_name="$branch_name.tar.gz"
			cd $target_directory
			tar -czf  $file_name *
			mv $file_name $artifact_path
			cd -
		else
			#Format is zip.
			file_name="$branch_name.zip"
			cd $target_directory
			zip  $file_name *
			mv $file_name $artifact_path
			cd -
			pwd
		fi
		echo "Archive created."

		if [[ "$remove_target_dir" = "true" ]]
		then
			echo "Deleting the target directory..."
			rm -r $target_directory
			echo "Deleted."
		fi

	else
		echo "target directory not found."
	fi
	
	
}

#build.sh --help 
if [[ "$1" == "--help" ]]
then
	usage
	exit 1
fi



parameters_list=":n:b:f:d:p:s:r:" 
while getopts ${parameters_list} OPTS;
do
	case "${OPTS}" in
		n)
                        new_branch_name=${OPTARG}
			;;
		
		b)
			branch_name=${OPTARG}
			;;
		f)
			format=${OPTARG}
			;;
		d)
			debug_mode=${OPTARG}
			;;
		p)
			artifact_path=${OPTARG}
			;;
		s)
			skip_test=${OPTARG}
			;;
		r)	
			remove_target_dir=${OPTARG}
			;;
		?)
			echo "Invalid parameter"
			usage
	esac
done

check
build


