#!/data/data/com.termux/files/usr/bin/bash

source ./lib/loader.sh

check_pager() {
	local name="$1"
	local cmd="${PAGER_CHECK["$name"]}"
	[ -z "$cmd" ] && return 1
	eval "$cmd" &>/dev/null
}

select_pager() {
	local name="$1"

	if check_pager "$name"; then
		echo "$name"
		return 0
	fi

	local fb="${PAGER_FALLBACK["$name"]}"
	[ "$fb" = "null" ] && return 1
	[ -z "$fb" ] && return 1

	select_pager "$fb"
}

exec_pager() {
	local name=$(select_pager "${PAGER_PRIORITY[0]}")
	[ -z "$name" ] && { cat; return; }
	local cmd="${PAGER_EXEC["$name"]}"
	eval "$cmd"
}

