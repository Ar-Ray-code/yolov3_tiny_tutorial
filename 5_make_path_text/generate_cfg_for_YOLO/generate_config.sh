#!/bin/bash

#Usage $ sh generate_config.sh <target_folder_path> <target_data_folder_path> <name_label file_path>

##Target folder path
mkdir $1
PROJECT_FOLDER=$(cd $1; pwd)
##Target data folder path
DATA=$(cd $2; pwd)
LABEL=$(basename $3)
LABEL_PATH=$(cd $(dirname $3); pwd)/$LABEL
CLASS=$(expr $(wc -l $LABEL_PATH | cut -d ' ' -f 1) - $(grep -c '^$' $LABEL_PATH))

cd $PROJECT_FOLDER
if [ ! -e .divide_files/divide_files ]; then
	git clone https://github.com/demulab/divide_files.git
	mv divide_files .divide_files
	cd .divide_files && gcc -o divide_files divide_files.c
	cd $PROJECT_FOLDER
fi

mkdir backup
touch train_cfg.data
cp $LABEL_PATH $PROJECT_FOLDER/

cd $DATA && $PROJECT_FOLDER/.divide_files/divide_files 0.2
mv $DATA/train.list $PROJECT_FOLDER/
mv $DATA/test.list $PROJECT_FOLDER/

cd $PROJECT_FOLDER
if [ -e train_cfg.data ]; then
	rm train_cfg.data
fi

clear

echo "============================"
echo "class(es):"$CLASS


echo "pwd:"$PROJECT_FOLDER
echo "data:"$DATA
echo "label:"$LABEL_PATH
echo "============================"

echo 'classes = '$CLASS >> train_cfg.data
echo 'train = '$PROJECT_FOLDER'/train.list' >> train_cfg.data
echo 'valid = '$PROJECT_FOLDER'/test.list' >> train_cfg.data
echo 'names = '$PROJECT_FOLDER'/'$LABEL >> train_cfg.data
echo 'backup = '$PROJECT_FOLDER'/backup' >> train_cfg.data

ESC=$(printf '\033')

echo "=============================================================================="
echo " "
echo "Finished generate config! Prease execute darknet."

echo "For example"
DARKNET=$(cd ~/ && find darknet -type d | grep -v /)
echo "~/"$DARKNET"/darknet detector train "$PROJECT_FOLDER"/train_cfg.data <your cfg file> <darknet53.conv.74's path>"
echo " "
echo "=============================================================================="
echo " "
echo "Prease change cfg file to train darknet!"
echo "For yolov3 training, open yolov3-voc.cfg and edit."
echo " "
echo "[convolutional]"
echo "size=1"
echo "stride=1"
echo "pad=1"
printf "${ESC}[36m%s${ESC}[m\n" "filters=75 <- change 'filters' [filters=mask_count*(classes+5)]"
printf '\033[36m%s\033[m'
echo "activation=linear"

echo "[yolo]"
echo "mask = 0,1,2"
echo "anchors = 10,14,  23,27,  37,58,  81,82,  135,169,  344,319"
printf "${ESC}[36m%s${ESC}[m\n" "classes=20  <-- change 'Classes'"
printf '\033[36m%s\033[m'
echo "num=6"
echo "jitter=.3"
echo "ignore_thresh = .7"
echo "truth_thresh = 1"
echo "random=1"
echo " "
echo "=============================================================================="


