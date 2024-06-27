fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'

author 'Spooni'
description 'Interaction Script'

ui_page {
	'nui://jo_libs/nui/menu/index.html'
}

server_scripts {
	'server/*.lua',
}

client_scripts {
	'client/*.lua',
	'shared/*.lua'
}

shared_scripts {
	'@jo_libs/init.lua',
	'shared/*.lua',
}

jo_libs {
	'menu',
}

dependencies {
    'jo_libs',
}