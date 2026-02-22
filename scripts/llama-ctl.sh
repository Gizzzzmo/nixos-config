#!/usr/bin/env bash
# Helper script to manage llama-server models
# Usage: llama-ctl.sh [command] [args]

LLAMA_HOST="${LLAMA_HOST:-100.64.0.3}"
LLAMA_PORT="${LLAMA_PORT:-11404}"
BASE_URL="http://${LLAMA_HOST}:${LLAMA_PORT}"

command="$1"
shift

case "$command" in
list | ls)
	echo "=== Available Models ==="
	curl -s "${BASE_URL}/v1/models" | jq -r '.data[] | "- \(.id)"' 2>/dev/null ||
		curl -s "${BASE_URL}/v1/models"
	;;

status | props)
	echo "=== Server Status ==="
	curl -s "${BASE_URL}/props" | jq '.' 2>/dev/null ||
		curl -s "${BASE_URL}/props"
	;;

slots)
	echo "=== Active Slots (Loaded Models) ==="
	curl -s "${BASE_URL}/slots" | jq '.' 2>/dev/null ||
		curl -s "${BASE_URL}/slots"
	;;

health)
	echo "=== Health Check ==="
	curl -s "${BASE_URL}/health"
	echo
	;;

unload)
	model_name="$1"
	if [ -z "$model_name" ]; then
		echo "Error: Model name required"
		echo "Usage: $0 unload <model-name>"
		echo "       $0 unload all  (to unload all models)"
		exit 1
	fi

	echo "Attempting to unload model: $model_name"
	# Try different API formats
	response=$(curl -s -X POST "${BASE_URL}/models/unload" \
		-H "Content-Type: application/json" \
		-d "{\"model\":\"$model_name\"}")

	if echo "$response" | grep -q "error"; then
		# Try alternative format
		response=$(curl -s -X POST "${BASE_URL}/models/unload?model=$model_name")
	fi

	echo "$response" | jq '.' 2>/dev/null || echo "$response"
	;;

load)
	model_name="$1"
	if [ -z "$model_name" ]; then
		echo "Error: Model name required"
		echo "Usage: $0 load <model-name>"
		exit 1
	fi

	echo "Attempting to load model: $model_name"
	response=$(curl -s -X POST "${BASE_URL}/models/load" \
		-H "Content-Type: application/json" \
		-d "{\"model\":\"$model_name\"}")

	echo "$response" | jq '.' 2>/dev/null || echo "$response"
	;;

restart)
	echo "Restarting llama-cpp service..."
	sudo systemctl restart llama-cpp.service
	echo "Waiting for service to be ready..."
	sleep 2
	$0 health
	;;

logs)
	lines="${1:-50}"
	echo "=== Recent Logs (last $lines lines) ==="
	journalctl -u llama-cpp.service -n "$lines" --no-pager
	;;

follow)
	echo "=== Following Logs (Ctrl+C to stop) ==="
	journalctl -u llama-cpp.service -f
	;;

help | --help | -h | "")
	cat <<EOF
llama-server Control Script
Usage: $0 <command> [args]

Commands:
  list, ls              List all available models
  status, props         Show server status and properties
  slots                 Show active slots (loaded models)
  health                Check server health
  unload <model>        Unload a specific model from memory
  unload all            Unload all models from memory
  load <model>          Load a specific model into memory
  restart               Restart the llama-cpp systemd service
  logs [n]              Show last n lines of logs (default: 50)
  follow                Follow logs in real-time
  help                  Show this help message

Environment Variables:
  LLAMA_HOST            Server host (default: 100.64.0.3)
  LLAMA_PORT            Server port (default: 11404)

Examples:
  $0 list                           # List all models
  $0 unload qwen-coder              # Unload specific model
  $0 unload all                     # Unload all models
  $0 load qwen-coder                # Load specific model
  $0 status                         # Check server status
  
Note: Model unload/load API may vary depending on llama.cpp version.
      If unload doesn't work, you can restart the service: $0 restart
EOF
	;;

*)
	echo "Error: Unknown command '$command'"
	echo "Run '$0 help' for usage information"
	exit 1
	;;
esac
