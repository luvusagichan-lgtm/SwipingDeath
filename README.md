# SwipingDeath

## Web Demo (Standalone)
https://luvusagichan-lgtm.github.io/SwipingDeath/

Current playable demo is fully web-based, using:

- `index.html`
- `assets/`
- `submissions/shinigami/config/`

The `0525/` folder is kept only as archived Godot source/release history and is **not required** for the web demo to run.

## Local Preview

Do not open `index.html` directly from `file://`.  
The page loads config files via `fetch()`, which browsers block in local-file mode.

On Windows, double-click:

```text
Start_Local_Preview.bat
```

Then open:

```text
http://127.0.0.1:4174/index.html
```
