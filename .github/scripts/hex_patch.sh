#!/usr/bin/env bash
#

function jumpto
{
    label=$1 
    cmd=$(sed -n "/^:[[:blank:]][[:blank:]]*${label}/{:a;n;p;ba};" $0 | grep -v ':$') 
    eval "$cmd" 
    exit
}

start=${1:-"start"}
#jumpto $start
:  start

SAVEIFS=$IFS
debug_mode=0
if [ $debug_mode -eq 1 ];then
    set -x
fi	
errnum=0
padding_char="#x20" #space char
#padding_char="#x00" #null char
#padding_char="" #empty

usage()
{
    echo -e "usage:\n $(basename $0) \"/path/to/dir,file\" \"serach string\" \"substitute string\""
    echo "The length of the substitute string must not exceed the search string."
    echo "The shorter length of the substitute string is added with padding_char."
    echo "Strings must be ASCII encoded only."
    echo "If the path argument is a folder, all binary files in subfolders will be searched and patched."
    errnum=127
    jumpto stop
}

if ! type xxd > /dev/null; then
  echo "install xxd: pkg install xxd"
  errnum=126
fi
if ! type bc > /dev/null; then
  echo "install bc: pkg install bc"
  errnum=126
fi
if ! type file > /dev/null; then
  echo "install file: pkg install file"
  errnum=126
fi
[ $errnum -gt 0 ] && jumpto stop


# read_char var
read_char() {
  stty -icanon -echo
  eval "$1=\$(dd bs=1 count=1 2>/dev/null)"
  stty icanon echo
}

check_string()
{
	LC_CTYPE=C
	#case "$1" in
 # 	*[![:cntrl:][:print:]]*) return 1;;
	#esac
    local len=$(echo $1 | wc -c)
    local truncated_len=$(echo "$1" | tr -d -c '[:print:]\n' 2>/dev/null | wc -c)
    [ $len -eq $truncated_len ] && return 0 || return 1
}

convert_str_to_hex()
{
	declare -n result="$1"
	result="$(printf '%s' "$2" | xxd -p | tr -d '\b\n' | sed -e 's/../\\x&/g')"
}

padding_substitute()
{
    declare -n result2="$4"
    if [ "$padding_char" == "" ];then
        result2="$1"
    else
        case $(echo "$2 - $3" | bc) in
            0)
                result2="$1"
            ;;

            1)
                result2="${1}${padding_char}"
                ;;

            *)
                padded_str="$1"
                for each in $(seq 1 $(echo "$2 - $3" | bc));do
                    padded_str+="${padding_char}"
                done
                result2=$(echo "$padded_str" | tr '#' '\\')
                ;;
        esac
    fi
}

if [ $# -gt 3 ] || [ $# -lt 1 ];then
    echo "The number of arguments is incorrect."
    echo
    usage
fi

find "$1" &>/dev/null
if [ $? -gt 0 ];then
    echo "$1 Not found or unavailable"
    errnum=1
    jumpto stop
fi
[ -z "$2" ] && usage
[ -z "$3" ] && usage
if ! check_string "$2" || ! check_string "$3";then
    echo "Only Ascii strings are allowed."
    errnum=2
    jumpto stop
fi

if [ $(echo $2 | wc -c) -lt $(echo $3 | wc -c) ];then
    echo "The length of the substitute string must not be greater than the search string."
    errnum=3
    jumpto stop
fi

if test -d $1;then
	echo -e "Caution: All binary files in\n$(realpath $1) \nand subdirs will be processed."
	echo -n "Are you sure? [y/N] "; read_char response
	case "$response" in
    	[yY][eE][sS]|[yY]) 
        	# Nothing...Continue script
        	;;
    	*)
        	errnum=0
    		jumpto stop
        	;;
	esac
fi

lenght=$(echo -n $2 | wc -c)

filename=""
convert_str_to_hex "search_pattern" "$2"
convert_str_to_hex "replace_pattern" "$3"
padding_substitute "$replace_pattern" $lenght $(echo -n "$3" | wc -c) "replace_pattern"

if [ $debug_mode -eq 1 ];then
    echo -e "search_pattern\n$search_pattern"
    echo -e "replace_pattern\n$replace_pattern"
    #errnum=0
    #jumpto stop
fi

#Offset of found hex values
declare -a offsets

let count_files=0
let patched_files=0

for exe in $(find "$1" -print0 | xargs -0 --no-run-if-empty file  --mime 2>/dev/null | grep "charset=binary" | awk -F: '{print $1}');
do
	#IFS=$SAVEIFS
	filename="$exe"
	let count_files+=1
	offsets=$(LANG=C grep -obUaP "$search_pattern" $exe 2>/dev/null | cut -d':' -f 1)
	if [ $? -eq '0'  ] && [ ! -z "${offsets[0]}" ];
	then
		#echo "${offsets[@]}"
		#IFS=$(echo -en "\b\n")
		for addrr in  ${offsets[@]};
		do
			echo "patching $filename in offset $addrr ..."
			printf "$replace_pattern" | dd of="$filename" bs=1 seek=$addrr count=$lenght conv=notrunc
		done
		let patched_files+=1
	fi
done
echo
if [ $count_files -gt 0 ] && [ $patched_files -gt 0 ];then
	echo "$patched_files file(s) out of $count_files found were patched"
else
		echo "no file were patched($count_files binary file(s) found)"
fi
:  stop
IFS=$SAVEIFS
echo
if [ $debug_mode -eq 1 ];then
    set +x
fi
