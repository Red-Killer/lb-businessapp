fx_version "cerulean"
game "gta5"

author "Red Killer"
description "Adding a business app to lb-phone"
version "1.0.0"

client_script "client.lua"
server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "server.lua",
}

files {
    "ui/**/*"
}

ui_page "ui/index.html"
