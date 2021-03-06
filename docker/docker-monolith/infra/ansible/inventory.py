#!/usr/bin/env python3

import argparse
import json
import subprocess
from typing import List
import sys
from pathlib import Path

ENV = ['prod']

def parse_args():
    parser = argparse.ArgumentParser(description="Terraform inventory script")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--list', action='store_true')
    return parser.parse_args()

def list_running_hosts():
    instances = []
    for env in ENV:
        path = (str(Path(__file__).parent.absolute()) + '/' + '../terraform/' + env)
        cmd = (f'terraform -chdir={path} show -json')
        try:
            encode = subprocess.check_output(cmd.split()).rstrip()
            state = json.loads(encode)
            res = state['values']['root_module']['child_modules']
            instances.extend(get_instances(res))
        except:
            continue
    group_list = {}
    group_list['_meta'] = {}
    group_list['_meta']['hostvars'] = {}
    for i in instances:
        group_list['_meta']['hostvars'][i['values']['hostname']] = {}
        if i['values']['network_interface'][0]['nat_ip_address']:
            group_list['_meta']['hostvars'][i['values']['hostname']]['ansible_host'] = i['values']['network_interface'][0]['nat_ip_address']
        if i['name'] in group_list.keys():
            group_list[i['name']].append(i['values']['hostname'])
        else:
            group_list[i['name']] = []
            group_list[i['name']].append(i['values']['hostname'])
    return group_list

def get_instances(state: List) -> List:
    instances = []
    for i in state:
        for j in i['resources']:
            if j['type'] == 'yandex_compute_instance':
                instances.append(j)
    return instances

def main():
    args = parse_args()
    if args.list:
        hosts = list_running_hosts()
        json.dump(hosts, sys.stdout)

if __name__ == '__main__':
    main()
