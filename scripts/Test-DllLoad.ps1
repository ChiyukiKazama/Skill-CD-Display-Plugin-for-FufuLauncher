param([Parameter(Mandatory)][string]$DllPath)
$ErrorActionPreference='Stop'
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class DllLoadProbe {
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern IntPtr LoadLibraryW(string path);
}
'@
$module=[DllLoadProbe]::LoadLibraryW((Resolve-Path -LiteralPath $DllPath).Path)
if ($module -eq [IntPtr]::Zero) { throw "Compressed DLL loading failed: $([Runtime.InteropServices.Marshal]::GetLastWin32Error())" }
# The plugin checks the host name and leaves game hooks inactive in this probe.
Start-Sleep -Milliseconds 300
Write-Output 'Compressed DLL LoadLibrary smoke check passed (no game attached).'
