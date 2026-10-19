---
name: youtube-gemini
description: Ask Gemini a question about a public YouTube video (summary, timestamped outline, quotes, what happens at a given time) by sending the URL as file_data to the Gemini API. Use when the user gives a YouTube link and wants something answered about its content.
---

# YouTube video Q&A via Gemini

Gemini can watch a public YouTube video directly: pass the URL as `file_data.file_uri`
in a `generateContent` request, alongside a text part with the question.

## Authentication

Do **not** set an `x-goog-api-key` header or a `?key=` query parameter. The session's
egress proxy injects the key for `generativelanguage.googleapis.com` automatically.
If the response is `PERMISSION_DENIED` ("unregistered callers") or `API_KEY_INVALID`,
the environment's injected credential is missing or wrong: tell the user to fix it in
the environment settings rather than working around it.

## How to run

Use the bundled script (needs `curl` and `jq`):

```bash
.claude/skills/youtube-gemini/scripts/ask_youtube.sh \
  "https://www.youtube.com/watch?v=VIDEO_ID" \
  "Give me a timestamped outline of this video." \
  /path/to/scratchpad/resp.json
```

- Prints the raw JSON response to stdout (and writes it to the optional output file);
  logs each attempt to stderr. Exit 0 on success, 1 if every model failed.
- Retries can take a few minutes. Run it with a long timeout, or in the background
  if foreground `sleep` is restricted, and read the output file when it finishes.

The request it sends is exactly:

```bash
curl -sS "https://generativelanguage.googleapis.com/v1beta/models/$MODEL:generateContent" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[
        {"file_data":{"file_uri":"<youtube-url>"}},
        {"text":"<question>"}]}]}'
```

## Model fallback and retries

Models are tried in order: `gemini-3.8-flash`, `gemini-3.7-flash`, `gemini-3.6-flash`,
`gemini-3.5-flash`, `gemini-flash-latest`.

- **503** (high demand) or a failed upstream connection: wait 20 s and retry the same
  model, up to 2 retries, then move to the next model.
- **404** (model retired, e.g. `gemini-2.5-flash` is closed to new users) or any other
  error: move to the next model immediately.

Override with env vars: `GEMINI_MODELS` (space-separated list), `GEMINI_RETRIES`,
`GEMINI_RETRY_WAIT` (seconds). Check `GET /v1beta/models` if the list goes stale.

## Reporting back

- Show the answer from `candidates[0].content.parts[].text`; show the raw JSON if the
  user asked for it.
- Mention which model answered. `modelVersion` in the response may differ from the
  model in the URL (Google sometimes serves a newer one); say so if it does.
- `usageMetadata.promptTokensDetails` shows the video's token cost (roughly 100K
  tokens for a 15-minute video).
