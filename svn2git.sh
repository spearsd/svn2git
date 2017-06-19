#!/bin/bash

REPO_ARG=""
REPO_LIST=""

installPrereqs() {
	yum install -y git-all
	if ! $(hash git 2>/dev/null); then
		echo "installing git-all..."
		yum install -y git-all
		if ! $(hash git 2>/dev/null); then
			echo "Unable to install git-all! Exiting..."
			exit 1
		fi
	fi
	if ! $(hash svn 2>/dev/null); then
		echo "installing subversion..."
		yum install -y subversion
		if ! $(hash svn 2>/dev/null); then
			echo "Unable to install subversion! Exiting..."
			exit 1
		fi
	fi
	if ! $(hash perl 2>/dev/null); then
		echo "installing perl..."
		yum install -y perl
		if ! $(hash perl 2>/dev/null); then
			echo "Unable to install perl! Exiting..."
			exit 1
		fi
	fi
}

# example function to parse a file storing each
# line into an array
createArray() {
    local array=() # Create local var array
    while IFS= read -r line # Read a line
    do
        local array+=("$line") # Append line to the array
    done < "$1"
}

# example of how to use the getArray function
array=$(createArray "file.txt")
array2=$(createArray "authors.txt")
for e in "${array[@]}"
do
    echo "$e"
done

# example of how to parse a "-r <option>" passed argument
while getopts ":r:" opt; do
  case $opt in
    a)
      echo "-r was triggered, Parameter: $OPTARG" >&2
	  # REPO_ARG=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# only used if authors list is needed.
svnCloneList() {
	REPO_LIST=$(createArray "$REPO_ARG")
	for r in "${REPO_LIST[@]}"
	do
		svn co $r
		svn log --xml --quiet | grep author | sort -u | perl -pe 's/.*>(.*?)<.*/$1 = /' >> authors.txt
	done
}

gitCloneList() {
	REPO_LIST=$(createArray "$REPO_ARG")
	for r in "${REPO_LIST[@]}"
	do
		local repo_name=$(echo "$r" | rev | cut -d '/' -f 1 | rev)
		git svn clone $r --authors-file=authors.txt --no-metadata --prefix"" -s $repo_name
		local branches=$(git branch -r)
		branch_array=$(createArray "branches")
		# only for loop when the branch doesn't begin with tag
		for b in "${branch_array[@]}"
		do
			git checkout -b $b $b
		done
	done
}

# loop over an svn repo list array from file
# then need to pull out repository name here using grep?
# clone svn repo
svn co http://url.to.svnRepo/repo

# List author names from svn commits within cloned svn repo  
# (Pulls commit logs, strips out author, sorts and removes xml tags).
svn log --xml --quiet | grep author | sort -u | perl -pe 's/.*>(.*?)<.*/$1 = /' >> users.txt

# once getArray has pulled in an svn authors array (users.txt) and
# the known svn = git authors array, compare and add to a new file
# svn_username (from users.txt) = Git_firstName Git_LastName <Git_user@email.com> (from known git authors array)
# if user exists in users.txt

# Initiate new git repo from existing svn repo, adding in authors file  
# (Checking on how to handle metadata, will probably change).
git svn clone http://url.to.svnRepo/repo --authors-file=/path/to/users.txt --no-metadata --prefix"" -s nameOfGitRepo

# lists exisiting remote branches
git branch -r

# checkout each branch returned from git branch -r
git checkout -b local_branch remote_branch

# create repo within project in bitbucket.
# to create a project: json needs name, key, description.
curl -D- -u user:password -X POST -d @/path/to/test.json -H "Content-Type: application/json" http://url.to.bitbucket/rest/api/1.0/projects/
# to create repo: json needs name, has_wiki, is_private, and project with sub-info key.
curl -D- -u user:password -X POST -d @/path/to/test.json -H "Content-Type: application/json" http://url.to.bitbucket/rest/api/1.0/projects/PROJECT_KEY/repos


#Within nameOfGitRepo remote new git repo to Bitbucket.
# use REST API to create repo/project
git remote add origin http://url.to.Bitbucket/scm/projectCode/repoName.git
git push -u origin all
# another git push for tags

# svn > git > pull all branches > clone old git into new git > push to bitbucket

installPrereqs()