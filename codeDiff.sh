#!/bin/bash

function calc_num {
	if(( `echo $1 | grep -c , ` == 1 )); then
		let begin=`echo $1 | cut -d"," -f1`
		let end=`echo $1 | cut -d"," -f2`
		let num=$end-$begin+1
		echo $num
	else
		let num=1
		echo $num
	fi
}

function calc_begin {
	if(( `echo $1 | grep -c , ` == 1 )); then
		echo `echo $1 | cut -d"," -f1`
	else
		echo $1
	fi
}

function calc_end {
	if(( `echo $1 | grep -c , ` == 1 )); then
		echo `echo $1 | cut -d"," -f2`
	else
		echo $1
	fi
}

function main {
diff -abBEi $1 $2 | grep -v ^'-'*$ > out.txt
declare -a lines

# Load file into array.
let i=0
while IFS=$'\n' read -r line_data; do
    lines[i]="${line_data}"
    ((++i))
done < out.txt

for line in "${lines[@]}" ; do
	if (( `echo $line | grep -c ^[0-9][0-9]*[c','][0-9][0-9]*[c0-9]*[0-9]*','*[0-9]*$` == 1 )); then
		str_del=`echo $line | cut -d"c" -f1`
		let num_del=`calc_num $str_del`
		let begin_del=`calc_begin $str_del`
		let end_del=`calc_end $str_del`
		for ((j = $begin_del; j <= $end_del ; j++)); do
			printf "%s\t%s\t%s\t%s %s\n" $j '-' "`cat $1 | head -$j | tail -1`" `date "+%d-%m-%Y"` `date "+%H:%M:%S"`
		done
		str_add=`echo $line | cut -d"c" -f2`
		let num_add=`calc_num $str_add`
		let begin_add=`calc_begin $str_add`
		let end_add=`calc_end $str_add`
		for ((j = $begin_add; j <= $end_add; j++)); do
			printf "%s\t+\t%s\t%s %s\n" $j "`cat $2 | head -$j | tail -1`" `date "+%d-%m-%Y"` `date "+%H:%M:%S"`
		done
	elif (( `echo $line | grep -c ^[0-9][0-9]*[a','][0-9][0-9]*[a0-9]*[0-9]*','*[0-9]*$` == 1 )); then
		string=`echo $line | cut -d"a" -f2`
		let num=`calc_num $string`
		let begin=`calc_begin $string`
		let end=`calc_end $string`
		for ((j = $begin; j <= $end ; j++)); do
			printf "%s\t+\t%s\t%s %s\n" $j "`cat $2 | head -$j | tail -1`" `date "+%d-%m-%Y"` `date "+%H:%M:%S"`
		done
	elif (( `echo $line | grep -c ^[0-9][0-9]*[d','][0-9][0-9]*[d0-9]*[0-9]*','*[0-9]*$` == 1 )); then
		string=`echo $line | cut -d"d" -f1`
		let num=`calc_num $string`
		let begin=`calc_begin $string`
		let end=`calc_end $string`
		for ((j = $begin; j <= $end ; j++)); do
			printf "%s\t%s\t%s\t%s %s\n" $j '-' "`cat $1 | head -$j | tail -1`" `date "+%d-%m-%Y"` `date "+%H:%M:%S"`
		done
	fi
	((++i))
done
}

function design {
declare -a lines_diff
let i=0
while IFS=$'\n' read -r line_diff; do
    lines_diff[i]="${line_diff}"
    ((++i))
done < $3
declare -a lines_new
let j=0
while IFS=$'\n' read -r line_new; do
    lines_new[j]="${line_new}"
    ((++j))
done < $2

let num=$(($i + `cat $3 | wc -l`))
let new=0
for line in "${lines_new[@]}" ; do
	printf "%s\n" "${lines_new[${new}]}<br />"
	((++new))
done
printf "<hr>/*<br />\n"
let cdiff=0
for line in "${lines_diff[@]}" ; do
	printf "%s\n" "${lines_diff[${cdiff}]}<br />"
	((++cdiff))
done
printf "*/"
}

main $1 $2 > mydiff.log
rm out.txt
design $1 $2 mydiff.log > code.log
rm mydiff.log
cp $2 $1
cat code.log >> efratCode.log
cp code.log ~/Desktop/DynamicTimeline/public/codeData/
