# Plugin for translating text using OpenAI's GPT-4 API
# Author: Hannes Diercks
# Description: Provides a simple command-line translation tool using OpenAI's GPT-4 API

# Main translation function
function translate() {
    # Check if OPENAI_API_KEY is set
    if [[ -z "$OPENAI_API_KEY" ]]; then
        echo "Error: OPENAI_API_KEY environment variable is not set" >&2
        echo "Please set your OpenAI API key in your .zshrc or .zshenv file:" >&2
        echo "export OPENAI_API_KEY='your-api-key-here'" >&2
        return 1
    fi
    
    local num_options=1  # Default to 1 translation option
    local show_options=false
    local alfred_output=false

    # Parse options
    while getopts "n:ah" opt; do
        case $opt in
            n)
                if [[ $OPTARG =~ ^[0-9]+$ ]]; then
                    num_options=$OPTARG
                    show_options=true
                else
                    echo "Error: -n requires a number" >&2
                    return 1
                fi
                ;;
            a)
                alfred_output=true
                ;;
            h)
                echo "Usage: translate [-n NUM] [-a] <target language> <text to translate>"
                echo "Options:"
                echo "  -n NUM    Show NUM translation options (default: 1)"
                echo "  -a        Output in Alfred-compatible JSON format"
                echo "  -h        Show this help message"
                echo ""
                echo "Examples:"
                echo "  translate German Hello, how are you?"
                echo "  translate -n 3 German Hello, how are you?"
                echo "  translate -a -n 3 German Hello, how are you?"
                return 0
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    # Check if enough arguments were provided
    if [[ $# -lt 2 ]]; then
        echo "Usage: translate [-n NUM] [-a] <target language> <text to translate>"
        echo "Use -h for more information"
        return 1
    fi

    # First argument is the target language
    local lang="$1"
    shift

    # The rest is the text to translate
    local text="$*"

    # Adjust the system message based on whether we want multiple options
    local system_message
    if [[ $show_options == true ]]; then
        system_message="You are a translator. Translate the following text to $lang. Provide ONLY the most accurate and commonly used translations (up to $num_options). Do not try to reach $num_options if there aren't enough truly relevant translations. Focus on the most natural and widely accepted translations. Sort by frequency of use, with the most common translation first. Each translation on a new line. Do not number the options. Only output the translations, nothing else."
    else
        system_message="You are a translator. Translate the following text to $lang. Only output the translation, nothing else."
    fi

    # Make the API request to ChatGPT
    local temp_file=$(mktemp)
    curl -s https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "{
            \"model\": \"gpt-4.1-nano\",
            \"messages\": [
                {
                    \"role\": \"system\",
                    \"content\": \"$system_message\"
                },
                {
                    \"role\": \"user\",
                    \"content\": \"$text\"
                }
            ],
            \"temperature\": 0.1
        }" > "$temp_file"

    # Check if the API request was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to connect to OpenAI API" >&2
        rm -f "$temp_file"
        return 1
    fi

    # Extract the translation from the response using the temporary file
    if ! local translation=$(jq -r '.choices[0].message.content' "$temp_file" 2>/dev/null); then
        echo "Error: Failed to parse API response" >&2
        echo "API Response: $(cat "$temp_file")" >&2
        rm -f "$temp_file"
        return 1
    fi

    # Clean up the temporary file
    rm -f "$temp_file"

    # Check if we got a valid translation
    if [[ "$translation" == "null" || -z "$translation" ]]; then
        echo "Error: Failed to get translation from API response" >&2
        return 1
    fi

    # Output the translation(s)
    if [[ $show_options == true ]]; then
        if [[ $alfred_output == true ]]; then
            # Start JSON output
            echo -n '{"items":['
            local first=true
            echo "$translation" | while IFS= read -r line; do
                # Trim whitespace from the line
                line="${line#"${line%%[![:space:]]*}"}"
                line="${line%"${line##*[![:space:]]}"}"
                if [[ -n "$line" ]]; then
                    if [[ $first == true ]]; then
                        first=false
                    else
                        echo -n ","
                    fi
                    # Escape any double quotes in the line
                    local escaped_line="${line//\"/\\\"}"
                    echo -n "{\"title\":\"$escaped_line\",\"arg\":\"$escaped_line\"}"
                fi
            done
            echo "]}"
        else
            # Regular output
            echo "$translation" | while IFS= read -r line; do
                # Trim whitespace from the line
                line="${line#"${line%%[![:space:]]*}"}"
                line="${line%"${line##*[![:space:]]}"}"
                if [[ -n "$line" ]]; then
                    echo "$line"
                fi
            done
        fi
    else
        if [[ $alfred_output == true ]]; then
            # Single translation in Alfred format
            # Trim whitespace from the translation
            translation="${translation#"${translation%%[![:space:]]*}"}"
            translation="${translation%"${translation##*[![:space:]]}"}"
            local escaped_translation="${translation//\"/\\\"}"
            echo "{\"items\":[{\"title\":\"$escaped_translation\",\"arg\":\"$escaped_translation\"}]}"
        else
            # Trim whitespace from the translation
            translation="${translation#"${translation%%[![:space:]]*}"}"
            translation="${translation%"${translation##*[![:space:]]}"}"
            echo "$translation"
        fi
    fi
}

# Add completion for the translate function
function _translate() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        '-n[Number of translation options]:number:->number' \
        '-a[Output in Alfred format]' \
        '-h[Show help message]' \
        '1: :->language' \
        '*: :->text'

    case $state in
        number)
            # Complete with numbers 1-5
            compadd {1..5}
            ;;
        language)
            # Common languages for completion
            compadd German English Spanish Italian Portuguese French Polish
            ;;
        text)
            # No completion for the text to translate
            ;;
    esac
}

# Only install completion if compdef is available
(( $+functions[compdef] )) && compdef _translate translate 