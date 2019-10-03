#!/usr/bin/env bash

#---------------------------------------------
#Date: 09/26/2019
#Code by: Juan Felipe Garcia
#---------------------------------------------

SF_DevHub_USERNAME='CMT_Test_DevHub'

INPUT1=$1
SF_NEW_SCRATCH_ORG_NAME="$INPUT1"
SF_NEW_SCRATCH_ORG_NAME="Testorg2"

#------------------ LOG TO FILE -------------
#LOG_FILE="${SF_NEW_SCRATCH_ORG_NAME}.log"
#rm "$LOG_FILE"
#exec > >(tee -ia "$LOG_FILE")
#---------------------------------------------

echo "####### Creating New Scratch Org"
#project-scratch-def.json has the configuration required for Vlocity Managed Package
sfdx force:org:create --definitionfile config/project-scratch-def.json -a "$SF_NEW_SCRATCH_ORG_NAME" --durationdays 29 --json --targetdevhubusername "$SF_DevHub_USERNAME"


SF_USERNAME="$SF_NEW_SCRATCH_ORG_NAME"

echo "####### New Scratch Org Information"
sfdx force:org:open -u "$SF_USERNAME" --urlonly
sfdx force:user:password:generate -u "$SF_USERNAME" --targetdevhubusername "$SF_DevHub_USERNAME"
sfdx force:org:display -u "$SF_USERNAME"  --verbose


#Salesfroce Settings and Manage Package Install/Update
echo "####### Deploying Managed Package"
##CME Summer 2019 105.900.268 https://cs91.salesforce.com/packaging/installPackage.apexp?p0=04t1J000000lZ3H
sfdx force:package:install -p 04t1J000000lZ3H --targetusername "$SF_USERNAME" -w 80 --noprompt
echo "####### Deploying SF Code Base"
#SF Push Data
sfdx force:source:push -u "$SF_USERNAME"
#SF Test Data Deploy
sfdx force:data:tree:import -u "$SF_USERNAME" --plan sfdx-data/Account-plan.json 
#SF Permission Set assign
sfdx force:user:permset:assign -u "$SF_USERNAME" --permsetname HandsetBuy



#Vlocity New Org Setup
echo "####### packUpdateSettings"
vlocity -sfdx.username "$SF_USERNAME" --nojob packUpdateSettings 
echo "####### installVlocityInitial"
vlocity -sfdx.username "$SF_USERNAME" --nojob installVlocityInitial --verbose
echo "####### runApex"
vlocity -sfdx.username "$SF_USERNAME" --nojob runApex -apex apex/InitializeOrg.cls


# Clean Org Data
echo "####### cleanOrgData"
vlocity -sfdx.username "$SF_USERNAME" --nojob cleanOrgData
# Deploy vlocity folder
echo "####### packDeploy"
vlocity -sfdx.username "$SF_USERNAME" -job jobs/Deploy.yaml packDeploy --verbose
# Run Batch Jobs
echo "####### runApex"
vlocity -sfdx.username "$SF_USERNAME" --nojob runApex -apex apex/RunProductBatchJobs.cls

#echo "####### Opening Org"
#sfdx force:org:open -u "$SF_USERNAME" 

