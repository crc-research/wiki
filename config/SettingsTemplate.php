<?php
// If not running MediaWiki, exit
if ( !defined( 'MEDIAWIKI' ) ) {
	exit;
}

# Enable nice URLs (remove index.php from URLs)
$wgScriptPath = "/w";
$wgArticlePath = "/$1";
$wgUsePathInfo = true;