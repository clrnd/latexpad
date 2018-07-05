LaTeXpad
=========

A LaTeX Scratchpad with simple save functionality.

* Type on the right, then click `save` to generate an URL
* Text is [Markdown](http://daringfireball.net/projects/markdown/) formatted
* Mathematics is `\(\LaTeX\)` formatted using [MathJax](http://www.mathjax.org/)

---

* Based on [Michael Gratton's Scratchpad](http://mjog.vee.net/latex-scratchpad/),
released under the [GNU AGPL v3](http://www.gnu.org/licenses/agpl.html)
* Made with [Servant](http://haskell-servant.readthedocs.io/)
and [acid-state](https://hackage.haskell.org/package/acid-state)

## Instalation

As simple as `stack build && stack install` and then `latexpad-server`.

## Extras

The API is documented with [Swagger](swagger.io). To build the docs
run `servant-swagger > docs.html` after building and open the resulting HTML file.

It also has a mock version with `latexpad-mock` which will
return random data.
