# Check if both arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/multiple/health.sh) <IDENTIFIER> <PIN>"
    exit 1
fi

IDENTIFIER="$1"
PIN="$2"

while true; do
STATUS_OUTPUT=$($HOME/multipleforlinux/multiple-cli status)
if echo "$STATUS_OUTPUT" | grep -q " :False"; then
    echo "Node is not running. Executing bind command..."
    $HOME/multipleforlinux/multiple-cli bind --bandwidth-download 100 --identifier "$IDENTIFIER" --pin "$PIN" --storage 200 --bandwidth-upload 100
else
    echo "Node is already binded. NodeRun: True, IsMain: True"
fi
    # Wait for 5 minutes before checking again
    sleep 300
done
