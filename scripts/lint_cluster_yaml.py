#!/usr/bin/env python3

import os
import sys
import glob
import yaml

def gather_yaml_files(path_pattern):
    return glob.glob(path_pattern)

def extract_cluster_values(yaml_file, keys_to_check):
    with open(yaml_file, 'r') as f:
        data = yaml.safe_load(f)
        cluster = data.get('cluster', {})
        return {key: cluster.get(key) for key in keys_to_check}

def main():
    if len(sys.argv) < 3:
        print("Usage: lint_yaml.py <path_pattern> <key1> <key2> ...")
        sys.exit(1)

    path_pattern = sys.argv[1]
    keys_to_check = sys.argv[2:]

    yaml_files = gather_yaml_files(path_pattern)

    extracted_values = {key: set() for key in keys_to_check}
    errors = []
    for yaml_file in yaml_files:
        values = extract_cluster_values(yaml_file, keys_to_check)
        for key, value in values.items():
            if value in extracted_values[key]:
                errors.append(f"Duplicate value '{value}' for key '{key}' found in {yaml_file}")
            else:
                extracted_values[key].add(value)

    if errors:
        for error in errors:
            print(error)
        sys.exit(1)
    else:
        print("No duplicates found for specified keys!")
        sys.exit(0)

if __name__ == '__main__':
    main()
