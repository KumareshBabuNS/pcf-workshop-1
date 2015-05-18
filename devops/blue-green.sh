cf login -a https://api.$CF_SYSTEM_DOMAIN <Add the correct flags to include the username, password, org and space> --skip-ssl-validation

DEPLOYED_VERSION_CMD=$(CF_COLOR=false cf apps | grep $CF_APP- | cut -d" " -f1)
DEPLOYED_VERSION="$DEPLOYED_VERSION_CMD"
ROUTE_VERSION=$(echo "${BUILD_NUMBER}" | cut -d"." -f1-3 | tr '.' '-')
echo "Deployed Version: $DEPLOYED_VERSION"
echo "Route Version: $ROUTE_VERSION"

# push a new version and map the route
cf <???> "$CF_APP-$BUILD_NUMBER" -n "$CF_APP-$ROUTE_VERSION" -d $CF_APPS_DOMAIN -p $CF_JAR -f $CF_MANIFEST
cf <???> "$CF_APP-${BUILD_NUMBER}" $CF_APPS_DOMAIN -n $CF_APP

if [ ! -z "$DEPLOYED_VERSION" -a "$DEPLOYED_VERSION" != " " -a "$DEPLOYED_VERSION" != "$CF_APP-${BUILD_NUMBER}" ]; then
  echo "Performing zero-downtime cutover to $BUILD_NUMBER"
  echo "$DEPLOYED_VERSION" | while read line
  do
    if [ ! -z "$line" -a "$line" != " " -a "$line" != "$CF_APP-${BUILD_NUMBER}" ]; then
      echo "Scaling down, unmapping and removing $line"
      # Unmap the route and delete
      cf <???>-route "$line" $CF_APPS_DOMAIN -n $CF_APP
      cf <???> "$line" -f
      cf delete-route $CF_APPS_DOMAIN -n "$line" -f
    else
      echo "Skipping $line"
    fi
  done
fi
