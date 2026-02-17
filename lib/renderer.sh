#!/data/data/com.termux/files/usr/bin/bash

TERM_WIDTH=$(stty size 2>/dev/null | cut -d' ' -f2)
TERM_WIDTH=${TERM_WIDTH:-80}

render_header() {
	local name="$1"
	local section="$2"
	local center="ZHSC 中文手册"
	local left="$name($section)"
	local right="$name($section)"

	local total_len=$((${#left} + ${#center} + ${#right}))
		local pad=$((TERM_WIDTH - total_len))
		local left_pad=$((pad / 2))
		local right_pad=$((pad - left_pad))

		printf "%s%*s%s%*s%s\n" "$left" "$left_pad" "" "$center" "$right_pad" "" "$right"
	}

render_section() {
	local title="$1"
	shift
	local content="$*"

	echo ""
	echo "$title"
	echo ""
	echo "$content" | sed 's/^/       /'
}

render_option() {
	local flags="$1"
	local desc="$2"

	echo "       $flags"
	echo "              $desc"
	echo ""
}

render_example() {
	local title="$1"
	local cmd="$2"
	local desc="$3"

	echo "       $title"
	echo "              $ $cmd"
	echo "              $desc"
	echo ""
}

