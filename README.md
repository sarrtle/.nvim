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
- typescript-language-server, svelte-language-server, tailwindcss-language-server, prettierd, emmet-language-server, html, cssls
### Rust plugins
- rust-analyzer
- You need to install rust with **rustup** to get the rust-std.

### Notes and features
1. **Auto close tags on react html and svelte**: whenever you write any html tags, it will be automatically close. `<p>This is a paragraph</p>`
2. **Auto formatting**: By following code writing standard, your code will be automatically clean from bad writing. Both python and Web development works.
3. **Markdown preview**: Preview markdown files with keyboard mapping of `mm` for toggle or `md` for split view.
4. **AI auto suggestion**: Using `Codeium`, this config has AI auto suggestions. To start, type command `:NeoCodeium auth` to get your API key from [Codeium](https://codeium.com/).
