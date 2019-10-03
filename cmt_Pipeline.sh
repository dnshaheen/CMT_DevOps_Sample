#!/usr/bin/env bash

#---------------------------------------------
#Date: 09/26/2019
#Code by: Juan Felipe Garcia
#---------------------------------------------

SF_USERNAME='CMT_Test_Dev1'
export SF_USERNAME

#####SF Setup
echo "####### Salesforce Deployment"
#sfdx force:source:deploy -u "$SF_USERNAME" -p salesforce_sfdx --verbose
sfdx force:mdapi:deploy --deploydir src --wait -1 --targetusername "$SF_USERNAME" --verbose
#sfdx force:package:install  -p App@1.0.0-1 w -1 -k password12 -u "$SF_USERNAME" 

#####Deploy vlocity folder
echo "####### packDeploy"
vlocity -sfdx.username "$SF_USERNAME" -job jobs/Deploy_Delta.yaml packDeploy --verbose

#####Run Batch Jobs
echo "####### runApex"
vlocity -sfdx.username "$SF_USERNAME" --nojob runApex -apex apex/RunProductBatchJobs.cls
