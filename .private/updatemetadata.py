#!/usr/bin/python

import argparse
import os
import sys
import yaml
import glob
import json
from collections import OrderedDict

def main():
    parser = argparse.ArgumentParser(description='convert metadata from chooselicense.com')
    parser.add_argument('-v', '--verbose')
    parser.add_argument('-d', '--debug', action='store_true', default=False)
    parser.add_argument('rules', type=str, nargs=1, help="rules.yml")
    parser.add_argument('license', type=str, nargs=1, help="license")
    args = parser.parse_args()

    r = open(args.rules[0])
    fdir = args.license[0]
    rules = yaml.load(r)
    fields = [ "limitations","permissions","conditions"]
    licenses = []
    for fname in glob.iglob(fdir+"/*.txt") :
        spdxid = os.path.splitext(os.path.basename(fname))[0].upper()
        doc = next(yaml.load_all(open(fname)))
        out = [(k,v) for (k,v) in doc.items() if k in fields]
        licenses.append((spdxid,dict(out)))
    json.dump(dict(licenses),sys.stdout, indent=2)
    json.dump(rules,sys.stdout, indent=2)

if __name__ == '__main__':
    main()


