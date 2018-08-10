$pkg_name="movie-database"
$pkg_origin="th_demo"
$pkg_version="0.1.0"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=@("Apache-2.0")
$pkg_source="http://download.microsoft.com/download/7/2/8/728F8794-E59A-4D18-9A56-7AD2DB05BD9D/MovieApp_CS.zip"
# $pkg_filename="$pkg_name-$pkg_version.zip"
$pkg_shasum="93bb6654357446cd443d75562949ad62194bac07a589b22cd95f2223292c61d0"
# $pkg_deps=@()
$pkg_build_deps=@("core/visual-build-tools-2017")
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
# $pkg_binds=@{
#   database="port host"
# }
# $pkg_binds_optional=@{
#   storage="port host"
# }
# $pkg_description="Some description."
# $pkg_upstream_url="http://example.com/project-name"

function Invoke-Download{
    return 0
}

function Invoke-Unpack{
    return 0
}

function Invoke-Verify{
    return 0
}
function Invoke-Build{
    cp -r $PLAN_CONTEXT/.. $HAB_CACHE_SRC_PATH/$pkg_dirname
    cd ${HAB_CACHE_SRC_PATH}/${pkg_dirname}

    Add-WindowsFeature NET-Framework-Core
    
    MSBuild.exe $HAB_CACHE_SRC_PATH\$pkg_dirname\src\MovieApp\MovieApp\MovieApp.csproj
}