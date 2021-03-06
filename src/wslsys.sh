version="18"

help_short="wslsys (-h|-v|-S|-U|-b|-B|-fB|-R|-K|-P) -s"
branch=`reg.exe query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "BuildBranch" 2>&1 | sed -n 3p | sed -e "s/BuildBranch//" | sed -e 's/^[[:space:]]*//' | awk '{$1=""; sub("  ", " "); print}' | sed -e 's|\r||g'`
build=`reg.exe query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "CurrentBuild" 2>&1 | egrep -o '([0-9]{5})'`
full_build=`reg.exe query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "BuildLabEx" 2>&1 | sed -n 3p | sed -e "s/BuildLabEx//" | sed -e 's/^[[:space:]]*//' | awk '{$1=""; sub("  ", " "); print}' | sed -e 's|\r||g'`
installdate=`reg.exe query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "InstallDate" | egrep -o "(0x|0X)[a-fA-F0-9]+" | xargs printf "%d\n" | bc | xargs -I '{}' date --date="@{}"`
release="$(lsb_release -ds | sed -e 's/"//g')"
kernel="$(uname -sr)"

case "$distro" in
	'ubuntu'|'kali'|'debian')
		uptime="$(uptime -p | sed 's/up //')"
		packages="$((packages+=$(dpkg --get-selections | grep -cv deinstall$)))";;
	'opensuse'|'sles')
		uptime="$(uptime | awk '{$1=$2=$(NF-6)=$(NF-5)=$(NF-4)=$(NF-3)=$(NF-2)=$(NF-1)=$NF="";sub(","," minutes");sub(":"," hours, "); print}' | sed "s/  //")"
		packages="$(rpm -qa | wc -l)"
		;;
esac

function printer
{
	if [[ $2 != "-s" ]]; then
		echo $1
	else
		echo $1 | sed 's/^.*: //'
	fi
}

case $1 in
        -h|--help) help $0 "$help_short"; exit;;
	    -v|--version) echo "wslsys v$wslu_version.$version"; exit;;
		-I|--sys-installdate) printer "system install date: $installdate" $2;exit;;
		-b|--branch) printer "branch: $branch" $2;exit;;
		-B|--build) printer "build: $build" $2;exit;;
		-fB|--full-build) printer "build: $full_build" $2;exit;;
		-U|--uptime) printer "uptime: $uptime" $2;exit;;
		-R|--release) printer "release: $release" $2;exit;;
		-K|--kernel) printer "kernel: $kernel" $2;exit;;
		-P|--package) printer "total package: $packages" $2;exit;;
		*) echo -e "$release on Windows 10 Build$full_build (kernel:$kernel; uptime:$uptime; package:$packages; system install date:$installdate)";exit;;
esac
