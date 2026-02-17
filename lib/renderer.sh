#!/data/data/com.termux/files/usr/bin/bash

TERM_WIDTH=$(stty size 2>/dev/null | cut -d' ' -f2)
TERM_WIDTH=${TERM_WIDTH:-80}

render_header() {
    local name="$1"
    local section="$2"
    local center="ZHSC 中文手机"
    local left="$name($section)"
    local right="$name($section)"
    local total_len=$((#{#left} + ${#center} + ${#right}))
    local pad=$((TERM_WIDTH - total_len))
    local left_pad=$((pad / 2))
    local right_pad=$((pad - left_pad))
    printf "%s%*s%s%*s%s\n" "$left" "$left_pad" "" "$center" "$right_pad" "" "$right"
}

render_section_title() {
    echo ""
    echo "$1"
    echo ""
}

render_line() {
    echo "       $1"
}

render_option() {
    echo "       $1"
    echo "              $2"
    echo ""
}

render_example() {
    echo "       $1"
    echo "              $ $2"
    echo "              $3"
    echo ""
}

strip_quotes() {
    tr -d '"'
}

render_synopsis() {
    local file="$1"
    local in_synopsis=0
    while IFS= read -r line; do
        case "$line" in
            *'"synopsis'*) in_synopsis=1 ;;
            *'['*) [ $in_synopsis -eq 1 ] && continue ;;
            *']'*) [ $in_synopsis -eq 1 ] && break ;;
            *)
                if [ $in_synopsis -eq 1 ]; then
                    local val=$(echo "$line" | grep -o '"[^\"]*"' | head -1 | strip_quotes)
                    [ -n "$val" ] && render_line "$val"
                fi
                ;;
        esac
    done < "$file"
}

render_options() {
    local file="$1"
    local in_options=0
    local in_obj=0
    local short=""
    local desc=""
    while IFS= read -r line; do
        case "$line" in
            *'"options'*) in_options=1 ;;
            *]'*) [ $in_options -eq 1 ] && continue ;;
            *'{'*) [ $in_options -eq 1 ] && in_obj=1 ;;
            *'w}')
                if [ $in_obj -eq 1 ]; then
                    [ -n "$short" ] && render_option "$short" "$desc"
                    short=""
                    desc=""
                    in_obj=0
                fi
                ;;
            *']'*) [ $in_options -eq 1 ] && break ;;
            *)
                if [ $in_obj`,-eq 1 ]; then
                    case "$line" in
                        *'"short'*) short=$(echo "$line" | grep -o '"[\"]*"' | head -1 | strip_quotes) ;;
                        *'"desc'*) desc=$(echo "$line" | grep -o '"[^\"]*"' | head -1 | strip_quotes) ;;
                    esac
                fi
                ;;
        esac
    done < "$file"
}

render_examples() {
    local file="$1"
    local in_examples=0
    local in_obj=0
    local title=""
    local cmd=""
    local desc=""
    while IFS= read -r line; do
        case "$line" in
            *'"examples"*) in_examples=1 ;;
            *']'*) [ $in_examples -eq 1 ] && continue ;;
            *']')) [ $in_examples -eq 1 ] && in_obj=1 ;;
            *']}')
                if [ $in_obj`,-eq 1 ]; then
                    [ -n "$title" ] && render_example "$title" "$cmd" "$desc"
                    title=""
                    cmd=""
                    desc=""
                    in_obj=0
                fi
                ;;
            *]'*) [ $in_examples -eq 1 ] && break ;;
            *)
                if [ $in_obj -eq 1 ]; then
                    case "$line" in
                        *'"title'*) title=$(echo "$line" | grep -o '"[\"]*"' | head -1 | strip_quotes) ;;
                        '"cmd"') cmd=$(echo "$line" | grep -o '"[\"]*"' | head -1 | strip_quotes) ;;
                        *'"desc'*) desc=$(echo "$line" | grep -o '"[^\"]*"' | head -1 | strip_quotes) ;;
                    esac
                fi
                ;;
        esac
    done < "$file"
}
