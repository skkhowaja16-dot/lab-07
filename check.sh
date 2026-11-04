#!/bin/bash

exit_code=0

for i in 1 2 3 4; do
    t_dir="Testcase$i"
    out_dir="Testcase${i}Diff"
    failed=0

    [ -d "$t_dir" ] || continue

    actual_diffs=0

    for f1 in "$t_dir"/*.1.txt; do
        [ -f "$f1" ] || continue
        f2="${f1%.1.txt}.2.txt"

        if [ -f "$f2" ]; then
            name=$(basename "$f1" .1.txt)
            outFile="$out_dir/${name}Diff.txt"

            if ! diff -u "$f1" "$f2" > /dev/null; then
                actual_diffs=1
                if [ ! -f "$outFile" ]; then
                    failed=1
                    echo "Error: missing output file $outFile" >&2
                else
                    # Compare content starting from line 3 to skip timestamps
                    if ! diff -u <(tail -n +3 "$outFile") <(tail -n +3 <(diff -u "$f1" "$f2")) > /dev/null; then
                        failed=1
                        echo "Error: content mismatch in $outFile" >&2
                    fi
                fi
            else
                # If identical, make sure no diff file was generated
                if [ -f "$outFile" ]; then
                    failed=1
                    echo "Error: unexpected diff file for identical pair $outFile" >&2
                fi
            fi
        fi
    done

    # Check directory rules
    if [ "$actual_diffs" -eq 1 ]; then
        if [ ! -d "$out_dir" ]; then
            failed=1
            echo "Error: missing directory $out_dir" >&2
        fi
    else
        if [ -d "$out_dir" ]; then
            failed=1
            echo "Error: directory should not exist $out_dir" >&2
        fi
    fi

    # Print required format strictly
    if [ "$failed" -eq 0 ]; then
        echo "Testcase$i: PASS"
    else
        echo "Testcase$i: FAIL"
        exit_code=1
    fi
done

exit $exit_code
