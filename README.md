# wakastat.nvim

Display your [WakaTime](https://wakatime.com/) coding stats in your Neovim statusline — supports daily, weekly, or monthly views with custom formatting and auto-refresh.

<img width="1800" height="246" alt="CleanShot 2025-08-09 at 21 44 35" src="https://github.com/user-attachments/assets/14320645-4c2c-4ac3-be3a-8676c78a9bba" />


## ✨ Features

* Async WakaTime CLI integration
* Show coding time for today, this week, or this month
* Custom text formatting
* Auto-refresh (default: every 5 minutes)
* Easy integration with [heirline.nvim](https://github.com/rebelot/heirline.nvim)
* Works with AstroNvim, LazyVim, and more

## 📦 Requirements

* [`wakatime-cli`](https://github.com/wakatime/wakatime-cli) installed and in your PATH
* WakaTime API key in `~/.wakatime.cfg`

### Install `wakatime-cli`

Choose one:

```bash
pip install wakatime             # Python
brew install wakatime-cli        # macOS/Linux
scoop install wakatime-cli       # Windows
choco install wakatime           # Windows
npm install -g @wakatime/cli     # Node.js
go install github.com/wakatime/wakatime-cli@latest
sudo apt install wakatime        # Debian/Ubuntu
```

Check:

```bash
wakatime-cli --version
```

## 🚀 Installation & Setup (Lazy.nvim)

```lua
return {
  {
    "fiqryq/wakastat.nvim",
    event = "VeryLazy",
    cmd = { "WakastatRefresh", "WakastatStatus" },
    opts = {
      args = { "--today" },                  -- or "--week", "--month"
      format = "Today Coding Time: %s",      -- %s replaced with time
      update_interval = 300,                 -- seconds between updates
      enable_timer = true,
    },
    config = function(_, opts)
      require("wakastat").setup(opts)
    end,

    specs = {
      {
        "rebelot/heirline.nvim",
        optional = true,
        opts = function(_, opts)
          opts.statusline = opts.statusline or {}
          table.insert(opts.statusline, 5, {  -- insert at position 5
            provider = function()
              return " " .. require("wakastat").status() .. " "
            end,
            hl = "Wakastat",
            update = { "User", pattern = "WakastatUpdated" },
          })
        end,
      },
    },
  },
}
```


## ⚙️ Options

```lua
{
  args = { "--today" },            -- CLI arguments
  format = "Today Coding Time: %s",-- display format
  update_interval = 300,           -- update frequency (seconds)
  enable_timer = true,             -- auto-refresh
}
```

**Common `args` values:**

* `{ "--today" }` — today’s coding time
* `{ "--week" }` — this week
* `{ "--month" }` — this month
* `{ "--year" }` — this year


## 🛠 Troubleshooting

* **No data** → Make sure WakaTime is tracking and your API key is set in `~/.wakatime.cfg`
* **CLI not found** → Install `wakatime-cli` and confirm with `wakatime-cli --version`
* **Not updating** → Lower `update_interval` or run `:WakastatRefresh`
