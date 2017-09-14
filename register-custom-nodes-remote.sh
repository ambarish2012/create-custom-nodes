#! /bin/bash -e

# parameters passed in
API_TOKEN=$1
SUBSCRIPTION_ID=$2
FRIENDLY_NAME=$3

# value must match file in https://github.com/Shippable/node/tree/master/scripts
# specify the  Docker version and OS version that you want and look at the link above
# to see the supported matrix.
OS_DOCKER=ubu_14.04_docker_1.13.sh
# Dummy IP address

## install packages we need
sudo apt-get update
sudo apt-get -f install jq
sudo apt-get -f install openssh-client
sudo apt-get -f install curl

# register the new node with Shippable via POST route
export RESPONSE=$(curl --request POST \
  --url https://api.shippable.com/clusterNodes \
  --header "authorization: apiToken $API_TOKEN" \
  --header "cache-control: no-cache" \
  --header "content-type: application/json" \
  --data "{\"subscriptionId\": \"$SUBSCRIPTION_ID\",\"friendlyName\": \"$FRIENDLY_NAME\",\"location\": \"1.1.1.1\",\"nodeInitScript\": \"$OS_DOCKER\",\"initializeSwap\": false,\"nodeTypeCode\": 7000,\"isShippableInitialized\": false}")

# extract the cluster node id from the response
CLUSTER_NODE_ID=$(echo $RESPONSE | jq -r '.id')

# download the initialization script from Shippable for this node
if [[ ! -f shipInitNode.sh ]]; then
  curl -o ./shipInitNode.sh --request GET https://api.shippable.com/clusterNodes/$CLUSTER_NODE_ID/initScript \
    --header "authorization: apiToken $API_TOKEN" \
    --header "cache-control: no-cache" \
    --header "content-type: application/json"
fi;

# make the init script executable
sudo chmod +x shipInitNode.sh

# run the init script
#scp -i yourKey shipInitNode.sh username@node:shipInitNode.sh
scp -i ambarish.pem shipInitNode.sh ubuntu@54.205.209.225:shipInitNode.sh
ssh -i ambarish.pem ubuntu@54.205.209.225 './shipInitNode.sh'
