-- rexmacs: Emacs default key bindings for Rex.
--
-- Emacs nouns map onto Rex like this:
--   Emacs window  -> Rex pane
--   Emacs tab     -> Rex tab
--   Emacs frame   -> Rex window
--   Emacs buffer  -> Rex session
--
-- Install: copy this file to ~/.config/rex/init.lua (or require it from
-- your own init.lua), then run `rex config reload`.

-- C-x <key> and C-x C-<key> that rexmacs does not claim still reach the
-- terminal, so shell and agent bindings such as C-x C-e keep working.
rex.action{
  name     = "rexmacs_send_keys",
  title    = "Send Keys",
  category = "rexmacs",
  args     = { keys = "array" },
  run      = function(ctx, args)
    for _, key in ipairs(args.keys) do
      rex.client.queue("pane.send_key", { key = key })
    end
  end,
}

-- M-x execute-extended-command
rex.bind("alt+x", "client.palette.toggle")

-- Windows (panes)
rex.bind("ctrl+x>2", "pane.split", { direction = "down" })  -- split-window-below
rex.bind("ctrl+x>3", "pane.split", { direction = "right" }) -- split-window-right
rex.bind("ctrl+x>0", "pane.close")                          -- delete-window
rex.bind("ctrl+x>1", "pane.zoom")                           -- delete-other-windows
rex.bind("ctrl+x>o", "pane.focus_next")                     -- other-window
rex.bind("ctrl+x>shift+=", "pane.balance")                  -- C-x +  balance-windows
rex.bind("ctrl+x>shift+6", "pane.resize", { direction = "down" })  -- C-x ^  enlarge-window
rex.bind("ctrl+x>shift+]", "pane.resize", { direction = "right" }) -- C-x }  enlarge-window-horizontally
rex.bind("ctrl+x>shift+[", "pane.resize", { direction = "left" })  -- C-x {  shrink-window-horizontally

-- Tabs (tab-bar-mode, C-x t)
rex.bind("ctrl+x>t>2", "client.tab.new")             -- tab-new
rex.bind("ctrl+x>t>0", "client.tab.close")           -- tab-close
rex.bind("ctrl+x>t>o", "client.tab.next")            -- tab-next
rex.bind("ctrl+x>t>shift+o", "client.tab.previous")  -- tab-previous
rex.bind("ctrl+x>t>r", "client.tab.rename")          -- tab-rename
rex.bind("ctrl+x>t>m", "client.tab.move.forward")    -- tab-move

-- Frames (windows, C-x 5)
rex.bind("ctrl+x>5>2", "client.window.new")    -- make-frame-command
rex.bind("ctrl+x>5>0", "client.window.close")  -- delete-frame

-- Buffers (sessions)
rex.bind("ctrl+x>b", "session.switch")         -- switch-to-buffer
rex.bind("ctrl+x>ctrl+b", "session.switch")    -- list-buffers
rex.bind("ctrl+x>right", "session.next")       -- next-buffer
rex.bind("ctrl+x>left", "session.previous")    -- previous-buffer

-- Files
rex.bind("ctrl+x>ctrl+f", "pane.go_to_directory")  -- find-file

-- Text scale (C-x C-+, C-x C-=, C-x C--, C-x C-0)
rex.bind("ctrl+x>ctrl+shift+=", "client.font.increase")
rex.bind("ctrl+x>ctrl+=", "client.font.increase")
rex.bind("ctrl+x>ctrl+-", "client.font.decrease")
rex.bind("ctrl+x>ctrl+0", "client.font.reset")

-- C-x C-g keyboard-quit: cancel the sequence and send nothing.
rex.bind("ctrl+x>ctrl+g", function() return true end)

-- C-x C-x sends a literal C-x, like tmux's prefix-prefix.
rex.bind("ctrl+x>ctrl+x", "pane.send_key", { key = "ctrl+x" })

-- Pass every other C-x <letter> and C-x C-<letter> through to the terminal.
local claimed = {}
for _, b in ipairs(rex.bindings()) do
  -- Claim each prefix too, so C-x t stays the start of the tab sequences.
  local prefix = ""
  for key in b.key:gmatch("[^>]+") do
    prefix = prefix == "" and key or prefix .. ">" .. key
    claimed[prefix] = true
  end
end
for c in ("abcdefghijklmnopqrstuvwxyz"):gmatch(".") do
  for _, key in ipairs({ c, "ctrl+" .. c }) do
    if not claimed["ctrl+x>" .. key] then
      rex.bind("ctrl+x>" .. key, "rexmacs_send_keys", { keys = { "ctrl+x", key } })
    end
  end
end
