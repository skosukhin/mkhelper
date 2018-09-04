#!/usr/bin/env python
import os
import fnmatch

import argparse


def parse_args():
    parser = argparse.ArgumentParser(
        description='Reads a set of makefiles and returns a list of all '
                    'direct and indirect prerequisites for TARGET. Optionally '
                    'filters the list with PATTERN.')

    parser.add_argument('-t',
                        metavar='TARGET', nargs='+',
                        help='names of the make targets')
    parser.add_argument('-p',
                        metavar='PATTERN', default='*',
                        help='shell-like pattern to filter the list of '
                             'prerequisites (default: %(default)s)')
    parser.add_argument('-f',
                        metavar='MAKEFILE', nargs='+',
                        help='paths to simple makefiles that contain only '
                             'dependencies (no recipes)')
    return parser.parse_args()


def pick_prerequisites(dep_graph, targets, result=set()):
    for target in targets:
        prerequisites = dep_graph.get(target, None)
        if prerequisites:
            new_prerequisites = prerequisites - result
            result.update(new_prerequisites)
            pick_prerequisites(dep_graph, new_prerequisites, result)
    return result


def parse_dep_file_to_dict(dep_file, result):
    if os.path.isfile(dep_file):
        with open(dep_file, 'r') as f:
            line = f.readline()
            while line:
                while line.endswith('\\\n'):
                    line = line[:-2] + f.readline()
                split = line.strip().split(':', 1)
                if split[0]:
                    targets = set(split[0].split())
                    new_prerequisites = set(
                        split[1].replace('|', ' ').replace(':', ' ').split())
                    for t in targets:
                        old_prerequisites = result.get(t, None)
                        if old_prerequisites:
                            old_prerequisites.update(new_prerequisites)
                        else:
                            result[t] = new_prerequisites
                line = f.readline()


def main():
    args = parse_args()

    dep_graph = dict()
    for makefile in args.f:
        parse_dep_file_to_dict(makefile, dep_graph)

    if not args.t:
        args.t = dep_graph.keys()

    all_prerequisites = pick_prerequisites(dep_graph, args.t)

    filtered_prerequisites = fnmatch.filter(all_prerequisites, args.p)

    print('\n'.join(filtered_prerequisites))


if __name__ == "__main__":
    main()
