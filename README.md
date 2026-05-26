# SwipingDeath
repo for ai game dev contest

## Local preview

Do not open `index.html` directly from the filesystem. The page loads JSON config files with `fetch()`, and browsers block that under `file://`.

On Windows, double-click:

```text
Start_Local_Preview.bat
```

Or run:

```text
python -m http.server 4174 --bind 127.0.0.1
```

Then open:

```text
http://127.0.0.1:4174/index.html
```
