TASKKILL /F /IM "MinecraftServerToTray.exe" > nul 2>&1
start /B MinecraftServerToTray.exe
TITLE Minecraft server console window
"C:\Program Files (x86)\Java\jre1.8.0_241\bin\java.exe" -Xmx1024M -Xms1024M -jar server.jar nogui