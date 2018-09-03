import fnmatch
import argparse


def pick_prerequisites(dep_graph, target, result=set()):
    prerequisites = dep_graph.get(target, None)
    if prerequisites:
        new_prerequisites = prerequisites - result
        result.update(new_prerequisites)
        for p in new_prerequisites:
            pick_prerequisites(dep_graph, p, result)
    return result


def parse_dep_file_to_dict(dep_file, result=dict()):
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
    parser = argparse.ArgumentParser(
        description='Reads a set of makefiles and returns a list of '
                    'all direct and indirect prerequisites for TARGET. '
                    'Optionally filters the list with PATTERN.')
    parser.add_argument('target',
                        metavar='TARGET',
                        help='name of the target')
    parser.add_argument('-p',
                        metavar='PATTERN', default='*',
                        help='shell-like pattern to filter the list of '
                             'prerequisites (default: %(default)s)')
    parser.add_argument('makefile',
                        metavar='MAKEFILE', nargs='+',
                        help='path to a simple makefile that contains only '
                             'dependencies (no recipes)')
    args = parser.parse_args()

    dep_graph = dict()
    for makefile in args.makefile:
        parse_dep_file_to_dict(makefile, dep_graph)

    prerequisites = pick_prerequisites(dep_graph, args.target)

    print('\n'.join(fnmatch.filter(prerequisites, args.p)))


if __name__ == "__main__":
    main()
