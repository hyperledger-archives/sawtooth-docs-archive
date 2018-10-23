#!/usr/bin/env python

# The MIT License (MIT)
# Copyright (c) 2011 Greg Thornton, http://xdissent.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# :Author: David Goodger, the Pygments team, Guenter Milde
# :Date: $Date: $
# :Copyright: This module has been placed in the public domain.

# This is a merge of the `Docutils`_ `rst2html` front end with an extension
# suggestion taken from the `Pygments`_ documentation, reworked specifically
# for `Octopress`_.
#
# .. _Pygments: http://pygments.org/
# .. _Docutils: http://docutils.sourceforge.net/
# .. _Octopress: http://octopress.org/

"""
A front end to docutils, producing HTML with syntax colouring using pygments
"""

try:
    import locale
    locale.setlocale(locale.LC_ALL, '')
except:
    pass

from transform import transform
from docutils.writers.html4css1 import Writer
from docutils.core import default_description
from directives import Pygments

description = ('Generates (X)HTML documents from standalone reStructuredText '
               'sources. Uses `pygments` to colorize the content of'
               '"code-block" directives. Needs an adapted stylesheet'
               + default_description)

def main():
    return transform(writer=Writer(), part='html_body')

if __name__ == '__main__':
    print(main())
