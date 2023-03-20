qdel $(qstat -u <your_username> | awk 'NR > 2 {print $1}')
