# nvim

My [LazyVim](https://github.com/LazyVim/LazyVim) based Neovim configuration, synced across macOS and Linux machines.

## Highlights

- **Completion**: [blink.cmp](https://github.com/Saghen/blink.cmp) with a minimal preset
- **AI**: [claude-code.nvim](https://github.com/coder/claudecode.nvim) under `<leader>a` (send selection, accept/deny diffs, ...)
- **Utilities**: [snacks.nvim](https://github.com/folke/snacks.nvim) — zoom (`<leader>m`), scroll toggle, LSP symbols picker (`<leader>v`)
- **Navigation**: custom split workflow (`<LocalLeader>x` / `<LocalLeader>c`), window cycling with `` ` ``, `zm` fold toggle
- **Note capture**: `<LocalLeader>n` in visual mode appends the selection to an Obsidian notes file (fenced with the filetype)
- **My plugins**: [waymark.nvim](https://github.com/Michael-Zs/waymark.nvim) (buffer waymarks), [ref.nvim](https://github.com/Michael-Zs/ref.nvim) (reference notes)
- Personal keymap tweaks: `jf` exits insert mode, `J`/`K` scroll half pages, `-` jumps to end of line

## Install

Requires Neovim ≥ 0.9 (see [LazyVim prerequisites](https://lazyvim.github.io/installation)).

```bash
git clone https://github.com/Michael-Zs/nvim.git ~/Prj/nvim
ln -s ~/Prj/nvim ~/.config/nvim
```

Then start `nvim` — plugins are installed automatically. `lazy-lock.json` is committed so you get the same plugin versions I use.

### Optional: note capture target

`<LocalLeader>n` appends notes to `~/Documents/obsidian/notes/tech/notes.md` by default. Override with:

```bash
export OBSIDIAN_NOTES_FILE=/path/to/your/notes.md
```

## Structure

```
lua/
├── config/       # options, keymaps, autocmds, split/window/fold helpers
└── plugins/      # lazy.nvim plugin specs
```

## License

[Apache 2.0](LICENSE)
