return {
  settings = {
    pyright = { autoImportCompletion = true, openFilesOnly = true },
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
        typeCheckingMode = "strict",
        venvPath = ".venv",
      },
    },
  },
}
