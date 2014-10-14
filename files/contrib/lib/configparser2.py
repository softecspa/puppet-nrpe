#!/usr/bin/env python

"""The  Parser  Class  implements  a  basic  configuration  file  parser
language which provides a structure similar to what you  would  find  on
Microsoft Windows INI files.

You can use this to write  Python  programs
which can be customized by end users easily.

"""

__version__ = '0.1 alpha'
__author__ = 'Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>'

import sys
if sys.version_info[:2] < (2, 6):
    raise('Sorry, require Python >= 2.6')

if sys.version_info[:2] == (2, 6):
    import __future__

import codecs
import collections
import locale
import re

if sys.version_info[0] == 3:
    import configparser as ConfigParser
else:
    import ConfigParser


class ParserError(Exception):
    pass


class Parser(ConfigParser.SafeConfigParser):

    def __init__(self, filenames, option_lower_case=True,
                 allow_no_value=False, encoding=None):
        """Keywords arguments:

        filenames         -- list of named configuration files,
                             a single filename is also allowed.
        option_lower_case -- if False (default: True) returns not lower-case
                             version of option
        allow_no_value    -- if True (default: False), options without
                             (if python >= 2.7)
                             values are accepted
        encoding          -- charset, ex.: utf-8

        """

        if not encoding:
            encoding = locale.getpreferredencoding() or 'utf-8'

        if sys.version_info[:2] < (2, 7):
            ConfigParser.SafeConfigParser.__init__(self)
        else:
            ConfigParser.SafeConfigParser.__init__(
                self, allow_no_value=allow_no_value)

        if not option_lower_case:
            self.optionxform = str

        if isinstance(filenames, str):
            filenames = [filenames]

        try:
            for filename in filenames:
                with codecs.open(filename, 'r', encoding=encoding) as fh:
                    self.readfp(fh)
        except IOError as e:
            raise ParserError('%s: %s' % (e.filename, e.strerror))
        except ConfigParser.MissingSectionHeaderError as e:
            raise ParserError('%s: %s' % (e.filename, e.message))
        except Exception as e:
            raise ParserError('Uncaught Exception: %s' % e)

    def get_sections(self, pattern=None):
        """Keywords arguments:

        pattern -- pattern

        Returns list:
            [section1, section2, section3]

        """
        if not pattern:
            return self.sections()

        try:
            pattern = re.compile(pattern)
        except Exception as e:
            raise ParserError('re.compile(%r): %s' % (pattern, e))

        return [i for i in self.sections() if pattern.match(i)]

    def get_items(self, section, strip_quotes=False):
        """Keywords arguments:

        section      -- section name
        strip_quotes -- remove ' or " at the beginning or at the end of the
                        value

        Returns list of tuple
            [('opt1', 'val1'), ('opt2', 'val2')]

        """
        try:
            if not strip_quotes:
                return self.items(section)
            else:
                return [(k, v.strip('\'"')) for (k, v) in self.items(section)]
        except ConfigParser.NoSectionError as e:
            raise ParserError('%s' % e.message)
        except Exception as e:
            raise ParserError('Uncaught Exception: %s' % e)

    def get_dict(self, section, strip_quotes=False):
        """Keywords arguments:

        section      -- section name
        strip_quotes -- remove ' or " at the beginning or at the end of the
                        value

        Returns dict, ordered if python >= 2.7:
            {'key1:' 'value1', 'key2': 'value2' }

        """
        try:
            if not hasattr(collections, 'OrderedDict'):
                # if Python 3 (2.6 not compile)
                # return {k:v for(k, v)
                #         in self.get_items(section, strip_quotes)}
                return dict(self.get_items(section, strip_quotes))
            else:
                return collections.OrderedDict(self.get_items(section,
                                               strip_quotes))
        except ParserError:
            raise
