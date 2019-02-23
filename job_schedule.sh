#!/bin/bash

i=0
samNum=39
current=`pwd`

while [ $i -le $samNum ]
do
	astNum=`awk '{if($2=="misawa")i++}END{print i}' $current/ast.txt`
    j=1
    k=1

	while [ $j -le $astNum ]
	do
	    while [ $k -le $astNum ]
	    do
		    node_cand=`grep misawa $current/ast.txt | awk '{if(NR=='$k'){print $1;exit}}'`
		    g16job=`ssh $node_cand ps -fu misawa | awk '{if(NR>=2){print $0}}'| grep "g16"| grep -v "grep"`
            if [ -z "$g16job" ];then
		        j=$k
                echo `date`" free $node_k"
                break
            fi
		    k=$[$k+1]
            if [ $k -gt $astNum ];then
		        k=1
                sleep 10
            fi
        done
		mkdir $i
        file_name_txt="_cluster$i.txt"
        file_name_gjf="cluster$i.gjf"
		samplei=`echo $i`
		cp $file_name_txt $samplei/
		cd $samplei
        cat ../calc_con.txt $file_name_txt ../basis.txt > $file_name_gjf

		node=`grep misawa $current/ast.txt | awk '{if(NR=='$j'){print $1;exit}}'`
		mem=`ssh $node free -g | awk '{if(NR==2){print $2}}'`
		cpu=`ssh $node nproc`

		g16wd=`pwd`
		sed -i "s/"MEM"/$mem/g" $file_name_gjf
		sed -i "s/"CPU"/$cpu/g" $file_name_gjf
		sed -i "s#"NAME"#$g16wd/"cluster$i"#g" $file_name_gjf
		sed -i "s#"NODE"#$g16wd/$i_$node#g" $file_name_gjf

		ssh $node g16 $g16wd/$file_name_gjf &
		#ssh $node sleep 5 &
        echo "$samplei"
		sleep 5

		cd $current

		i=$[$i+1]

		if [ $i -gt $samNum ];then
			break
		fi

	done
done

