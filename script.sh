#!/bin/bash
PA="/home/dst/.klei/DoNotStarveTogether/world"
mkdir -p $PA
gosu root chown -R dst:dst $PA

function fail()
{
	echo Error: "$@" >&2
	exit 1
}

if [ ! -z "$SAVE_URL" ]; then
wget -O $PA/example.zip $SAVE_URL || fail "downalod world faild!"
unzip $PA/example.zip -d $PA  || fail "this world file not zip !"
echo downloaded world successful
rm $PA/example.zip
else

if [ "$REFORGED" = true ]; then
cp -n -r  /home/dst/.klei/DoNotStarveTogether/Reforged/* $PA
MODS="${MODS},1938752683"
if [ "$PUGNAX" = true ]; then
MODS="${MODS},2038128735" 
echo "pugnax ON"
fi
if [ "$HALLOWED" = true  ]; then
MODS="${MODS},2633870801" 
fi
echo mods update to $MODS

else
cp -n -r  /home/dst/.klei/DoNotStarveTogether/example_world/* $PA

fi
fi

if [ -z "$CLUSTER_TOKEN" ] || [ "$CLUSTER_TOKEN" = "****"  ] ; then
echo ERROR 404! CLUSTER_TOKEN not found
exit 1
fi

if [ -z "$CLUSTER_NAME" ]; then
CLUSTER_NAME="dstdedi -- test"
fi
echo "your server name is : $CLUSTER_NAME"

if [ -z "$MAX_PLAYER" ]; then
MAX_PLAYER=6
fi
echo "max player set to: $MAX_PLAYER"

if [ -z "$CLUSTER_DESCRIPTION" ]; then
CLUSTER_DESCRIPTION="Powered by Docker - seyedmahdi3\/dstdedi"
fi
echo -e "description set to: $CLUSTER_DESCRIPTION"



if [ -z "$GAMEMODE" ]; then
GAMEMODE="survival"
fi

if [ "$REFORGED" = true ]; then
GAMEMODE="lavaarena"
fi

echo "gamemode set to: $GAMEMODE"

if [ -z "$STYLE" ]; then
STYLE="cooperative"
fi
echo "playstyle set to: $STYLE"

if [ -z "$PVP" ]; then
PVP="false"
fi
echo "PVP set to: $PVP"

if [ -z "$AUTOPAUSE" ]; then
AUTOPAUSE="true"
fi
echo "autopause is : $AUTOPAUSE"
if [ ! -z "$CLUSTER_PASSWORD" ]; then
echo "password is set to: $CLUSTER_PASSWORD"
fi
sed -i "s/cluster_name = .*$/cluster_name = ${CLUSTER_NAME}/g" $PA/cluster.ini || fail "error in permision . make issues"
sed -i "s/cluster_description = .*$/cluster_description = ${CLUSTER_DESCRIPTION}/g" $PA/cluster.ini
sed -i "s/max_players = .*$/max_players = ${MAX_PLAYER}/g" $PA/cluster.ini
sed -i "s/cluster_password = .*$/cluster_password = ${CLUSTER_PASSWORD}/g" $PA/cluster.ini
sed -i "s/pvp = .*$/pvp = ${PVP}/g" $PA/cluster.ini
sed -i "s/cluster_intention = .*$/cluster_intention = ${STYLE}/g" $PA/cluster.ini
sed -i "s/pause_when_empty = .*$/pause_when_empty = ${AUTOPAUSE}/g" $PA/cluster.ini
sed -i "s/game_mode = .*$/game_mode = ${GAMEMODE}/g" $PA/cluster.ini
echo $CLUSTER_TOKEN > $PA/cluster_token.txt

IFS=',' read -ra admins <<< "${ADMIN_IDS}"
for admin in "${admins[@]}"; do
  echo $admin >> $PA/adminlist.txt
  echo "add admins:$admin"
done


#mod

if [ ! -z "$MODS" ]; then
MODOVER="$PA/Master/modoverrides.lua"
MODOVER_Caves="$PA/Caves/modoverrides.lua"
echo -e "return {" > $MODOVER
if [ ! "$REFORGED" = true ]; then
echo -e "return {" > $MODOVER_Caves
fi
IFS=',' read -ra all_mods <<< "${MODS}"
for mod in "${all_mods[@]}"; do
  echo -e "[\"workshop-${mod}\"]={enabled=true}," >> $MODOVER
if [ ! "$REFORGED" = true ]; then
  echo -e "[\"workshop-${mod}\"]={enabled=true}," >> $MODOVER_Caves
fi
  echo -e "ServerModSetup(\"${mod}\")"   >> /home/dst/dontstarvetogether_dedicated_server/mods/dedicated_server_mods_setup.lua
  echo  "Mod ${mod} is enable"
done
echo -e "}" >> $MODOVER
if [ ! "$REFORGED" = true ]; then
echo -e "}" >> $MODOVER_Caves
fi
fi



cd /home/dst/dontstarvetogether_dedicated_server/bin64
grep_cmd="grep 'Server registered\|is now ready\|Your Server Will Not Start\|No auth token could be found\|Account Failed\|Please visit\|Sim paused\|Client connected\|Client authenticated\|Announcement\|Say\|Sim unpaused\|request\:\|Spawning player at\|Server Autopaused\|ReceiveRemoteExecute\|Available disk space for save files'"
if [ ! "$DEBUG" = "true" ]; then

if [ "$REFORGED" = true ]; then
echo "running Reforged server . . ."
./dontstarve_dedicated_server_nullrenderer_x64 -console -cluster world -monitor_parent_process $$ -shard Master |grep 'Server registered\|is now ready\|Your Server Will Not Start\|No auth token could be found\|Account Failed\|Please visit\|Sim paused\|Client connected\|Client authenticated\|Announcement\|Say\|Sim unpaused\|request\:\|Spawning player at\|Server Autopaused\|ReceiveRemoteExecute\|Available disk space for save files'
else
echo "running server . . ."
./dontstarve_dedicated_server_nullrenderer_x64 -console -cluster world -monitor_parent_process $$ -shard Master |grep 'Server registered\|is now ready\|Your Server Will Not Start\|No auth token could be found\|Account Failed\|Please visit\|Sim paused\|Client connected\|Client authenticated\|Announcement\|Say\|Sim unpaused\|request\:\|Spawning player at\|Server Autopaused\|ReceiveRemoteExecute\|Available disk space for save files' & \
./dontstarve_dedicated_server_nullrenderer_x64 -console -cluster world -monitor_parent_process $$ -shard Caves | grep 'Server registered\|is now ready\|Your Server Will Not Start\|No auth token could be found\|Account Failed\|Please visit\|Sim paused\|Client connected\|Client authenticated\|Announcement\|Say\|Sim unpaused\|request\:\|Spawning player at\|Server Autopaused\|ReceiveRemoteExecute\|Available disk space for save files'
fi

else


echo "running server . . ."
if [ "$REFORGED" = true ] || [ "$CAVE" = false ]  ; then
./dontstarve_dedicated_server_nullrenderer_x64 -console -cluster world -monitor_parent_process $$ -shard Master
else
./dontstarve_dedicated_server_nullrenderer_x64 -console -cluster world -monitor_parent_process $$ -shard Master & \
./dontstarve_dedicated_server_nullrenderer_x64 -console -cluster world -monitor_parent_process $$ -shard Caves
fi
fi
