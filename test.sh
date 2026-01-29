#!/bin/bash

cd "$(dirname "$0")"

# Test with 20% context usage (green)
echo "Test 1 - Low context (20%):"
echo '{"workspace":{"current_dir":"'"$PWD"'"},"model":{"display_name":"Opus 4.5"},"context_window":{"used_percentage":20,"total_input_tokens":15000,"total_output_tokens":5000,"context_window_size":200000}}' | bash statusline-command.sh
echo -e "\n"

# Test with 65% context usage (orange)
echo "Test 2 - Medium context (65%):"
echo '{"workspace":{"current_dir":"'"$PWD"'"},"model":{"display_name":"Opus 4.5"},"context_window":{"used_percentage":65,"total_input_tokens":100000,"total_output_tokens":30000,"context_window_size":200000}}' | bash statusline-command.sh
echo -e "\n"

# Test with 95% context usage (red)
echo "Test 3 - High context (95%):"
echo '{"workspace":{"current_dir":"'"$PWD"'"},"model":{"display_name":"Opus 4.5"},"context_window":{"used_percentage":95,"total_input_tokens":180000,"total_output_tokens":10000,"context_window_size":200000}}' | bash statusline-command.sh
echo -e "\n"
