$pkg_name="movie-database"
$pkg_origin="th_demo"
$pkg_version="0.1.0"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=@("Apache-2.0")
$pkg_source="http://download.microsoft.com/download/7/2/8/728F8794-E59A-4D18-9A56-7AD2DB05BD9D/MovieApp_CS.zip"
# $pkg_filename="$pkg_name-$pkg_version.zip"
$pkg_shasum="93bb6654357446cd443d75562949ad62194bac07a589b22cd95f2223292c61d0"
$pkg_deps=@("core/dsc-core")
$pkg_build_deps=@("core/visual-build-tools-2017", "core/dsc-core", 'core/aspnet-mvc1', "core/nuget")
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

    cp -r $PLAN_CONTEXT/../aspnetdb.mdf $HAB_CACHE_SRC_PATH\$pkg_dirname\MovieApp\MovieApp\App_Data
    cp -r $PLAN_CONTEXT/../aspnetdb_log.ldf $HAB_CACHE_SRC_PATH\$pkg_dirname\MovieApp\MovieApp\App_Data
    
    Import-Module "$(Get-HabPackagePath dsc-core)/Modules/DscCore"
    Start-DscCore $PLAN_CONTEXT\config\enable-net35.ps1 EnableNet35

    $csprojPath = "$HAB_CACHE_SRC_PATH\$pkg_dirname\MovieApp\MovieApp\MovieApp.csproj"

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
            $_.Project = "$HAB_CACHE_SRC_PATH\$pkg_dirname\MSBuild.Microsoft.VisualStudio.Web.targets.14.0.0.3\tools\VSToolsPath\\WebApplications\Microsoft.WebApplication.targets"
        }
        
    }
    $proj.Save($csprojPath)
    
    nuget install MSBuild.Microsoft.VisualStudio.Web.targets -Version 14.0.0.3 -OutputDirectory $HAB_CACHE_SRC_PATH/$pkg_dirname/
    MSBuild.exe $csprojPath /property:Configuration=Release 
    if($LASTEXITCODE -ne 0) {
        Write-Error "dotnet build failed!"
    }
  }

function Invoke-Install{
    New-Item -ItemType Directory -Path $pkg_prefix/MovieApp
    Write-Host "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/bin/"
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/App_Data" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/Scripts" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/Content" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/bin/" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/Views/" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/Default.aspx" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/Global.asax" "$pkg_prefix/MovieApp" -recurse
}