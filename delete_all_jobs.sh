qdel $(qstat -u larryh1998 | awk 'NR > 2 {print $1}')
