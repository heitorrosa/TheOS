# The $GLOBAL_INTERVAL variable stores the desired IMOD interval to be applied to all XHCI controllers. You
# can override this for individual controllers by using the DEV_XXXX hardware id value for the XHCI controller.
# See the example below.
#
#    $GLOBAL_INTERVAL = 0x0
#
#    $INDIVIDUAL_INTERVALS = @{
#        "DEV_8CB1" = 0xFFFF
#    }
#
# In this example, the IMOD interval for all controllers will be set to 0x0, but the DEV_8CB1 XHCI controller's
# IMOD interval will override the global value and be set to 0xFFFF.
#
# https://gist.github.com/amitxv/4fe34e139f0aec681a6122f39757d86e
#

$GLOBAL_INTERVAL = 0x0

$INDIVIDUAL_INTERVALS = @{}

# specify the path to Rw.exe
$RWE_PATH = "C:\Program Files\RW-Everything\Rw.exe"

# the values  usually don't need to be changed as they are consistent across vendors
# refer to the XHCI docs to confirm the offset values
$HCSPARAMS_OFFSET = 0x4
$RTSOFF = 0x18

function GetValueFromAddress($address) {
    # convert the hex value to string for RWE
    $address = "0x$(([uint64]$address).ToString("X2"))"

    $stdout = & $RWE_PATH /Min /NoLogo /Stdout /Command="R32 $($address)" | Out-String
    $split_string = $stdout -split " "
    return [uint64]$split_string[-1]
}

function Is-Admin() {
    $current_principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $current_principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function main() {
    if (-not (Is-Admin)) {
        Write-Host "error: administrator privileges required"
        return 1
    }

    if (-not (Test-Path $RWE_PATH -PathType Leaf)) {
        Write-Host "error: $($RWE_PATH) not exists, edit the script to change the path to Rw.exe"
        Write-Host "http://rweverything.com/download"
        return 1
    }

    # CLI will not work if Rw is already open
    Stop-Process -Name "Rw" -ErrorAction SilentlyContinue

    # get physical address of each device present in the system
    $device_map = @{}

    $resources = Get-WmiObject -Class Win32_PNPAllocatedResource -ComputerName LocalHost -Namespace root\CIMV2

    foreach ($resource in $resources) {
        $device_ID = $resource.Dependent.Split("=")[1].Replace('"', '').Replace("\\", "\")
        $physical_address = $resource.Antecedent.Split("=")[1].Replace('"', '')

        if (-not $device_map.ContainsKey($device_ID) -and $device_ID -and $physical_address) {
            $device_map[$device_ID] = [uint64]$physical_address
        }
    }

    foreach ($xhci_controller in Get-WmiObject Win32_USBController) {
        $is_disabled = $xhci_controller.ConfigManagerErrorCode -eq 22

        if ($is_disabled) {
            continue
        }

        $device_ID = $xhci_controller.DeviceID

        Write-Host "$($xhci_controller.Caption) - $($device_ID)"

        # skip if entry is null
        if (-not $device_map.Contains($device_ID)) {
            Write-Host "error: could not obtain base address`n"
            continue
        }

        $capability_address = $device_map[$device_ID]
        $HCSPARAMS_value = GetValueFromAddress($capability_address + $HCSPARAMS_OFFSET)
        $HCSPARAMS_bitmask = [Convert]::ToString($HCSPARAMS_value, 2)
        $max_intrs = [Convert]::ToInt32($HCSPARAMS_bitmask.Substring($HCSPARAMS_bitmask.Length - 16, 8), 2)
        $RTSOFF_value = GetValueFromAddress($capability_address + $RTSOFF)
        $runtime_address = $capability_address + $RTSOFF_value

        $desired_interval = $GLOBAL_INTERVAL

        foreach ($hwid in $INDIVIDUAL_INTERVALS.Keys) {
            if ($device_ID -match $hwid) {
                $desired_interval = $INDIVIDUAL_INTERVALS[$hwid]
            }
        }

        for ($i = 0; $i -lt $max_intrs; $i++) {
            # calculate address and convert address to hex string
            $interrupter_address = "0x$(([uint64]($runtime_address + 0x24 + (0x20 * $i))).ToString("X2"))"
            & $RWE_PATH /Min /NoLogo /Stdout /Command="W32 $($interrupter_address) $($desired_interval)" | Write-Host
        }

        # new line
        Write-Host
    }

    return 0
}

exit main
