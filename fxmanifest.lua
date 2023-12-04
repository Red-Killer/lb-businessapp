fx_version "cerulean"
game "gta5"

author "Red Killer & MIKEEEE"
description "Adding a business app to lb-phone"
version "1.1.0"

client_script "client.lua"
server_scripts { 
    "@oxmysql/lib/MySQL.lua",
    "server.lua" 
}

files {
    "ui/**/*"
}

ui_page "ui/index.html"
