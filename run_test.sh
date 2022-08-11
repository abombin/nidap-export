# This is to run the unit-test.
# 
##############################################################
# 1. Build docker image from Dockerfile if haven't done it
# Pleasse do not change the image tag name
# cd ./test/Tools/docker
# docker build -t unit_test:latest .
#
##############################################################
# 2. Parse and run pipeline
bash ./test/generate_material_for_tests.sh
#
#
##############################################################
# 3. Run unit-test in DICE
# DICE (DSPCAD Integrative Command-line Environment) package can be found here:
# https://code.umd.edu/dspcad-pub/dspcadwiki/-/wikis/software/DICE-Setup
# Load DICE before running this script
# Generally you can use the following command to load DICE: 
#
# cd "$HOME/dspcad_user/dice_user"
# source startup/dice_startup
#
# Run test
# dxtest