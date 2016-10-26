$wgLogo = $wgScriptPath . '/images/feup_logo.png';
enableSemantics( 'http://gcc-mci.fe.up.pt/grupoXXXX' ); //FIXME
//
//Prevent new user registrations except by sysops
$wgGroupPermissions['*']['createaccount'] = false;

//enable uploads
$wgEnableUploads = true; # Enable uploads

$wgTrustedMediaFormats[] = 'application/zip';

$wgFileExtensions = array( 'png', 'gif', 'jpg', 'jpeg', 'doc',
    'xls', 'mpp', 'pdf', 'ppt', 'tiff', 'bmp', 'docx', 'xlsx',
    'pptx', 'ps', 'odt', 'ods', 'odp', 'odg', 'zip'
);

//enable captchas to present spam
wfLoadExtensions( array( 'ConfirmEdit', 'ConfirmEdit/QuestyCaptcha' ) );

// Add your questions in LocalSettings.php using this format:
$wgCaptchaQuestions = array(
    'Qual é o nome ou sigla desta Unidade Curricular?' => array( 'GCC', 'gestt
ão de conhecimento e colaboração', 'Gestão de Conhecimento', 'Gestão de CC
onhecimento e Colaboração', 'gestao de conhecimento e colaboracao' ), // A qq
uestion may have many answers
);

$wgGroupPermissions['*']['edit'] = false;
