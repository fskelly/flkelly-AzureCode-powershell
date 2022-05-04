choco install openssh

$username = ""
$keyLocation = ''
$keyName = $username
$keyPath = $keyLocation + $keyName

ssh-keygen -m PEM -t rsa -b 4096 -f $keyPath -C $username

$pubKeyPath = $keyPath + '.pub'
$pubKey = get-content -Path $pubKeyPath
$pubKey
$destinationIp = ""

type $pubKeyPath | ssh $username@$destinationIp "cat >> .ssh/authorized_keys"