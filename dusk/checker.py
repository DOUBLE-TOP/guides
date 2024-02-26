import requests
import time
from datetime import datetime, timedelta, timezone
import subprocess
import json
import re
import os

last_known_global_height_info = (None, datetime.min)

def count_blocks_mined():
    # Run the grep command and capture its output
    grep_process = subprocess.Popen(["grep", "execute_state_transition", "/var/log/rusk.log"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, _ = grep_process.communicate()

    # Count the number of lines returned by the grep command
    num_lines = len(output.decode().split('\n')) - 1

    # Check if the number of lines increased since the last call
    if hasattr(count_blocks_mined, 'last_count'):
        if num_lines > count_blocks_mined.last_count:
            print("####### BLOCK MINED! #######")

    # Update the last count value
    count_blocks_mined.last_count = num_lines

    return num_lines

def count_alive_nodes():
    url = 'http://127.0.0.1:8980/02/Chain'
    headers = {
        'Rusk-Version': '0.7',
        'Content-Type': 'application/json'
    }
    data = {
        'topic': 'alive_nodes',
        'data': ' 100'
    }

    try:
        response = requests.get(url, headers=headers, json=data)
        response.raise_for_status()  # This will raise an exception for HTTP error codes
        node_list = response.json()
        return len(node_list)
    except requests.RequestException as e:
        print(f"Error fetching data: {e}")
        return -1

def find_most_recent_execution_timestamp():
    lines_to_read = 8000
    command = f"tail -n {lines_to_read} /var/log/rusk.log | grep -i 'execute_state_transition'"
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    output, _ = process.communicate()
    lines = output.decode().splitlines()

    # Use a static variable to hold the most recent timestamp
    if not hasattr(find_most_recent_execution_timestamp, 'most_recent_timestamp'):
        find_most_recent_execution_timestamp.most_recent_timestamp = None

    for line in lines:
        line = remove_ansi_codes(line)
        timestamp = parse_timestamp(line)
        if timestamp:
            if find_most_recent_execution_timestamp.most_recent_timestamp is None or timestamp > find_most_recent_execution_timestamp.most_recent_timestamp:
                find_most_recent_execution_timestamp.most_recent_timestamp = timestamp

    return find_most_recent_execution_timestamp.most_recent_timestamp

def count_mined_blocks_and_get_last_timestamp(log_file_path):
    search_string = "execute_state_transition"

    # Command to grep for 'execute_state_transition' in the entire log file
    command = f"grep -i '{search_string}' {log_file_path}"
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    output, _ = process.communicate()
    lines = output.decode().splitlines()

    num_lines = len(lines)
    most_recent_timestamp = None

    # Iterate through each line to find the most recent timestamp
    for line in lines:
        line = remove_ansi_codes(line)
        timestamp = parse_timestamp(line)
        if timestamp and (most_recent_timestamp is None or timestamp > most_recent_timestamp):
            most_recent_timestamp = timestamp

    # Return the count of mined blocks and the most recent timestamp
    return num_lines, most_recent_timestamp

def check_consensus_keys_password():
    # Define the number of lines to check at the end of the log file
    num_lines_to_check = 2000

    # Run the tail command to get the last 2000 lines of the log file
    tail_process = subprocess.Popen(["tail", "-n", str(num_lines_to_check), "/var/log/rusk.log"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, _ = tail_process.communicate()

    # Convert the output from bytes to a string
    log_data = output.decode()

    # Check for the specific error message in the log data
    if "Invalid consensus keys password: BlockModeError" in log_data:
        print("ERROR: Invalid consensus keys password detected. Please ensure you enter same password you created. Refer to the steps on the website (https://docs.dusk.network/itn/node-running-guide/) for guidance.")

def estimate_catch_up_time(global_height, local_height, log_file_path, intervals):
    block_accepted_counts, oldest_timestamp = count_block_accepted(log_file_path, intervals)

    # Use the largest interval for catch-up estimation
    largest_interval = max(intervals)
    blocks_accepted = block_accepted_counts[largest_interval]

    # Calculate average block time
    if blocks_accepted > 0 and oldest_timestamp:
        time_span = datetime.now(timezone.utc) - oldest_timestamp
        average_block_time = time_span.total_seconds() / blocks_accepted
    else:
        return None  # Not enough data to estimate

    # Calculate catch-up time
    blocks_behind = global_height - local_height
    catch_up_seconds = average_block_time * blocks_behind
    catch_up_time = timedelta(seconds=catch_up_seconds)

    return format_timedelta(catch_up_time)

def remove_ansi_codes(text):
    ansi_escape = re.compile(r'\x1B[@-_][0-?]*[ -/]*[@-~]')
    return ansi_escape.sub('', text)

def parse_timestamp(line):
    try:
        parts = line.split(' ')[0].split('T')
        date_part = parts[0].split('-')
        time_part = parts[1].split(':')
        time_subpart = time_part[2].split('.')
        time_subpart[1] = time_subpart[1][:-1]  # Remove 'Z'

        year, month, day = map(int, date_part)
        hour, minute = map(int, time_part[:2])
        second, microsecond = map(int, time_subpart)

        return datetime(year, month, day, hour, minute, second, microsecond, tzinfo=timezone.utc)
    except (ValueError, IndexError):
        return None

def count_block_accepted(log_file_path, intervals):
    current_time = datetime.now(timezone.utc)
    counters = {interval: 0 for interval in intervals}
    lines_to_read = 8000

    command = f"tail -n {lines_to_read} {log_file_path} | grep -i 'block accepted'"
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    output, _ = process.communicate()
    lines = output.decode().splitlines()

    oldest_timestamp = None

    for line in lines:
        line = remove_ansi_codes(line)
        timestamp = parse_timestamp(line)
        if timestamp:
            if oldest_timestamp is None or timestamp < oldest_timestamp:
                oldest_timestamp = timestamp
            for interval in intervals:
                if current_time - timestamp <= timedelta(minutes=interval):
                    counters[interval] += 1

    return counters, oldest_timestamp

def dusk_network_connect_status():
    # Run the tail command to get the last 500 lines of the log file
    #tail_process = subprocess.Popen(["tail", "-n", "200", "/var/log/rusk.log"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    #output, _ = tail_process.communicate()

    nodes = count_alive_nodes()

    if nodes > 0:
        status = f"ONLINE - Connected to {nodes} Nodes"
    else:
        status = "OFFLINE - Check your port forwarding"

    #Check for the string "block received" in the output
    #if "block received" in output.decode():
    #    status = "Connected: Receiving Blocks"
    #else:
    #    status = "Not Connected: Network Congested or Node Offline. check #announcements on discord"

    print(f"DUSK Network Status: {status}")

def get_current_local_height():
    try:
        response = requests.post(
            'http://127.0.0.1:8980/02/Chain',
            headers={'Rusk-Version': '0.7.0-rc', 'Content-Type': 'application/json'},
            json={"topic": "gql", "data": "query { block(height: -1) { header { height } } }"}
        )
        return response.json()['block']['header']['height']
    except Exception:
        return None

def get_global_height():
    try:
        response = requests.get('https://api.dusk.network/v1/stats?node=nodes.dusk.network', timeout=2)
        data = response.json()
        if 'lastBlock' in data:
            return data['lastBlock']
        else:
            # Handle the absence of 'lastBlock' key
            raise KeyError("Key 'lastBlock' not found in the response")
    except Exception:
        # Catch any exception and return -1
        return -1

def get_local_node_height():
    try:
        response = requests.post(
            'http://127.0.0.1:8980/02/Chain',
            headers={'Rusk-Version': '0.7', 'Content-Type': 'application/json'},
            json={"topic": "gql", "data": "query { block(height: -1) {header {height, timestamp}}}"}
        )
        data = response.json()
        if 'block' in data and 'header' in data['block'] and 'height' in data['block']['header']:
            return data['block']['header']['height']
        else:
            raise KeyError("Required keys not found in the response")
    except Exception:
        return -1

def get_global_height_safe(max_retries=2, retry_delay=2):
    data_file = os.path.expanduser('~/dusk_global_height.json')  # File path for storing data

    # Check if the file exists and read the last known height and timestamp
    if os.path.exists(data_file):
        with open(data_file, 'r') as file:
            data = json.load(file)
            last_known_height = data.get('height')
            last_timestamp = datetime.fromisoformat(data.get('timestamp'))

            # If less than an hour has passed, return the saved data
            if datetime.now() - last_timestamp < timedelta(hours=1):
                return last_known_height, last_timestamp

    # If more than an hour has passed, or the file doesn't exist, get new data
    retries = 0
    while retries < max_retries:
        local_height = get_global_height()
        if local_height != -1:
            # Save the new height and current timestamp to the file
            with open(data_file, 'w') as file:
                current_time = datetime.now()
                json.dump({'height': local_height, 'timestamp': current_time.isoformat()}, file)
            return local_height, current_time
        else:
            time.sleep(retry_delay)
        retries += 1

    # Return the last known data if available, or None if not
    if os.path.exists(data_file):
        with open(data_file, 'r') as file:
            data = json.load(file)
            return data.get('height'), datetime.fromisoformat(data.get('timestamp'))
    else:
        return None, datetime.now()

def clear_terminal():
        os.system('clear')

def calculate_block_increase(local_heights, interval, current_height):
    if len(local_heights[interval]) >= 2:
        return current_height - local_heights[interval][-2]
    return 0

def format_timedelta(td):
    days = td.days
    hours, rem = divmod(td.seconds, 3600)
    minutes, seconds = divmod(rem, 60)

    parts = []
    if days:
        parts.append(f"{days} days")
    if hours:
        parts.append(f"{hours} hours")
    if minutes:
        parts.append(f"{minutes} minutes")
    if seconds > 0 and minutes == 0 and hours == 0 and days == 0:
        parts.append("<1 minute")


    return ", ".join(parts)

def localNodeErrorMsg():
     print("LOCAL NODE UNREACHABLE. Service is either not running or firewall rules are broken \nCheck the support-forum or #faq on the Discord Server")

def main():
    log_file_path = '/var/log/rusk.log'
    intervals = [1, 5, 15]  # Minutes
    local_heights = {interval: [] for interval in intervals}
    last_interval_check = {interval: datetime.now() for interval in intervals}
    check_consensus_keys_password()
    # Get initial local height
    local_height = get_current_local_height()
    if local_height is None:
        localNodeErrorMsg()
        return

    global_height, last_global_check = get_global_height_safe()
    
    while True:
        current_time = datetime.now()
        clear_terminal()
        print("-----------------------------")

        # Update local height
        local_height = get_current_local_height()
        if local_height is None:
            localNodeErrorMsg()
            time.sleep(10)
            continue

        # Display local height
        print("Your Local Node Block Height:", local_height)

        # Update and handle global height information
        global_height, last_global_check = get_global_height_safe()

        if 0: #debug
            global_height = 125000

        # Display global height
        if global_height is not None:
            age = datetime.now() - last_global_check
            age_text = "Now" if age.total_seconds() < 1 else format_timedelta(age)
            print(f"Estimated Global Block Height: {global_height} (Age: {age_text})")

            # Determine node status: SYNCED or SYNCING
            if local_height >= global_height:
                print("Node Status: SYNCED!")
            else:
                # Calculate estimated catch-up time using count_block_accepted
                estimated_catch_up_time = estimate_catch_up_time(global_height, local_height, log_file_path, intervals)
                if estimated_catch_up_time:
                    print(f"Node Status: Syncing. (ETA to Global: {estimated_catch_up_time})")
        else:
            print("Estimated Global Block Height: Unavailable at this time")

        # Create a separate UTC current time variable for log file processing
        log_current_time = datetime.now(timezone.utc)

        # Display information about recently mined blocks
        mined_blocks_count, last_mined_timestamp = count_mined_blocks_and_get_last_timestamp(log_file_path)
        if last_mined_timestamp:
            # Ensure last_mined_timestamp is timezone-aware in UTC
            if last_mined_timestamp.tzinfo is None:
                last_mined_timestamp = last_mined_timestamp.replace(tzinfo=timezone.utc)

            time_diff = log_current_time - last_mined_timestamp
            human_readable_time = format_timedelta(time_diff)
            print(f"Recently Mined Blocks: {mined_blocks_count} (Last mined {human_readable_time} ago)")
        else:
            print(f"Recently Mined Blocks: {mined_blocks_count}")


        dusk_network_connect_status()

        print("-----------------------------")

        # Display block accepted information
        block_accepted_counts = count_block_accepted(log_file_path, intervals)[0]
        for interval in intervals:
            print(f"Blocks 'accepted' in the last {interval} minutes: {block_accepted_counts[interval]}")

        print("\nPress Ctrl+C to kill")
        time.sleep(10)  # Wait for 10 seconds before next check

if __name__ == "__main__":
    main()