# social-creator

A **San persona** that turns ideas into social-media content — WeChat 公众号
articles, explainer-video scripts, 小红书 / X posts, and more.

> Evolved from the *video-creator* concept (idea → script → video) into a
> broader social-media content creator.

## What's inside

This repo **is** the persona — its files sit at the root, and the installers
copy them into `.san/personas/social-creator/`:

```
system/
  identity.md    # who: a senior social-media content creator (社媒主理人)
  behavior.md    # how: align-first workflow + per-platform playbooks
skills/
  inkpost/       # 文案 → 手绘图文长图 (图解/海报): template + headless-Chrome PNG exporter
settings.json    # description + skills: { inkpost: active }

install.sh · install.ps1 · uninstall.sh · uninstall.ps1   # tooling (not copied)
```

It overrides only the **identity** and **behavior** parts of San's system
prompt — San's built-in safety / tool / git rules stay in force (there is no
`rules.md`) — and bundles the **inkpost** skill, which turns copy into a
hand-drawn illustrated long-image sized per platform and exports it to PNG
(needs macOS + Google Chrome). The skill resolves its own directory at runtime,
so it works whether the persona is installed at project or user scope.

## One-line install (project scope by default)

**macOS / Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/genai-io/social-creator/main/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/genai-io/social-creator/main/install.sh | bash -s -- --user
```

**Windows (PowerShell 5.1+)**

```powershell
irm https://raw.githubusercontent.com/genai-io/social-creator/main/install.ps1 | iex
# user scope (scriptblock form is needed to pass options):
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/genai-io/social-creator/main/install.ps1))) -User
```

It copies the persona into `.san/personas/social-creator` and enables it by
setting `"persona": "social-creator"` in the target `settings.json` (other keys
preserved). Then run `san` in that directory and the persona is active. Both
scripts also run from a local checkout: `./install.sh [--user|--dir PATH]`.

Switch by hand anytime:

```
/persona social-creator    # activate
/persona default           # back to built-in San
```

## Uninstall

**macOS / Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/genai-io/social-creator/main/uninstall.sh | bash
curl -fsSL https://raw.githubusercontent.com/genai-io/social-creator/main/uninstall.sh | bash -s -- --user
```

**Windows**

```powershell
irm https://raw.githubusercontent.com/genai-io/social-creator/main/uninstall.ps1 | iex
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/genai-io/social-creator/main/uninstall.ps1))) -User
```

Removes the persona directory and drops the selection (only if it pointed at
this persona).

## Requirements

- [San](https://github.com/genai-io/san) — the agent CLI.
- `python3` for a safe `settings.json` merge (a fallback covers the
  no-existing-settings case without it).
