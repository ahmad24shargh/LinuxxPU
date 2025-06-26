#!/usr/bin/env bash
echo "inside $0"
#C_VERSION=$1
#C_LAST_COMMIT=$2
#C_TAG_NAME=$3
echo "C_TAG_NAME=${C_TAG_NAME}"
echo "C_LAST_COMMIT=${C_LAST_COMMIT}"
echo "C_VERSION=${C_VERSION}"
for file in $(grep -R --exclude='.github' --exclude='.git' $GITHUB_WORKSPACE -e 'let version_code' 2>/dev/null | cut -d':' -f 1 | sort | uniq);do [ "$file" != "$0" ] && sed -E -i 's|(let version_code)(.*=.+\+.+)version_code(.+)|\1\2'${C_VERSION}'\3|g' $file;done
for file in $(grep -R --exclude='.github' --exclude='.git' $GITHUB_WORKSPACE -e 'let version_name' 2>/dev/null | cut -d':' -f 1 | sort | uniq);do [ "$file" != "$0" ] && sed -E -i 's|(let version_name = )version_name(\.trim.+)|\1"'${C_TAG_NAME}'"\2|g' $file;cat $file | grep  'let version_';done
#for file in $(grep -RE --exclude='.github' --exclude='.git' $GITHUB_WORKSPACE -e 'KSU_(GIT|LOCAL|GITHUB)_VERSION' 2>/dev/null | cut -d':' -f 1 | sort | uniq);do [ "$file" != "$0" ] && sed -E -i 's|(KSU_[^[:space:]]+_VERSION \:=).+|\1 '${C_VERSION}'|g' $file;cat $file | grep -E 'KSU_(GIT|LOCAL|GITHUB)_VERSION';done
for file in $(grep -R --exclude='.github' --exclude='.git' $GITHUB_WORKSPACE -e 'return.*commitCount' 2>/dev/null | cut -d':' -f 1 | sort | uniq);do [ "$file" != "$0" ] && sed -E -i 's|(return.+\+.+)commitCount(.+)|\1'${C_VERSION}'\2|g' $file;done
for file in $(grep -R --exclude='.github' --exclude='.git' $GITHUB_WORKSPACE -e 'return getGitDescribe()' 2>/dev/null | cut -d':' -f 1 | sort | uniq);do [ "$file" != "$0" ] && sed -i 's|return getGitDescribe()|return "'${C_TAG_NAME}'"|g' $file;cat $file | grep  'return';done

          
