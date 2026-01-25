-- lua/plugins/oil.lua
local M = {}

function M.setup()
  local ok, oil = pcall(require, "oil")
  if not ok then
    return
  end

  oil.setup({
    default_file_explorer = true,

    -- Nice in-terminal layout
    columns = {
      "icon",
      "permissions",
      "size",
      "mtime",
    },

    -- Keep things stable/predictable
    skip_confirm_for_simple_edits = true,
    prompt_save_on_select_new_entry = true,
    cleanup_delay_ms = 2000,

    -- Hide some clutter, but keep dotfiles toggleable
    view_options = {
      show_hidden = true, -- dotfiles visible by default
      is_hidden_file = function(name, _)
        -- Hide common junk
        return name == ".DS_Store" or name == "thumbs.db"
      end,
      is_always_hidden = function(name, _)
        -- Never show these
        return name == ".git"
      end,
      natural_order = true,
      sort = {
        { "type", "asc" },
        { "name", "asc" },
      },
    },

    -- Keymaps inside the Oil buffer
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-s>"] = "actions.select_vsplit",
      ["<C-h>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",

      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",

      ["g."] = "actions.toggle_hidden",

      ["q"] = "actions.close",
      ["<Esc>"] = "actions.close",

      ["R"] = "actions.refresh",

      ["<BS>"] = "actions.parent",
    },

    -- Optional: open directories in the same window instead of netrw-style splits
    -- use_default_keymaps = true, -- leave default keymaps enabled; we override specific ones above
  })

  -- Optional global mapping: open Oil in current file's directory
  -- (You already mapped "-" in your plugin spec; keep ONE of these to avoid dupes.)
  vim.keymap.set("n", "<leader>o", "<cmd>Oil<cr>", {
    desc = "Open Oil",
  })
end

return M
