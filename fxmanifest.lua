fx_version 'cerulean'
game 'gta5'

description 'XU-TruckRobbing'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/main.lua'
}
server_scripts {
     'server/main.lua'
}

ui_page('html/index.html')

files({
    'html/*'
})

lua54 'yes'