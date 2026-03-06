#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Azure Landing Zone Inventory Web Server
.DESCRIPTION
    Starts a web server that provides a live view of Azure Landing Zone inventory
    with authentication, navigation, and PDF export capabilities.
.PARAMETER Port
    Port number for the web server (default: 8080)
.NOTES
    Requires PowerShell 7.0 or higher
#>

param(
    [int]$Port = 8080
)

# Import required modules
$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Azure Landing Zone Inventory Server..." -ForegroundColor Cyan

# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "❌ ERROR: PowerShell 7 or higher is required." -ForegroundColor Red
    Write-Host "   Current version: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
    Write-Host "   Download PowerShell 7+: https://aka.ms/powershell" -ForegroundColor Cyan
    exit 1
}

Write-Host "✓ PowerShell version: $($PSVersionTable.PSVersion)" -ForegroundColor Green

# Check and import Azure modules
$requiredModules = @(
    'Az.Accounts', 
    'Az.Resources', 
    'Az.Network', 
    'Az.PolicyInsights'
)

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "⚠️  Module $module not found. Installing..." -ForegroundColor Yellow
        Install-Module -Name $module -Force -Scope CurrentUser -AllowClobber
    }
    Import-Module $module -ErrorAction SilentlyContinue
}

# Import inventory collection module
$inventoryModulePath = Join-Path $PSScriptRoot "Get-AzureLandingZoneInventory.ps1"
. $inventoryModulePath

# Check Azure connection
function Test-AzureConnection {
    try {
        $context = Get-AzContext
        if ($null -eq $context) {
            return $false
        }
        return $true
    }
    catch {
        return $false
    }
}

# Global state
$script:IsAuthenticated = Test-AzureConnection
$script:InventoryData = @{}
$script:LastUpdate = $null

Write-Host "🔐 Azure Authentication Status: $(if ($script:IsAuthenticated) { 'Connected ✓' } else { 'Not Connected ✗' })" -ForegroundColor $(if ($script:IsAuthenticated) { 'Green' } else { 'Yellow' })

# HTTP Listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()

Write-Host "🌐 Server started at http://localhost:$Port" -ForegroundColor Green
Write-Host "📊 Access the Azure Landing Zone Inventory Dashboard in your browser" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $path = $request.Url.AbsolutePath
        $method = $request.HttpMethod
        
        Write-Host "$(Get-Date -Format 'HH:mm:ss') $method $path" -ForegroundColor Gray
        
        # Content type and response
        $content = ""
        $contentType = "text/html; charset=utf-8"
        
        # Route handling
        switch -Regex ($path) {
            '^/$' {
                # Serve main page
                $indexPath = Join-Path $PSScriptRoot "index.html"
                if (Test-Path $indexPath) {
                    $content = Get-Content $indexPath -Raw
                } else {
                    $content = "<html><body><h1>Azure Landing Zone Inventory Server</h1><p>index.html not found</p></body></html>"
                }
            }
            
            '^/styles\.css$' {
                $cssPath = Join-Path $PSScriptRoot "styles.css"
                if (Test-Path $cssPath) {
                    $content = Get-Content $cssPath -Raw
                    $contentType = "text/css"
                }
            }
            
            '^/app\.js$' {
                $jsPath = Join-Path $PSScriptRoot "app.js"
                if (Test-Path $jsPath) {
                    $content = Get-Content $jsPath -Raw
                    $contentType = "application/javascript"
                }
            }
            
            '^/api/auth/status$' {
                $script:IsAuthenticated = Test-AzureConnection
                $authStatus = @{
                    authenticated = $script:IsAuthenticated
                    context = if ($script:IsAuthenticated) {
                        $ctx = Get-AzContext
                        @{
                            account = $ctx.Account.Id
                            subscription = $ctx.Subscription.Name
                            tenant = $ctx.Tenant.Id
                        }
                    } else { $null }
                }
                $content = $authStatus | ConvertTo-Json
                $contentType = "application/json"
            }
            
            '^/api/auth/login$' {
                try {
                    Connect-AzAccount -UseDeviceAuthentication | Out-Null
                    $script:IsAuthenticated = $true
                    $content = @{ success = $true; message = "Authentication successful" } | ConvertTo-Json
                } catch {
                    $content = @{ success = $false; message = $_.Exception.Message } | ConvertTo-Json
                }
                $contentType = "application/json"
            }
            
            '^/api/inventory/data$' {
                if ($script:IsAuthenticated) {
                    try {
                        Write-Host "  📊 Collecting Azure Landing Zone inventory..." -ForegroundColor Cyan
                        $script:InventoryData = Get-AzureLandingZoneInventory
                        $script:LastUpdate = Get-Date
                        $content = $script:InventoryData | ConvertTo-Json -Depth 10
                    } catch {
                        $content = @{ error = $_.Exception.Message } | ConvertTo-Json
                    }
                } else {
                    $response.StatusCode = 401
                    $content = @{ error = "Not authenticated" } | ConvertTo-Json
                }
                $contentType = "application/json"
            }
            
            '^/api/inventory/refresh$' {
                if ($script:IsAuthenticated) {
                    try {
                        Write-Host "  🔄 Refreshing inventory..." -ForegroundColor Cyan
                        $script:InventoryData = Get-AzureLandingZoneInventory
                        $script:LastUpdate = Get-Date
                        $content = @{ 
                            success = $true
                            lastUpdate = $script:LastUpdate.ToString('o')
                        } | ConvertTo-Json
                    } catch {
                        $content = @{ success = $false; error = $_.Exception.Message } | ConvertTo-Json
                    }
                } else {
                    $response.StatusCode = 401
                    $content = @{ success = $false; error = "Not authenticated" } | ConvertTo-Json
                }
                $contentType = "application/json"
            }
            
            default {
                $response.StatusCode = 404
                $content = "<html><body><h1>404 - Not Found</h1></body></html>"
            }
        }
        
        # Send response
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentLength64 = $buffer.Length
        $response.ContentType = $contentType
        $response.Headers.Add("Access-Control-Allow-Origin", "*")
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()
    }
}
finally {
    Write-Host "`n🛑 Stopping server..." -ForegroundColor Yellow
    $listener.Stop()
    $listener.Close()
    Write-Host "✓ Server stopped" -ForegroundColor Green
}
