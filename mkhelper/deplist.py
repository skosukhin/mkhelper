#!/usr/bin/env python
import os
import re
import sys
import fnmatch

try:
    import argparse
except ImportError:
    import _argparse as argparse

_re_rule = re.compile(
    r'^[ ]*([-\w./]+(?:[ ]+[-\w./]+)*)[ ]*'  # targets
    r':(?:[ ]*([-\w./]+(?:[ ]+[-\w./]+)*))?[ ]*'  # normal prerequisites
    r'(?:\|[ ]*([-\w./]+(?:[ ]+[-\w./]+)*))?')  # order-only prerequisites
_meta_root = 0


def parse_args():
    parser = argparse.ArgumentParser(
        description='Reads a set of makefiles and returns a list of all '
                    'direct and indirect dependencies or dependants of the '
                    'TARGET(s).')

    parser.add_argument(
        '-d', '--debug-file',
        help='dump debug information to DEBUG_FILE')
    parser.add_argument(
        '-t', '--target', nargs='*',
        help='names of the make targets (or prerequisites, see --reverse); if '
             'not specified, all targets (or prerequisites) found in '
             'MAKEFILE(s) are considered as children of a meta target, which '
             'is the default value of the argument')
    parser.add_argument(
        '-p', '--pattern', action='append',
        help='shell-like pattern to filter the list of '
             'dependencies/dependants (default: %(default)s)')
    parser.add_argument(
        '--inc-oo', action='store_true',
        help='include order-only dependencies')
    parser.add_argument(
        '-l', '--max-level', type=int,
        help='positive integer, maximum recursion level when traversing the '
             'dependency graph: 1 - to consider only children, 2 - to '
             'consider children and their children, etc.; if not specified, '
             'all descendants of the TARGET(s) are considered')
    parser.add_argument(
        '-r', '--reverse', action='store_true',
        help='reverse the dependency graph: makefile targets become children '
             'of their prerequisites')
    parser.add_argument(
        '-f', '--makefile', nargs='*',
        help='paths to makefiles')

    args = parser.parse_args()

    if not args.target:
        args.target = [_meta_root]

    return args


def get_descendants(dep_graph, roots, max_level=None):
    result = set()
    for root in roots:
        descendants = _get_descendants(dep_graph, root, max_level, set())
        if descendants:
            result.update(descendants)
    return result


def build_dep_graph(makefiles, reverse=False, inc_order_only=False):
    result = dict()
    for f in makefiles:
        _update_dep_graph(result, f, reverse, inc_order_only)
    result[_meta_root] = set(result.keys())
    return result


def main():
    args = parse_args()

    if args.debug_file:
        with open(args.debug_file, 'w') as debug_file:
            debug_file.writelines([
                '# Python version: ', sys.version.replace('\n', ' '), '\n',
                '# Command:\n',
                '  ', '\n    '.join(sys.argv), '\n',
                '# Parsed arguments:\n ',
                '\n '.join(
                    [k + '=' + str(v) for k, v in vars(args).items()]), '\n'])

    if args.makefile is None:
        return

    dep_graph = build_dep_graph(args.makefile, args.reverse, args.inc_oo)

    if not dep_graph:
        return

    descendants = get_descendants(dep_graph, args.target, args.max_level)

    if not args.pattern:
        print('\n'.join(descendants))
    elif len(args.pattern) == 1:
        print('\n'.join(fnmatch.filter(descendants, args.pattern[0])))
    else:
        print('\n'.join(
            [descendant
             for descendant in descendants if any(
                [fnmatch.fnmatch(descendant, pattern)
                 for pattern in args.pattern])]))


def _get_descendants(dep_graph, root, max_level, visited):
    if max_level is not None:
        if max_level < 1:
            return None
        else:
            max_level -= 1

    children = dep_graph.get(root, None)
    if children is None:
        return None

    visited.add(root)

    result = children - visited

    if max_level is not None and max_level < 1:
        return result

    for child in children:
        if child not in visited:
            new_descendants = _get_descendants(
                dep_graph, child, max_level, visited)
            if new_descendants:
                result.update(new_descendants)
    return result


def _update_dep_graph(dep_graph, makefile, reverse, inc_order_only):
    if not os.path.isfile(makefile):
        return

    with open(makefile, 'r') as f:
        while True:
            line = f.readline()
            if not line:
                break

            while line.endswith('\\\n'):
                line = line[:-2] + f.readline()

            match = _re_rule.match(line)
            if match:
                parents = set(match.group(1).split())
                new_children = set()

                if match.group(2):
                    new_children.update(match.group(2).split())

                if match.group(3) and inc_order_only:
                    new_children.update(match.group(3).split())

                if not new_children:
                    continue

                if reverse:
                    parents, new_children = new_children, parents

                for p in parents:
                    known_children = dep_graph.get(p, None)
                    if known_children:
                        known_children.update(new_children)
                    else:
                        dep_graph[p] = new_children


if __name__ == "__main__":
    main()
