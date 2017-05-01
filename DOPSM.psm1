<#
###################################################
  _____  _       _ _        _                      
 |  __ \(_)     (_) |      | |                     
 | |  | |_  __ _ _| |_ __ _| |                     
 | |  | | |/ _` | | __/ _` | |                     
 | |__| | | (_| | | || (_| | |                     
 |_____/|_|\__, |_|\__\__,_|_|                     
  / __ \    __/ |                                  
 | |  | | _|___/_  __ _ _ __                       
 | |  | |/ __/ _ \/ _` | '_ \                      
 | |__| | (_|  __/ (_| | | | |                     
  \____/ \___\___|\__,_|_| |_|_____ _          _ _ 
 |  __ \                     / ____| |        | | |
 | |__) |____      _____ _ _| (___ | |__   ___| | |
 |  ___/ _ \ \ /\ / / _ \ '__\___ \| '_ \ / _ \ | |
 | |  | (_) \ V  V /  __/ |  ____) | | | |  __/ | |
 |_|  _\___/ \_/\_/_\___|_|_|_____/|_| |_|\___|_|_|
 |  \/  |         | |     | |                      
 | \  / | ___   __| |_   _| | ___                  
 | |\/| |/ _ \ / _` | | | | |/ _ \                 
 | |  | | (_) | (_| | |_| | |  __/                 
 |_|  |_|\___/ \__,_|\__,_|_|\___|                 
                                                               
       
       Github:     91jme/DOPS
       Version:    0.1        

###################################################                     
#>

Function Set-RequestHeaders{
    $global:headers = @{}
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Bearer $token")
    $global:rooturi = "https://api.digitalocean.com/v2/"
}

<#
#########################################
  _____                  _      _       
 |  __ \                | |    | |      
 | |  | |_ __ ___  _ __ | | ___| |_ ___ 
 | |  | | '__/ _ \| '_ \| |/ _ \ __/ __|
 | |__| | | | (_) | |_) | |  __/ |_\__ \
 |_____/|_|  \___/| .__/|_|\___|\__|___/
                  | |                   
                  |_|                   
#########################################
#>

Function Get-Droplet{
    param([Parameter(Mandatory)][string]$id)
        $uri = $rooturi + 'droplets/' + $id
        $response = Invoke-WebRequest -Uri $uri -Method GET -Headers $headers
        $data = ConvertFrom-Json -InputObject $response
        return $data.droplet
    }

Function Get-Droplets{
        $uri = $rooturi + 'droplets/'
        $response = Invoke-WebRequest -Uri $uri -Method GET -Headers $headers
        $data = ConvertFrom-Json -InputObject $response
        return $data.droplets
}

Function Start-DropletAction{
    param([Parameter(Mandatory)][string]$id,
           [Parameter(Mandatory)][string]$action,
           [string]$image,
           [boolean]$resizedisks,
           [string]$size)
    $uri = $rooturi + 'droplets/' + $id + '/actions'
    $body = @{"type"="$action"}
    if($image){
        $body += ("image",$image)
    }
    $body = ConvertTo-Json -InputObject $body
    $response = Invoke-WebRequest -Uri $uri -Method POST -Headers $headers -Body $body
    $data = ConvertFrom-Json -InputObject $response.Content
    if($data.action.status -eq "errored"){
        return "Error performing action $action on Droplet $id"
    }
    while(($result = Get-Action -id $id -action $data.action.id).status -ne 'completed'){
        Write-Host "Action status: " $result.status
        Write-Host "Waiting for $action to complete... checking again in 5 seconds"
        Start-Sleep -Seconds 5
    }
    Write-Host "Action status: " $result.status
}

Function Reboot-Droplet{
    param([Parameter(Mandatory)][string]$id)
           Start-DropletAction -id $id -action "reboot"

}

Function Restore-Droplet{
    param([Parameter(Mandatory)][string]$id,
            [Parameter(Mandatory)][string]$image)
           Start-DropletAction -id $id -action "restore" -image $image

}

Function Test-Function{
        param([string]$size = $(Get-Sizes))

}


Function Resize-Droplet{
    param([Parameter(Mandatory)][string]$id,
            [switch]$resizedisk = $false,
            [Parameter(Mandatory)][switch]$size)
           Start-DropletAction -id $id -action "resize" -resizedisks $resizedisk -size $size

}

Function Shutdown-Droplet{
    param([Parameter(Mandatory)][string]$id,
           [Parameter(Mandatory)][string]$action)
           Start-DropletAction -id $id -action "shutdown"

}

Function PowerOff-Droplet{
    param([Parameter(Mandatory)][string]$id)
           Start-DropletAction -id $id -action "power_off"

}


Function PasswordReset-Droplet{
    param([Parameter(Mandatory)][string]$id)
           Start-DropletAction -id $id -action "password_reset"

}

Function PowerOn-Droplet{
    param([Parameter(Mandatory)][string]$id)
           Start-DropletAction -id $id -action "power_on"

}

Function PowerCycle-Droplet{
    param([Parameter(Mandatory)][string]$id)
           Start-DropletAction -id $id -action "power_cycle"

}

Function Enable-DropletBackups{
    param([Parameter(Mandatory)][string]$id)
           Start-DropletAction -id $id -action "enable_backups"

}

Function Disable-DropletBackups{
    param([Parameter(Mandatory)][string]$id)
           Start-DropletAction -id $id -action "disable_backups"

}

Function Remove-Droplet{
    param([string] $id)
    $uri = $rooturi + 'droplets/' + $id
    $response = Invoke-WebRequest -Uri $uri -Method DELETE -Headers $headers
    if($response.StatusCode -eq "204"){
        return "Droplet removed"
    }else{
        return "Error removing Droplet, please try again."
    }
}

Function Create-Droplet{
    param([Parameter(Mandatory)][string] $name,
            [Parameter(Mandatory)][string] $image,
            [Parameter(Mandatory)][string] $region,
            [Parameter(Mandatory)][string] $size)
    $uri = $rooturi + 'droplets/'
    $body = @{}
    $body.Add("name", $name)
    $body.Add("region", $region)
    $body.Add("size", $size)
    $body.Add("image", $image)
    $body = ConvertTo-Json -InputObject $body
    $body
    $response = Invoke-WebRequest -Uri $uri -Method POST -Headers $headers -Body $body
    $data = ConvertFrom-Json -InputObject $response.Content
    if($data.droplet.id){
        Write-Host "Droplet created"
        Get-Droplet -id $data.droplet.id
    }else{
        Write-Host "Unable to create droplet, try again later?"
    }
}


<#
######################################
               _   _                 
     /\       | | (_)                
    /  \   ___| |_ _  ___  _ __  ___ 
   / /\ \ / __| __| |/ _ \| '_ \/ __|
  / ____ \ (__| |_| | (_) | | | \__ \
 /_/    \_\___|\__|_|\___/|_| |_|___/
                                     
                                     
######################################

#>

Function Set-Token{
    param([string]$token = $(Read-Host "Please enter your API token"))
    $global:token = $token
    Export-ModuleMember -Variable token
    Set-RequestHeaders
}

Function Get-Token{
    Write-Host $token
}

Function Get-Action{
    param([Parameter(Mandatory)][string]$id,
           [Parameter(Mandatory)][string]$action)
    $uri = $rooturi + 'droplets/' + $id + '/actions/' + $action
    $response = Invoke-WebRequest -Uri $uri -Method GET -Headers $headers
    $data = ConvertFrom-Json -InputObject $response.Content
    return $data.action
}

Function Get-Actions{
    param([Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]$id)
    $uri = $rooturi + 'droplets/' + $id + '/actions/'
    $response = Invoke-WebRequest -Uri $uri -Method GET -Headers $headers
    $data = ConvertFrom-Json -InputObject $response.Content
    return $data.actions
}


Function Get-Snapshots{
    $uri = $rooturi + 'snapshots/'
    $response = Invoke-WebRequest -Uri $uri -Method GET -Headers $headers
    $data = ConvertFrom-Json -InputObject $response.Content
    return $data.snapshots
}

Function Remove-Snapshot{
    param([Parameter(Mandatory)][string] $id)
    $uri = $rooturi + 'snapshots/' + $id
    $response = Invoke-WebRequest -Uri $uri -Method DELETE -Headers $headers
    if($response.StatusCode -eq "204"){
        return $true
    }else{
        return $false
    }
}

Function Get-Sizes{
    $uri = $rooturi + 'sizes/'
    $response = Invoke-WebRequest -Uri $uri -Method GET -Headers $headers
    $data = ConvertFrom-Json -InputObject $response
    return $data.sizes
}

Function Get-SSHKeys{
    $uri = $rooturi + 'account/keys/'
    $response = Invoke-WebRequest -Uri $uri -Method GET -Headers $headers
    $data = ConvertFrom-Json -InputObject $response
    return $data.ssh_keys
}

Function Get-Regions{
    $uri = $rooturi + 'regions/'
    $response = Invoke-WebRequest -Uri $uri -Method GET -Headers $headers
    $data = ConvertFrom-Json -InputObject $response
    return $data.regions

}

Function Get-Images{
    param([switch]$Applications,
            [switch]$Distributions,
            [switch]$Private)
    $uri = $rooturi + 'images/?page=1&per_page=100'
    if($Applications){
        $uri += '&type=application'
    }elseif($Distributions){
        $uri += '&type=distribution'
    }elseif($Private){
        $uri += '&private=true'
    }
    $response = Invoke-WebRequest -Uri $uri -Method GET -Headers $headers
    $data = ConvertFrom-Json -InputObject $response
    return $data.images
}

Function Remove-Image{
    param([string] $id)
    $uri = $rooturi + 'images/' + $id
    $response = Invoke-WebRequest -Uri $uri -Method DELETE -Headers $headers
    if($response.StatusCode -eq "204"){
        return $true
    }else{
        return $false
    }
}

Function Clean-Memory {
Get-Variable |
 Where-Object { $startupVariables -notcontains $_.Name } |
 ForEach-Object {
  try { Remove-Variable -Name "$($_.Name)" -Force -Scope "global" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue}
  catch { }
 }
}


Export-ModuleMember -Variable token -Function *