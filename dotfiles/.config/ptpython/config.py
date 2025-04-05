from prompt_toolkit.filters import ViInsertMode
from prompt_toolkit.key_binding.key_processor import KeyPress
from prompt_toolkit.keys import Keys
from prompt_toolkit.styles import Style

from ptpython.layout import CompletionVisualisation

__all__ = ["configure"]


def configure(repl):
    repl.vi_mode = True

    repl.vi_keep_last_used_mode = True

    repl.use_code_colorscheme("dracula")

    @repl.add_key_binding("c-f", filter=ViInsertMode())
    def _(event):
        event.cli.key_processor.feed(KeyPress(Keys("c-i")))

    # corrections = {"improt": "import"}
    # keybinding to auto correct certain words
    # unfortunately it makes typing feel a little unresponsive
    # @repl.add_key_binding(" ")
    # def _(event):
    #     "When a space is pressed. Check & correct word before cursor."
    #     b = event.cli.current_buffer
    #     w = b.document.get_word_before_cursor()
    #
    #     if w is not None:
    #         if w in corrections:
    #             b.delete_before_cursor(count=len(w))
    #             b.insert_text(corrections[w])
    #
    #     b.insert_text(" ")
