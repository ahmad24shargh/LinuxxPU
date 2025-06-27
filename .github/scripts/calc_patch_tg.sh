#!/usr/bin/env bash
echo "inside $0"
#C_VERSION=$1
#C_LAST_COMMIT=$2
#C_TAG_NAME=$3
echo "C_TAG_NAME=${C_TAG_NAME}"
echo "C_LAST_COMMIT=${C_LAST_COMMIT}"
echo "C_VERSION=${C_VERSION}"
if [ -f ${GITHUB_WORKSPACE}/TAG_NAME.ME ];then
  for file in $(grep -R --exclude='.github' --exclude='.git' $GITHUB_WORKSPACE -e 'let version_name' 2>/dev/null | cut -d':' -f 1 | sort | uniq);do [ "$file" != "$0" ] && sed -E -i 's|(let version_name = )version_name(\.trim.+)|\1"'$(cat ${GITHUB_WORKSPACE}/TAG_NAME.ME)'"\2|g' $file;cat $file | grep  'let version_';done
  for file in $(grep -R --exclude='.github' --exclude='.git' $GITHUB_WORKSPACE -e 'return getGitDescribe()' 2>/dev/null | cut -d':' -f 1 | sort | uniq);do [ "$file" != "$0" ] && sed -i 's|return getGitDescribe()|return "'$(cat ${GITHUB_WORKSPACE}/TAG_NAME.ME)'"|g' $file;cat $file | grep  'return';done
  if [ -f "${GITHUB_WORKSPACE}/manager/build.gradle.kts" ];then
    ksu_fork=$(cat "${GITHUB_WORKSPACE}/LPU_FORK.ME")
    # S1NVTg== = KSUN
    # U1VLSVNV = SUKISU
    echo $ksu_fork
    if [ "${ksu_fork}" == 'S1NVTg==' ];then
      tag_name=$(cat ${GITHUB_WORKSPACE}/TAG_NAME.ME)
    elif [ "${ksu_fork}" == 'U1VLSVNV' ];then
      tag_name=$(echo $(cat ${GITHUB_WORKSPACE}/TAG_NAME.ME) | cut -d'-' -f1)
    else
      exit 1
      false
    fi
    sed -E -i 's|val managerVersionName by extra.+|val managerVersionName by extra("'${tag_name}'")|g' "${GITHUB_WORKSPACE}/manager/build.gradle.kts"
  fi
fi
#for file in $(grep -R --exclude='.github' --exclude='.git' $GITHUB_WORKSPACE -e 'let version_code' 2>/dev/null | cut -d':' -f 1 | sort | uniq);do [ "$file" != "$0" ] && sed -E -i 's|(let version_code)(.*=.+\+.+)version_code(.+)|\1\2'${C_VERSION}'\3|g' $file;done
#for file in $(grep -R --exclude='.github' --exclude='.git' $GITHUB_WORKSPACE -e 'let version_name' 2>/dev/null | cut -d':' -f 1 | sort | uniq);do [ "$file" != "$0" ] && sed -E -i 's|(let version_name = )version_name(\.trim.+)|\1"'${C_TAG_NAME}'"\2|g' $file;cat $file | grep  'let version_';done
#for file in $(grep -RE --exclude='.github' --exclude='.git' $GITHUB_WORKSPACE -e 'KSU_(GIT|LOCAL|GITHUB)_VERSION' 2>/dev/null | cut -d':' -f 1 | sort | uniq);do [ "$file" != "$0" ] && sed -E -i 's|(KSU_[^[:space:]]+_VERSION \:=).+|\1 '${C_VERSION}'|g' $file;cat $file | grep -E 'KSU_(GIT|LOCAL|GITHUB)_VERSION';done
#for file in $(grep -R --exclude='.github' --exclude='.git' $GITHUB_WORKSPACE -e 'return.*commitCount' 2>/dev/null | cut -d':' -f 1 | sort | uniq);do [ "$file" != "$0" ] && sed -E -i 's|(return.+\+.+)commitCount(.+)|\1'${C_VERSION}'\2|g' $file;done
#for file in $(grep -R --exclude='.github' --exclude='.git' $GITHUB_WORKSPACE -e 'return getGitDescribe()' 2>/dev/null | cut -d':' -f 1 | sort | uniq);do [ "$file" != "$0" ] && sed -i 's|return getGitDescribe()|return "'${C_TAG_NAME}'"|g' $file;cat $file | grep  'return';done

          
