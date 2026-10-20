<p align="center">
  <img src="assets/banner.png" alt="The Rex T-rex chasing the Emacs logo" width="800">
</p>

# rexmacs

Emacs default key bindings for [Rex](https://www.superlogical.com/updates/public-testing-beginning), the terminal and multiplexer from Superlogical.

Rex has no built-in Emacs preset, so `init.lua` binds Emacs's default window, tab, frame and buffer keys to Rex's actions:

| Emacs | Rex |
| --- | --- |
| window | pane |
| tab | tab |
| frame | window |
| buffer | session |

## Install

```sh
mkdir -p ~/.config/rex
curl -fsSL https://raw.githubusercontent.com/millionco/rexmacs/main/init.lua -o ~/.config/rex/init.lua
rex config reload
```

If you already have an `init.lua`, save this one beside it as `rexmacs.lua` and add `require("rexmacs")` to yours.

## Bindings

| Keys | Emacs command | Rex action |
| --- | --- | --- |
| `M-x` / `Cmd-x` | execute-extended-command | Command palette |
| `C-x 2` | split-window-below | Split pane down |
| `C-x 3` | split-window-right | Split pane right |
| `C-x 0` | delete-window | Close pane |
| `C-x 1` | delete-other-windows | Zoom pane |
| `C-x o` | other-window | Focus next pane |
| `C-x +` | balance-windows | Balance splits |
| `C-x ^` | enlarge-window | Resize pane down |
| `C-x }` | enlarge-window-horizontally | Resize pane right |
| `C-x {` | shrink-window-horizontally | Resize pane left |
| `C-x t 2` | tab-new | New tab |
| `C-x t 0` | tab-close | Close tab |
| `C-x t o` | tab-next | Next tab |
| `C-x t O` | tab-previous | Previous tab |
| `C-x t r` | tab-rename | Rename tab |
| `C-x t m` | tab-move | Move tab forward |
| `C-x 5 2` | make-frame-command | New window |
| `C-x 5 0` | delete-frame | Close window |
| `C-x b` | switch-to-buffer | Change session |
| `C-x C-b` | list-buffers | Change session |
| `C-x →` / `C-x ←` | next-buffer / previous-buffer | Next / previous session |
| `C-x C-f` | find-file | Go to directory |
| `C-x C-+` / `C-x C-=` | text-scale-increase | Increase font size |
| `C-x C--` | text-scale-decrease | Decrease font size |
| `C-x C-0` | text-scale-adjust 0 | Reset font size |
| `C-x C-g`, `C-x t C-g`, `C-x 5 C-g` | keyboard-quit | Cancel the sequence |

## The terminal still gets C-x

Rex treats `C-x` as the start of a sequence, so on its own it no longer reaches the terminal. To keep shell and editor bindings working:

- Every `C-x <letter>` and `C-x C-<letter>` that rexmacs doesn't claim is passed through to the terminal unchanged, so `C-x C-e` (edit-command-line) and similar still work.
- `C-x C-x` sends a single literal `C-x`.

`C-x k` (kill-buffer) is deliberately left out, because closing a Rex session ends every process in it. `C-x k` passes through to the terminal like any other unclaimed key.

## Ctrl+M and Ctrl+G in the command palette

In Emacs, `C-m` is Return and `C-g` cancels. In the terminal, `C-m` already works as Return, because it sends the same character, and `C-g` reaches the program running there. In Rex's own text fields, like the command palette and the session switcher, both just beep: those are standard macOS text fields, and macOS binds neither key.

Rex's shortcuts can't fix this, because they apply everywhere, not just in the palette. A global `C-g` binding would also take the key away from Emacs and other programs in the terminal. Instead, tell macOS's text system that Ctrl+M means Return and Ctrl+G means Escape.

1. Create the file `~/Library/KeyBindings/DefaultKeyBinding.dict`:

   ```sh
   mkdir -p ~/Library/KeyBindings
   cat > ~/Library/KeyBindings/DefaultKeyBinding.dict <<'EOF'
   {
       "^m" = "insertNewline:";
       "^g" = "cancelOperation:";
   }
   EOF
   ```

   If you already have this file, add the two lines inside its braces instead of overwriting it.

2. Check the file is valid:

   ```sh
   plutil -lint ~/Library/KeyBindings/DefaultKeyBinding.dict
   ```

3. Quit Rex and open it again. Apps read this file only when they launch. Your sessions survive: they run in Rex Server, which keeps going when the window app quits. Do this from another terminal, such as Terminal.app, rather than from inside Rex:

   ```sh
   osascript -e 'quit app "Rex Beta"' && sleep 1 && open -a "Rex Beta"
   ```

The bindings apply to every Mac app that uses the standard text system, not just Rex. Ctrl+M submits a single-line field and starts a new line in a text editor. Ctrl+G does whatever Escape does there, such as closing the palette or cancelling a dialog. Chromium and Electron apps draw their own text fields and ignore the file. To undo it, delete the file and relaunch the app.

If you manage your Mac with Home Manager, declare the file instead:

```nix
home.file."Library/KeyBindings/DefaultKeyBinding.dict".text = ''
  {
      "^m" = "insertNewline:";
      "^g" = "cancelOperation:";
  }
'';
```

## Meta

For `M-f`, `M-b`, `M-d` and the rest to reach the shell, open Rex's Settings, search for "Option Key Behavior", and make Option act as Alt (both keys, or only the left one if you type accented characters with the right).
