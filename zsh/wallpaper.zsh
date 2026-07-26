wallpaper() {
    local DIR="$HOME/Pictures/wallpapers"
    clear
    echo ""
    echo -e "\e[38;2;224;0;176m  ██╗    ██╗  █████╗  ██╗      ██╗     \e[0m"
    echo -e "\e[38;2;232;0;184m  ██║    ██║ ██╔══██╗ ██║      ██║     \e[0m"
    echo -e "\e[38;2;240;0;192m  ██║ █╗ ██║ ███████║ ██║      ██║     \e[0m"
    echo -e "\e[38;2;220;184;240m  ██║███╗██║ ██╔══██║ ██║      ██║     \e[0m"
    echo -e "\e[38;2;220;184;240m  ╚███╔███╔╝ ██║  ██║ ███████╗ ███████╗\e[0m"
    echo -e "\e[38;2;220;184;240m   ╚══╝╚══╝  ╚═╝  ╚═╝ ╚══════╝ ╚══════╝\e[0m"
    echo ""
    echo -e "\e[38;2;220;184;240m  ──────────────────────────────────\e[0m"
    echo -e "\e[38;2;0;192;208m          Wallpaper Selector\e[0m"
    echo -e "\e[38;2;220;184;240m  ──────────────────────────────────\e[0m"
    echo ""
    local WALLS=()
    for f in "$DIR"/**/*.(jpg|jpeg|png|webp|gif|mp4|webm|mkv|mov)(N.); do
      WALLS+=("${f#$DIR/}")
    done
    if [ ${#WALLS[@]} -eq 0 ]; then
        echo -e "\e[38;2;224;0;176m  ✗  folder empty $DIR\e[0m"
        return
    fi
    for i in $(seq 1 ${#WALLS[@]}); do
        if (( i % 2 == 0 )); then
            echo -e "  \e[38;2;240;0;192m$i\e[0m  \e[38;2;157;127;184m${WALLS[$i]}\e[0m"
        else
            echo -e "  \e[38;2;224;0;176m$i\e[0m  \e[38;2;245;230;255m${WALLS[$i]}\e[0m"
        fi
    done
    echo ""
    echo -e "\e[38;2;220;184;240m  ──────────────────────────────────\e[0m"
    echo ""
    echo -ne "  \e[38;2;0;192;208m❯ Choose  \e[0m"
    read SELECTION
    echo ""
    if [[ "$SELECTION" =~ ^[0-9]+$ ]] && [ "$SELECTION" -ge 1 ] && [ "$SELECTION" -le "${#WALLS[@]}" ]; then
        local SELECTED_WALL="${WALLS[$SELECTION]}"
        local FULL_PATH="$DIR/$SELECTED_WALL"
        echo -e "  \e[38;2;0;192;208m󰔟  Replacing Wallpaper + Colors...\e[0m"
        ~/.config/hypr/scripts/set-wallpaper.sh "$FULL_PATH" > /dev/null 2>&1
        echo -e "  \e[38;2;0;192;208m✓  $SELECTED_WALL\e[0m"
        echo ""
    else
        echo -e "  \e[38;2;0;192;208m✗  Salah nomor Bos!!\e[0m"
        echo ""
    fi
}
