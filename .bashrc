# Functions declarations
#
function addCommitPush()
{
	git add .
	git commit -a -m "$1"
	git push
}

# TODO: Terminare e migliorare l'implementazione della funzione seguente...
#
# function resetByRemote()
# {
#     git fetch --all
#     git reset --hard origin/master

#     # if (($1 == "") && ($2 == ""))
#     # {
#     #     git reset --hard $1/$2
#     # }
# }

# Functions aliases
#
alias push-commit=addCommitPush

# GIT commands
#
alias init="git init"
alias clone="git clone"
alias fetch="git fetch --all"

alias master="git checkout master"

alias branch="git checkout"
alias new-branch="git checkout -B"

alias compare="git diff"
alias merge="git merge"
alias status="git status"

alias add="git add ."
alias commit="git commit -a -m"

alias hard-reset="git reset --hard"

alias pull="git pull"
alias push="git push"
alias push-new-branch="git push --set-upstream origin"
