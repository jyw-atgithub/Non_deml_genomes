#!/usr/bin/env bash
set -euo pipefail

# ponytail: Extracted the PyPy logic into a variable so we can test it 
# independently of the samtools IO pipeline. The self-check asserts the 
# logic drops the bad secondary alignment and keeps the good one.

PY_LOGIC='
import sys

def run():
    group = []
    cur_q = None
    out = sys.stdout.write 

    def process_group(lines):
        pri = {}
        for l in lines:
            c = l.split("\t", 3)
            f = int(c[1])
            if not (f & 256):
                m = 1 if (f & 64) else 2 if (f & 128) else 0
                pri[m] = c[2]
        
        for l in lines:
            c = l.split("\t", 3)
            f = int(c[1])
            if f & 256:
                m = 1 if (f & 64) else 2 if (f & 128) else 0
                if pri.get(m) != c[2]:
                    continue
            out(l)

    for line in sys.stdin:
        if line[0] == "@":
            out(line)
            continue
            
        q = line.split("\t", 1)[0]
        if q != cur_q:
            if group:
                process_group(group)
            group = [line]
            cur_q = q
        else:
            group.append(line)

    if group:
        process_group(group)

if __name__ == "__main__":
    run()
'

# Runnable self-check
if [[ "${1:-}" == "--test" ]]; then
    echo "Running self-test..."
    
    # Input SAM: 
    # - read1 primary on chr1
    # - read1 secondary on chr1 (should KEEP)
    # - read1 secondary on chr2 (should DROP)
    TEST_SAM=$(cat << 'EOF'
@SQ	SN:chr1	LN:100
@SQ	SN:chr2	LN:100
read1	0	chr1	10	255	100M	*	0	0	*	*
read1	256	chr1	50	255	100M	*	0	0	*	*
read1	256	chr2	20	255	100M	*	0	0	*	*
EOF
)

    EXPECTED=$(cat << 'EOF'
@SQ	SN:chr1	LN:100
@SQ	SN:chr2	LN:100
read1	0	chr1	10	255	100M	*	0	0	*	*
read1	256	chr1	50	255	100M	*	0	0	*	*
EOF
)

    # Use pypy3 if available, fallback to python3 for the test
    PY_BIN=$(command -v pypy3 || echo "python3")
    
    RESULT=$(echo "$TEST_SAM" | "$PY_BIN" -c "$PY_LOGIC")
    
    if [[ "$RESULT" == "$EXPECTED" ]]; then
        echo "PASS: Logic correctly kept same-contig secondary and dropped cross-contig secondary."
        exit 0
    else
        echo "FAIL: Output did not match expected."
        echo "GOT:"
        echo "$RESULT"
        exit 1
    fi
fi

# Main pipeline
IN_BAM="${1:?Usage: $0 <in.bam> <out.bam> [threads] OR $0 --test}"
OUT_BAM="${2:-}"
THREADS="${3:-8}"

if [[ -z "$OUT_BAM" ]]; then
    echo "Error: Output BAM required for main execution."
    exit 1
fi

samtools collate -O -u -@ "$THREADS" "$IN_BAM" | \
samtools view -@ "$THREADS" -h - | \
pypy3 -c "$PY_LOGIC" | \
samtools sort -m 1500M -@ "$THREADS" -o "$OUT_BAM" -
