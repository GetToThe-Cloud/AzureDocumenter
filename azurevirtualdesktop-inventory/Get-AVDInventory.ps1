<#
.SYNOPSIS
    Azure Virtual Desktop Inventory Collection Module
.DESCRIPTION
    Collects comprehensive inventory data from Azure Virtual Desktop environments
#>

function Get-AVDInventoryData {
    [CmdletBinding()]
    param()
    
    Write-Host "    ○ Gathering subscriptions..." -ForegroundColor Gray
    
    $inventory = @{
        collectionTime = (Get-Date).ToString('o')
        subscriptions = @()
        summary = @{
            totalHostPools = 0
            totalSessionHosts = 0
            totalWorkspaces = 0
            totalApplicationGroups = 0
            totalScalingPlans = 0
            availableSessionHosts = 0
            unavailableSessionHosts = 0
            totalVNets = 0
            totalComputeGalleries = 0
            totalUserSessions = 0
            activeUserSessions = 0
            disconnectedUserSessions = 0
        }
        explanation = @{
            overview = "Azure Virtual Desktop (AVD) is a cloud-based desktop and application virtualization service. This inventory shows all AVD resources and their relationships."
            hostPools = "Host pools contain session hosts (VMs) that serve desktops and applications to users. They define the type (pooled/personal) and load balancing method."
            sessionHosts = "Session hosts are the VMs that run user sessions. They connect to virtual networks and can be managed by scaling plans."
            workspaces = "Workspaces are end-user facing resources that group application groups for a consistent user experience."
            applicationGroups = "Application groups define which applications or desktops users can access from a host pool."
            scalingPlans = "Scaling plans automate the start/stop of session hosts based on time schedules to optimize costs."
            virtualNetworks = "Virtual networks provide network connectivity for session hosts, enabling communication with other Azure services and on-premises resources."
            computeGalleries = "Compute galleries store and manage custom images used to deploy session hosts with pre-configured software."
            userSessions = "User sessions represent active and disconnected user connections to AVD session hosts. Active sessions are currently in use, while disconnected sessions are temporarily disconnected but still consuming resources."
        }
    }
    
    # Get all subscriptions
    $subscriptions = Get-AzSubscription | Where-Object { $_.State -eq 'Enabled' }
    
    foreach ($sub in $subscriptions) {
        Write-Host "    ○ Processing subscription: $($sub.Name)" -ForegroundColor Gray
        Set-AzContext -SubscriptionId $sub.Id | Out-Null
        
        $subData = @{
            id = $sub.Id
            name = $sub.Name
            tenantId = $sub.TenantId
            hostPools = @()
            workspaces = @()
            applicationGroups = @()
            scalingPlans = @()
            virtualNetworks = @()
            computeGalleries = @()
        }
        
        # Get Host Pools
        try {
            $hostPools = Get-AzWvdHostPool -ErrorAction SilentlyContinue
            foreach ($hp in $hostPools) {
                Write-Host "      • Host Pool: $($hp.Name)" -ForegroundColor DarkGray
                
                $hpData = @{
                    name = $hp.Name
                    resourceGroup = $hp.Id.Split('/')[4]
                    location = $hp.Location
                    hostPoolType = $hp.HostPoolType
                    loadBalancerType = $hp.LoadBalancerType
                    maxSessionLimit = $hp.MaxSessionLimit
                    preferredAppGroupType = $hp.PreferredAppGroupType
                    registrationToken = if ($hp.RegistrationInfo.ExpirationTime) {
                        @{
                            exists = $true
                            expiration = $hp.RegistrationInfo.ExpirationTime.ToString('o')
                            expired = $hp.RegistrationInfo.ExpirationTime -lt (Get-Date)
                        }
                    } else {
                        @{ exists = $false }
                    }
                    sessionHosts = @()
                    sessionHostCount = 0
                    availableHosts = 0
                    unavailableHosts = 0
                    totalUserSessions = 0
                    activeUserSessions = 0
                    disconnectedUserSessions = 0
                    scalingPlanReference = $null
                }
                
                # Get Session Hosts
                try {
                    $sessionHosts = Get-AzWvdSessionHost -HostPoolName $hp.Name -ResourceGroupName $hpData.resourceGroup -ErrorAction SilentlyContinue
                    $hpData.sessionHostCount = $sessionHosts.Count
                    
                    foreach ($sh in $sessionHosts) {
                        $shName = $sh.Name.Split('/')[1]
                        $sessions = Get-AzWvdUserSession -HostPoolName $hp.Name -ResourceGroupName $hpData.resourceGroup -SessionHostName $shName -ErrorAction SilentlyContinue
                        
                        # Count session states
                        $activeSessions = 0
                        $disconnectedSessions = 0
                        foreach ($session in $sessions) {
                            if ($session.SessionState -eq 'Active') {
                                $activeSessions++
                            } elseif ($session.SessionState -eq 'Disconnected') {
                                $disconnectedSessions++
                            }
                        }
                        
                        $hpData.totalUserSessions += $sessions.Count
                        $hpData.activeUserSessions += $activeSessions
                        $hpData.disconnectedUserSessions += $disconnectedSessions
                        
                        # Get VM network and image information
                        $vmName = $shName.Split('.')[0]
                        $networkInfo = $null
                        $imageInfo = $null
                        try {
                            $vm = Get-AzVM -Name $vmName -ResourceGroupName $hpData.resourceGroup -ErrorAction SilentlyContinue
                            if ($vm) {
                                # Network information
                                $nic = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id -ErrorAction SilentlyContinue
                                if ($nic) {
                                    $vnetId = $nic.IpConfigurations[0].Subnet.Id
                                    $vnetName = $vnetId.Split('/')[8]
                                    $subnetName = $vnetId.Split('/')[10]
                                    $networkInfo = @{
                                        vnetName = $vnetName
                                        subnetName = $subnetName
                                        privateIP = $nic.IpConfigurations[0].PrivateIpAddress
                                        vnetResourceGroup = $vnetId.Split('/')[4]
                                        vnetId = $vnetId
                                    }
                                }
                                
                                # Image information
                                if ($vm.StorageProfile.ImageReference.Id) {
                                    $imageId = $vm.StorageProfile.ImageReference.Id
                                    $imageInfo = @{
                                        type = 'Gallery'
                                        id = $imageId
                                        galleryName = $imageId.Split('/')[8]
                                        imageName = $imageId.Split('/')[10]
                                        version = $imageId.Split('/')[12]
                                    }
                                } elseif ($vm.StorageProfile.ImageReference.Offer) {
                                    $imageInfo = @{
                                        type = 'Marketplace'
                                        publisher = $vm.StorageProfile.ImageReference.Publisher
                                        offer = $vm.StorageProfile.ImageReference.Offer
                                        sku = $vm.StorageProfile.ImageReference.Sku
                                        version = $vm.StorageProfile.ImageReference.Version
                                    }
                                }
                            }
                        }
                        catch {
                            # Silently continue if VM info cannot be retrieved
                        }
                        
                        $shData = @{
                            name = $shName
                            status = $sh.Status
                            allowNewSession = $sh.AllowNewSession
                            sessions = $sessions.Count
                            activeSessions = $activeSessions
                            disconnectedSessions = $disconnectedSessions
                            assignedUser = $sh.AssignedUser
                            osVersion = $sh.OSVersion
                            agentVersion = $sh.AgentVersion
                            lastHeartBeat = if ($sh.LastHeartBeat) { $sh.LastHeartBeat.ToString('o') } else { $null }
                            updateState = $sh.UpdateState
                            network = $networkInfo
                            image = $imageInfo
                        }
                        
                        if ($sh.Status -eq 'Available') {
                            $hpData.availableHosts++
                        } else {
                            $hpData.unavailableHosts++
                        }
                        
                        $hpData.sessionHosts += $shData
                    }
                }
                catch {
                    Write-Host "      ⚠ Could not retrieve session hosts: $($_.Exception.Message)" -ForegroundColor Yellow
                }
                
                $inventory.summary.totalSessionHosts += $hpData.sessionHostCount
                $inventory.summary.availableSessionHosts += $hpData.availableHosts
                $inventory.summary.unavailableSessionHosts += $hpData.unavailableHosts
                $inventory.summary.totalUserSessions += $hpData.totalUserSessions
                $inventory.summary.activeUserSessions += $hpData.activeUserSessions
                $inventory.summary.disconnectedUserSessions += $hpData.disconnectedUserSessions
                
                $subData.hostPools += $hpData
            }
            
            $inventory.summary.totalHostPools += $hostPools.Count
        }
        catch {
            Write-Host "    ⚠ Could not retrieve host pools: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Get Workspaces
        try {
            $workspaces = Get-AzWvdWorkspace -ErrorAction SilentlyContinue
            foreach ($ws in $workspaces) {
                $wsData = @{
                    name = $ws.Name
                    resourceGroup = $ws.Id.Split('/')[4]
                    location = $ws.Location
                    friendlyName = $ws.FriendlyName
                    description = $ws.Description
                    applicationGroupReferences = $ws.ApplicationGroupReference
                }
                $subData.workspaces += $wsData
            }
            $inventory.summary.totalWorkspaces += $workspaces.Count
        }
        catch {
            Write-Host "    ⚠ Could not retrieve workspaces: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Get Application Groups
        try {
            $appGroups = Get-AzWvdApplicationGroup -ErrorAction SilentlyContinue
            foreach ($ag in $appGroups) {
                $agData = @{
                    name = $ag.Name
                    resourceGroup = $ag.Id.Split('/')[4]
                    location = $ag.Location
                    friendlyName = $ag.FriendlyName
                    applicationGroupType = $ag.ApplicationGroupType
                    hostPoolArmPath = $ag.HostPoolArmPath
                    workspaceArmPath = $ag.WorkspaceArmPath
                    applications = @()
                }
                
                # Get Applications in the group
                if ($ag.ApplicationGroupType -eq 'RemoteApp') {
                    try {
                        $apps = Get-AzWvdApplication -GroupName $ag.Name -ResourceGroupName $agData.resourceGroup -ErrorAction SilentlyContinue
                        foreach ($app in $apps) {
                            $agData.applications += @{
                                name = $app.Name
                                friendlyName = $app.FriendlyName
                                filePath = $app.FilePath
                                commandLineSetting = $app.CommandLineSetting
                                showInPortal = $app.ShowInPortal
                            }
                        }
                    }
                    catch {
                        # Silently continue if apps cannot be retrieved
                    }
                }
                
                $subData.applicationGroups += $agData
            }
            $inventory.summary.totalApplicationGroups += $appGroups.Count
        }
        catch {
            Write-Host "    ⚠ Could not retrieve application groups: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Get Scaling Plans
        try {
            $scalingPlans = Get-AzWvdScalingPlan -ErrorAction SilentlyContinue
            foreach ($sp in $scalingPlans) {
                $spData = @{
                    name = $sp.Name
                    resourceGroup = $sp.Id.Split('/')[4]
                    location = $sp.Location
                    friendlyName = $sp.FriendlyName
                    description = $sp.Description
                    timeZone = $sp.TimeZone
                    hostPoolType = $sp.HostPoolType
                    exclusionTag = $sp.ExclusionTag
                    schedules = @()
                    hostPoolReferences = @()
                }
                
                # Get schedules with proper time conversion
                if ($sp.Schedule) {
                    foreach ($schedule in $sp.Schedule) {
                        $spData.schedules += @{
                            name = $schedule.Name
                            daysOfWeek = if ($schedule.DaysOfWeek) { $schedule.DaysOfWeek -join ', ' } else { 'N/A' }
                            rampUpStartTime = if ($schedule.RampUpStartTime) { $schedule.RampUpStartTime.Hour.ToString('00') + ':' + $schedule.RampUpStartTime.Minute.ToString('00') } else { 'N/A' }
                            rampUpLoadBalancingAlgorithm = $schedule.RampUpLoadBalancingAlgorithm
                            rampUpMinimumHostsPct = $schedule.RampUpMinimumHostsPct
                            rampUpCapacityThresholdPct = $schedule.RampUpCapacityThresholdPct
                            peakStartTime = if ($schedule.PeakStartTime) { $schedule.PeakStartTime.Hour.ToString('00') + ':' + $schedule.PeakStartTime.Minute.ToString('00') } else { 'N/A' }
                            peakLoadBalancingAlgorithm = $schedule.PeakLoadBalancingAlgorithm
                            rampDownStartTime = if ($schedule.RampDownStartTime) { $schedule.RampDownStartTime.Hour.ToString('00') + ':' + $schedule.RampDownStartTime.Minute.ToString('00') } else { 'N/A' }
                            rampDownLoadBalancingAlgorithm = $schedule.RampDownLoadBalancingAlgorithm
                            rampDownMinimumHostsPct = $schedule.RampDownMinimumHostsPct
                            rampDownCapacityThresholdPct = $schedule.RampDownCapacityThresholdPct
                            rampDownForceLogoffUser = $schedule.RampDownForceLogoffUser
                            rampDownWaitTimeMinute = $schedule.RampDownWaitTimeMinute
                            rampDownNotificationMessage = $schedule.RampDownNotificationMessage
                            offPeakStartTime = if ($schedule.OffPeakStartTime) { $schedule.OffPeakStartTime.Hour.ToString('00') + ':' + $schedule.OffPeakStartTime.Minute.ToString('00') } else { 'N/A' }
                            offPeakLoadBalancingAlgorithm = $schedule.OffPeakLoadBalancingAlgorithm
                        }
                    }
                }
                
                # Get host pool references
                if ($sp.HostPoolReference) {
                    foreach ($hpRef in $sp.HostPoolReference) {
                        $spData.hostPoolReferences += @{
                            hostPoolArmPath = $hpRef.HostPoolArmPath
                            scalingPlanEnabled = $hpRef.ScalingPlanEnabled
                        }
                        
                        # Update host pool with scaling plan reference
                        foreach ($hp in $subData.hostPools) {
                            if ($hpRef.HostPoolArmPath -like "*/$($hp.name)") {
                                $hp.scalingPlanReference = $sp.Name
                            }
                        }
                    }
                }
                
                $subData.scalingPlans += $spData
            }
            $inventory.summary.totalScalingPlans += $scalingPlans.Count
        }
        catch {
            Write-Host "    ⚠ Could not retrieve scaling plans: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Get Virtual Networks used by AVD
        try {
            # Track unique VNets
            $avdVNetIds = @{}
            
            # Collect VNet IDs from session hosts
            foreach ($hp in $subData.hostPools) {
                foreach ($sh in $hp.sessionHosts) {
                    if ($sh.network -and $sh.network.vnetId) {
                        $avdVNetIds[$sh.network.vnetId] = @{
                            name = $sh.network.vnetName
                            resourceGroup = $sh.network.vnetResourceGroup
                        }
                    }
                }
            }
            
            # Get details for each unique VNet
            foreach ($vnetId in $avdVNetIds.Keys) {
                $vnetInfo = $avdVNetIds[$vnetId]
                try {
                    $vnet = Get-AzVirtualNetwork -Name $vnetInfo.name -ResourceGroupName $vnetInfo.resourceGroup -ErrorAction SilentlyContinue
                    
                    if ($vnet) {
                        # Count connected session hosts
                        $connectedHosts = 0
                        foreach ($hp in $subData.hostPools) {
                            foreach ($sh in $hp.sessionHosts) {
                                if ($sh.network -and $sh.network.vnetId -eq $vnetId) {
                                    $connectedHosts++
                                }
                            }
                        }
                        
                        $vnetData = @{
                            name = $vnet.Name
                            resourceGroup = $vnet.ResourceGroupName
                            location = $vnet.Location
                            addressSpace = $vnet.AddressSpace.AddressPrefixes -join ', '
                            subnets = @()
                            dnsServers = if ($vnet.DhcpOptions.DnsServers) { $vnet.DhcpOptions.DnsServers -join ', ' } else { 'Azure-provided' }
                            connectedSessionHosts = $connectedHosts
                            peerings = @()
                        }
                        
                        # Get subnet details
                        foreach ($subnet in $vnet.Subnets) {
                            $subnetHostCount = 0
                            foreach ($hp in $subData.hostPools) {
                                foreach ($sh in $hp.sessionHosts) {
                                    if ($sh.network -and $sh.network.vnetName -eq $vnet.Name -and $sh.network.subnetName -eq $subnet.Name) {
                                        $subnetHostCount++
                                    }
                                }
                            }
                            
                            $vnetData.subnets += @{
                                name = $subnet.Name
                                addressPrefix = $subnet.AddressPrefix
                                connectedSessionHosts = $subnetHostCount
                            }
                        }
                        
                        # Get VNet peerings
                        if ($vnet.VirtualNetworkPeerings) {
                            foreach ($peering in $vnet.VirtualNetworkPeerings) {
                                $vnetData.peerings += @{
                                    name = $peering.Name
                                    remoteVirtualNetwork = $peering.RemoteVirtualNetwork.Id.Split('/')[8]
                                    peeringState = $peering.PeeringState
                                    allowForwardedTraffic = $peering.AllowForwardedTraffic
                                    allowGatewayTransit = $peering.AllowGatewayTransit
                                }
                            }
                        }
                        
                        $subData.virtualNetworks += $vnetData
                    }
                }
                catch {
                    Write-Host "      ⚠ Could not retrieve VNet details: $($_.Exception.Message)" -ForegroundColor Yellow
                }
            }
            $inventory.summary.totalVNets += $subData.virtualNetworks.Count
        }
        catch {
            Write-Host "    ⚠ Could not retrieve virtual networks: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Get Compute Galleries
        try {
            $galleries = Get-AzGallery -ErrorAction SilentlyContinue
            foreach ($gallery in $galleries) {
                Write-Host "      • Compute Gallery: $($gallery.Name)" -ForegroundColor DarkGray
                
                $galleryData = @{
                    name = $gallery.Name
                    resourceGroup = $gallery.ResourceGroupName
                    location = $gallery.Location
                    description = $gallery.Description
                    images = @()
                }
                
                # Get images in the gallery
                try {
                    $images = Get-AzGalleryImageDefinition -ResourceGroupName $gallery.ResourceGroupName -GalleryName $gallery.Name -ErrorAction SilentlyContinue
                    foreach ($image in $images) {
                        $imageData = @{
                            name = $image.Name
                            osType = $image.OsType
                            osState = $image.OsState
                            publisher = $image.Identifier.Publisher
                            offer = $image.Identifier.Offer
                            sku = $image.Identifier.Sku
                            versions = @()
                            usedBySessionHosts = 0
                        }
                        
                        # Get image versions
                        try {
                            $versions = Get-AzGalleryImageVersion -ResourceGroupName $gallery.ResourceGroupName -GalleryName $gallery.Name -GalleryImageDefinitionName $image.Name -ErrorAction SilentlyContinue
                            foreach ($version in $versions) {
                                $imageData.versions += @{
                                    name = $version.Name
                                    publishingDate = if ($version.PublishingProfile.PublishedDate) { $version.PublishingProfile.PublishedDate.ToString('o') } else { 'N/A' }
                                    replicaCount = $version.PublishingProfile.ReplicaCount
                                }
                            }
                        }
                        catch {
                            # Silently continue if versions cannot be retrieved
                        }
                        
                        # Count how many session hosts use this image
                        foreach ($hp in $subData.hostPools) {
                            foreach ($sh in $hp.sessionHosts) {
                                if ($sh.image -and $sh.image.type -eq 'Gallery' -and $sh.image.imageName -eq $image.Name) {
                                    $imageData.usedBySessionHosts++
                                }
                            }
                        }
                        
                        $galleryData.images += $imageData
                    }
                }
                catch {
                    Write-Host "      ⚠ Could not retrieve gallery images: $($_.Exception.Message)" -ForegroundColor Yellow
                }
                
                $subData.computeGalleries += $galleryData
            }
            $inventory.summary.totalComputeGalleries += $galleries.Count
        }
        catch {
            Write-Host "    ⚠ Could not retrieve compute galleries: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        $inventory.subscriptions += $subData
    }
    
    Write-Host "    ✓ Inventory collection complete" -ForegroundColor Green
    return $inventory
}

function Get-AVDConnectionDiagram {
    [CmdletBinding()]
    param()
    
    Write-Host "    ○ Generating connection diagram..." -ForegroundColor Gray
    
    $diagram = @{
        nodes = @()
        edges = @()
    }
    
    $subscriptions = Get-AzSubscription | Where-Object { $_.State -eq 'Enabled' }
    
    foreach ($sub in $subscriptions) {
        Set-AzContext -SubscriptionId $sub.Id | Out-Null
        
        # Add subscription node
        $diagram.nodes += @{
            id = "sub-$($sub.Id)"
            label = $sub.Name
            type = "subscription"
            group = 1
        }
        
        # Get Host Pools
        $hostPools = Get-AzWvdHostPool -ErrorAction SilentlyContinue
        foreach ($hp in $hostPools) {
            $hpId = "hp-$($hp.Id)"
            $diagram.nodes += @{
                id = $hpId
                label = $hp.Name
                type = "hostpool"
                group = 2
                details = @{
                    type = $hp.HostPoolType
                    loadBalancer = $hp.LoadBalancerType
                }
            }
            
            $diagram.edges += @{
                from = "sub-$($sub.Id)"
                to = $hpId
                label = "contains"
            }
            
            # Get Session Hosts
            $rgName = $hp.Id.Split('/')[4]
            $sessionHosts = Get-AzWvdSessionHost -HostPoolName $hp.Name -ResourceGroupName $rgName -ErrorAction SilentlyContinue
            
            foreach ($sh in $sessionHosts) {
                $shId = "sh-$($sh.Id)"
                $shName = $sh.Name.Split('/')[1]
                $diagram.nodes += @{
                    id = $shId
                    label = $shName
                    type = "sessionhost"
                    group = 3
                    details = @{
                        status = $sh.Status
                        sessions = 0
                    }
                }
                
                $diagram.edges += @{
                    from = $hpId
                    to = $shId
                    label = "manages"
                }
                
                # Get VM network information for VNet connection
                try {
                    $vmName = $shName.Split('.')[0]
                    $vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName -ErrorAction SilentlyContinue
                    if ($vm) {
                        $nic = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id -ErrorAction SilentlyContinue
                        if ($nic) {
                            $vnetId = $nic.IpConfigurations[0].Subnet.Id
                            $vnetName = $vnetId.Split('/')[8]
                            
                            # Add edge to VNet
                            $vnetNodeId = "vnet-$vnetId"
                            $diagram.edges += @{
                                from = $shId
                                to = $vnetNodeId
                                label = "connected to"
                            }
                        }
                    }
                }
                catch {
                    # Silently continue if network info cannot be retrieved
                }
            }
        }
        
        # Get Workspaces
        $workspaces = Get-AzWvdWorkspace -ErrorAction SilentlyContinue
        foreach ($ws in $workspaces) {
            $wsId = "ws-$($ws.Id)"
            $diagram.nodes += @{
                id = $wsId
                label = $ws.Name
                type = "workspace"
                group = 4
            }
            
            $diagram.edges += @{
                from = "sub-$($sub.Id)"
                to = $wsId
                label = "contains"
            }
        }
        
        # Get Application Groups
        $appGroups = Get-AzWvdApplicationGroup -ErrorAction SilentlyContinue
        foreach ($ag in $appGroups) {
            $agId = "ag-$($ag.Id)"
            $diagram.nodes += @{
                id = $agId
                label = $ag.Name
                type = "applicationgroup"
                group = 5
                details = @{
                    type = $ag.ApplicationGroupType
                }
            }
            
            # Link to host pool
            if ($ag.HostPoolArmPath) {
                $hpConnectId = "hp-$($ag.HostPoolArmPath)"
                $diagram.edges += @{
                    from = $agId
                    to = $hpConnectId
                    label = "uses"
                }
            }
            
            # Link to workspace
            if ($ag.WorkspaceArmPath) {
                $wsConnectId = "ws-$($ag.WorkspaceArmPath)"
                $diagram.edges += @{
                    from = $wsConnectId
                    to = $agId
                    label = "publishes"
                }
            }
        }
        
        # Get Scaling Plans
        $scalingPlans = Get-AzWvdScalingPlan -ErrorAction SilentlyContinue
        foreach ($sp in $scalingPlans) {
            $spId = "sp-$($sp.Id)"
            $diagram.nodes += @{
                id = $spId
                label = $sp.Name
                type = "scalingplan"
                group = 6
                details = @{
                    hostPoolType = $sp.HostPoolType
                    timeZone = $sp.TimeZone
                }
            }
            
            $diagram.edges += @{
                from = "sub-$($sub.Id)"
                to = $spId
                label = "contains"
            }
            
            # Link to host pools
            if ($sp.HostPoolReference) {
                foreach ($hpRef in $sp.HostPoolReference) {
                    $hpConnectId = "hp-$($hpRef.HostPoolArmPath)"
                    $diagram.edges += @{
                        from = $spId
                        to = $hpConnectId
                        label = "scales"
                    }
                }
            }
        }
        
        # Get Virtual Networks (only those used by AVD)
        $vnets = Get-AzVirtualNetwork -ErrorAction SilentlyContinue
        $addedVNets = @{}
        foreach ($vnet in $vnets) {
            $vnetId = $vnet.Id
            
            # Check if this VNet is already referenced in edges
            $isUsed = $diagram.edges | Where-Object { $_.to -eq "vnet-$vnetId" }
            
            if ($isUsed -and -not $addedVNets.ContainsKey($vnetId)) {
                $diagram.nodes += @{
                    id = "vnet-$vnetId"
                    label = $vnet.Name
                    type = "vnet"
                    group = 7
                    details = @{
                        addressSpace = $vnet.AddressSpace.AddressPrefixes -join ', '
                        location = $vnet.Location
                    }
                }
                
                $diagram.edges += @{
                    from = "sub-$($sub.Id)"
                    to = "vnet-$vnetId"
                    label = "contains"
                }
                
                $addedVNets[$vnetId] = $true
            }
        }
    }
    
    Write-Host "    ✓ Diagram generation complete" -ForegroundColor Green
    return $diagram
}
