function Import-Svg([string]$svgFile)
{
    $svgDOM = New-Object System.Xml.XmlDocument
    $settings = New-Object System.Xml.XmlReaderSettings
    $settings.MaxCharactersFromEntities = 0;
    $settings.DtdProcessing = [System.Xml.DtdProcessing]::Parse
    $reader = [System.Xml.XmlReader]::Create($svgFile, $settings)
    try {
        $svgDOM.Load($reader)
    }
    finally {
        $reader.Close()
    }
    return $svgDOM
}

function Convert-Svg([string]$svgFile)
{
    $svgDOM = Import-Svg $svgFile
    $namespaceURI = $svgDOM.DocumentElement.NamespaceURI
    $nsmgr = New-Object System.Xml.XmlNamespaceManager($svgDOM.NameTable)
    $nsmgr.AddNamespace("svg", $namespaceURI)

    # set transparent background
    $svgDOM.svg.rect.style = "fill:none;"

    # set responsive text style
    $svgStyle = $svgDOM.CreateElement("style", $namespaceURI)
    $svgStyle.InnerText = "text { fill: #000; } @media (prefers-color-scheme: dark) { text { fill: #eee; } }"
    [void]$svgDOM.SelectSingleNode("/svg:svg", $nsmgr).PrependChild($svgStyle)

    # remove default text style from all text nodes
    foreach ($textElement in $svgDOM.SelectNodes("//svg:text", $nsmgr)) {
        $textElement.style = $textElement.style.replace("fill:rgb(0,0,0);", "")
    }

    $svgDOM.Save($svgFile)
}