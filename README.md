# social-creator

A **San persona** that turns ideas into social-media content — WeChat 公众号
articles, explainer-video scripts, 小红书 / X posts, and more.

> Evolved from the *video-creator* concept (idea → script → video) into a
> broader social-media content creator.

## What's inside

`persona/` is a San persona:

```
persona/
  system/
    identity.md    # who: a senior social-media content creator (社媒主理人)
    behavior.md    # how: align-first workflow + per-platform playbooks
  settings.json    # description
```

It overrides only the **identity** and **behavior** parts of San's system
prompt — San's built-in safety / tool / git rules stay in force (there is no
`rules.md`).

## Install (project scope by default)

```bash
./install.sh             # → ./.san/personas/social-creator  + enables it
./install.sh --user      # → ~/.san/personas/social-creator  (user scope)
./install.sh --dir PATH  # → PATH/.san/personas/social-creator
```

`install.sh` copies the persona and enables it by setting
`"persona": "social-creator"` in the target `settings.json` (other keys
preserved). Then run `san` in that directory and the persona is active.

Switch by hand anytime:

```
/persona social-creator    # activate
/persona default           # back to built-in San
```

## Uninstall

```bash
./uninstall.sh           # remove from ./.san and disable (project scope)
./uninstall.sh --user    # remove from ~/.san
```

## Requirements

- [San](https://github.com/genai-io/san) — the agent CLI.
- `python3` for a safe `settings.json` merge (a fallback covers the
  no-existing-settings case without it).
