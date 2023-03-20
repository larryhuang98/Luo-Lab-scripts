import os
import pymol

# Initialize the PyMOL instance
pymol.finish_launching()

# Read in the wild-type structure
pymol.cmd.load('wt.pse')

# Get a list of all .pdb files in the current directory
pdb_files = [f for f in os.listdir('.') if f.endswith('.pdb')]

# Iterate through the list of pdb files and align each to the wild-type structure
for pdb_file in pdb_files:
    # Load the pdb file
    pymol.cmd.load(pdb_file)

    # Get the name of the pdb file without the .pdb extension
    pdb_name = os.path.splitext(pdb_file)[0]

    # Align the pdb file to the wild-type structure
    pymol.cmd.align(pdb_name, 'wt')

    # Set the viewport and create the PNG image
    pymol.cmd.viewport(1200, 800)
    pymol.cmd.png(f'{pdb_name}_aligned.png', width=1200, height=800, dpi=300)

    # Remove the pdb file from the PyMOL session
    pymol.cmd.delete(pdb_name)

# Quit PyMOL
pymol.cmd.quit()

