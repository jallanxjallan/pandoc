#!/usr/bin/env python

from pandocfilters import Header, Para, Plain, toJSONFilter

def split_by_top_heading(key, value, format_, meta):
    if key == 'Header' and value[0] == 1:
        # Create a new output file for each top-level heading
        filename = value[2][0].lower().replace(' ', '_') + '.' + format_
        with open(filename, 'w') as file:
            file.write("# " + value[2][0] + "\n\n")
            contents = traverse(value)
            for item in contents:
                if isinstance(item, str):
                    file.write(item + "\n\n")
                elif isinstance(item, list):
                    file.write('\n'.join(item) + "\n\n")

        return []

def traverse(item):
    if isinstance(item, list):
        return [traverse(i) for i in item]
    elif isinstance(item, dict):
        return [traverse(item[key]) for key in item]
    elif isinstance(item, str):
        return item
    else:
        return []

if __name__ == '__main__':
    toJSONFilter(split_by_top_heading)
