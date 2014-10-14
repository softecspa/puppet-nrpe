#!/usr/bin/env python

import argparse
import re
import sys
import time

try:
    import nagiosrange
except ImportError as e:
    print('ImportError: %s', e)
    sys.exit(2)


class NagPlugin(object):
    RETSTRING = {0: 'OK', 1: 'WARNING', 2: 'CRITICAL', 3: 'UNKNOWN'}
    RETCODE = {'OK': 0, 'WARNING': 1, 'CRITICAL': 2, 'UNKNOWN': 3}
    returncode_value = [0, 1, 2, 3]
    perfdata_uom_value = ['s', '%', 'B', 'KB', 'MB', 'TB', 'c']

    def __init__(self, **kwargs):
        self.pluginname = kwargs.get('pluginname') or ''
        self.version = kwargs.get('version') or None
        self.tagstatusline = kwargs.get('tagstatusline') or ''
        self.description = kwargs.get('description') or ''
        self.argparser = argparse.ArgumentParser(description=self.description)
        self.cmdlineoptions_parsed = False
        self.output = ''
        self.multilineoutput = []
        self.performancedata = []
        self.returncode = ''

    def add_cmdlineoption(self, shortoption, longoption, dest, help,
                          **kwargs):
        self.argparser.add_argument(shortoption, longoption, dest=dest,
                                    help=help, **kwargs)

    def parse_error(self, msgerr):
        self.argparser.error(str(msgerr))

    def parse_cmdlineoptions(self):
        if self.cmdlineoptions_parsed:
            return
        # -V version (--version) & -v verbose (--verbose)
        # http://nagiosplug.sourceforge.net/developer-guidelines.html
        if self.version:
            self.argparser.add_argument('-V', '--version', action='version',
                                        version=self.version)
        self.argparser.add_argument('-v', '--verbose', dest='verbose',
                                    help='Verbosity, more and more...',
                                    action='count', default=0)
        self.options = self.argparser.parse_args()
        self.cmdlineoptions_parsed = True

    def add_output(self, value):
        self.output = value

    def add_returncode(self, value):
        self.returncode = value

    def format_performancedata(self, label, value, unit, *args, **kwargs):
        label = label.strip()

        if re.search('[=\' ]', label):
            label = '\'%s\'' % (label)
        perfdata = '%s=%s' % (label, str(value))

        if unit:
            if self.check_if_as_member(self.perfdata_uom_value, unit):
                perfdata = '%s%s' % (perfdata, str(unit).strip())
            else:
                print('%s is NOT valid unit for perfdata' % (unit))
                return self.RETCODE['UNKNOWN']

        for key in ['warn', 'crit', 'min', 'max']:
            perfdata = '%s;' % (perfdata)
            if key in kwargs and kwargs[key] is not None:
                perfdata = '%s%s' % (perfdata, str(kwargs[key]))

        return perfdata

    def append_performancedata(self, perfdata):
        self.performancedata.append(perfdata)

    def add_performancedata(self, label, value, unit, *args, **kwargs):
        self.append_performancedata(self.format_performancedata(
                                    label, value, unit, *args, **kwargs))

    def add_multilineoutput(self, value):
        self.multilineoutput.append(value)

    def check_if_as_member(self, obj, value):
        if value in obj:
            return True
        return False

    def verbose(self, level, output):
        if level <= self.options.verbose:
            print('V%s: %s' % (str(level), output))

    def date_from_timestamp(self, timestamp):
        year, mon, mday, hour, min, sec = time.localtime(timestamp)[:6]
        date = '%s-%s-%s %s:%s:%s' % (year, mon, mday, hour, min, sec)
        return date

    def str_to_float(self, x):
        """
        Return string or number to a floating point number ... if possible
        or return original string or number
        """
        f = x
        try:
            f = float(x)
        except ValueError:
            pass
        return f

    def value_in_range(self, nagios_range, threshold):
        """
        TODO
        """
        nagios_range = str(nagios_range)
        try:
            check = nagiosrange.Range(nagios_range)
        except nagiosrange.RangeValueError as e:
            raise ValueError(str(e))
        try:
            return check.in_range(threshold)
        except nagiosrange.RangeValueError as e:
            raise ValueError(str(e))

    def value_wc_to_returncode(self, value, range_warn, range_crit):
        if range_crit and self.value_in_range(range_crit, value):
            return self.RETCODE['CRITICAL']
        if range_warn and self.value_in_range(range_warn, value):
            return self.RETCODE['WARNING']
        if range_warn or range_crit:
            return self.RETCODE['OK']
        else:
            return self.RETCODE['UNKNOWN']

    def ret2nagios(self, returncode, statusline=None, multiline=None,
                   performancedata=None):
        if self.tagstatusline:
            out = '%s %s' % (self.tagstatusline, self.RETSTRING[returncode])
        else:
            out = self.RETSTRING[returncode]

        if statusline:
            out = '%s -' % (out)
            if type(statusline) == str:
                out = '%s %s' % (out, statusline)
            elif type(statusline) in [list, tuple]:
                out = '%s %s' % (out, ', '.join(statusline).replace('|', ' '))

        if multiline:
            if type(multiline) == str:
                out = '%s\n%s' % (out, multiline.replace('|', ' '))
            elif type(multiline) in [list, tuple]:
                out = '%s\n%s' % (out, '\n'.join(multiline).replace('|', ' '))

        if performancedata:
            out = '%s|' % (out)
            if type(performancedata) == str:
                out = '%s%s' % (out, performancedata)
            elif type(performancedata) in [list, tuple]:
                out = '%s%s' % (out,
                                ' '.join(performancedata).replace('|', ' '))

        print(out)
        sys.exit(returncode)

    def check_returncode(self, returncode):
        if self.check_if_as_member(self.returncode_value, returncode):
            return returncode
        else:
            err = 'Nagios do NOT support returncode %s' % (returncode)
            raise ValueError(err)
        return returncode

    def exit(self):
        returncode = self.check_returncode(self.returncode)
        self.ret2nagios(returncode, statusline=self.output,
                        multiline=self.multilineoutput,
                        performancedata=self.performancedata)
