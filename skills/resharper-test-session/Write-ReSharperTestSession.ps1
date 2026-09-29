[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $SessionName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $OutputPath,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]] $TestId
)

$uniqueTestIds = @($TestId | Sort-Object -Unique)

if ($uniqueTestIds.Count -eq 0) {
    throw 'Expected at least one ReSharper test ID.'
}

foreach ($identifier in $uniqueTestIds) {
    if ($identifier -notmatch '^[^:]+::[0-9A-Fa-f-]{36}::[^:]+::.+$') {
        throw "Invalid ReSharper test ID: '$identifier'."
    }
}

$resolvedOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
$outputDirectory = [System.IO.Path]::GetDirectoryName($resolvedOutputPath)

if ([string]::IsNullOrWhiteSpace($outputDirectory)) {
    throw "Could not resolve the output directory from '$OutputPath'."
}

[System.IO.Directory]::CreateDirectory($outputDirectory) | Out-Null

$settings = [System.Xml.XmlWriterSettings]::new()
$settings.Indent = $true
$settings.Encoding = [System.Text.UTF8Encoding]::new($false)
$settings.NewLineChars = [Environment]::NewLine

$writer = [System.Xml.XmlWriter]::Create($resolvedOutputPath, $settings)

try {
    $namespace = 'urn:schemas-jetbrains-com:jetbrains-ut-session'
    $writer.WriteStartDocument()
    $writer.WriteStartElement('SessionState', $namespace)
    $writer.WriteAttributeString('ContinuousTestingMode', '0')
    $writer.WriteAttributeString('IsActive', 'True')
    $writer.WriteAttributeString('Name', $SessionName)
    $writer.WriteStartElement('TestAncestor', $namespace)

    foreach ($identifier in $uniqueTestIds) {
        $writer.WriteElementString('TestId', $namespace, $identifier)
    }

    $writer.WriteEndElement()
    $writer.WriteEndElement()
    $writer.WriteEndDocument()
}
finally {
    $writer.Dispose()
}

[xml] $generatedSession = Get-Content -LiteralPath $resolvedOutputPath -Raw
$namespaceManager = [System.Xml.XmlNamespaceManager]::new($generatedSession.NameTable)
$namespaceManager.AddNamespace('jb', 'urn:schemas-jetbrains-com:jetbrains-ut-session')
$writtenTestIds = @($generatedSession.SelectNodes('/jb:SessionState/jb:TestAncestor/jb:TestId', $namespaceManager))

if ($writtenTestIds.Count -ne $uniqueTestIds.Count) {
    throw "Expected $($uniqueTestIds.Count) test IDs, but wrote $($writtenTestIds.Count)."
}

if ($generatedSession.SelectSingleNode('//jb:Not', $namespaceManager)) {
    throw 'Generated session unexpectedly contains an exclusion node.'
}

Write-Output $resolvedOutputPath
