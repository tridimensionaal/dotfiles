return {
  sources = function()
    local h = require("null-ls.helpers")
    local methods = require("null-ls.methods")

    local function decode_json(payload)
      if not payload or payload == "" then
        return nil
      end

      local ok, decoded = pcall(vim.json.decode, payload)
      if not ok or decoded == vim.NIL then
        return nil
      end

      return decoded
    end

    local to_diagnostics = h.diagnostics.from_json({
      attributes = {
        row = "line",
        col = "column",
        end_row = "endLine",
        end_col = "endColumn",
        code = "code",
        message = "message",
        severity = "level",
      },
      severities = { error = 1, warning = 2, info = 3, style = 4 },
    })

    local shellcheck = h.make_builtin({
      name = "shellcheck",
      method = methods.internal.DIAGNOSTICS,
      filetypes = { "sh", "bash" },
      generator_opts = {
        command = "shellcheck",
        args = { "-f", "json", "--severity", "info", "-" },
        format = "raw",
        check_exit_code = { 0, 1, 2 },
        to_stdin = true,
        on_output = function(params, done)
          local decoded = decode_json(params.output) or decode_json(params.err)
          if not decoded or vim.tbl_count(decoded) == 0 then
            return done()
          end

          params.output = decoded
          done(to_diagnostics(params))
        end,
      },
      factory = h.generator_factory,
    })

    return { shellcheck }
  end,
  tools = { "shellcheck" },
}
