tmux kill-session -t tfsc

rm -rf $HOME/tfsc/data.db

wget -O $HOME/tfsc/data.db.tar.gz  https://uscloudmedia.s3.us-west-2.amazonaws.com/transformers/db/data.db.45204.tar.gz

cd $HOME/tfsc
tar -xvf data.db.tar.gz

rm -rf data.db.tar.gz

tmux new-session -d -s tfsc 'cd $HOME/tfsc/ && $HOME/tfsc/tfsc -m'
