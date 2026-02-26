export PROMPT_COMMAND='echo "$(date +"%b %d %H:%M:%S") BASH_CMD:$(whoami):$(pwd):$(history 1 | sed "s/^[ ]*[0-9]*[ ]*//")" >> /var/log/commands.log'
