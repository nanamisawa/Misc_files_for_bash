#!/bin/bash

current=`pwd`
recalc_list=""

for i in $recalc_list
do
	astNum=`awk '{if($2=="misawa")i++}END{print i}' $current/ast.txt`
    j=1
    k=1

    while [ $k -le $astNum ]
    do
	    node_cand=`grep misawa $current/ast.txt | awk '{if(NR=='$k'){print $1;exit}}'`
	    g16job=`ssh $node_cand ps -fu misawa | awk '{if(NR>=2){print $0}}'| grep "g16"| grep -v "grep"`
        if [ -z "$g16job" ];then
	        j=$k
            echo `date`" free $node_cand"
            break
        fi
	    k=$[$k+1]
        if [ $k -gt $astNum ];then
	        k=1
            sleep 10
        fi
    done
    file_name_recalc="recalc.txt"
    file_name_gjf="cluster$i.gjf"
    file_name_log="cluster$i.log"
	samplei=`echo $i`
	cp $file_name_recalc $samplei/
	cd $samplei
    mv $file_name_log _cluster$i.log 
    mv $file_name_gjf _cluster$i.gjf 
    cat $file_name_recalc ../basis.txt > $file_name_gjf

	node=`grep misawa $current/ast.txt | awk '{if(NR=='$j'){print $1;exit}}'`
	mem=`ssh $node free -g | awk '{if(NR==2){print $2}}'`
	cpu=`ssh $node nproc`

	g16wd=`pwd`
	sed -i "s/"MEM"/$mem/g" $file_name_gjf
	sed -i "s/"CPU"/$cpu/g" $file_name_gjf
	sed -i "s#"NAME"#$g16wd/"cluster$i"#g" $file_name_gjf
	sed -i "s#"NODE"#$g16wd/$i_$node#g" $file_name_gjf

	ssh $node g16 $g09wd/$file_name_gjf &
	#ssh $node sleep 5 &
    echo "$samplei"
	sleep 5

	cd $current

done

