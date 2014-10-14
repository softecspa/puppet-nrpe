#!/usr/bin/env python

"""Autore:

Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>

"""

import collections
import ConfigParser
import os
import re


class Parser(object):

    def __init__(self, config, option_lower_case=True):
        """Keywords arguments:

        config -- str or list file config
        option_lower_case -- if False returns not lower-case version of option

        """

        if not os.path.isfile(config):
            raise IOError('%s does not exist' % config)

        if not os.access(config, os.R_OK):
            raise IOError('%s access denied' % config)

        try:
            self.parser = ConfigParser.SafeConfigParser()

            if option_lower_case is False:
                self.parser.optionxform = str

            if len(self.parser.read(config)) == 0:
                raise RuntimeError('%s: is empty' % config)

        except ConfigParser.MissingSectionHeaderError, e:
            raise RuntimeError('%s: %s' % (e.filename, e.message))
        except Exception as e:
            raise RuntimeError('Uncaught Exception' % e)

    def get_sections(self, pattern=None):
        """Keywords arguments:

        pattern -- pattern

        Returns list:
            [section1, section2, section3]

        """

        if not pattern:
            return [section for section in self.parser.sections()]

        try:
            pattern = re.compile(pattern)
        except Exception, e:
            raise RuntimeError(e)

        return [section for section in self.parser.sections()
                if re.match(pattern, section)]

    def get_namevalue(self, section, strip_quotes=False):
        """Keywords arguments:

        section      -- section name
        strip_quotes -- remove ' or " at the beginning or at the end of the
                        value

        Returns dict:
            {'name:' 'value', 'name': 'value'}

        """
        d = collections.defaultdict(str)

        try:
            for option in self.parser.options(section):
                if not strip_quotes:
                    d[option] = self.parser.get(section, option)
                else:
                    d[option] = self.parser.get(section, option).strip('\'"')
        except ConfigParser.NoSectionError as e:
            raise RuntimeError('%s' % e.message)
        except Exception as e:
            raise RuntimeError('Uncaught Exception' % e)

        return d
