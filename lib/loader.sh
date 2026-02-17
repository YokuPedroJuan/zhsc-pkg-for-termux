#!/data/data/com.termux/files/usr/bin/bash

declare -gA PAGER_CHECK
declare -gA PAGER_EXEC
declare -gA PAGER_FALLBACK
declare -ga PAGER_PRIORITY

json_get_string() {
	local file="$1"
	local key="$2"
	grep -o "\"$key\": *\"[^\"]*\"" "$file" 2>/dev/null | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/'
}

json_get_array() {
	local file="$1"
	local key="$2"
	grep -A20 "\"$key\":" "$file" 2>/dev/null | grep -o '"[^"]*"' | tr -d '"' | tail -n +2 | sed '/^\[$/d' | sed '/^\]$/d'
}

load_pager_config() {
	local file="${1:-./config/pagers.json}"
	[ -f "$file" ] || { echo "error: $file not found" >&2; return 1; }

	PAGER_PRIORITY=($(json_get_array "$file" "priority"))

	local name
	for name in "${PAGER_PRIORITY[@]}"; do
		PAGER_CHECK["$name"]=$(json_get_string "$file" "check")
		PAGER_EXEC["$name"]=$(json_get_string "$file" "exec")
		PAGER_FALLBACK["$name"]=$(json_get_string "$file" "fallback")
	done
}

