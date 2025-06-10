# wakastat.nvim
Display your WakaTime coding stats in your Neovim statusline — supports daily, weekly, or monthly views, custom formatting, and async updates.

![CleanShot 2025-06-10 at 19 27 50](https://github.com/user-attachments/assets/a9a60bf4-261e-4284-800f-72877eb628f0)


## ✨ Features
- ✅ Async WakaTime CLI integration via `vim.loop`
- ✅ Show coding time for `--today`, `--week`, or `--month`
- ✅ Custom text formatting
- ✅ Periodic refresh (default: every 5 minutes)
- ✅ Seamless integration with [heirline.nvim](https://github.com/rebelot/heirline.nvim)
- ✅ Compatible with AstroNvim, LazyVim, and other Neovim distributions

## 📦 Installation

### 🔧 Requirements
- [`wakatime-cli`](https://github.com/wakatime/wakatime-cli) must be installed and accessible in your shell
- WakaTime API key configured (`~/.wakatime.cfg`)

#### Installing wakatime-cli

**Using pip (Python):**
```bash
pip install wakatime
```

**Using Homebrew (macOS/Linux):**
```bash
brew install wakatime-cli
```

**Using Scoop (Windows):**
```bash
scoop install wakatime-cli
```

**Using Chocolatey (Windows):**
```bash
choco install wakatime
```

**Using winget (Windows):**
```bash
winget install WakaTime.WakaTime
```

**Using npm (Node.js):**
```bash
npm install -g @wakatime/cli
```

**Using go install:**
```bash
go install github.com/wakatime/wakatime-cli@latest
```

**Using apt (Debian/Ubuntu):**
```bash
sudo apt install wakatime
```
---

### 🚀 Using [lazy.nvim](https://github.com/folke/lazy.nvim)

#### Basic Setup
```lua
{
  "fiqryq/wakastat.nvim",
  config = function()
    require("wakastat").setup {
      args = { "--today" },           -- or "--week", "--month"
      format = "Coding Time: %s",     -- customize text display
      update_interval = 300,          -- seconds between updates
    }
  end,
  dependencies = { "rebelot/heirline.nvim" },
}
```

#### With Heirline Integration
```lua
{
  "fiqryq/wakastat.nvim",
  config = function()
    require("wakastat").setup {
      args = { "--today" },
      format = "Coding Time: %s",
      update_interval = 300,
    }
  end,
  dependencies = { "rebelot/heirline.nvim" },
}

-- Then in your heirline config:
{
  "rebelot/heirline.nvim",
  config = function()
    local heirline = require("heirline")
    local wakastat = require("wakastat")
    
    heirline.setup {
      statusline = {
        -- your other components
        { provider = "%=" }, -- flexible space
        {
          provider = function()
            return " " .. wakastat.wakatime() .. " "
          end,
          hl = { fg = "cyan", bg = "NONE" },
        },
      },
    }
  end,
}
```

#### AstroNvim Integration
```lua
-- In your plugins directory
{
  "fiqryq/wakastat.nvim",
  config = function()
    require("wakastat").setup {
      args = { "--today" },
      format = "Coding Time: %s",
      update_interval = 300,
    }
  end,
  dependencies = { "rebelot/heirline.nvim" },
}

-- In your heirline override (usually in lua/plugins/heirline.lua):
return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"
    
    -- Create WakaTime component
    local wakatime_component = {
      provider = function()
        return " " .. require("wakastat").wakatime() .. " "
      end,
      hl = { fg = "cyan", bg = "bg" },
    }
    
    -- Add to existing statusline
    table.insert(opts.statusline, #opts.statusline, wakatime_component)
    
    return opts
  end,
}
```

### 📦 Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
  "fiqryq/wakastat.nvim",
  requires = { "rebelot/heirline.nvim" },
  config = function()
    require("wakastat").setup {
      args = { "--today" },
      format = "Coding Time: %s",
      update_interval = 300,
    }
  end,
}
```

### 🔌 Using [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'rebelot/heirline.nvim'
Plug 'fiqryq/wakastat.nvim'
```

Then in your `init.lua`:
```lua
require("wakastat").setup {
  args = { "--today" },
  format = "Coding Time: %s",
  update_interval = 300,
}
```

### 📋 Using [mini.deps](https://github.com/echasnovski/mini.deps)
```lua
local add = MiniDeps.add

add("rebelot/heirline.nvim")
add("fiqryq/wakastat.nvim")

require("wakastat").setup {
  args = { "--today" },
  format = "Coding Time: %s",
  update_interval = 300,
}
```

### 🌊 Using [rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim)
```toml
[plugins]
"wakastat.nvim" = "scm"
"heirline.nvim" = "scm"
```

Then configure in your `init.lua`:
```lua
require("wakastat").setup {
  args = { "--today" },
  format = "Coding Time: %s",
  update_interval = 300,
}
```

## ⚙️ Configuration

### Default Configuration
```lua
require("wakastat").setup {
  args = { "--today" },           -- WakaTime CLI arguments
  format = "Today Coding Time: %s", -- Display format (%s will be replaced with time)
  update_interval = 300,          -- Update every 5 minutes (300 seconds)
}
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `args` | `table` | `{ "--today" }` | Arguments passed to wakatime-cli |
| `format` | `string` | `"Today Coding Time: %s"` | Display format string |
| `update_interval` | `number` | `300` | Seconds between updates |

### Available WakaTime Arguments
- `{ "--today" }` - Show today's coding time
- `{ "--week" }` - Show this week's coding time
- `{ "--month" }` - Show this month's coding time
- `{ "--year" }` - Show this year's coding time
- `{ "--range", "STARTDATE", "ENDDATE" }` - Custom date range

## 🎨 Usage Examples

### Different Time Periods
```lua
-- Today's stats
require("wakastat").setup {
  args = { "--today" },
  format = "Today: %s",
}

-- Weekly stats
require("wakastat").setup {
  args = { "--week" },
  format = "This Week: %s",
}

-- Monthly stats
require("wakastat").setup {
  args = { "--month" },
  format = "This Month: %s",
}
```

### Custom Formatting
```lua
require("wakastat").setup {
  args = { "--today" },
  format = "⏱️ %s coded today",
  update_interval = 180, -- Update every 3 minutes
}
```

### Integration with Statuslines

#### Lualine Example
```lua
require("lualine").setup {
  sections = {
    lualine_x = {
      function()
        return require("wakastat").wakatime()
      end,
    },
  },
}
```

#### Custom Statusline
```lua
-- Add to your statusline
function _G.wakatime_status()
  return require("wakastat").wakatime()
end

vim.o.statusline = "%f %m %r%= %{v:lua.wakatime_status()} %l,%c %P"
```

## 🤝 API Reference

### `setup(config)`
Initialize the plugin with configuration options.

### `wakatime()`
Returns the current WakaTime status string. This function is meant to be called from your statusline configuration.

### `add_to_heirline(existing_statusline)`
Helper function to add WakaTime component to an existing Heirline statusline configuration.

## 🛠️ Troubleshooting

### WakaTime CLI Not Found
Make sure `wakatime-cli` is installed and available in your PATH. Choose your preferred installation method:

**Package Managers:**
```bash
# Python (pip)
pip install wakatime

# Homebrew (macOS/Linux)
brew install wakatime-cli

# Scoop (Windows)
scoop install wakatime-cli

# Chocolatey (Windows)
choco install wakatime

# npm (Node.js)
npm install -g @wakatime/cli

# Go
go install github.com/wakatime/wakatime-cli@latest
```

**Verify installation:**
```bash
wakatime-cli --version
```

### No Data Showing
1. Verify WakaTime is configured with your API key in `~/.wakatime.cfg`
2. Check that you have coding activity logged in WakaTime
3. Test wakatime-cli manually: `wakatime-cli --today`

### Plugin Not Updating
The plugin updates every 5 minutes by default. You can:
- Reduce `update_interval` for more frequent updates
- Force update by restarting Neovim
- Check if wakatime-cli is responding: `wakatime-cli --today`


## 📄 License
MIT License - see LICENSE file for details.


## 🙏 Contributing
Pull requests and issues are welcome! Please check the existing issues before creating a new one.
