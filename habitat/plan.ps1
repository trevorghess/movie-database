$pkg_name="movie-database"
$pkg_origin="th_demo"
$pkg_version="0.1.0"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=@("Apache-2.0")
$pkg_source="http://download.microsoft.com/download/7/2/8/728F8794-E59A-4D18-9A56-7AD2DB05BD9D/MovieApp_CS.zip"
# $pkg_filename="$pkg_name-$pkg_version.zip"
$pkg_shasum="93bb6654357446cd443d75562949ad62194bac07a589b22cd95f2223292c61d0"
$pkg_deps=@("core/dsc-core", "core/nuget")
$pkg_build_deps=@("core/visual-build-tools-2017", "core/dsc-core", 'core/aspnet-mvc1')
# $pkg_lib_dirs=@("lib")
# $pkg_include_dirs=@("include")
# $pkg_bin_dirs=@("bin")
# $pkg_svc_run="MyBinary.exe"
# $pkg_exports=@{
#   host="srv.address"
#   port="srv.port"
#   ssl-port="srv.ssl.port"
# }
# $pkg_exposes=@("port", "ssl-port")
$pkg_binds=@{
  database="port username password"
}
# $pkg_binds_optional=@{
#   storage="port host"
# }
# $pkg_description="Some description."
# $pkg_upstream_url="http://example.com/project-name"

function Invoke-Build{
    cp -r $PLAN_CONTEXT/.. $HAB_CACHE_SRC_PATH/$pkg_dirname
    cd ${HAB_CACHE_SRC_PATH}/${pkg_dirname}
    
    Import-Module "$(Get-HabPackagePath dsc-core)/Modules/DscCore"
    Start-DscCore $PLAN_CONTEXT\config\enable-net35.ps1 EnableNet35

    $csprojPath = "$HAB_CACHE_SRC_PATH\$pkg_dirname\src\MovieApp\MovieApp\MovieApp.csproj"

    $proj = [xml](get-content $csprojPath)
    $mvcAssemblyHintPathNode = $proj.CreateElement("HintPath", "http://schemas.microsoft.com/developer/msbuild/2003")
    $mvcAssemblyHintPath = "$(Get-HabPackagePath aspnet-mvc1)\Assemblies\System.Web.Mvc.dll"
    $mvcAssemblyHintPathNode.InnerText = $mvcAssemblyHintPath
    $proj.GetElementsByTagName("Reference") | foreach {
        if($_.Include -eq 'System.Web.Mvc, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL'){
            $_.AppendChild($mvcAssemblyHintPathNode)
        }
    }
    $proj.GetElementsByTagName("Import") | foreach {
        if($_.Project -eq '$(MSBuildExtensionsPath)\Microsoft\VisualStudio\v9.0\WebApplications\Microsoft.WebApplication.targets'){
            $_.Project = '$(MSBuildExtensionsPath)\Microsoft\VisualStudio\v15.0\WebApplications\Microsoft.WebApplication.targets'
        }
        
    }
    $proj.Save($csprojPath)
    
    MSBuild.exe $csprojPath /property:Configuration=Release 
}

function Invoke-Install{
    nuget install Microsoft.SqlServer.SqlManagementObjects -Version 140.17279.0
    nuget install System.Data.SqlClient -Version 4.4.2
    Unblock-File "C:\Users\azureadmin\.nuget\packages\microsoft.sqlserver.sqlmanagementobjects\140.17279.0\lib\netstandard2.0\Microsoft.SqlServer.Smo.dll"
    Unblock-File "C:\Users\azureadmin\.nuget\packages\microsoft.sqlserver.sqlmanagementobjects\140.17279.0\lib\net40\Microsoft.SqlServer.Smo.dll"
    Unblock-File "C:\Users\azureadmin\.nuget\packages\system.data.sqlclient\4.4.2\lib\netstandard1.2\System.Data.SqlClient.dll"

    New-Item -ItemType Directory -Path $pkg_prefix/MovieApp
    Write-Host "$HAB_CACHE_SRC_PATH/$pkg_dirname/src/MovieApp/MovieApp/bin/"
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/src/MovieApp/MovieApp/App_Data" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/src/MovieApp/MovieApp/Scripts" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/src/MovieApp/MovieApp/Content" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/src/MovieApp/MovieApp/bin/" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/src/MovieApp/MovieApp/Views/" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/src/MovieApp/MovieApp/Default.aspx" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/src/MovieApp/MovieApp/Global.asax" "$pkg_prefix/MovieApp" -recurse
}