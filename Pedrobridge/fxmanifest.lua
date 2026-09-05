fx_version "cerulean"
game "gta5"
lua54 "yes"
version "1.0.0"

author "Pedro Scripts"
description "Pedrobridge - ponte universal para frameworks FiveM"


ui_page "web/index.html"

shared_scripts {
    -- "@vrp/lib/utils.lua",           ----- Se utilizar vRP, vRPex ou Creative descomente esta linha. (If you use vRP, vRPex, or Creative, uncomment this line.)
    "config.lua",
    "language/*.lua",
    "utils/shared.lua",
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "utils/server/*.lua",
    "framework/**/server.lua",
}

client_scripts {
    "utils/client/*.lua",
    "framework/**/client.lua",
}

files {
    "web/*.html",
    "web/*.css",
    "web/*.js",
}

dependencies {
    "/onesync",
    "mysql-async",
}
