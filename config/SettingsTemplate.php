<?php

## All skins and extensions should be installed here.
## In the future we can probably remove our custom LocalSettings.php and just customize this file.

// If not running MediaWiki, exit
if ( !defined( 'MEDIAWIKI' ) ) {
	exit;
}

# Enable nice URLs (remove index.php from URLs)
$wgScriptPath = "/w";
$wgArticlePath = "/$1";
$wgUsePathInfo = true;

## Skins
wfLoadSkin( 'Vector' );
wfLoadSkin( 'MonoBook' );
wfLoadSkin( 'Timeless' );
wfLoadSkin( 'MinervaNeue' );
$wgDefaultSkin = "timeless";

## Extensions
wfLoadExtension( 'CodeMirror' );
wfLoadExtension( 'VisualEditor' );
wfLoadExtension( 'VEForAll' );
wfLoadExtension( 'WikiEditor' );
wfLoadExtension( 'InputBox' );
wfLoadExtension( 'Gadgets' );
wfLoadExtension( 'Math' );
wfLoadExtension( 'AdminLinks' );
wfLoadExtension( 'SimpleChanges' );
wfLoadExtension( 'CommentStreams' );
wfLoadExtension( 'ParserFunctions' );   // template logic
wfLoadExtension( 'TemplateStyles' );    // scoped css in templates
wfLoadExtension( 'TemplateData' );
wfLoadExtension( 'Elastica' );
wfLoadExtension( 'CirrusSearch' );
wfLoadExtension( 'SlashCommands' );

## wikitext source mode inside VE toolbar
$wgVisualEditorEnableWikitext = true;    
$wgDefaultUserOptions['visualeditor-newwikitext'] = 1;

## Add CreatePageUw and configure it to use VisualEditor
wfLoadExtension( 'CreatePageUw' );
$wgCreatePageUwUseVE = true;

## Add Scribunto and configure it to use LuaSandbox
wfLoadExtension( 'Scribunto' );
$wgScribuntoDefaultEngine = 'luasandbox';

## Custom sidebar - modify the default sidebar
$wgHooks['SkinBuildSidebar'][] = function( $skin, &$sidebar ) {
    $sidebar['navigation']['Create new page'] = [
        'text' => 'Create new page',
        'href' => $skin->makeSpecialUrl( 'CreatePage' ),
        'id' => 'n-createpage',
        'active' => false
    ];
};

## Logo configuration
$wgLogos = [
	'icon' => "https://crc.artyom.me/w/images/c/c9/Logo.png",
	'1x' => "https://crc.artyom.me/w/images/c/c9/Logo.png",
	'2x' => "https://crc.artyom.me/w/images/c/c9/Logo.png",
];
