# Uses NvChad distribution

> [!TIP]
> **for Linux** <br/>
> `git clone https://github.com/sarrtle/.nvim.git .config/nvim`<br/>
> **for windows** <br/>
> `git clone https://github.com/sarrtle/.nvim.git appdata/local/nvim`
> - open your terminal and run `nvim`
> - wait for it to install then run `:Mason`
> - wait for it to load and run `:MasonInstallAll` this will install the plugins

### Python plugins
- basedpyright, ruff, black
### Web development plugins
- typescript-language-server, tailwindcss-language-server, prettierd, emmet-language-server, html, cssls
### Rust plugins
- rust-analyzer
- You need to install rust with **rustup** to get the rust-std.
### C++ plugins
- clangd, clang-format
- `clangd` is started with `--clang-tidy`, so linting comes from the language server itself and follows your project's `.clang-tidy`. There is no separate `clang-tidy` package in Mason, so don't go looking for one.
- Like every other mason package here, this puts `clangd` and `clang-format` in `~/.local/share/nvim/mason/bin`, which Mason prepends to `PATH`. Neovim therefore uses the mason copies even if you also have LLVM installed system-wide.
- clangd needs a compilation database to resolve headers and types. For CMake projects: `cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`, then symlink `build/compile_commands.json` into the project root. For anything else, a `compile_flags.txt` or a `.clangd` file works.
- `cpp` is in the treesitter parsers, and `clang-format` is wired to the `cpp` filetype only. `.c` files need `c` added to both lists themselves if you ever write plain C.
### Lua plugins
- lua-language-server, stylua
### QML plugins
- **qmlls**, started by this config as `qmlls6`, so **`qmlls6` must be in your `PATH`**
- It ships with Qt 6. Mason installs the same server as plain `qmlls`, so either install Qt 6 or symlink `qmlls6` to it
- `qmljs` is included in the treesitter parsers, and `qml` is one of the filetypes enabled for neocodeium

### Notes and features
1. **Auto formatting**: By following code writing standard, your code will be automatically clean from bad writing. Python, Rust, C++ and Web development works.
2. **Markdown preview**: Preview markdown files with keyboard mapping of `mm` for toggle or `md` for split view.
3. **AI auto suggestion**: Using `neocodeium`, this config has AI auto suggestions. To start, type command `:NeoCodeium auth` to get your API key from [Codeium](https://codeium.com/).

### Keymaps
| Mode | Keys | Action |
| ---- | ---- | ------ |
| normal | `;` | enter command mode |
| insert | `jk` | escape to normal mode |
| normal | `m` | toggle LSP inlay hints |
| normal | `mm` | toggle markdown preview (markview) |
| normal | `md` | toggle markdown split preview (markview) |
| normal | `<C-a>` | toggle code outline (aerial) |
| normal | `nt` | toggle code outline navigation window (aerial) |
| insert | `<A-f>` | AI suggestion: accept |
| insert | `<A-w>` | AI suggestion: accept word |
| insert | `<A-a>` | AI suggestion: accept line |
| insert | `<A-c>` | AI suggestion: clear |
| insert | `<A-E>` / `<A-R>` | AI suggestion: cycle forward / backward |

`<A-*>` are Alt combos (uppercase variants are Alt+Shift). All of these live in `lua/mappings.lua`, alongside NvChad's built-in leader mappings.
Note: since `m` is mapped on its own, the `mm` and `md` sequences make a lone `m` wait for `timeoutlen` before it applies.
