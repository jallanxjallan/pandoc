#!/home/jeremy/Python3.12Env/bin/python
# -*- coding: utf-8 -*-
#
#  module.py
#
#  Copyright 2019 Jeremy Allan <jeremy@jeremyallan.com>
import sys
import re
from pathlib import Path

# Load the index file
INDEX_FILE = Path("content_index.md")
with INDEX_FILE.open("r") as f:
    index_text = f.read()

# Extract all markdown file paths in order
pattern = re.compile(r'\]\((stories/[^)]+\.md)\)')
index_order = pattern.findall(index_text)

# Convert index list to a dict for fast lookup and ordering
index_rank = {path: i for i, path in enumerate(index_order)}

# Read input stream
input_files = [line.strip() for line in sys.stdin if line.strip()]

# Filter and sort
input_set = set(input_files)
ordered_files = sorted(
    (f for f in index_order if f in input_set),
    key=lambda f: index_rank[f]
)

# Output result
for f in ordered_files:
    print(f)
