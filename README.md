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

### Tools
1. AI assistant: A prototype AI assistant builtin for this project
- Requirements: add gemini token to your environment variable: `export GOOGLE_API_KEY=YOUR_API_KEY`
- type `tt` in your keyboard to open the chat window
- `td` to close the chat window
- `tu` to navigate to the response window, `tt` for user input again, `tr` for clearing all session--you need to tap ENTER, `tl` and `th` for history navigation.

### Notes and features
1. **Auto formatting**: By following code writing standard, your code will be automatically clean from bad writing. Python, Rust and Web development works.
2. **Markdown preview**: Preview markdown files with keyboard mapping of `mm` for toggle or `md` for split view.
3. **AI auto suggestion**: Using `Codeium`, this config has AI auto suggestions. To start, type command `:NeoCodeium auth` to get your API key from [Codeium](https://codeium.com/).
