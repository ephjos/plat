#!/usr/bin/env python
from shutil import copyfile

def level_name(num):
    return "Level_" + str(num).zfill(2)

def create_file_from(src, dst, replaces):
    with open(src, "rt") as fin:
        with open(dst, "wt") as fout:
            for line in fin:
                buf = line
                for l, r in replaces:
                    buf = buf.replace(l, r)
                fout.write(buf)

def main():
    base = level_name(1)
    next_base = level_name(2)

    for i in range(2, 21):
        curr = level_name(i)
        next_up = level_name(i+1)
        create_file_from(base+".gd", curr+".gd", [
            [next_base, next_up],
            [base, curr],
        ])
        create_file_from(base+".tscn", curr+".tscn", [
            [next_base, next_up],
            [base, curr],
        ])

if __name__ == "__main__":
    main()

