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
import sys
from docutils.core import publish_parts
from optparse import OptionParser
from docutils.frontend import OptionParser as DocutilsOptionParser
from docutils.parsers.rst import Parser

def transform(writer=None, part=None):
    p = OptionParser(add_help_option=False)

    # Collect all the command line options
    docutils_parser = DocutilsOptionParser(components=(writer, Parser()))
    for group in docutils_parser.option_groups:
        p.add_option_group(group.title, None).add_options(group.option_list)

    p.add_option('--part', default=part)

    opts, args = p.parse_args()

    settings = dict({
        'file_insertion_enabled': False,
        'raw_enabled': False,
    }, **opts.__dict__)

    if len(args) == 1:
        try:
            content = open(args[0], 'r').read()
        except IOError:
            content = args[0]
    else:
        content = sys.stdin.read()

    parts = publish_parts(
        source=content,
        settings_overrides=settings,
        writer=writer,
    )

    if opts.part in parts:
        return parts[opts.part]
    return ''