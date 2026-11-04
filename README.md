# my-skills

My Claude Code skills, published as a plugin marketplace so any repo can use them.

## Use in another repo

In Claude Code:

```
/plugin marketplace add rodrigorey16/my-skills
/plugin install superpowers@my-skills
```

Or have a repo pick them up automatically by adding this to its `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "my-skills": {
      "source": { "source": "github", "repo": "rodrigorey16/my-skills" }
    }
  },
  "enabledPlugins": {
    "superpowers@my-skills": true,
    "code-review@my-skills": true
  }
}
```

## Plugins

| Plugin | What it does | Source |
| --- | --- | --- |
| `superpowers` | Brainstorming, planning, TDD, debugging, code review, parallel agents, worktrees, verification, plus the upstream SessionStart hook | [obra/superpowers](https://github.com/obra/superpowers), pinned commit |
| `alpaca-trading` | Alpaca backtests and paper trading (API, CLI, MCP) | [alpacahq/alpaca-skills](https://github.com/alpacahq/alpaca-skills) |
| `youtube-gemini` | Ask Gemini about a public YouTube video | this repo |
| `code-review` | `/code-review:code-review` PR review with parallel agents and confidence filtering | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-review), pinned commit |

`superpowers` and `code-review` install straight from their upstream repos at a pinned commit; bump the `sha` in `.claude-plugin/marketplace.json` to update them. `alpaca-trading` and `youtube-gemini` are served from `.claude/skills/`; bump their `version` when those skills change.

Sessions in this repo load the skills in `.claude/skills/` directly. The `code-review` plugin only appears after installing it from the marketplace.

### code-review notes

- Claude Code has a built-in `/code-review` skill with the same name. Run the plugin as `/code-review:code-review`.
- It uses the `gh` CLI. `--comment` posts inline comments through `mcp__github_inline_comment__create_inline_comment`, which only exists in the claude-code-action GitHub Action; elsewhere, run it without `--comment` (terminal output only).

## Not included here

- `/fewer-permission-prompts` is built into Claude Code, so it already works in every repo.
- **Dev Loop: Fix, Commit and Ship** has no public source to vendor; install it from the Anthropic plugin directory on claude.ai.
