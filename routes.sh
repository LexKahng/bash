#!/bin/bash
### Purpose & Overview #############################################################
#The script will be used to retrieve network resource relationships to the instance. 
#The script currently takes instanceID as input.
#
####################################################################################
read -p "Enter that instanceID: " instanceID


### instance type, running state, subnet, az #######################################
### Variable Dictionary
#instanceType - Prints Instance Type
#currentStatus - Stores state of the Instance. If the instance is running, will print "running"
#subnetId - Stores Subnet ID
#availabilityZone - Stores Availability Zone
#routeTableId - Stores Route Table ID
#routes - Stores Table format of the Routes
####################################################################################


### Variable Instantiation #########################################################
instanceType=`aws ec2 describe-instance-attribute --instance-id $instanceID --attribute instanceType | sed -n '2p' | awk '{print $2}'`
currentStatus=`aws ec2 describe-instances --instance-ids $instanceID --query 'Reservations[*].Instances[*].[State.Name]' --output text`
subnetId=`aws ec2 describe-instances --instance-ids $instanceID --query 'Reservations[*].Instances[*].[SubnetId]' --output text`
availabilityZone=`aws ec2 describe-instances --instance-ids $instanceID --query 'Reservations[*].Instances[*].[SubnetId]' --output text`
routeTableId=`aws ec2 describe-route-tables --query "RouteTables[*].Associations[?SubnetId=='$subnetId'].RouteTableId" --output text`
routes=""
####################################################################################


echo "Instance type is:	$instanceType"
echo "It is currently $currentStatus"
echo "The subnet is $subnetId"

if [[ -z "$routeTableId" ]]; then
	echo The instance is using the main route table.
else
	echo "$routeTableId" is the routeTableID of the instance.
fi

#interactive query to find if user wantes this answer.
read -p "Do you want to find the routes? (y/n) " wantsRoute
while [[ "$wantsRoute" != "y" && "$wantsRoute" != "Y" && "$wantsRoute" != "n" && "$wantsRoute" != "N" ]]; do
        read -p "You gotta enter \"y\" or \"n\": " wantsRoute
        if [[ wantsRoute == "n" || wantsRoute == "N" ]]; then
		echo "fine. be that way"
		exit 1
	fi
done

if [[ -z "$routeTableId" ]]; then
	echo "Retrieving default VPC route. Just wait."
else
	routes=`aws ec2 describe-route-tables --route-table-ids $routeTableId --query "RouteTables[*].Routes[*]" --output table`
	echo "This is the Route Table: \n $routes"
fi


echo "end of test."
