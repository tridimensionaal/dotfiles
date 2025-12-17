local ok, blink = pcall(require, "blink.cmp")

if ok and blink.get_lsp_capabilities then
  return blink.get_lsp_capabilities()
end

return vim.lsp.protocol.make_client_capabilities()
