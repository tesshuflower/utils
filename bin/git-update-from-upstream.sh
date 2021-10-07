if [ ! -f ./git/hooks/commit-msg ]; then
    ln -sf ${MY_TOOLS_DIR}/git/hooks/commit-msg ./.git/hooks/commit-msg
fi

git fetch upstream

branch=$1

if [ "$branch" == "" ]; then
    branch="main"
fi

git checkout ${branch}
if [ $? -ne 0 ]; then
    exit 1
fi

git pull upstream ${branch}
if [ $? -ne 0 ]; then
    exit 1
fi

git push
