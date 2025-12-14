fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'

author 'Spooni'
description 'Interaction Script'
version '9'

server_scripts {
	'server/*.lua',
}

client_scripts {
	'shared/translation.lua',
	'client/cl_common.lua',
	'shared/config.lua',
	'client/cl_prompt.lua',
	'client/cl_detection.lua',
	'client/cl_menu.lua',
	'client/cl_interaction.lua',
	'client/cl_main.lua',
}

shared_scripts {
	'shared/*.lua',
}

dependencies {
    'vorp_menu',
}