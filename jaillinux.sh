#!/bin/bash

# ==============================================
# Initial Configuration
# ==============================================
JAIL_DIR="./jail"
COMMAND_HISTORY="history.txt"
TEMP_DIR="/tmp"
DEBUG_MODE=false
LANG="en"  # Default language (English)

# ==============================================
# Colors and Emojis for the Interface
# ==============================================
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

EMOJI_ERROR="❌"
EMOJI_SUCCESS="✅"
EMOJI_WARNING="⚠️"
EMOJI_INFO="ℹ️"
EMOJI_GAME="🎮"
EMOJI_SNAKE="🐍"
EMOJI_INSTALL="🔧"
EMOJI_WEB="🌐"
EMOJI_JAIL="🔒"
EMOJI_HELP="📘"
EMOJI_EXIT="🚪"

# ==============================================
# Utility Functions
# ==============================================

# Print error messages
print_error() {
    echo -e "${RED}${EMOJI_ERROR} Error: $1${RESET}"
}

# Print success messages
print_success() {
    echo -e "${GREEN}${EMOJI_SUCCESS} Success: $1${RESET}"
}

# Print warning messages
print_warning() {
    echo -e "${YELLOW}${EMOJI_WARNING} Warning: $1${RESET}"
}

# Print informational messages
print_info() {
    echo -e "${BLUE}${EMOJI_INFO} Info: $1${RESET}"
}

# Print ASCII art for the welcome screen
print_ascii_art() {
    echo -e "${YELLOW}"
    cat <<EOF
.------------------------------------------------------------------------------------------------------.
|       █████   █████████   █████ █████       █████       █████ ██████   █████ █████  █████ █████ █████|
|      ░░███   ███░░░░░███ ░░███ ░░███       ░░███       ░░███ ░░██████ ░░███ ░░███  ░░███ ░░███ ░░███ |
|       ░███  ░███    ░███  ░███  ░███        ░███        ░███  ░███░███ ░███  ░███   ░███  ░░███ ███  |
|       ░███  ░███████████  ░███  ░███        ░███        ░███  ░███░░███░███  ░███   ░███   ░░█████   |
|       ░███  ░███░░░░░███  ░███  ░███        ░███        ░███  ░███ ░░██████  ░███   ░███    ███░███  |
| ███   ░███  ░███    ░███  ░███  ░███      █ ░███      █ ░███  ░███  ░░█████  ░███   ░███   ███ ░░███ |
|░░████████   █████   █████ █████ ███████████ ███████████ █████ █████  ░░█████ ░░████████   █████ █████|
| ░░░░░░░░   ░░░░░   ░░░░░ ░░░░░ ░░░░░░░░░░░ ░░░░░░░░░░░ ░░░░░ ░░░░░    ░░░░░   ░░░░░░░░   ░░░░░ ░░░░░ |
'------------------------------------------------------------------------------------------------------'
EOF
    echo -e "${RESET}"
}

# ==============================================
# Core Functions
# ==============================================

# Show help menu
show_help() {
    echo -e "${BLUE}${EMOJI_HELP} Available commands:${RESET}"
    echo "  ls       - Displays files and directories."
    echo "  pwd      - Shows the current directory."
    echo "  cd       - Changes the directory (usage: cd <directory>)."
    echo "  history  - Displays the history of executed commands."
    echo "  clear    - Clears the screen."
    echo "  guess    - ${EMOJI_GAME} Play the 'Guess the Number' game."
    echo "  snake    - ${EMOJI_SNAKE} Play a simple Snake game in the terminal."
    echo "  install  - ${EMOJI_INSTALL} Installs necessary components and sets up environment."
    echo "  open_local_web - ${EMOJI_WEB} Opens the local web page in Lynx."
    echo "  jail     - ${EMOJI_JAIL} Manage jail processes (create, list, kill, status)."
    echo "  exit     - ${EMOJI_EXIT} Exits the shell."
    echo "  help     - ${EMOJI_HELP} Displays this help message."
}

# Create a prisoner process
create_prisoner() {
    local prisoner_name="$1"
    local prisoner_script="$JAIL_DIR/$prisoner_name.sh"

    # Create the jail directory if it doesn't exist
    mkdir -p "$JAIL_DIR"

    if [[ "$prisoner_name" =~ [^a-zA-Z0-9_-] ]]; then
        print_error "The prisoner name contains invalid characters."
        return 1
    fi

    cat <<EOF > "$prisoner_script"
#!/bin/bash
echo "Prisoner $prisoner_name (PID: \$\$) is alive."
while true; do
    sleep 1
done
EOF

    chmod +x "$prisoner_script"
    "$prisoner_script" &
    print_success "Prisoner $prisoner_name created with PID: $!"
}

# List all alive prisoners
list_prisoners() {
    echo -e "${BLUE}${EMOJI_JAIL} Alive prisoners:${RESET}"
    for script in "$JAIL_DIR"/*.sh; do
        [ -e "$script" ] || continue
        pid=$(pgrep -f "$script")
        if [ -n "$pid" ]; then
            name=$(basename "$script" .sh)
            echo "Name: $name, PID: $pid"
        fi
    done
}

# Kill a prisoner process
kill_prisoner() {
    local pid="$1"
    if kill -9 "$pid" 2>/dev/null; then
        print_success "Prisoner with PID $pid has been terminated."
    else
        print_error "Failed to terminate prisoner with PID $pid."
    fi
}

# Show prisoner status (alias for list_prisoners)
prisoner_status() {
    list_prisoners
}

# Guess the Number game
guess_number_game() {
    local secret_number=$(( RANDOM % 100 + 1 ))
    local attempts=0
    echo -e "${GREEN}${EMOJI_GAME} Welcome to the Guess the Number game! ${EMOJI_GAME}${RESET}"
    echo "I have chosen a number between 1 and 100. Try to guess it!"

    while true; do
        read -p "Enter your number: " user_number
        if [[ ! "$user_number" =~ ^[0-9]+$ || "$user_number" -lt 1 || "$user_number" -gt 100 ]]; then
            print_error "Please enter a valid number between 1 and 100."
            continue
        fi

        attempts=$(( attempts + 1 ))
        if (( user_number < secret_number )); then
            echo "🔼 The number is higher. Try again."
        elif (( user_number > secret_number )); then
            echo "🔽 The number is lower. Try again."
        else
            echo -e "${GREEN}🎉 Congratulations! You guessed the number $secret_number in $attempts attempts.${RESET}"
            break
        fi
    done
}

# Snake game
snake_game() {
    echo -e "${GREEN}${EMOJI_SNAKE} Starting Snake game... (Press Ctrl+C to exit)${RESET}"
    sleep 2
    if command -v nsnake &>/dev/null; then
        nsnake
    else
        print_warning "Install 'nsnake' to play (sudo apt install nsnake)."
    fi
}

# Install dependencies
install() {
    mkdir -p "$TEMP_DIR/example_dir"
    touch "$TEMP_DIR/example_file.txt"
    print_success "Files and directories created in $TEMP_DIR."

    if ! command -v nsnake &>/dev/null; then
        echo -e "${BLUE}${EMOJI_INSTALL} Installing nsnake...${RESET}"
        sudo apt install -qq nsnake
    else
        print_info "nsnake is already installed."
    fi

    if ! command -v git &>/dev/null; then
        echo -e "${BLUE}${EMOJI_INSTALL} Installing git...${RESET}"
        sudo apt install -qq git
    else
        print_info "git is already installed."
    fi

    if [ ! -d "JailLinux" ]; then
        git clone https://github.com/Cristiangarcia913/JailLinux.git
    else
        print_info "JailLinux repository is already cloned."
    fi
}

# Open the local web page in Lynx
open_local_web() {
    if command -v lynx &>/dev/null; then
        echo -e "${BLUE}${EMOJI_WEB} Opening local web page...${RESET}"
        lynx JailLinux/index.html
    else
        print_error "Lynx is not installed. Install it with 'sudo apt install lynx'."
    fi
}

# ==============================================
# Main Function
# ==============================================
main() {
    clear
    print_ascii_art
    echo -e "${GREEN}Welcome to Jaillinux. Type 'help' to see available commands.${RESET}"

    while true; do
        echo -n ">>> "
        read -r user_input
        echo "$(date '+%Y-%m-%d %H:%M') - $user_input" >> "$COMMAND_HISTORY"

        # Split input into command and arguments
        read -r command args <<< "$user_input"

        case "$command" in
            exit)
                echo -e "${RED}${EMOJI_EXIT} Exiting Jaillinux...${RESET}"
                break
                ;;
            help)
                show_help
                ;;
            history)
                cat "$COMMAND_HISTORY"
                ;;
            jail)
                read -r subcommand subargs <<< "$args"
                case "$subcommand" in
                    create)
                        create_prisoner "$subargs"
                        ;;
                    list)
                        list_prisoners
                        ;;
                    kill)
                        kill_prisoner "$subargs"
                        ;;
                    status)
                        prisoner_status
                        ;;
                    *)
                        print_error "Invalid jail command. Use 'jail help' for more information."
                        ;;
                esac
                ;;
            guess)
                guess_number_game
                ;;
            snake)
                snake_game
                ;;
            install)
                install
                ;;
            open_local_web)
                open_local_web
                ;;
            *)
                # Execute any valid Bash command
                bash -c "$user_input"
                ;;
        esac
    done
}

# Start Jaillinux
if [[ -n "$1" ]]; then
    echo "Ejecutando comando: $1"
    eval "$1"
else
    main
fi

