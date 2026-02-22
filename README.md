<details><summary> Linux and Mac </summary>

```sh
git clone https://github.com/chickengods/nvim-config.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

</details>


### FAQ

* Wait did this config start from [kickstart](https://github.com/nvim-lua/kickstart.nvim)
  * yes

### Environment Selection

This config can switch behavior by environment (`work` vs `personal`).

1. Copy `.nvim-env.example` to `.nvim-env`.
2. Set `NVIM_ENV=work` on your work machine and `NVIM_ENV=personal` on your personal machine.
3. Optional one-off override: launch Neovim with `NVIM_ENV=work nvim`.
