return {
  sources = function(null_ls)
    local stylelint_config_files = {
      ".stylelintrc",
      ".stylelintrc.json",
      ".stylelintrc.yaml",
      ".stylelintrc.yml",
      ".stylelintrc.js",
      ".stylelintrc.cjs",
      ".stylelintrc.mjs",
      ".stylelintrc.ts",
      "stylelint.config.js",
      "stylelint.config.cjs",
      "stylelint.config.mjs",
      "stylelint.config.ts",
    }

    local function has_stylelint_config_file()
      local root = require("null-ls.utils").get_root()
      if not root then
        return false
      end

      for _, file_name in ipairs(stylelint_config_files) do
        if vim.fn.filereadable(root .. "/" .. file_name) == 1 then
          return true
        end
      end

      return false
    end

    local function has_package_json_stylelint()
      local root = require("null-ls.utils").get_root()
      if not root then
        return false
      end

      local package_json_path = root .. "/package.json"
      if vim.fn.filereadable(package_json_path) == 0 then
        return false
      end

      local ok_read, lines = pcall(vim.fn.readfile, package_json_path)
      if not ok_read then
        return false
      end

      local ok_decode, pkg = pcall(vim.json.decode, table.concat(lines, "\n"))
      return ok_decode and type(pkg) == "table" and pkg.stylelint ~= nil
    end

    return {
      null_ls.builtins.diagnostics.stylelint.with({
        filetypes = { "css", "scss", "less" },
        condition = function()
          return has_stylelint_config_file() or has_package_json_stylelint()
        end,
      }),
    }
  end,
  tools = { "stylelint" },
}
