# wakastat.nvim

Display your WakaTime coding stats in your Neovim statusline — supports daily, weekly, or monthly views, custom formatting, and async updates.

![wakastat screenshot](https://github.com/user-attachments/assets/4dba6071-bf6e-445e-9b2e-1e4ce5d120c8)

---

## ✨ Features

- ✅ Async WakaTime CLI integration via `vim.loop`
- ✅ Show coding time for `--today`, `--week`, or `--month`
- ✅ Custom text formatting
- ✅ Periodic refresh (default: every 5 minutes)
- ✅ Seamless with [heirline.nvim](https://github.com/rebelot/heirline.nvim)

---

## 📦 Installation

### 🔧 Requirements

- [`wakatime-cli`](https://github.com/wakatime/wakatime-cli) must be installed and accessible in your shell
- WakaTime API key configured (`~/.wakatime.cfg`)

---

### 🚀 Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "fiqryq/wakastat.nvim",
  config = function()
    local wakastat = require("wakastat")

    wakastat.setup {
      args = { "--today" },                      -- or "--week", "--month"
      format = "Coding Time: %s",                -- customize text display
      update_interval = 300,                     -- seconds between updates
    }

    require("heirline").setup {
      statusline = {
        -- your other statusline components
        {
          provider = wakastat.wakatime,
          hl = { fg = "cyan", bg = "NONE" },
        },
      },
    }
  end,
  dependencies = { "rebelot/heirline.nvim" },
}

```
