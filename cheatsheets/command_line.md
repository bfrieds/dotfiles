Command Line FU
==================

<C-x> <C-e>       | Opens a text editor to write a command in
<ESC> .           | The arguments from the last line
<space> command   | Command wont be saved in history
<C-u> [...] <C-y> | Yank the current line, run another command, paste the original line
vim -x filename   | Encrypt file
<ESC> *           | Insert autocompletion results on the command line

Tmux
======================

Copy Paste
	<prefix [> Enter copy mode
	Space      Start selection
			   * Highlight Selection *
	<CR>       Copy to Tmux Buffer
			   * Navigate to Paste Location *
	<prefix	]> Paste From Buffer

Other Copy Paste
	tmux show-buffer
	tmux save-buffer file_name.txt
	tmux list-buffers
	tmux show-buffer -b [buff_index]
	tmux save-buffer -b [buff_index]
