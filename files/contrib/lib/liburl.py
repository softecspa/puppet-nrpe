import socket
import sys

PY3 = sys.version_info >= (3, 0)

if not PY3:
    import urllib2
else:
    import http
    import urllib.request as urllib2

__version__ = (0, 0, 1)
__author__ = 'Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>'
__all__ = ['Request']


class Request(object):

    def __init__(self, url, data=None, timeout=socket._GLOBAL_DEFAULT_TIMEOUT,
                 debug=False, authentication=None, headers={}):

        _handlers = []

        if debug:
            if not PY3:
                _handlers.extend([urllib2.HTTPHandler(debuglevel=debug),
                                  urllib2.HTTPSHandler(debuglevel=debug)])
            else:
                http.client.HTTPConnection.debuglevel = debug

        if authentication:
            try:
                username, password = authentication.split(':')
            except ValueError:
                raise ValueError('Wrong format of authentication data, '
                                 'username and password must to be separated '
                                 'by ":"')

            pswmgr = urllib2.HTTPPasswordMgrWithDefaultRealm()
            pswmgr.add_password(None, url, username, password)
            _handlers.extend([urllib2.HTTPBasicAuthHandler(pswmgr),
                              urllib2.HTTPDigestAuthHandler(pswmgr)])

        if _handlers:
            opener = urllib2.build_opener(*_handlers)
            urllib2.install_opener(opener)

        _request = urllib2.Request(url=url, data=data, headers=headers)
        self.response = urllib2.urlopen(_request, timeout=timeout)

        if not PY3:
            self.html = [l for l in self.response]
            self.headers = self.response.headers.dict
        else:
            # NOTE: Python3 does not read the html code as string
            # but as html code bytearray, convert to string with decode()
            self.html = [l.decode('utf-8', 'ignore') for l in self.response]
            self.headers = dict(self.response.getheaders())

        self.code = self.response.code
        self.url = self.response.geturl()

    def close(self):
        self.response.close()

    def __del__(self):
        self.close()

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: %s URL [timeout]' % (sys.argv[0]))
        sys.exit(1)

    url = sys.argv[1]

    try:
        timeout = float(sys.argv[2])
    except IndexError:
        timeout = 5.0

    user_agent = 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'
    headers = {'User-Agent': user_agent}

    try:
        response = Request(url=url, headers=headers, timeout=timeout)
    except ValueError as e:
        raise SystemExit('%s' % (e))
    except urllib2.HTTPError as e:
        raise SystemExit('%s %s' % (e.code, e.reason))
    except urllib2.URLError as e:
        raise SystemExit('%s' % e.reason)

    response.close()

    for line in response.html:
        for l in line:
            print(l, type(l))

    for k in response.headers:
        print('{::<22} {}'.format(k, response.headers[k]))
