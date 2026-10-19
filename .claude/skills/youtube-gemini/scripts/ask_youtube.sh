#!/usr/bin/env bash
# Ask Gemini a question about a public YouTube video.
#
# Usage: ask_youtube.sh <youtube-url> <question> [output-file]
#
# No API key is sent: the session's egress proxy injects x-goog-api-key for
# generativelanguage.googleapis.com. Never add a key header or ?key= here.
#
# Tries each model in GEMINI_MODELS in order. On a 503 (or a failed upstream
# connection) it waits GEMINI_RETRY_WAIT seconds and retries, up to
# GEMINI_RETRIES times, before moving on. Any other error (e.g. 404 for a
# retired model) moves straight to the next model.
#
# Prints the raw JSON response to stdout (and to output-file if given) and a
# log of attempts to stderr. Exits 0 on HTTP 200, 1 if every model failed.

set -uo pipefail

if [ $# -lt 2 ]; then
  echo "usage: $0 <youtube-url> <question> [output-file]" >&2
  exit 2
fi

URL=$1
QUESTION=$2
OUT=${3:-$(mktemp)}
MODELS=${GEMINI_MODELS:-"gemini-3.8-flash gemini-3.7-flash gemini-3.6-flash gemini-3.5-flash gemini-flash-latest"}
RETRIES=${GEMINI_RETRIES:-2}
WAIT=${GEMINI_RETRY_WAIT:-20}

BODY=$(jq -n --arg uri "$URL" --arg q "$QUESTION" \
  '{contents: [{parts: [{file_data: {file_uri: $uri}}, {text: $q}]}]}')

for MODEL in $MODELS; do
  for ((attempt = 0; attempt <= RETRIES; attempt++)); do
    CODE=$(curl -sS -o "$OUT" -w '%{http_code}' --max-time 300 \
      "https://generativelanguage.googleapis.com/v1beta/models/$MODEL:generateContent" \
      -H "Content-Type: application/json" -d "$BODY")
    echo "$MODEL attempt $((attempt + 1)) -> HTTP $CODE" >&2

    if [ "$CODE" = "200" ]; then
      cat "$OUT"
      exit 0
    fi

    # 503 = overloaded; 000/502/504 = upstream connection failed. Worth a retry.
    case "$CODE" in
      503 | 000 | 502 | 504)
        if [ "$attempt" -lt "$RETRIES" ]; then
          sleep "$WAIT"
          continue
        fi
        ;;
    esac
    cat "$OUT" >&2 2>/dev/null
    echo >&2
    break
  done
done

echo "All models failed: $MODELS" >&2
exit 1
