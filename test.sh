#!/bin/bash -e

echo "Starting job on "`date` # to display the start date
echo "Running on "`uname -a` # to display the machine where the job is running
echo "System release "`cat /etc/redhat-release` # and the system release
echo "CMSSW on Condor"

# check arguments
export CMSSWVER=""
export LFN=""
export REDIR=""
while getopts "C:L:X:" opt; do
	case "$opt" in
		C) CMSSWVER="$OPTARG"
		;;
		L) LFN="$OPTARG"
		;;
		X) REDIR="$OPTARG"
		;;
	esac
done

# standardize values
REDIR="${REDIR%/}/"

echo ""
echo "parameter set:"
echo "CMSSWVER: $CMSSWVER"
echo "LFN: $LFN"
echo "REDIR: $REDIR"
echo ""

# environment setup
source /cvmfs/cms.cern.ch/cmsset_default.sh

# get CMSSW (for xrootd and root)
cmsrel ${CMSSWVER}
cd ${CMSSWVER}/src
cmsenv

# create macro
cat << EOF > test.C
{
auto file = TFile::Open("$REDIR$LFN");
file->ls();
auto tree = (TTree*)file->Get("Events");
tree->Print();
}
EOF

# try to read the file
root -b -l -q test.C

echo ""
echo "Done"
