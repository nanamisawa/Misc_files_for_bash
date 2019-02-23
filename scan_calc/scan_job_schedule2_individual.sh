#!/bin/bash

i=1
samNum=19
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
                echo `date`" free $node_cand"
                break
            fi
		    k=$[$k+1]
            if [ $k -gt $astNum ];then
		        k=1
                sleep 10
            fi
        done

		mkdir $i-
		dis=`echo "scale=4; 5.00000 + 0.2000*$i" | bc`
        file_name_coord="3-.txt"
        file_name_inp1="input1.txt"
        file_name_elem="elements_mod.txt"
        file_name_inp2="input2.txt"
        file_name_gjf="C1_$i-.gjf"
		samplei=`echo $i-`

		cd $samplei
        touch calc_inp.txt
        touch calc_out.txt
        echo "distance" >> calc_inp.txt
        echo $dis >> calc_inp.txt
        echo "1 77" >>calc_inp.txt
        echo "1 24" >>calc_inp.txt
        $current/CrdTranslator.exe $current/$file_name_coord calc_inp.txt calc_out.txt 
        paste $current/$file_name_elem calc_out.txt > coord.txt
        cat $current/$file_name_inp1 coord.txt $current/$file_name_inp2 > $file_name_gjf

		node=`grep misawa $current/ast.txt | awk '{if(NR=='$j'){print $1;exit}}'`
		mem=`ssh $node free -g | awk '{if(NR==2){print $2}}'`
		cpu=`ssh $node nproc`

		g09wd=`pwd`
		sed -i "s/"MEM"/$mem/g" $file_name_gjf
		sed -i "s/"CPU"/$cpu/g" $file_name_gjf
		sed -i "s#"NAME"#$g09wd/$i#g" $file_name_gjf
		sed -i "s#"NODE"#$g09wd/$i_$node#g" $file_name_gjf
		sed -i "s/"DIS"/$dis/g" $file_name_gjf

		ssh $node g09 $g09wd/$file_name_gjf &
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

