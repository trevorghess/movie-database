# movie-database

ASP.NET MVC 1.0 App Repackaged with Habitat
https://docs.microsoft.com/en-us/aspnet/mvc/overview/older-versions-1/movie-database/create-a-movie-database-application-in-15-minutes-with-asp-net-mvc-cs 


### Setup steps to run in any environment

Make sure your VM is running Windows Server 2016 (4GB of Ram is advisable). Open a Powershell console and install Chocolatey, git, chrome and Habitat:

```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install habitat -y
choco install git -y
choco install googlechrome -y
```

Close and reopen your Powershell console to refresh the changed `PATH`.

Navigate to `c:\`. The SQL Server installer can fail if the install path is too long. Entering into a local studio at `c:\users\administrators\sqlwebadmin` will result in a much longer install path than entering from `c:\sqlwebadmin`. Clone this repo and `cd` into the top level directory:

```
cd c:\
git clone https://github.com/trevorghess/movie-database
cd movie-database
```

Setup a local default origin and key by running `hab setup`

### Demo in a Windows VM

**Important**: For a smooth demo in front of an audience, make sure to run through the initial install and loading of services once before the live demo and then `unload` the services when everything is confirmed working. The first load takes MUCH longer than subsequent loads because of the .Net 2.0 and SQL Server installation. Susequent loads will already have these in place and will be much faster.

Open two PowerShell Administrator Windows

In one PowerShell instance, run the Habitat Supervisor. This will be your view into the packages running in Habitat
```
hab sup run
```

In the second PowerShell instance, load the core/sqlserver package, make sure to pass the name of your Windows Admin user to the config before loading.

```
"sys_admin_account = 'azureadmin'" | hab config apply sqlserver.default 1
hab svc load core/sqlserver
```

This will take several minutes to load since it is downloading and installing the .Net 2.0 runtime and installing SQL Server 2005. While its loading, build this plan in a third PowerShell Administrator instance:

```
cd C:\movie-database
hab studio enter -w
build
```

Now we need to wait for SQL Server's `post-run` hook to complete. View the Supervisor output in the first PowerShell terminal and wait for the message:

```
sqlserver.default hook[post-run]:(HK): 1> 2> 3> 4> 5> 6> Application user setup complete
```

Now install your built package in the second PowerShell terminal that we launched SQL from. 
```
hab pkg install C:\movie-database\habitat\results\<your_package.hart>
```

Now load `<your_origin>/movie-database`:

```
hab svc load <your_origin>/movie-database --bind database:sqlserver2005.default
```

In the Supervisor log wait for:

```
movie-database.default(O): movie-database is running
```

The website should now be accessible. Browse to `http://localhost:8099/movie_db_app`. Enjoy the fine selection of films!

## Thanks
Much of this readme was stolen and repurposed from https://github.com/habitat-sh/sqlwebadmin thanks Matt Wrock!
