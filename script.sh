#!/bin/bash

# Loop through all 4 testcases dynamically
for i in 1 2 3 4; do
    t_dir="Testcase$i"
    out_dir="Testcase${i}Diff"

    # Skip if the directory is missing
    [ -d "$t_dir" ] || continue

    # Clean out any old diff directory to keep things fresh
    rm -rf "$out_dir"

    has_diffs=0

    # Find files ending in .1.txt
    for f1 in "$t_dir"/*.1.txt; do
        [ -f "$f1" ] || continue

        # Corresponding .2.txt file
        f2="${f1%.1.txt}.2.txt"

        if [ -f "$f2" ]; then
            # Extract the base name (e.g., Version3 from Testcase3/Version3.1.txt)
            name=$(basename "$f1" .1.txt)
            target="$out_dir/${name}Diff.txt"

            # Run diff -u; if it fails, files are different
            if ! diff -u "$f1" "$f2" > /dev/null; then
                mkdir -p "$out_dir"
                diff -u "$f1" "$f2" > "$target"
                has_diffs=1
            fi
        fi
    done

    # If no files differed in this testcase, remove the empty output directory
    if [ "$has_diffs" -eq 0 ]; then
        rm -rf "$out_dir"
    fi
done
