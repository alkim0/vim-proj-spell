# vim-proj-spell

vim-proj-spell is a vim plugin which enables project-specific spell files

## Installing
Install vim-proj-spell using either
[pathogen](https://github.com/tpope/vim-pathogen) or
[vundle](https://github.com/VundleVim/Vundle.vim). For example, for vundle, add the following lines to your ``~/.vimrc``:

    Plugin 'alkim0/vim-proj-spell'

## Usage
Create a `.spell` directory in your project root directory, then add a wordlist file.
The name of the wordlist file does not matter, all wordlists in `.spell` are sourced.
The wordlist is expected to be a single word per line.

Then open any file in the project, and the words should already be added to your list of spellfiles.
If you manually changed the wordlist files in `.spell`, you can call `:ProjSpellReload` to resource the wordlist files.

Because, vim-proj-spell messes with the `spellfile` setting, if you do not have `spellfile` specified, when you use `zg`, the word may not be saved to a permanent location.
To deal with this, either explicitly set your `spellfile`, or remap:
```
silent nnoremap zg :ProjSpellAddWordGlobal expand('<cword>')<cr>
```

I like `zG` to save words to the project-specific wordlist, so I also have:
```
silent nnoremap zG :ProjSpellAddWordProj expand('<cword>')<cr>
```

Note that this plugin will likely only work for Unix-like systems.
