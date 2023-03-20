#!/bin/bash

for t in 1 2 3; do 

echo "Step 1: Pre Solute"
pdb=wt.${t}.wat.pdb

tleap -f - << EOF

source leaprc.protein.ff14SB 

# For ZN-CCHH
addAtomTypes { { "ZN" "Zn" "sp3" } { "S4" "S" "sp3" } { "N3" "N" "sp3" } } #Add atom types for the ZAFF metal center with Center ID 4
loadoff atomic_ions.lib #Load the library for atomic ions
loadamberparams frcmod.ions1lm_126_tip3p # replaces old frcmod.ions1lsm_hfe_tip3p file for monovalent metal ions, incorportates same HFE dataset
loadamberprep ../ZAFF.prep #Load ZAFF prep file
loadamberparams ../ZAFF.frcmod #Load ZAFF frcmod file

# For protein, phosphorylated THR: TPO
source leaprc.gaff
source leaprc.phosaa10

# For water
source leaprc.water.tip3p 
mol = loadpdb wt_noH.pdb

# Save the dry pdb and prmtop files
savepdb mol wt.${t}.dry.pdb
saveamberparm mol wt.${t}.dry.prmtop wt.${t}.dry.inpcrd

# For water and salt
solvateoct mol TIP3PBOX 10 #Solvate the complex with a cubic water box
addIons2 mol Cl- 0 #Add Cl- ions to neutralize the system
addIons2 mol Na+ 0 

# Save a working pdb copy for salt ions
savepdb mol ${pdb}

# Quit tleap program
quit 

EOF

# Compute ions needed for salt concentration
wat_mol=`grep "O   WAT" ${pdb} | wc -l` 
ions_num=`echo .15*${wat_mol}/56 | bc`
echo "${ions_num} Na+/Cl- ions needed for ${wat_mol} waters" 

###########################
echo "Step 2: Post Solute"

tleap -f - << EOF
source leaprc.protein.ff14SB

# For ZN-CCHH
addAtomTypes { { "ZN" "Zn" "sp3" } { "S4" "S" "sp3" } { "N3" "N" "sp3" } } #Add atom types for the ZAFF metal center with Center ID 4
loadoff atomic_ions.lib #Load the library for atomic ions
loadamberparams frcmod.ions1lm_126_tip3p # replaces old frcmod.ions1lsm_hfe_tip3p file for monovalent metal ions, incorportates same HFE dataset
loadamberprep ../ZAFF.prep #Load ZAFF prep file
loadamberparams ../ZAFF.frcmod #Load ZAFF frcmod file

# For protein, phosphorylated THR: TPO
source leaprc.gaff
source leaprc.phosaa10

# For water
source leaprc.water.tip3p
mol = loadpdb wt_noH.pdb

# Save the dry pdb and prmtop files
savepdb mol wt.${t}.dry.pdb #Save the pdb file
saveamberparm mol wt.${t}.dry.prmtop wt.${t}.dry.inpcrd #Save the topology and coordiante files

# For water and salt
addIons2 mol Cl- 0 #Add Cl- ions to neutralize the system
addIons2 mol Na+ 0
addIons2 mol Cl- ${ions_num} Na+ ${ions_num} # Add more ions up to the salt concentration
solvateoct mol TIP3PBOX 10 #Solvate the complex with a cubic water box

check mol

# Save the solvated pdb and prmtop files
savepdb mol ${pdb}
saveamberparm mol wt.${t}.wat.prmtop wt.${t}.wat.inpcrd #Save AMBER topology and coordinate files

# Quit tleap program
quit

EOF

# Reporting ...
#ions_num=`echo .15*${wat_mol}/56 | bc`
wat_mol=`grep "O   WAT" ${pdb} | wc -l` 
ions_na_real=`grep "Na+  Na+" $pdb | wc -l`
ions_cl_real=`grep "Cl-  Cl-" $pdb | wc -l`
echo "Final ${ions_na_real} Na+ and ${ions_cl_real} Cl- ions determined for ${wat_mol} waters" 

done 

