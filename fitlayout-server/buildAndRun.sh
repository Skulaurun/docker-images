#!/bin/sh

WD="`pwd`"
mkdir files

# Build FitLayout core
cd ../FitLayout
mvn -DskipTests clean install

# Build FitLayout web API
cd ../FitLayoutWeb/FitLayoutWebService
mvn clean package && mvn payara-micro:bundle

# Check the result
cd "$WD"
if [ ! -f ../FitLayoutWeb/FitLayoutWebService/target/fitlayout-web-microbundle.jar ]; then
    echo "BUILD FAILED"
    exit 1
fi
cp ../FitLayoutWeb/FitLayoutWebService/target/fitlayout-web-microbundle.jar files

# Copy puppeteer-backend files
cp ../fitlayout-puppeteer/index.js files
cp ../fitlayout-puppeteer/package*.json files

# Create docker image
docker build -t fitlayout/fitlayout-server .

# Clean
rm -rf files

# Run the image
docker rm -f fitlayout-server || true && docker run -d -p 8400:8400 --mount 'source=flstorage,target=/opt/storage' --name fitlayout-server --restart unless-stopped fitlayout/fitlayout-server 