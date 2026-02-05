return function()
  require("obsidian").setup {
    workspaces = {
      {
        name = "main",
        path = "~/notes/main",
      },
      {
        name = "work",
        path = "~/notes/work",
      },
    },

    notes_subdir = "notes",
    daily_notes = {
      folder = "daily",
      date_format = "%Y-%m%d",
      default_tags = { "daily" },
      template = nil -- TODO add template
    },

    legacy_commands = false,

    completion = {
      --nvim_cmp = true,
      min_chars = 2,
    },

    new_notes_location = "notes_subdir",

    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      local suffix = ""
      if title ~= nil then
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.time()) .. "-" .. suffix
    end,

    wiki_link_func = function(opts)
      return require("obsidian.util").markdown_link(opts)
    end,

    preferred_link_style = "wiki",

    templates = {
      folder = "templates",
      date_format = "%Y-%m%d",
      time_format = "%I:%M %p",
      subsitutions = {},
    },

    picker = {
      name = "mini.pick",
    },

    search = {
      sort_by = "accessed",
      sort_reversed = true,
      max_lines = 1000,
    },

    open_notes_in = "vsplit",
  }
end
