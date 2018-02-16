#! /bin/bash -e

# parameters passed in
API_TOKEN=$1
SUBSCRIPTION_ID=$2
FRIENDLY_NAME=$3
CLUSTER_ID=$4

# value must match file in https://github.com/Shippable/node/tree/master/scripts
# specify the  Docker version and OS version that you want and look at the link above
# to see the supported matrix.
OS_DOCKER=ubu_16.04_docker_1.13.sh

## install JQ package
sudo apt-get update
sudo apt-get -f install jq

# register the new node with Shippable via POST route
export RESPONSE=$(curl --request POST \
  --url https://api.shippable.com/clusterNodes \
  --header "authorization: apiToken $API_TOKEN" \
  --header "cache-control: no-cache" \
  --header "content-type: application/json" \
  --data "{\"clusterId\": \"$CLUSTER_ID\", \"subscriptionId\": \"$SUBSCRIPTION_ID\",\"friendlyName\": \"$FRIENDLY_NAME\",\"location\": \"1.1.1.1\",\"nodeInitScript\": \"$OS_DOCKER\",\"initializeSwap\": false,\"nodeTypeCode\": 7000,\"isShippableInitialized\": false}")

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
sudo ./shipInitNode.sh
