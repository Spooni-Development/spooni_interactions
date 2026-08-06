fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'

author 'Spooni'
description 'Interaction Script'
version '9'

ui_page 'nui://jo_libs/nui/menu/index.html'

server_scripts {
	'server/*.lua',
}

client_scripts {
	'client/cl_common.lua',
	'shared/config.lua',
	'client/cl_prompt.lua',
	'client/cl_detection.lua',
	'client/cl_menu.lua',
	'client/cl_interaction.lua',
	'client/cl_main.lua',
}

shared_scripts {
	'@jo_libs/init.lua',
	'shared/translation.lua',
	'shared/config.lua',
}

jo_libs {
	'menu',
}

dependencies {
	'jo_libs',
}
