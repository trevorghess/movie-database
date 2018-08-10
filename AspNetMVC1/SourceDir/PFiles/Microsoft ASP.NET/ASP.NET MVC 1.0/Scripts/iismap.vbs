Const HKEY_LOCAL_MACHINE = &H80000002
Const MACHINE_NAME = "localhost"
Const FRAMEWORK_VERSION = "v2.0.50727"
Const DEFAULT_PATH = "W3SVC"
Const SCRIPT_MAPS = "ScriptMaps"

Function ExtensionExists(extension)
    Dim scriptExtension
    iisScriptMaps = GetScriptMaps()
    
    For scriptIndex = 0 To UBound(iisScriptMaps)
        scriptMap = iisScriptMaps(scriptIndex)
        decomposedScriptMap = Split(scriptMap, ",")
        scriptExtension = Right(decomposedScriptMap(0), Len(decomposedScriptMap(0))-1)
        If StrComp(LCase(scriptExtension), LCase(extension)) = 0 Then
            ExtensionExists = true
        End If
    Next
    
    ExtensionsExist = false
End Function

Function GetFrameworkPath()
    strComputer = "."
    Set registryObj = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
 
    strKeyPath = "SOFTWARE\Microsoft\.NETFramework"
    strValueName = "InstallRoot"
    registryObj.GetStringValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName, strValue

    GetFrameworkPath = strValue & FRAMEWORK_VERSION
End Function

Function GetScriptMaps()
    Dim iisObject

    Set iisObject = GetObject("IIS://" & MACHINE_NAME & "/" & DEFAULT_PATH)
    
    GetScriptMaps = iisObject.Get(SCRIPT_MAPS)
End Function

Sub RegisterExtension(extension)
    Dim iisScriptMaps
    
    Set iisObject = GetObject("IIS://" & MACHINE_NAME & "/" & DEFAULT_PATH)
    iisScriptMaps = GetScriptMaps()
    
    If ExtensionExists(extension) Then
        WScript.Echo extension & " is already registered."
        WScript.Quit
    End If

    ReDim Preserve iisScriptMaps(UBound(iisScriptMaps)+1)
    
    iisScriptMaps(UBound(iisScriptMaps)) = "." & extension & "," & GetFrameworkPath() & "\aspnet_isapi.dll,1,GET,HEAD,POST"
    iisObject.Put "ScriptMaps", iisScriptMaps
    iisObject.Setinfo
End Sub

Sub SetScriptMaps(ScriptMaps)
    Dim iisObject
    
    Set iisObject = GetObject("ISS://" & MACHINE_NAME & "/" & DEFAULT_PATH)
    
    iisObject.Put SCRIPT_MAPS, ScriptMaps
    iisObject.Setinfo
End Sub

Sub UnregisterExtension(extension)
    Dim newScriptMaps
    
    Set iisObject = GetObject("IIS://" & MACHINE_NAME & "/" & DEFAULT_PATH)
    iisScriptMaps = GetScriptMaps()
    
    If Not ExtensionExists(extension) Then
        WScript.Echo extension & " is not registered."
        WScript.Quit
    End If

    ReDim newScriptMaps(UBound(iisScriptMaps)-1)
    Dim newScriptIndex
    newScriptIndex = 0

    For scriptIndex = 0 To UBound(iisScriptMaps)
        scriptMap = iisScriptMaps(scriptIndex)
        decomposedScriptMap = Split(scriptMap, ",")
        scriptExtension = Right(decomposedScriptMap(0), Len(decomposedScriptMap(0))-1)
        If StrComp(LCase(scriptExtension), LCase(extension)) <> 0 Then
            newScriptMaps(newScriptIndex) = scriptMap
            newScriptIndex = newScriptIndex + 1
        End If
    Next
    
    iisObject.Put "ScriptMaps", newScriptMaps
    iisObject.Setinfo
End Sub
'' SIG '' Begin signature block
'' SIG '' MIIXLQYJKoZIhvcNAQcCoIIXHjCCFxoCAQExCzAJBgUr
'' SIG '' DgMCGgUAMGcGCisGAQQBgjcCAQSgWTBXMDIGCisGAQQB
'' SIG '' gjcCAR4wJAIBAQQQTvApFpkntU2P5azhDxfrqwIBAAIB
'' SIG '' AAIBAAIBAAIBADAhMAkGBSsOAwIaBQAEFOjbgy6dvP3F
'' SIG '' coke1c1w1wlFcycjoIISJDCCBGAwggNMoAMCAQICCi6r
'' SIG '' EdxQ/1ydy8AwCQYFKw4DAh0FADBwMSswKQYDVQQLEyJD
'' SIG '' b3B5cmlnaHQgKGMpIDE5OTcgTWljcm9zb2Z0IENvcnAu
'' SIG '' MR4wHAYDVQQLExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
'' SIG '' ITAfBgNVBAMTGE1pY3Jvc29mdCBSb290IEF1dGhvcml0
'' SIG '' eTAeFw0wNzA4MjIyMjMxMDJaFw0xMjA4MjUwNzAwMDBa
'' SIG '' MHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
'' SIG '' dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
'' SIG '' aWNyb3NvZnQgQ29ycG9yYXRpb24xIzAhBgNVBAMTGk1p
'' SIG '' Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBMIIBIjANBgkq
'' SIG '' hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAt3l91l2zRTmo
'' SIG '' NKwx2vklNUl3wPsfnsdFce/RRujUjMNrTFJi9JkCw03Y
'' SIG '' SWwvJD5lv84jtwtIt3913UW9qo8OUMUlK/Kg5w0jH9FB
'' SIG '' JPpimc8ZRaWTSh+ZzbMvIsNKLXxv2RUeO4w5EDndvSn0
'' SIG '' ZjstATL//idIprVsAYec+7qyY3+C+VyggYSFjrDyuJSj
'' SIG '' zzimUIUXJ4dO3TD2AD30xvk9gb6G7Ww5py409rQurwp9
'' SIG '' YpF4ZpyYcw2Gr/LE8yC5TxKNY8ss2TJFGe67SpY7UFMY
'' SIG '' zmZReaqth8hWPp+CUIhuBbE1wXskvVJmPZlOzCt+M26E
'' SIG '' RwbRntBKhgJuhgCkwIffUwIDAQABo4H6MIH3MBMGA1Ud
'' SIG '' JQQMMAoGCCsGAQUFBwMDMIGiBgNVHQEEgZowgZeAEFvQ
'' SIG '' cO9pcp4jUX4Usk2O/8uhcjBwMSswKQYDVQQLEyJDb3B5
'' SIG '' cmlnaHQgKGMpIDE5OTcgTWljcm9zb2Z0IENvcnAuMR4w
'' SIG '' HAYDVQQLExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAf
'' SIG '' BgNVBAMTGE1pY3Jvc29mdCBSb290IEF1dGhvcml0eYIP
'' SIG '' AMEAizw8iBHRPvZj7N9AMA8GA1UdEwEB/wQFMAMBAf8w
'' SIG '' HQYDVR0OBBYEFMwdznYAcFuv8drETppRRC6jRGPwMAsG
'' SIG '' A1UdDwQEAwIBhjAJBgUrDgMCHQUAA4IBAQB7q65+Siby
'' SIG '' zrxOdKJYJ3QqdbOG/atMlHgATenK6xjcacUOonzzAkPG
'' SIG '' yofM+FPMwp+9Vm/wY0SpRADulsia1Ry4C58ZDZTX2h6t
'' SIG '' KX3v7aZzrI/eOY49mGq8OG3SiK8j/d/p1mkJkYi9/uEA
'' SIG '' uzTz93z5EBIuBesplpNCayhxtziP4AcNyV1ozb2AQWtm
'' SIG '' qLu3u440yvIDEHx69dLgQt97/uHhrP7239UNs3DWkuNP
'' SIG '' tjiifC3UPds0C2I3Ap+BaiOJ9lxjj7BauznXYIxVhBoz
'' SIG '' 9TuYoIIMol+Lsyy3oaXLq9ogtr8wGYUgFA0qvFL0QeBe
'' SIG '' MOOSKGmHwXDi86erzoBCcnYOMIIEejCCA2KgAwIBAgIK
'' SIG '' YQYngQAAAAAACDANBgkqhkiG9w0BAQUFADB5MQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQg
'' SIG '' Q29kZSBTaWduaW5nIFBDQTAeFw0wODEwMjIyMTI0NTVa
'' SIG '' Fw0xMDAxMjIyMTM0NTVaMIGDMQswCQYDVQQGEwJVUzET
'' SIG '' MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
'' SIG '' bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
'' SIG '' aW9uMQ0wCwYDVQQLEwRNT1BSMR4wHAYDVQQDExVNaWNy
'' SIG '' b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEB
'' SIG '' AQUAA4IBDwAwggEKAoIBAQC9crSJ5xyfhcd0uGBcAzY9
'' SIG '' nP2ZepopRiKwp4dT7e5GOsdbBQtXqLfKBczTTHdHcIWz
'' SIG '' 5cvfZ+ej/XQnk2ef14oDRDDG98m6yTodCFZETxcIDfm0
'' SIG '' GWiqJBz7BVeF6cVOByE3p+vOLC+2Qs0hBafW5tMoV8cb
'' SIG '' es4pNgfNnlXMu/Ei66gjpA0pwvvQw1o+Yz3HLEkLe3mF
'' SIG '' 8Ijvcb1DWuOjsw3zVfsl4OIg0+eaXpSlMy0of1cbVWoM
'' SIG '' MkTvZmxv8Dic7wKtmqHdmAcQDjwYaeJ5TkYU4LmM0HVt
'' SIG '' nKwAnC1C9VG4WvR4RYPpLnwru13NGWEorZRDCsVqQv+1
'' SIG '' Mq6kKSLeFujTAgMBAAGjgfgwgfUwEwYDVR0lBAwwCgYI
'' SIG '' KwYBBQUHAwMwHQYDVR0OBBYEFCPRcypMvfvlIfpxHpkV
'' SIG '' 0Rf5xKaKMA4GA1UdDwEB/wQEAwIHgDAfBgNVHSMEGDAW
'' SIG '' gBTMHc52AHBbr/HaxE6aUUQuo0Rj8DBEBgNVHR8EPTA7
'' SIG '' MDmgN6A1hjNodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20v
'' SIG '' cGtpL2NybC9wcm9kdWN0cy9DU1BDQS5jcmwwSAYIKwYB
'' SIG '' BQUHAQEEPDA6MDgGCCsGAQUFBzAChixodHRwOi8vd3d3
'' SIG '' Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL0NTUENBLmNy
'' SIG '' dDANBgkqhkiG9w0BAQUFAAOCAQEAQynPY71s43Ntw5nX
'' SIG '' bQyIO8ZIc3olziziN3udNJ+9I86+39hceRFrE1EgAWO5
'' SIG '' cvcI48Z9USoWKNTR55sqzxgN0hNxkSnsVr351sUNL69l
'' SIG '' LW1NRSlWcoRPP9JqHUFiqXlcjvDHd4rLAiguncecK+W5
'' SIG '' Kgnd7Jfi5XqNXhCIU6HdYE93mHFgqFs5kdOrEh8F6cNF
'' SIG '' qdPCUbmvuNz8BoQA9HSj2//MHaAjBQfkJzXCl5AZqoJg
'' SIG '' J+j7hCse0QTLjs+CDdeoTUNAddLe3XfvilxrD4dkj7S6
'' SIG '' t7qrZ1QhRapKaOdUXosUXGd47JBcAxCRCJ0kIJfo3wAR
'' SIG '' cKn5snJwt67iwp8WAjCCBJ0wggOFoAMCAQICCmFJfO0A
'' SIG '' AAAAAAUwDQYJKoZIhvcNAQEFBQAweTELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEjMCEGA1UEAxMaTWljcm9zb2Z0IFRpbWVz
'' SIG '' dGFtcGluZyBQQ0EwHhcNMDYwOTE2MDE1NTIyWhcNMTEw
'' SIG '' OTE2MDIwNTIyWjCBpjELMAkGA1UEBhMCVVMxEzARBgNV
'' SIG '' BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
'' SIG '' HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEn
'' SIG '' MCUGA1UECxMebkNpcGhlciBEU0UgRVNOOjEwRDgtNTg0
'' SIG '' Ny1DQkY4MScwJQYDVQQDEx5NaWNyb3NvZnQgVGltZXN0
'' SIG '' YW1waW5nIFNlcnZpY2UwggEiMA0GCSqGSIb3DQEBAQUA
'' SIG '' A4IBDwAwggEKAoIBAQDqugVjyNl5roREPqWzxO1MniTf
'' SIG '' OXYeCdYySlh40ivZpQeQ7+c9+70mfKP75X1+Ms/ZPYs5
'' SIG '' N/L42Ds0FtSSgvs07GiFchqP4LhM4LiF8zMKAsGidnM1
'' SIG '' TF3xt+FKfR24lHjb/x6FFUJGcc5/J1cS0YNPO8/63vaL
'' SIG '' 7T8A49XeYfkXjUukgTz1aUDq4Ym/B0+6dHvpDOVH6qts
'' SIG '' 8dVngQj4Fsp9E7tz4glM+mL77aA5mjr+6xHIYR5iWNgK
'' SIG '' VIPVO0tL4lW9L2AajpIFQ9pd64IKI5cJoAUxZYuTTh5B
'' SIG '' IaKSkP1FREVvNbFFN61pqWX5NEOxF8I7OeEQjPIah+NU
'' SIG '' UB87nTGtAgMBAAGjgfgwgfUwHQYDVR0OBBYEFH5y8C4/
'' SIG '' VingJfdouAH8S+F+z+M+MB8GA1UdIwQYMBaAFG/oTj+X
'' SIG '' uTSrS4aPvJzqrDtBQ8bQMEQGA1UdHwQ9MDswOaA3oDWG
'' SIG '' M2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3Js
'' SIG '' L3Byb2R1Y3RzL3RzcGNhLmNybDBIBggrBgEFBQcBAQQ8
'' SIG '' MDowOAYIKwYBBQUHMAKGLGh0dHA6Ly93d3cubWljcm9z
'' SIG '' b2Z0LmNvbS9wa2kvY2VydHMvdHNwY2EuY3J0MBMGA1Ud
'' SIG '' JQQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIGwDAN
'' SIG '' BgkqhkiG9w0BAQUFAAOCAQEAaXqCCQwW0d7PRokuv9E0
'' SIG '' eoF/JyhBKvPTIZIOl61fU14p+e3BVEqoffcT0AsU+U3y
'' SIG '' hhUAbuODHShFpyw5Mt1vmjda7iNSj1QDjT+nnGQ49jbI
'' SIG '' FEO2Oj6YyQ3DcYEo82anMeJcXY/5UlLhXOuTkJ1pCUyJ
'' SIG '' 0dF2TDQNauF8RKcrW4NUf0UkGSXEikbFJeMZgGkpFPYX
'' SIG '' xvAiLIFGXiv0+abGdz4jb/mmZIWOomINqS0eqOWQPn//
'' SIG '' sI78l+zx/QSvzUnOWnSs+vMTHxs5zqO01rz0tO7IrfJW
'' SIG '' Hvs88cjWKkS8v5w/fWYYzbIgYwrKQD1lMhl8srg9wSZI
'' SIG '' TiIZmW6MMMHxkTCCBJ0wggOFoAMCAQICEGoLmU/AACWr
'' SIG '' EdtFH1h6Z6IwDQYJKoZIhvcNAQEFBQAwcDErMCkGA1UE
'' SIG '' CxMiQ29weXJpZ2h0IChjKSAxOTk3IE1pY3Jvc29mdCBD
'' SIG '' b3JwLjEeMBwGA1UECxMVTWljcm9zb2Z0IENvcnBvcmF0
'' SIG '' aW9uMSEwHwYDVQQDExhNaWNyb3NvZnQgUm9vdCBBdXRo
'' SIG '' b3JpdHkwHhcNMDYwOTE2MDEwNDQ3WhcNMTkwOTE1MDcw
'' SIG '' MDAwWjB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
'' SIG '' aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
'' SIG '' ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSMwIQYDVQQD
'' SIG '' ExpNaWNyb3NvZnQgVGltZXN0YW1waW5nIFBDQTCCASIw
'' SIG '' DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANw3bvuv
'' SIG '' yEJKcRjIzkg+U8D6qxS6LDK7Ek9SyIPtPjPZSTGSKLaR
'' SIG '' ZOAfUIS6wkvRfwX473W+i8eo1a5pcGZ4J2botrfvhbnN
'' SIG '' 7qr9EqQLWSIpL89A2VYEG3a1bWRtSlTb3fHev5+Dx4Df
'' SIG '' f0wCN5T1wJ4IVh5oR83ZwHZcL322JQS0VltqHGP/gHw8
'' SIG '' 7tUEJU05d3QHXcJc2IY3LHXJDuoeOQl8dv6dbG564Ow+
'' SIG '' j5eecQ5fKk8YYmAyntKDTisiXGhFi94vhBBQsvm1Go1s
'' SIG '' 7iWbE/jLENeFDvSCdnM2xpV6osxgBuwFsIYzt/iUW4RB
'' SIG '' hFiFlG6wHyxIzG+cQ+Bq6H8mjmsCAwEAAaOCASgwggEk
'' SIG '' MBMGA1UdJQQMMAoGCCsGAQUFBwMIMIGiBgNVHQEEgZow
'' SIG '' gZeAEFvQcO9pcp4jUX4Usk2O/8uhcjBwMSswKQYDVQQL
'' SIG '' EyJDb3B5cmlnaHQgKGMpIDE5OTcgTWljcm9zb2Z0IENv
'' SIG '' cnAuMR4wHAYDVQQLExVNaWNyb3NvZnQgQ29ycG9yYXRp
'' SIG '' b24xITAfBgNVBAMTGE1pY3Jvc29mdCBSb290IEF1dGhv
'' SIG '' cml0eYIPAMEAizw8iBHRPvZj7N9AMBAGCSsGAQQBgjcV
'' SIG '' AQQDAgEAMB0GA1UdDgQWBBRv6E4/l7k0q0uGj7yc6qw7
'' SIG '' QUPG0DAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
'' SIG '' BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zANBgkq
'' SIG '' hkiG9w0BAQUFAAOCAQEAlE0RMcJ8ULsRjqFhBwEOjHBF
'' SIG '' je9zVL0/CQUt/7hRU4Uc7TmRt6NWC96Mtjsb0fusp8m3
'' SIG '' sVEhG28IaX5rA6IiRu1stG18IrhG04TzjQ++B4o2wet+
'' SIG '' 6XBdRZ+S0szO3Y7A4b8qzXzsya4y1Ye5y2PENtEYIb92
'' SIG '' 3juasxtzniGI2LS0ElSM9JzCZUqaKCacYIoPO8cTZXhI
'' SIG '' u8+tgzpPsGJY3jDp6Tkd44ny2jmB+RMhjGSAYwYElvKa
'' SIG '' AkMve0aIuv8C2WX5St7aA3STswVuDMyd3ChhfEjxF5wR
'' SIG '' ITgCHIesBsWWMrjlQMZTPb2pid7oZjeN9CKWnMywd1RR
'' SIG '' OtZyRLIj9jGCBHUwggRxAgEBMIGHMHkxCzAJBgNVBAYT
'' SIG '' AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
'' SIG '' EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
'' SIG '' cG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2Rl
'' SIG '' IFNpZ25pbmcgUENBAgphBieBAAAAAAAIMAkGBSsOAwIa
'' SIG '' BQCggaAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
'' SIG '' HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJ
'' SIG '' KoZIhvcNAQkEMRYEFM63VAZ8Rq+YzKGE0JWAusKc0VRE
'' SIG '' MEAGCisGAQQBgjcCAQwxMjAwoBiAFgBBAFMAUAAuAE4A
'' SIG '' RQBUACAATQBWAEOhFIASaHR0cDovL3d3dy5hc3AubmV0
'' SIG '' MA0GCSqGSIb3DQEBAQUABIIBADUIlsIGqq5rGvVmEhKU
'' SIG '' KocgMJ47/20Z9emqRgLjkf+HN+5WrbQ+dR72y8JZaOyN
'' SIG '' NvPw45iL0m79qby9/8G2MMe1UZX8tnHU/gdUhVUxaaJ8
'' SIG '' pHN1FnfDnJqquMOOtMO50U9URas3WZg1HcnXNlVs6Dun
'' SIG '' etb7nJVmd7RUxULwMNCUvvZkljMVtU9IEJybK/4Lj1pK
'' SIG '' 9gacY8kBHoDB8WIbAAYDZjsnwmuRJ8sLA+V5YyJXMv8J
'' SIG '' L9Rn1Oi957+6wFlsn+/ATk6UtMIoAxuzRkErloUMssnM
'' SIG '' Tf2/J3fJqncKAr540qdeYAMDZcLdMZ8vLTU1Jwf4cFrx
'' SIG '' Rt2rXyRDgPbVuS6hggIfMIICGwYJKoZIhvcNAQkGMYIC
'' SIG '' DDCCAggCAQEwgYcweTELMAkGA1UEBhMCVVMxEzARBgNV
'' SIG '' BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
'' SIG '' HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEj
'' SIG '' MCEGA1UEAxMaTWljcm9zb2Z0IFRpbWVzdGFtcGluZyBQ
'' SIG '' Q0ECCmFJfO0AAAAAAAUwBwYFKw4DAhqgXTAYBgkqhkiG
'' SIG '' 9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEP
'' SIG '' Fw0wOTAyMjgwMDM5NDVaMCMGCSqGSIb3DQEJBDEWBBQv
'' SIG '' gv+Z3zhx2RP0Y77+1l8NEzDuqDANBgkqhkiG9w0BAQUF
'' SIG '' AASCAQCTCc49z9nNDxp5m582iBGJb7g2O+9hPFXhYzp6
'' SIG '' OcBuEUHnjWOtuHHvwqePlXV0Y4uZMF8uey/yUwcQhExn
'' SIG '' ztERdVNA6yzmwpBxdF5ER4KXsyYE+zUccdy7JEg55cla
'' SIG '' uZnsR9VU+fp1kmlBcOwe5WnFa2vmtmprijdc/VOiREoO
'' SIG '' yfiwMjS6mIxqm4FbPygJMHZgGTcnRJqEFl1eVak5dqlh
'' SIG '' r0RgRPsRaeob+WtfIYpkfkCk4rJcyAmg752pnw7yYV5f
'' SIG '' Vkz2LZ3Ucpx2LkK6FCZvSHy3mLNm732aOSGla6KJbUVJ
'' SIG '' Jm3cuUVMN2TT6/2A7kVeocPaoFM4dY8y7Kv7yuxT
'' SIG '' End signature block
