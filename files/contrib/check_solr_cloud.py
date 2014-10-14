#!/usr/bin/python2.7
"""check_solr_cloud.py.

Nagios plugin for checking the status of a SolrCloud instance by
examining the clusterstate.json file on zookeeper.

Usage:

check_solr_cloud.py --zkhosts=<zookeeper hosts> --collection=<collection>

    zkhosts: Comma-delimited list of zookeeper hosts with port numbers
    collection: Solr collection to check

NOTE: aggiunto "cose" da Lorenzo Cocchi <lorenzo.cocchi@softecspa.it>

"""

import argparse
import json
import kazoo.client
import sys
import time

# At least 1 active node per shard
# Only 1 active leader per shard
# Leader is active

# Config
ZK_HOSTS = 'localhost:9001'
SOLR_INDEX = 'index'

# Exit codes
STATE_OK = 0
STATE_WARNING = 1
STATE_CRITICAL = 2
STATE_UNKNOWN = 3

STATE_STR_OK = 'SOLR CLOUD OK'
STATE_STR_WARNING = 'SOLR CLOUD WARNING'
STATE_STR_CRITICAL = 'SOLR CLOUD CRITICAL'
STATE_STR_UNKNOWN = 'SOLR CLOUD UNKNOWN'


def exit_ok(message=None):
    if message:
        print('%s: %s' % (STATE_STR_OK, message))
    else:
        print(STATE_STR_OK)
    sys.exit(STATE_OK)


def exit_warning(message):
    print('%s: %s' % (STATE_STR_WARNING, message))
    sys.exit(STATE_WARNING)


def exit_critical(message):
    print('%s: %s' % (STATE_STR_CRITICAL, message))
    sys.exit(STATE_CRITICAL)


def main(zk_host, collections, verbose=False):
    collections = collections

    try:
        if verbose:
            print('Connect to: %s' % zk_host)
        zk_client = kazoo.client.KazooClient(hosts=zk_host, read_only=True)
        zk_client.start(timeout=5)
    except kazoo.handlers.threading.TimeoutError:
        exit_critical('Unable to connect to zookeeper hosts')

    try:
        cluster_state_str = zk_client.get('/clusterstate.json')[0]
    except kazoo.exceptions.NoNodeError:
        exit_critical('clusterstate.json file missing from zookeeper')

    try:
        if not collections:
            collections = zk_client.get_children('/collections')
        # workaround for threading bug
        time.sleep(0.001)
    except (kazoo.exceptions.NoNodeError,
            kazoo.exceptions.ZookeeperError) as e:
        exit_critical('get_children(/collections): %s' % e)

    if not collections:
        exit_critical('collections is empty')

    # cluster state
    c_state = json.loads(cluster_state_str)

    for collection in collections:
        if verbose:
            print('Check %s' % collection)
        for shard, shard_data in c_state[collection]['shards'].iteritems():
            at_least_one_active_node = False
            one_leader = False
            # replica
            for rep, rep_data in shard_data['replicas'].iteritems():
                if rep_data['state'] == 'active':
                    at_least_one_active_node = True
                if 'leader' in rep_data and rep_data['leader'] == 'true':
                    if one_leader:
                        exit_critical(
                            'More than one leader for shard: %s' % shard)
                    else:
                        one_leader = True
            if not at_least_one_active_node:
                zk_client.stop()
                exit_critical('No active nodes for shard: %s' % shard)
            if not one_leader:
                zk_client.stop()
                exit_critical('No leader for shard: %s' % shard)

    zk_client.stop()
    exit_ok()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-z', '--zkhosts',
                        help='Comma delimited list of zookeeper hosts with '
                        'port numbers', required=True)
    parser.add_argument('-c', '--collection', help='Solr colletion, can be '
                        'repeated', action='append', default=[])
    parser.add_argument('-v', '--verbose', help='verbose output',
                        action='store_true')
    args = parser.parse_args()
    main(args.zkhosts, args.collection, args.verbose)
