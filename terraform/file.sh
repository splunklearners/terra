#!/usr/bin/env bash

#------------------------------------#
# Script to display AWS EC2 machines #
#------------------------------------#

# NOTES:
# o Requires 'awscli' tools (for ex. on MacOS: $ brew install awscli)
# o AWS output is tabbed - we convert to spaces via 'column' command


#~~~~~~~~~~~~~~~~~~~~#
# Assemble variables #
#~~~~~~~~~~~~~~~~~~~~#

regions=$(aws ec2 describe-regions --output text | cut -f4 | sort)

query_mach='Reservations[].Instances[]'
query_flds='PrivateIpAddress,InstanceId,InstanceType'
query_tags='Tags[?Key==`Name`].Value[]'
query_full="$query_mach.[$query_flds,$query_tags]"


#~~~~~~~~~~~~~~~~~~~~~~~~#
# Output AWS information #
#~~~~~~~~~~~~~~~~~~~~~~~~#

# Iterate through credentials profiles
for profile in 'default' 'work'; do

    # Print profile header
    echo -e "\n"
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo -e "Credentials profile:'$profile'..."
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

    # Iterate through all regions
    for region in $regions; do

        # Print region header
        echo -e "\n"
        echo -e "Region: $region..."
        echo -e "--------------------------------------------------------------"

        # Output items for the region
        aws ec2 describe-instances    \
          --profile $profile          \
          --region  $region           \
          --query   $query_full       \
          --output  text              \
          | sed     's/None$/None\n/' \
          | sed     '$!N;s/\n/ /'     \
          | column  -t -s $'\t'

    done
done
