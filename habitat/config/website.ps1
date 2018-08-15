Configuration NewWebsite
{
    $DestinationPath = Resolve-Path "{{pkg.svc_path}}\MovieApp"
    Write-Host $DestinationPath
    Import-DscResource -Module xWebAdministration
    Node 'localhost' {
        WindowsFeature netfx3 
        { 
            Ensure = "Present"
            Name = "NET-Framework-Core"
            {{#if cfg.netfx3_source}}
                Source = "{{cfg.netfx3_source}}"
            {{/if}}
        }

        WindowsFeature ASP 
        { 
            Ensure = "Present"
            Name = "WEB-ASP-NET"
        }

        WindowsFeature static_content 
        { 
            Ensure = "Present"
            Name = "WEB-STATIC-CONTENT"
        }

        xWebAppPool {{cfg.app_pool}}
        {
            Name   = "{{cfg.app_pool}}"
            ManagedPipelineMode = "Integrated"
            Enable32BitAppOnWin64 = $true
            ManagedRuntimeVersion = "v2.0"
            Ensure = "Present"
            State  = "Started"
        }
        
        xWebsite {{cfg.site_name}}
        {
            Ensure          = "Present"
            Name            = "{{cfg.site_name}}"
            State           = "Started"
            PhysicalPath    = Resolve-Path "{{pkg.svc_path}}\www"
            ApplicationPool = "{{cfg.app_pool}}"
            BindingInfo = @(
                MSFT_xWebBindingInformation
                {
                    Protocol = "http"
                    Port = {{cfg.port}}
                }
            )
        }
        xWebApplication '{{cfg.app_name}}' 
        {
            Ensure                  = 'Present'
            Name                    = '{{cfg.app_name}}'
            WebAppPool              = '{{cfg.app_pool}}'
            Website                 = '{{cfg.site_name}}'
            PreloadEnabled          = $true
            ServiceAutoStartEnabled = $true
            AuthenticationInfo      = MSFT_xWebApplicationAuthenticationInformation
            {
                Anonymous   = $true
                Basic       = $false
                Digest      = $false
                Windows     = $false
            }
            SslFlags                = ''
            PhysicalPath            = $DestinationPath
            DependsOn               = '[xWebsite]{{cfg.site_name}}','[xWebAppPool]{{cfg.app_pool}}'
        }
    }
}
