#!/usr/bin/env bash

#---------------------------------------------
#Date: 09/26/2019
#Code by: Juan Felipe Garcia
#---------------------------------------------

SF_USERNAME='Alias_Dev1'
export SF_USERNAME

#SF Setuop
echo "####### force:source:deploy"
##Deploy in source format 
#sfdx force:source:deploy -u "$SF_USERNAME" -p salesforce_sfdx --verbose 
##Deploy in mdapi format
sfdx force:mdapi:deploy --deploydir ./src --wait -1 --targetusername "$SF_USERNAME" --verbose  
echo "####### force:data:tree:import"
sfdx force:data:tree:import -u "$SF_USERNAME" --plan sfdx-data/Account-plan.json
echo "####### force:user:permset:assign"
sfdx force:user:permset:assign -u "$SF_USERNAME" --permsetname HandsetBuy

#Vlocity New Org Setup
echo "####### packUpdateSettings"
vlocity -sfdx.username "$SF_USERNAME" --nojob packUpdateSettings
echo "####### installVlocityInitial"
vlocity -sfdx.username "$SF_USERNAME" --nojob installVlocityInitial
echo "####### runApex"
vlocity -sfdx.username "$SF_USERNAME" --nojob runApex -apex apex/InitializeOrg.cls


# Deploy vlocity folder
echo "####### packDeploy"
vlocity -sfdx.username "$SF_USERNAME" -job jobs/Deploy.yaml packDeploy --verbose
# Run Batch Jobs
echo "####### runApex"
vlocity -sfdx.username "$SF_USERNAME" --nojob runApex -apex apex/RunProductBatchJobs.cls

#echo "####### Opening Org"
#sfdx force:org:open -u "$SF_USERNAME" 