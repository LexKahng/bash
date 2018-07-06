#!/bin/bash
####################################################################################
#The script will be used to retrieve network resource relationships to the instance. 
#The script currently takes instanceID as input.
#
####################################################################################
read -p "Enter that instanceID: " instanceID


### instance type, running state, subnet, az
instanceType=`aws ec2 describe-instance-attribute --instance-id $instanceID --attribute instanceType | sed -n '2p' | awk '{print $2}'`
currentStatus=`aws ec2 describe-instances --instance-ids $instanceID --query 'Reservations[*].Instances[*].[State.Name]' --output text`
subnetId=`aws ec2 describe-instances --instance-ids $instanceID --query 'Reservations[*].Instances[*].[SubnetId]' --output text`
availabilityZone=`aws ec2 describe-instances --instance-ids $instanceID --query 'Reservations[*].Instances[*].[SubnetId]' --output text`
routeTable=`aws ec2 describe-route-tables --query "RouteTables[*].Associations[?SubnetId=='$subnetId'].RouteTableId" --output text`
routes=""

####################################################################################
echo "Instance type is:	$instanceType"
echo "It is currently $currentStatus"
echo "The subnet is $subnetId"

if [[ -z "$routeTable" ]]; then
	echo The instance is using the main route table.
else
	echo "$routeTable" is the routeTableID of the instance.
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

if [[ -z "$routeTable" ]]; then
	echo "Retrieving default VPC route. Just wait."
else
	routes=`aws ec2 describe-route-tables --route-table-ids $routeTable --query "RouteTables[*].Routes[1].GatewayId" --output text`
	echo "This is the first Target: $routes"
fi


echo "end of test."
