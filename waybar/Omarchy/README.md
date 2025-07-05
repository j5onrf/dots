### paruf alias for easy package search  (2025-July5)

Custom `paru` alias for finding and installing packages:

```bash
alias paruf="paru -Slq | fzf --multi --preview 'paru -Sii {1}' --preview-window=down:75% | xargs -ro paru -S"
```

![FullScreen-2025-07-05_10-45-03](https://github.com/user-attachments/assets/fb2f19e1-2020-4b37-b863-0aadd13af356)
