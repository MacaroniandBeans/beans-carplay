fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Beans'
description 'Carplay works with youtube links'

ui_page 'html/index.html'

files {
   'html/index.html',
   'html/style.css',
   'html/prp.png'
}

client_scripts {
   '@ox_lib/init.lua',
   'client.lua'
}

server_scripts {
   'server.lua'
}