#!/bin/bash

# Function to download Minecraft server jars
download_server() {
    SERVER_TYPE=$1
    VERSION=$2

    echo "Downloading $SERVER_TYPE server version $VERSION..."

    case $SERVER_TYPE in
        paper)
            JAR_URL="https://api.papermc.io/v2/projects/paper/versions/$VERSION/builds/latest/downloads/paper-$VERSION.jar"
            ;;
        spigot)
            JAR_URL="https://download.getbukkit.org/spigot/spigot-$VERSION.jar"
            ;;
        purpur)
            JAR_URL="https://api.purpurmc.org/v2/purpur/$VERSION/latest/download"
            ;;
        vanilla)
            JAR_URL="https://piston-data.mojang.com/v1/objects/$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r '.versions[] | select(.id=="'$VERSION'") | .url' | xargs curl -s | jq -r '.downloads.server.url')"
            ;;
        *)
            echo "Invalid server type!"
            exit 1
            ;;
    esac

    wget -O server.jar "$JAR_URL"

    if [ $? -ne 0 ]; then
        echo "Download failed! Please check the version and server type."
        exit 1
    else
        echo "Download successful!"
    fi
}

# Ask for server type
echo "Choose a server type:"
echo "1) Paper"
echo "2) Spigot"
echo "3) Purpur"
echo "4) Vanilla"
read -p "Enter the number: " TYPE

case $TYPE in
    1) SERVER_TYPE="paper" ;;
    2) SERVER_TYPE="spigot" ;;
    3) SERVER_TYPE="purpur" ;;
    4) SERVER_TYPE="vanilla" ;;
    *) echo "Invalid option!"; exit 1 ;;
esac

# Ask for Minecraft version
read -p "Enter the Minecraft version (e.g., 1.20.4): " VERSION

# Ask for RAM allocation
read -p "Enter the minimum RAM (e.g., 2G): " MIN_RAM
read -p "Enter the maximum RAM (e.g., 4G): " MAX_RAM

# Create server directory
mkdir -p minecraft-server
cd minecraft-server

# Download the selected server type and version
download_server $SERVER_TYPE $VERSION

# Accept EULA
echo "eula=true" > eula.txt

# Create startup script with selected RAM
echo "#!/bin/bash
java -Xms$MIN_RAM -Xmx$MAX_RAM -jar server.jar nogui" > start.sh
chmod +x start.sh

# Ask for OP username
read -p "Enter your Minecraft username to set as OP (leave blank to skip): " OP_NAME
if [ ! -z "$OP_NAME" ]; then
    echo "ops=[\"$OP_NAME\"]" > ops.json
fi

echo "Installation complete! Run ./start.sh to start the server."
