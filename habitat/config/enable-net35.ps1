Configuration EnableNet35
{
    Node 'localhost' {
        WindowsFeature netfx3 
        { 
            Ensure = "Present"
            Name = "NET-Framework-Core"
        }
    }
}
