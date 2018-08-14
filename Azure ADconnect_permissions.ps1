# Setup remote conenction to Domain Controller if running remotely.

$RemServer = "CFSNTHITIDC01.adcfs.capita.co.uk"

$creds = Get-Credential

$s = new-pssession -computer $RemServer -Credential $creds

Invoke-Command -session $s -script { Import-Module ActiveDirectory }

Import-PSSession -session $s -module ActiveDirectory #-prefix Rem

# below runs through setting the permissions
# should see the reult of the account being defined for the service account if successfull

# msDS-ConsistencyGuid feature

$accountName = "ADCFS\Svc_Add_Connect"
$ForestDN = "DC=adcfs,DC=capita,DC=co,DC=uk"
$cmd = "dsacls '$ForestDN' /I:S /G '`"$accountName`":WP;ms-ds-consistencyGuid;user'"
Invoke-Expression $cmd

# Password Sync 

$accountName = "ADCFS\Svc_Add_Connect"
$RootDSE = [ADSI]"LDAP://RootDSE"
$DefaultNamingContext = $RootDse.defaultNamingContext
$ConfigurationNamingContext = $RootDse.configurationNamingContext
$cmd = "dsacls '$DefaultNamingContext' /G '`" $accountName`":CA;`"Replicating Directory Changes`";'"
Invoke-Expression $cmd
$cmd = "dsacls '$DefaultNamingContext' /G '`"$accountName`":CA;`"Replicating Directory Changes All`";'"
Invoke-Expression $cmd

# Password Writeback

$accountName = "ADCFS\Svc_Add_Connect"
$DN = "OU=TEST,DC=adcfs,DC=capita,DC=co,DC=uk"
$cmd = "dsacls '$DN' /I:S /G '`"$accountName`":CA;`"Reset Password`";user'"
Invoke-Expression $cmd
$cmd = "dsacls '$DN' /I:S /G '`"$accountName`":CA;`"Change Password`";user'"
Invoke-Expression $cmd
$cmd = "dsacls '$DN' /I:S /G '`"$accountName`":WP;pwdLastSet;user'"
Invoke-Expression $cmd
$cmd = "dsacls '$DN' /I:S /G '`"$accountName`":WP;lockoutTime;user'"
Invoke-Expression $cmd