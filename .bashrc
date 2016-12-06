# Functions declarations
#
function addCommitPush()
{
	git add .
	git commit -a -m "$1"
	git push
}

# Functions aliases
#
alias push-commit=addCommitPush

# GIT commands
#
alias init="git init"
alias clone="git clone"

alias master="git checkout master"

alias branch="git checkout"
alias new-branch="git checkout -B"

alias compare="git diff"
alias status="git status"

alias add="git add ."
alias commit="git commit -a -m"

alias hard-reset="git reset --hard"

alias pull="git pull"
alias push="git push"
alias push-new-branch="git push --set-upstream origin"
