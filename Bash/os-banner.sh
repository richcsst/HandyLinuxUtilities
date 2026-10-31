# Terminal Startup Banner
if [ -n "$PS1" ]; then
    reset -Q
    TERMINAL_WIDTH=$(tput cols)
    TERMINAL_HEIGHT=$(tput lines)

    # Accept logo filename as the first argument, defaulting to ZorinOS.png if none provided
    LOGO_FILE="${1:-/etc/ZorinOS.png}"

    # Render logo dynamically
    /usr/bin/chafa --view-size "${TERMINAL_WIDTH}x${TERMINAL_HEIGHT}" "$LOGO_FILE"

    # Define ANSI Color Codes
    NC='\033[0m'
    BOLD_WHITE='\033[1;97m'   # Headings: Bright White & Bold

    # High-intensity colors for each value field
    VAL_HOST='\033[1;95m'     # Bright Magenta
    VAL_KERNEL='\033[1;96m'   # Bright Cyan
    VAL_CPU='\033[1;94m'      # Bright Blue
    VAL_RAM='\033[1;92m'      # Bright Green
    VAL_LOAD='\033[1;93m'     # Bright Yellow
    VAL_UPTIME='\033[1;95m'   # Light Purple / Bright Magenta
    VAL_HW='\033[1;96m'       # Bright Cyan
    VAL_VIRT='\033[1;33m'     # Bright Yellow (for Virtual Machines)

    # --- 1. Gather System Data ---
    HOST_NAME=$(hostname)
    KERNEL=$(uname -r)
    CPU_CORES=$(nproc)
    TOTAL_RAM=$(free -h | awk '/Mem:/ {print $2}' | sed 's/i//g')
    LOAD_AVG=$(awk '{print $1", "$2", "$3}' /proc/loadavg)
    UPTIME_RAW=$(uptime -p | sed 's/up //')
    HW_MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Unknown")

    # Robust Virtualization Check: only query type if systemd-detect-virt confirms a VM/container
    if systemd-detect-virt --quiet 2>/dev/null; then
        VIRT_TYPE=$(systemd-detect-virt 2>/dev/null)
        IS_VIRT=true
    else
        IS_VIRT=false
    fi

    # --- 2. Build Single-Line & Multi-Line Strings Conditionally ---
    if [ "$IS_VIRT" = true ]; then
        # Virtual Machine layout (includes virtualization)
        SINGLE_PLAIN="Hostname: $HOST_NAME, Linux Version: $KERNEL, CPU Cores: $CPU_CORES, RAM: $TOTAL_RAM, Load Average: $LOAD_AVG, Uptime: $UPTIME_RAW, Hardware Model: $HW_MODEL, Virtualization: $VIRT_TYPE"
        SINGLE_ANSI="${BOLD_WHITE}Hostname:${NC} ${VAL_HOST}$HOST_NAME${NC}, ${BOLD_WHITE}Linux Version:${NC} ${VAL_KERNEL}$KERNEL${NC}, ${BOLD_WHITE}CPU Cores:${NC} ${VAL_CPU}$CPU_CORES${NC}, ${BOLD_WHITE}RAM:${NC} ${VAL_RAM}$TOTAL_RAM${NC}, ${BOLD_WHITE}Load Average:${NC} ${VAL_LOAD}$LOAD_AVG${NC}, ${BOLD_WHITE}Uptime:${NC} ${VAL_UPTIME}$UPTIME_RAW${NC}, ${BOLD_WHITE}Hardware Model:${NC} ${VAL_HW}$HW_MODEL${NC}, ${BOLD_WHITE}Virtualization:${NC} ${VAL_VIRT}$VIRT_TYPE${NC}"

        L4_PLAIN="Hardware Model: $HW_MODEL, Virtualization: $VIRT_TYPE"
        L4_ANSI="${BOLD_WHITE}Hardware Model:${NC} ${VAL_HW}$HW_MODEL${NC}, ${BOLD_WHITE}Virtualization:${NC} ${VAL_VIRT}$VIRT_TYPE${NC}"
    else
        # Bare Metal layout (omits virtualization entirely)
        SINGLE_PLAIN="Hostname: $HOST_NAME, Linux Version: $KERNEL, CPU Cores: $CPU_CORES, RAM: $TOTAL_RAM, Load Average: $LOAD_AVG, Uptime: $UPTIME_RAW, Hardware Model: $HW_MODEL"
        SINGLE_ANSI="${BOLD_WHITE}Hostname:${NC} ${VAL_HOST}$HOST_NAME${NC}, ${BOLD_WHITE}Linux Version:${NC} ${VAL_KERNEL}$KERNEL${NC}, ${BOLD_WHITE}CPU Cores:${NC} ${VAL_CPU}$CPU_CORES${NC}, ${BOLD_WHITE}RAM:${NC} ${VAL_RAM}$TOTAL_RAM${NC}, ${BOLD_WHITE}Load Average:${NC} ${VAL_LOAD}$LOAD_AVG${NC}, ${BOLD_WHITE}Uptime:${NC} ${VAL_UPTIME}$UPTIME_RAW${NC}, ${BOLD_WHITE}Hardware Model:${NC} ${VAL_HW}$HW_MODEL${NC}"

        L4_PLAIN="Hardware Virtualization: $HW_MODEL"
        L4_ANSI="${BOLD_WHITE}Hardware Virtualization:${NC} ${VAL_HW}$HW_MODEL${NC}"
    fi

    L1_PLAIN="Hostname: $HOST_NAME"
    L1_ANSI="${BOLD_WHITE}Hostname:${NC} ${VAL_HOST}$HOST_NAME${NC}"

    L2_PLAIN="Linux Version: $KERNEL, CPU Cores: $CPU_CORES, RAM: $TOTAL_RAM"
    L2_ANSI="${BOLD_WHITE}Linux Version:${NC} ${VAL_KERNEL}$KERNEL${NC}, ${BOLD_WHITE}CPU Cores:${NC} ${VAL_CPU}$CPU_CORES${NC}, ${BOLD_WHITE}RAM:${NC} ${VAL_RAM}$TOTAL_RAM${NC}"

    L3_PLAIN="Load Average: $LOAD_AVG, Uptime: $UPTIME_RAW"
    L3_ANSI="${BOLD_WHITE}Load Average:${NC} ${VAL_LOAD}$LOAD_AVG${NC}, ${BOLD_WHITE}Uptime:${NC} ${VAL_UPTIME}$UPTIME_RAW${NC}"

    # Helper function for center-aligning any string
    print_centered() {
        local plain_text="$1"
        local ansi_text="$2"
        local plen=${#plain_text}
        local padding=""
        if [ "$TERMINAL_WIDTH" -gt "$plen" ]; then
            local half=$(( (TERMINAL_WIDTH - plen) / 2 ))
            printf -v padding '%*s' "$half" ""
        fi
        echo -e "${padding}${ansi_text}"
    }

    # --- 3. Conditional Layout Switch ---
    SINGLE_LEN=${#SINGLE_PLAIN}
    if [ "$TERMINAL_WIDTH" -ge "$SINGLE_LEN" ]; then
        print_centered "$SINGLE_PLAIN" "$SINGLE_ANSI"
    else
        print_centered "$L1_PLAIN" "$L1_ANSI"
        print_centered "$L2_PLAIN" "$L2_ANSI"
        print_centered "$L3_PLAIN" "$L3_ANSI"
        print_centered "$L4_PLAIN" "$L4_ANSI"
    fi
fi

