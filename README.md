# DOPSM (DigitalOcean PowerShell Module)
A PowerShell module providing cmdlets that allow easy administration of droplets, images and snapshots via the DigitalOcean API.

## Setup
Import module file and use the "Set-Token" cmdlet to added your DigitalOcean API token, this is required.

    Import-Module ./DOPSM.psm1

    Set-Token -token <your api token here>

## Example Commands
#### Listing all available Droplet names and ids
	Get-Droplets | Select name,id | Format-Table
#### Rebooting a Droplet with name "web-server"
	$Droplet = Get-Droplet | Where {$_.name -like "web-server"}; Reboot-Droplet -id $Droplet.id
#### Listing all available regions
	Get-Regions
#### Creating a new droplet
	Create-Droplet -name "mydroplet" -region "lon1" -size "512mb" -image 3214324
#### List personal images/snapshots
	Get-Images -Private
#### List CentOS images
    Get-Images -Distributions | Where {$_.distribution -like "*cent*"}
#### List Wordpress application images
    Get-Images -Applications | Where {$_.name -like "*word*"}
