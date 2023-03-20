import sys
import re
import csv

def parse_mdout(file_name):
    data = []
    with open(file_name, 'r') as file:
        lines = file.readlines()
        
        for i, line in enumerate(lines):
            if "NSTEP" in line:
                nstep = int(lines[i].split()[2])
                time_ps = float(lines[i].split()[5])
                temp = float(lines[i+1].split()[8])
                etot = float(lines[i+1].split()[17])
                ektot = float(lines[i+1].split()[26])
                eptot = float(lines[i+1].split()[35])
                data.append([nstep, time_ps, temp, etot, ektot, eptot])

    return data

def write_csv(data, output_file):
    header = ['NSTEP', 'Time (ps)', 'TEMP(K)', 'ETOT', 'EKTOT', 'EPTOT']
    
    with open(output_file, 'w', newline='') as file:
        csv_writer = csv.writer(file)
        csv_writer.writerow(header)
        csv_writer.writerows(data)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python amber_mdout_parser.py <input_mdout_file> <output_csv_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    data = parse_mdout(input_file)
    write_csv(data, output_file)
    print("Data extracted and saved to", output_file)
