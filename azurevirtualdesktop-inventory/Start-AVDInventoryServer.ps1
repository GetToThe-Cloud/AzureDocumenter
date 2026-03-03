#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Azure Virtual Desktop Inventory Web Server
.DESCRIPTION
    Starts a web server that provides a live view of Azure Virtual Desktop inventory
    with authentication, navigation, PDF export, and connection diagrams.
.PARAMETER Port
    Port number for the web server (default: 8080)
#>

param(
    [int]$Port = 8080
)

# Import required modules
$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Azure Virtual Desktop Inventory Server..." -ForegroundColor Cyan

# Check and import Azure modules
$requiredModules = @('Az.Accounts', 'Az.DesktopVirtualization', 'Az.Resources', 'Az.Network', 'Az.Compute')
foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "⚠️  Module $module not found. Installing..." -ForegroundColor Yellow
        Install-Module -Name $module -Force -Scope CurrentUser -AllowClobber
    }
    Import-Module $module -ErrorAction SilentlyContinue
}

# Import inventory collection module
$inventoryModulePath = Join-Path $PSScriptRoot "Get-AVDInventory.ps1"
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
Write-Host "📊 Access the AVD Inventory Dashboard in your browser" -ForegroundColor Cyan
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
                    $content = "<html><body><h1>AVD Inventory Server</h1><p>index.html not found</p></body></html>"
                }
            }
            
            '^/test\.html$' {
                # Serve test page
                $testPath = Join-Path $PSScriptRoot "test.html"
                if (Test-Path $testPath) {
                    $content = Get-Content $testPath -Raw
                } else {
                    $content = "<html><body><h1>Test Page Not Found</h1></body></html>"
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
            
            '^/favicon\.ico$' {
                # Return empty response for favicon to prevent 404 errors
                $response.StatusCode = 204
                $content = ""
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
                        Write-Host "  📊 Collecting AVD inventory..." -ForegroundColor Cyan
                        Write-Host "  ⏱️  Start time: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
                        
                        $script:InventoryData = Get-AVDInventoryData
                        
                        Write-Host "  ✅ Inventory collection complete" -ForegroundColor Green
                        Write-Host "  ⏱️  End time: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
                        
                        $script:LastUpdate = Get-Date
                        
                        Write-Host "  📦 Converting to JSON..." -ForegroundColor Gray
                        $content = $script:InventoryData | ConvertTo-Json -Depth 20 -Compress:$false
                        Write-Host "  ✅ JSON conversion complete ($(($content.Length / 1KB).ToString('N2')) KB)" -ForegroundColor Green
                    } catch {
                        Write-Host "  ❌ Error collecting inventory: $($_.Exception.Message)" -ForegroundColor Red
                        Write-Host "  📍 Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
                        $content = @{ error = $_.Exception.Message; details = $_.ScriptStackTrace } | ConvertTo-Json
                    }
                } else {
                    Write-Host "  ⚠️  Request rejected - not authenticated" -ForegroundColor Yellow
                    $response.StatusCode = 401
                    $content = @{ error = "Not authenticated" } | ConvertTo-Json
                }
                $contentType = "application/json"
            }
            
            '^/api/inventory/refresh$' {
                if ($script:IsAuthenticated) {
                    try {
                        Write-Host "  🔄 Refreshing AVD inventory..." -ForegroundColor Cyan
                        Write-Host "  ⏱️  Start time: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
                        
                        $script:InventoryData = Get-AVDInventoryData
                        
                        Write-Host "  ✅ Inventory refresh complete" -ForegroundColor Green
                        Write-Host "  ⏱️  End time: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
                        
                        $script:LastUpdate = Get-Date
                        $content = @{ success = $true; lastUpdate = $script:LastUpdate.ToString('o') } | ConvertTo-Json
                    } catch {
                        Write-Host "  ❌ Error refreshing inventory: $($_.Exception.Message)" -ForegroundColor Red
                        Write-Host "  📍 Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
                        $content = @{ success = $false; error = $_.Exception.Message; details = $_.ScriptStackTrace } | ConvertTo-Json
                    }
                } else {
                    Write-Host "  ⚠️  Request rejected - not authenticated" -ForegroundColor Yellow
                    $response.StatusCode = 401
                    $content = @{ error = "Not authenticated" } | ConvertTo-Json
                }
                $contentType = "application/json"
            }
            
            '^/api/diagram/connections$' {
                if ($script:IsAuthenticated) {
                    try {
                        $diagramData = Get-AVDConnectionDiagram
                        $content = $diagramData | ConvertTo-Json -Depth 10
                    } catch {
                        $content = @{ error = $_.Exception.Message } | ConvertTo-Json
                    }
                } else {
                    $response.StatusCode = 401
                    $content = @{ error = "Not authenticated" } | ConvertTo-Json
                }
                $contentType = "application/json"
            }
            
            default {
                $response.StatusCode = 404
                $content = "<html><body><h1>404 Not Found</h1></body></html>"
            }
        }
        
        # Send response
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentLength64 = $buffer.Length
        $response.ContentType = $contentType
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.OutputStream.Close()
    }
}
finally {
    $listener.Stop()
    Write-Host "`n🛑 Server stopped" -ForegroundColor Yellow
}
