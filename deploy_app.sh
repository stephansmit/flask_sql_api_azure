#/bin/bash
RANDOM="StephanSmit"
APP_NAME="webappwithSQL$RANDOM"
APP_PLAN_NAME="${APP_NAME}Plan"
SERVER_NAME="webappwithsql$RANDOM"
LOCATION="northeurope"
STARTIP="0.0.0.0"
ENDIP="0.0.0.0"

RESOURCE_GROUP="flaskPythonAppSQL"


# Create a Resource Group
az group create \
        --location $LOCATION \
        --name $RESOURCE_GROUP

# Create an App Service Plan
az appservice plan create \
        --resource-group $RESOURCE_GROUP \
        --name $APP_PLAN_NAME \
        --location $LOCATION \
        --is-linux \
        --sku B1

# Create a Web App
az webapp create \
        --name $APP_NAME \
        --plan $APP_PLAN_NAME \
        --resource-group $RESOURCE_GROUP \
        --runtime "python|3.6" \
        --startup-file startup.txt

# Create a SQL Database server
az sql server create \
	--admin-user $USER_NAME \
	--admin-password $SQL_PASSWORD \
	--name $SERVER_NAME \
	--resource-group $RESOURCE_GROUP \
	--location $LOCATION 


# Configure firewall for Azure access
az sql server firewall-rule create \
	--server $SERVER_NAME \
	--resource-group $RESOURCE_GROUP \
	--name AllowYourIp \
	--start-ip-address $STARTIP \
	--end-ip-address $ENDIP

# Create a database called 'MySampleDatabase' on server
az sql db create \
	--server $SERVER_NAME \
	--resource-group $RESOURCE_GROUP \
	--name MySampleDatabase \
	--service-objective S0

# Get connection string for the database
connstring=$(az sql db show-connection-string \
		--name MySampleDatabase \
		--server $SERVER_NAME \
		--client ado.net \
		--output tsv)

# Add credentials to connection string
connstring=${connstring//<username>/$USERNAME}
connstring=${connstring//<password>/$SQLPASSWORD}

# Assign the connection string to an app setting in the web app
az webapp config appsettings set \
	--name $APP_NAME \
	--resource-group $RESOURCE_GROUP \
	--settings "SQLSRV_CONNSTR=$connstring"
