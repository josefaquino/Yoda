# A3 strace parser
# Input: trace files produced with strace -ttt -T.
# Output: one TSV row per trace file.
# Fields: trace valid success lock_wait_us critical_us rename_us unlock_us

function dur_seconds(line,    x) {
    x=line
    sub(/^.*</, "", x)
    sub(/>$/, "", x)
    return x+0
}

function trace_name(path,    n,a) {
    n=split(path,a,"/")
    return a[n]
}

{
    seen[FILENAME]=1
}

/flock\(.*LOCK_EX/ {
    ex_seen[FILENAME]=1
    ex_start[FILENAME]=$1+0
    ex_dur[FILENAME]=dur_seconds($0)
}

/flock\(.*LOCK_UN/ {
    un_seen[FILENAME]=1
    un_start[FILENAME]=$1+0
    un_dur[FILENAME]=dur_seconds($0)
}

/rename(at2|at)?\(/ {
    rename_seen[FILENAME]=1
    rename_dur[FILENAME]=dur_seconds($0)
}

END {
    print "trace\tvalid\tsuccess\tlock_wait_us\tcritical_us\trename_us\tunlock_us"

    for (f in seen) {
        valid=(ex_seen[f] && un_seen[f]) ? 1 : 0
        success=rename_seen[f] ? 1 : 0

        wait_us=ex_dur[f]*1000000.0
        unlock_us=un_dur[f]*1000000.0
        rename_us=success ? rename_dur[f]*1000000.0 : 0.0

        critical_us=0.0

        if (valid) {
            critical_us=(un_start[f]-(ex_start[f]+ex_dur[f]))*1000000.0
            if (critical_us < 0)
                critical_us=0.0
        }

        printf "%s\t%d\t%d\t%.3f\t%.3f\t%.3f\t%.3f\n", \
            trace_name(f), valid, success, wait_us, critical_us, rename_us, unlock_us
    }
}
