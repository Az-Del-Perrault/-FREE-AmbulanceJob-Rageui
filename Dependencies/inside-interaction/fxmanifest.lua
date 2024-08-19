fx_version 'cerulean'

game 'gta5'

lua54 'yes'

ui_page 'html/index.html'

files { 
    'html/index.html', 
    'html/css/*.css',
    'html/css/jquery/*.css',
    'html/css/fonts/*.ttf', 
    'html/js/jquery/*.js',
    'html/js/*.js'
}
    
client_scripts {
    'config.lua',
    'client/main.lua'
}

escrow_ignore {
    'config.lua',
    'client/main.lua'
}
dependency '/assetpacks'