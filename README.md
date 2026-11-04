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
| `superpowers` | Brainstorming, planning, TDD, debugging, code review, parallel agents, worktrees, verification | [obra/superpowers](https://github.com/obra/superpowers) |
| `alpaca-trading` | Alpaca backtests and paper trading (API, CLI, MCP) | [alpacahq/alpaca-skills](https://github.com/alpacahq/alpaca-skills) |
| `youtube-gemini` | Ask Gemini about a public YouTube video | this repo |
| `code-review` | `/code-review` PR review with parallel agents and confidence filtering | [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-review) (Apache-2.0) |

Skills live in `.claude/skills/`, so sessions in this repo load them directly as well.

## Not included here

- `/fewer-permission-prompts` is built into Claude Code, so it already works in every repo.
- **Dev Loop: Fix, Commit and Ship** has no public source to vendor; install it from the Anthropic plugin directory on claude.ai.
