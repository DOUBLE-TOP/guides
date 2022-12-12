apt install unzip

tmux kill-session -t tfsc

rm -rf $HOME/tfsc/data.db

wget -O $HOME/tfsc/data.zip  https://doubletop-bin.ams3.digitaloceanspaces.com/tfsc/data.db57704.zip

cd $HOME/tfsc
unzip data.zip

rm -rf data.zip

tmux new-session -d -s tfsc 'cd $HOME/tfsc/ && $HOME/tfsc/tfsc -m'
