#!/bin/bash

##############################################################################
#
#
# CHANGE THE VALUES OF VARIABLES BELOW AS APPROPRIATE
#
#
##############################################################################


### Define PWV range (initial, final, increment)
VINI='15.0'
VEND='30.0'
VINC='0.1'


##############################################################################
#
#
# PATHS TO INPUT FILES, UVSPEC AND OUTPUT DIRECTORY
#
#
##############################################################################


# Full path to the output directory
OUTPUTDIR='/home/elion/libRadtran-2.0.4/pwv'

# Full path to the uvspec binary file
UVBIN='/home/elion/libRadtran-2.0.4/bin/uvspec'

# Full path to the atmospheric profile file
ATMPROF='/home/elion/libRadtran-2.0.4/data/atmmod/afglt.dat' # Tropical profile

# Full path to filter files
FILTER4='/home/elion/libRadtran-2.0.4/pwv/transmittance4.dat'

# Full path to radiosonde file:
SONDE='/home/elion/libRadtran-2.0.4/pwv/sonda_08-02-2018_12.csv'

# Output file name
FILENAME=lt_2.0_08022018_CH4.csv


##############################################################################
#
#
# DO NOT CHANGE ANYTHING BELOW, UNLESS YOU KNOW WHAT YOU ARE DOING
#
#
##############################################################################


# Initialize output file
ini=`date`
echo "Starting script at: " $ini 
OUTFILE=$OUTPUTDIR/$FILENAME

rm -rf $OUTFILE
echo "Profile,PWV(mm),Cos,Rad4" > $OUTFILE

# Start loops over PWV range
for PWV  in $(seq $VINI $VINC $VEND); do


PROFILE=1

# Generate the uvspec scripts
echo "
atmosphere_file $ATMPROF
source thermal
mol_abs_param reptran fine
rte_solver disort

wavelength 9500.0167553 12999.9985807
filter_function_file $FILTER4 normalize

longitude W 46 44 6		
latitude S 23 33 40
time 2017 07 06 12 00 00
altitude 0.722
zout 0.060

radiosonde $SONDE H2O RH
mixing_ratio CO2 409
mol_modify H2O $PWV MM

umu -1.0 -0.975 -0.95 -0.925 -0.9 -0.875 -0.85 -0.825 -0.8 -0.775 -0.75 -0.725 -0.7 -0.675 -0.65 -0.625 -0.6 -0.575 -0.55 -0.525 -0.5
phi 180.0

output_process integrate
output_user uu
quiet
" > $OUTPUTDIR/INPUT


# Run uvspec
echo
date
echo "  Running: Lookup Table - CH4"
echo "    PWV from $VINI to $VEND mm"
echo "    PWV = $PWV mm"

$UVBIN < $OUTPUTDIR/INPUT | awk -F" " '{print '$PROFILE' "," '$PWV' ",-1.00," $1 "\n" '$PROFILE' "," '$PWV' ",-0.975," $2 "\n" '$PROFILE' "," '$PWV' ",-0.950," $3 "\n" '$PROFILE' "," '$PWV' ",-0.925," $4 "\n" '$PROFILE' "," '$PWV' ",-0.900," $5 "\n" '$PROFILE' "," '$PWV' ",-0.875," $6 "\n" '$PROFILE' "," '$PWV' ",-0.850," $7 "\n" '$PROFILE' "," '$PWV' ",-0.825," $8 "\n" '$PROFILE' "," '$PWV' ",-0.800," $9 "\n" '$PROFILE' "," '$PWV' ",-0.775," $10 "\n" '$PROFILE' "," '$PWV' ",-0.750," $11 "\n" '$PROFILE' "," '$PWV' ",-0.725," $12 "\n" '$PROFILE' "," '$PWV' ",-0.700," $13 "\n" '$PROFILE' "," '$PWV' ",-0.675," $14 "\n" '$PROFILE' "," '$PWV' ",-0.650," $15 "\n" '$PROFILE' "," '$PWV' ",-0.625," $16 "\n" '$PROFILE' "," '$PWV' ",-0.600," $17 "\n" '$PROFILE' "," '$PWV' ",-0.575," $18 "\n" '$PROFILE' "," '$PWV' ",-0.550," $19 "\n" '$PROFILE' "," '$PWV' ",-0.525," $20 "\n" '$PROFILE' "," '$PWV' ",-0.500," $21}' >> $OUTFILE

done # for PWV  in $(seq $VINI $VINC $VEND)


# Finalize the script
echo
fin=`date`
echo "Script started  at: " $ini
echo "Script finished at: " $fin

