export PROMPT_COMMAND='CMD=$(history 1 | sed "s/^[ ]*[0-9]*[ ]*//"); printf "%s BASH_CMD:%s:%s:%s\n" "$(date +"%b %d %H:%M:%S")" "$(whoami)" "$(pwd)" "$CMD" >> /var/log/commands.log'
