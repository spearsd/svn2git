#!/bin/bash

# install all prereqs needed
yum install -y git-all subversion perl

# true if git-all is installed
if hash git-all 2>/dev/null; then

# example function to parse a file storing each
# line into an array
createArray() {
    local array=() # Create array
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

# example of how to parse a "-a <option>" passed argument
while getopts ":a:" opt; do
  case $opt in
    a)
      echo "-a was triggered, Parameter: $OPTARG" >&2
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

#Within nameOfGitRepo remote new git repo to Bitbucket.
git remote add origin http://url.to.Bitbucket/scm/projectCode/repoName.git
git push -u origin master

# svn > git > pull all branches > clone old git into new git > push to bitbucket