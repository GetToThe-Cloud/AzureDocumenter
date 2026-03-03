<#
.SYNOPSIS
    Azure Landing Zone Inventory Collection Module
.DESCRIPTION
    Collects comprehensive inventory data from Azure Landing Zone environments including
    management groups, policies, subscriptions, networking, and governance settings.
#>

function Get-AzureLandingZoneInventory {
    [CmdletBinding()]
    param()
    
    Write-Host "    ○ Gathering Azure Landing Zone inventory..." -ForegroundColor Gray
    
    $inventory = @{
        collectionTime = (Get-Date).ToString('o')
        tenantId = (Get-AzContext).Tenant.Id
        managementGroups = @()
        subscriptions = @()
        policies = @{
            definitions = @()
            initiatives = @()
            assignments = @()
        }
        roleAssignments = @()
        networking = @{
            vnets = @()
            peerings = @()
            vpnGateways = @()
            expressRoutes = @()
            firewalls = @()
            networkSecurityGroups = @()
            privateDnsZones = @()
            privateEndpoints = @()
        }
        compute = @{
            virtualMachines = @()
        }
        governance = @{
            budgets = @()
            tags = @()
            locks = @()
            diagnosticSettings = @()
        }
        summary = @{
            totalManagementGroups = 0
            totalSubscriptions = 0
            totalPolicyDefinitions = 0
            totalPolicyInitiatives = 0
            totalPolicyAssignments = 0
            totalRoleAssignments = 0
            totalVNets = 0
            totalPeerings = 0
            totalBudgets = 0
            totalLocks = 0
            totalVMs = 0
            totalPrivateDnsZones = 0
            totalPrivateEndpoints = 0
        }
        explanations = @{
            overview = @"
Azure Landing Zone is an enterprise-scale architecture pattern that provides a standardized foundation for cloud adoption. 
It implements governance, security, networking, and identity best practices aligned with the Cloud Adoption Framework (CAF).

Key Components:
• Management Groups: Hierarchical containers for organizing subscriptions
• Policies: Governance rules enforced across workloads
• Role Assignments: Identity and access management (IAM) controls
• Networking: Hub-spoke topology for secure, scalable connectivity
• Governance: Budgets, locks, tags, and diagnostic settings
"@
            managementGroups = @"
Management Groups provide a hierarchical structure for organizing subscriptions and applying governance controls at scale.

Structure:
• Root Management Group: Top-level container for the tenant
• Platform: Infrastructure services (identity, management, connectivity)
• Landing Zones: Application workloads (corp-connected, online)
• Sandboxes: Development and testing environments
• Decommissioned: Archived or sunset resources

Each management group can have policies, role assignments, and budgets applied that cascade to all child subscriptions.
"@
            policies = @"
Azure Policy helps enforce organizational standards and assess compliance at scale.

Types:
• Policy Definitions: Individual rules (e.g., "Require tag on resources")
• Policy Initiatives (Sets): Groups of related policies (e.g., "CIS Benchmark")
• Policy Assignments: Application of policies to specific scopes

Effects:
• Deny: Block non-compliant resource creation
• Audit: Log non-compliance without blocking
• DeployIfNotExists: Automatically remediate resources
• Modify: Change resource properties to comply
• Disabled: Policy exists but is not enforced

Policies enable automated compliance monitoring and enforcement across all workloads.
"@
            roleAssignments = @"
Role-Based Access Control (RBAC) manages who can access Azure resources and what they can do.

Key Concepts:
• Security Principal: User, group, service principal, or managed identity
• Role Definition: Collection of permissions (e.g., Owner, Contributor, Reader)
• Scope: Where the assignment applies (management group, subscription, resource group, resource)

Built-in Roles:
• Owner: Full access including the ability to assign roles
• Contributor: Full access except role assignment
• Reader: View-only access
• Custom Roles: Tailored permissions for specific scenarios

Best Practices:
• Use least-privilege principle
• Assign roles to groups, not individual users
• Regular access reviews and audits
• Use managed identities for service-to-service authentication
"@
            networking = @"
Azure Landing Zone networking follows a hub-spoke topology for secure, scalable connectivity.

Hub-Spoke Architecture:
• Hub VNet: Central connectivity point with shared services
  - VPN Gateway or ExpressRoute for on-premises connectivity
  - Azure Firewall for traffic inspection and filtering
  - DNS and other shared services
• Spoke VNets: Isolated workload networks
  - Application resources and services
  - Peered to hub for centralized connectivity
  - Network security groups for micro-segmentation

Connectivity Options:
• VNet Peering: High-speed Azure network connections
• VPN Gateway: Encrypted tunnels over internet
• ExpressRoute: Private dedicated connection to on-premises
• Azure Firewall: Network and application-level filtering
• Virtual WAN: Microsoft-managed hub for global connectivity

Security:
• Network Security Groups (NSGs): Subnet/NIC-level firewall rules
• Application Security Groups: Group VMs by application role
• Service Endpoints: Private connectivity to Azure services
• Private Link: Private IP access to PaaS services

Private Connectivity:
• Private DNS Zones: DNS resolution for private endpoints and custom domains
  - Integrated with VNets for automatic registration
  - Support for Azure service-specific zones (privatelink.*)
  - Centralized DNS management across landing zones
• Private Endpoints: Private IP addresses for Azure PaaS services
  - Eliminates exposure to public internet
  - Traffic stays on Microsoft backbone network
  - Integrates with Private DNS Zones for name resolution
  - Supports blob storage, SQL databases, Key Vault, and more
"@
            governance = @"
Governance ensures consistent management, security, and compliance across all Azure resources.

Budgets:
• Spending thresholds with alerting
• Forecast-based monitoring
• Action groups for automated responses

Resource Locks:
• ReadOnly: Prevents modifications
• CanNotDelete: Prevents deletion
• Applied at subscription, resource group, or resource scope
• Inherited by child resources

Tags:
• Key-value pairs for resource organization
• Enable cost tracking and allocation
• Support automation and lifecycle management
• Common tags: Environment, Owner, CostCenter, Application

Diagnostic Settings:
• Log and metric collection configuration
• Send to Log Analytics, Storage, or Event Hub
• Activity logs, resource logs, and metrics
• Enable monitoring, auditing, and troubleshooting

Blueprints (deprecated, use Template Specs):
• Declarative definition of environment
• Includes ARM templates, policies, role assignments
• Versioning and tracking of deployments
"@
            subscriptions = @"
Azure subscriptions are billing and management boundaries within the landing zone.

Placement Strategy:
• Platform Subscriptions:
  - Identity: AD DS, Azure AD Connect
  - Management: Monitoring, backup, governance tooling
  - Connectivity: Hub networking, VPN/ExpressRoute
• Landing Zone Subscriptions:
  - Corp-Connected: On-premises connectivity required
  - Online: Internet-facing workloads
  - Sandbox: Development and testing
• Decommissioned: Sunset applications

Subscription Limits:
• Resource quotas (VMs, storage, networking)
• API throttling limits
• Service-specific constraints

Move Strategy:
• Move between management groups for different governance
• Subscription transfer for billing ownership change
• Resource move for reorganization within/across subscriptions
"@
        }
    }
    
    try {
        # Get Management Groups
        Write-Host "    ○ Collecting Management Groups..." -ForegroundColor Gray
        try {
            $mgList = Get-AzManagementGroup -ErrorAction SilentlyContinue
            $inventory.summary.totalManagementGroups = $mgList.Count
            
            foreach ($mg in $mgList) {
                try {
                    $mgDetails = Get-AzManagementGroup -GroupId $mg.Name -Expand -Recurse -ErrorAction SilentlyContinue
                    $inventory.managementGroups += @{
                        id = $mg.Id
                        name = $mg.Name
                        displayName = $mg.DisplayName
                        tenantId = $mg.TenantId
                        type = $mg.Type
                        children = @($mgDetails.Children | ForEach-Object {
                            @{
                                id = $_.Id
                                name = $_.Name
                                displayName = $_.DisplayName
                                type = $_.Type
                            }
                        })
                        parentName = if ($mgDetails.ParentName) { $mgDetails.ParentName } else { "Root" }
                    }
                } catch {
                    Write-Host "      ⚠️  Could not get details for MG: $($mg.Name)" -ForegroundColor Yellow
                }
            }
        } catch {
            Write-Host "      ⚠️  Limited access to Management Groups" -ForegroundColor Yellow
        }
        
        # Get Subscriptions
        Write-Host "    ○ Collecting Subscriptions..." -ForegroundColor Gray
        $subs = Get-AzSubscription
        $inventory.summary.totalSubscriptions = $subs.Count
        
        foreach ($sub in $subs) {
            try {
                Set-AzContext -SubscriptionId $sub.Id | Out-Null
                
                $subDetails = @{
                    id = $sub.Id
                    name = $sub.Name
                    state = $sub.State
                    subscriptionId = $sub.SubscriptionId
                    tenantId = $sub.TenantId
                    tags = @{}
                }
                
                # Get subscription tags
                try {
                    $subResource = Get-AzSubscription -SubscriptionId $sub.Id
                    if ($subResource.Tags) {
                        $subDetails.tags = $subResource.Tags
                    }
                } catch {}
                
                $inventory.subscriptions += $subDetails
            } catch {
                Write-Host "      ⚠️  Could not access subscription: $($sub.Name)" -ForegroundColor Yellow
            }
        }
        
        # Get Policy Definitions
        Write-Host "    ○ Collecting Policy Definitions..." -ForegroundColor Gray
        try {
            # Collect both custom and a sample of built-in policies
            $customPolicyDefs = Get-AzPolicyDefinition -Custom -ErrorAction SilentlyContinue
            $builtInPolicyDefs = Get-AzPolicyDefinition -Builtin -ErrorAction SilentlyContinue | Select-Object -First 20
            $allPolicyDefs = @($customPolicyDefs) + @($builtInPolicyDefs)
            
            $inventory.summary.totalPolicyDefinitions = $customPolicyDefs.Count
            
            foreach ($policy in $allPolicyDefs) {
                # Try to get display name, falling back to name or a friendly message
                $displayName = if ($policy.Properties.DisplayName) { 
                    $policy.Properties.DisplayName 
                } elseif ($policy.DisplayName) { 
                    $policy.DisplayName 
                } elseif ($policy.Name) { 
                    $policy.Name 
                } else { 
                    'Unnamed Policy' 
                }
                
                # Try to get policy type from multiple locations
                $policyType = if ($policy.Properties.PolicyType) { 
                    $policy.Properties.PolicyType 
                } elseif ($policy.PolicyType) { 
                    $policy.PolicyType 
                } else { 
                    'Custom' 
                }
                
                $inventory.policies.definitions += @{
                    name = if ($policy.Name) { $policy.Name } else { 'Unknown' }
                    displayName = $displayName
                    description = if ($policy.Properties.Description) { $policy.Properties.Description } else { 'No description available' }
                    policyType = $policyType
                    mode = if ($policy.Properties.Mode) { $policy.Properties.Mode } else { 'All' }
                    metadata = $policy.Properties.Metadata
                }
            }
        } catch {
            Write-Host "      ⚠️  Error: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Get Policy Initiatives (SetDefinitions)
        Write-Host "    ○ Collecting Policy Initiatives..." -ForegroundColor Gray
        try {
            # Collect both custom and a sample of built-in initiatives
            $customInitiatives = Get-AzPolicySetDefinition -Custom -ErrorAction SilentlyContinue
            $builtInInitiatives = Get-AzPolicySetDefinition -Builtin -ErrorAction SilentlyContinue | Select-Object -First 20
            $allInitiatives = @($customInitiatives) + @($builtInInitiatives)
            
            $inventory.summary.totalPolicyInitiatives = $customInitiatives.Count
            
            foreach ($initiative in $allInitiatives) {
                # Try to get display name from multiple locations
                $displayName = if ($initiative.Properties.DisplayName) { 
                    $initiative.Properties.DisplayName 
                } elseif ($initiative.DisplayName) { 
                    $initiative.DisplayName
                } elseif ($initiative.Name) { 
                    $initiative.Name 
                } else { 
                    'Unnamed Initiative' 
                }
                
                # Try to get policy type from multiple possible locations
                $policyType = if ($initiative.Properties.PolicyType) { 
                    $initiative.Properties.PolicyType 
                } elseif ($initiative.PolicyType) { 
                    $initiative.PolicyType 
                } else { 
                    'BuiltIn' 
                }
                
                $inventory.policies.initiatives += @{
                    name = if ($initiative.Name) { $initiative.Name } else { 'Unknown' }
                    displayName = $displayName
                    description = if ($initiative.Properties.Description) { $initiative.Properties.Description } else { 'No description available' }
                    policyType = $policyType
                    metadata = $initiative.Properties.Metadata
                    policyDefinitions = @($initiative.Properties.PolicyDefinitions | ForEach-Object {
                        @{
                            policyDefinitionId = $_.policyDefinitionId
                            parameters = $_.parameters
                        }
                    })
                }
            }
        } catch {
            Write-Host "      ⚠️  Error: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Get Policy Assignments
        Write-Host "    ○ Collecting Policy Assignments..." -ForegroundColor Gray
        try {
            $assignments = Get-AzPolicyAssignment -ErrorAction SilentlyContinue | Select-Object -First 100
            $inventory.summary.totalPolicyAssignments = $assignments.Count
            
            foreach ($assignment in $assignments) {
                # Extract policy name from definition ID
                $policyName = 'Unknown'
                if ($assignment.Properties.PolicyDefinitionId) {
                    $policyName = Split-Path $assignment.Properties.PolicyDefinitionId -Leaf
                }
                
                # Try to get display name from multiple locations
                $displayName = if ($assignment.Properties.DisplayName) { 
                    $assignment.Properties.DisplayName 
                } elseif ($assignment.DisplayName) { 
                    $assignment.DisplayName 
                } elseif ($assignment.Name) { 
                    $assignment.Name 
                } else { 
                    "Assignment of $policyName" 
                }
                
                # Try to get scope from multiple possible locations
                $assignmentScope = if ($assignment.Properties.Scope) { 
                    $assignment.Properties.Scope 
                } elseif ($assignment.Scope) { 
                    $assignment.Scope 
                } else { 
                    'Not specified' 
                }
                
                $inventory.policies.assignments += @{
                    name = if ($assignment.Name) { $assignment.Name } else { 'Unknown' }
                    displayName = $displayName
                    description = if ($assignment.Properties.Description) { $assignment.Properties.Description } else { "Assignment of $policyName" }
                    enforcementMode = if ($assignment.Properties.EnforcementMode) { $assignment.Properties.EnforcementMode } else { 'Default' }
                    scope = $assignmentScope
                    policyDefinitionId = $assignment.Properties.PolicyDefinitionId
                    policyName = $policyName
                    parameters = $assignment.Properties.Parameters
                    notScopes = $assignment.Properties.NotScopes
                }
            }
        } catch {
            Write-Host "      ⚠️  Error: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Get Role Assignments
        Write-Host "    ○ Collecting Role Assignments..." -ForegroundColor Gray
        try {
            $roles = Get-AzRoleAssignment -ErrorAction SilentlyContinue | Select-Object -First 100
            $inventory.summary.totalRoleAssignments = $roles.Count
            
            foreach ($role in $roles) {
                $inventory.roleAssignments += @{
                    displayName = $role.DisplayName
                    signInName = $role.SignInName
                    roleDefinitionName = $role.RoleDefinitionName
                    roleDefinitionId = $role.RoleDefinitionId
                    scope = $role.Scope
                    objectType = $role.ObjectType
                    objectId = $role.ObjectId
                }
            }
        } catch {
            Write-Host "      ⚠️  Could not retrieve role assignments" -ForegroundColor Yellow
        }
        
        # Get Networking Resources (loop through subscriptions)
        Write-Host "    ○ Collecting Networking Resources..." -ForegroundColor Gray
        foreach ($sub in $subs | Select-Object -First 10) {
            try {
                Set-AzContext -SubscriptionId $sub.Id | Out-Null
                
                # Virtual Networks
                $vnets = Get-AzVirtualNetwork -ErrorAction SilentlyContinue
                foreach ($vnet in $vnets) {
                    $inventory.networking.vnets += @{
                        name = $vnet.Name
                        resourceGroup = $vnet.ResourceGroupName
                        location = $vnet.Location
                        addressSpace = $vnet.AddressSpace.AddressPrefixes
                        subnets = @($vnet.Subnets | ForEach-Object {
                            @{
                                name = $_.Name
                                addressPrefix = $_.AddressPrefix
                                serviceEndpoints = @($_.ServiceEndpoints | ForEach-Object { $_.Service })
                            }
                        })
                        dnsServers = $vnet.DhcpOptions.DnsServers
                        tags = $vnet.Tag
                        subscription = $sub.Name
                    }
                }
                $inventory.summary.totalVNets += $vnets.Count
                
                # VNet Peerings
                foreach ($vnet in $vnets) {
                    $peerings = $vnet.VirtualNetworkPeerings
                    foreach ($peer in $peerings) {
                        $inventory.networking.peerings += @{
                            name = $peer.Name
                            id = $peer.Id
                            sourceVNet = $vnet.Name
                            sourceVNetId = $vnet.Id
                            sourceResourceGroup = $vnet.ResourceGroupName
                            remoteVNet = Split-Path $peer.RemoteVirtualNetwork.Id -Leaf
                            remoteVNetId = $peer.RemoteVirtualNetwork.Id
                            peeringState = $peer.PeeringState
                            provisioningState = $peer.ProvisioningState
                            allowForwardedTraffic = $peer.AllowForwardedTraffic
                            allowGatewayTransit = $peer.AllowGatewayTransit
                            allowVirtualNetworkAccess = $peer.AllowVirtualNetworkAccess
                            doNotVerifyRemoteGateways = $peer.DoNotVerifyRemoteGateways
                            useRemoteGateways = $peer.UseRemoteGateways
                            remoteAddressSpace = $peer.RemoteVirtualNetworkAddressSpace.AddressPrefixes
                            subscription = $sub.Name
                        }
                    }
                }
                $inventory.summary.totalPeerings = $inventory.networking.peerings.Count
                
                # VPN Gateways - use Get-AzResource to find them
                try {
                    $vpnGatewayResources = Get-AzResource -ResourceType 'Microsoft.Network/virtualNetworkGateways' -ErrorAction SilentlyContinue
                    foreach ($vpnResource in $vpnGatewayResources) {
                        try {
                            $vpn = Get-AzVirtualNetworkGateway -ResourceGroupName $vpnResource.ResourceGroupName -Name $vpnResource.Name -ErrorAction SilentlyContinue
                            if ($vpn) {
                                $inventory.networking.vpnGateways += @{
                                    name = $vpn.Name
                                    resourceGroup = $vpn.ResourceGroupName
                                    location = $vpn.Location
                                    gatewayType = $vpn.GatewayType
                                    vpnType = $vpn.VpnType
                                    sku = $vpn.Sku.Name
                                    activeActive = $vpn.ActiveActive
                                    enableBgp = $vpn.EnableBgp
                                    subscription = $sub.Name
                                }
                            }
                        } catch {}
                    }
                } catch {}
                
                # Azure Firewalls - use Get-AzResource to find them
                try {
                    $firewallResources = Get-AzResource -ResourceType 'Microsoft.Network/azureFirewalls' -ErrorAction SilentlyContinue
                    foreach ($fwResource in $firewallResources) {
                        try {
                            $fw = Get-AzFirewall -ResourceGroupName $fwResource.ResourceGroupName -Name $fwResource.Name -ErrorAction SilentlyContinue
                            if ($fw) {
                                $inventory.networking.firewalls += @{
                                    name = $fw.Name
                                    resourceGroup = $fw.ResourceGroupName
                                    location = $fw.Location
                                    tier = $fw.Sku.Tier
                                    threatIntelMode = $fw.ThreatIntelMode
                                    applicationRules = $fw.ApplicationRuleCollections.Count
                                    networkRules = $fw.NetworkRuleCollections.Count
                                    natRules = $fw.NatRuleCollections.Count
                                    subscription = $sub.Name
                                }
                            }
                        } catch {}
                    }
                } catch {}
                
                # Network Security Groups - use Get-AzResource to find them
                try {
                    $nsgResources = Get-AzResource -ResourceType 'Microsoft.Network/networkSecurityGroups' -ErrorAction SilentlyContinue
                    foreach ($nsgResource in $nsgResources) {
                        try {
                            $nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $nsgResource.ResourceGroupName -Name $nsgResource.Name -ErrorAction SilentlyContinue
                            if ($nsg) {
                                $inventory.networking.networkSecurityGroups += @{
                                    name = $nsg.Name
                                    resourceGroup = $nsg.ResourceGroupName
                                    location = $nsg.Location
                                    securityRulesCount = $nsg.SecurityRules.Count
                                    defaultSecurityRulesCount = $nsg.DefaultSecurityRules.Count
                                    subscription = $sub.Name
                                }
                            }
                        } catch {}
                    }
                } catch {}
                
                # Private DNS Zones
                try {
                    $privateDnsZones = Get-AzPrivateDnsZone -ErrorAction SilentlyContinue
                    foreach ($zone in $privateDnsZones) {
                        try {
                            # Get virtual network links for this zone
                            $vnetLinks = Get-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $zone.ResourceGroupName -ZoneName $zone.Name -ErrorAction SilentlyContinue
                            $linkedVNets = @()
                            foreach ($link in $vnetLinks) {
                                $vnetName = if ($link.VirtualNetwork.Id) { Split-Path $link.VirtualNetwork.Id -Leaf } else { 'N/A' }
                                $linkedVNets += @{
                                    linkName = $link.Name
                                    vnetName = $vnetName
                                    vnetId = $link.VirtualNetwork.Id
                                    registrationEnabled = $link.RegistrationEnabled
                                }
                            }
                            
                            # Get record sets count
                            $recordSets = Get-AzPrivateDnsRecordSet -ResourceGroupName $zone.ResourceGroupName -ZoneName $zone.Name -ErrorAction SilentlyContinue
                            
                            $inventory.networking.privateDnsZones += @{
                                name = $zone.Name
                                id = $zone.Id
                                resourceGroup = $zone.ResourceGroupName
                                location = $zone.Location
                                numberOfRecordSets = $recordSets.Count
                                numberOfVirtualNetworkLinks = $vnetLinks.Count
                                virtualNetworkLinks = $linkedVNets
                                tags = $zone.Tags
                                subscription = $sub.Name
                            }
                        } catch {
                            Write-Host "      ⚠️  Error processing Private DNS Zone: $($zone.Name)" -ForegroundColor Yellow
                        }
                    }
                    $inventory.summary.totalPrivateDnsZones += $privateDnsZones.Count
                } catch {
                    Write-Host "      ⚠️  Error collecting Private DNS Zones" -ForegroundColor Yellow
                }
                
                # Private Endpoints
                try {
                    $privateEndpoints = Get-AzPrivateEndpoint -ErrorAction SilentlyContinue
                    foreach ($pe in $privateEndpoints) {
                        try {
                            # Get private link service connection details
                            $connections = @()
                            foreach ($conn in $pe.PrivateLinkServiceConnections) {
                                $connections += @{
                                    name = $conn.Name
                                    privateLinkServiceId = $conn.PrivateLinkServiceId
                                    groupIds = $conn.GroupIds
                                    requestMessage = $conn.RequestMessage
                                    status = $conn.PrivateLinkServiceConnectionState.Status
                                }
                            }
                            
                            # Get subnet and VNet info
                            $subnetId = if ($pe.Subnet.Id) { $pe.Subnet.Id } else { $null }
                            $vnetName = if ($subnetId) { ($subnetId -split '/subnets/')[0] | Split-Path -Leaf } else { 'N/A' }
                            $subnetName = if ($subnetId) { Split-Path $subnetId -Leaf } else { 'N/A' }
                            
                            # Get private IP addresses
                            $privateIPs = @()
                            foreach ($ipConfig in $pe.NetworkInterfaces) {
                                if ($ipConfig.Id) {
                                    try {
                                        $nicRG = ($ipConfig.Id -split '/')[4]
                                        $nicName = Split-Path $ipConfig.Id -Leaf
                                        $nic = Get-AzNetworkInterface -ResourceGroupName $nicRG -Name $nicName -ErrorAction SilentlyContinue
                                        if ($nic) {
                                            foreach ($ip in $nic.IpConfigurations) {
                                                if ($ip.PrivateIpAddress) {
                                                    $privateIPs += $ip.PrivateIpAddress
                                                }
                                            }
                                        }
                                    } catch {}
                                }
                            }
                            
                            # Get connected resource name from the first connection
                            $connectedResource = 'N/A'
                            if ($connections.Count -gt 0 -and $connections[0].privateLinkServiceId) {
                                $connectedResource = Split-Path $connections[0].privateLinkServiceId -Leaf
                            }
                            
                            $inventory.networking.privateEndpoints += @{
                                name = $pe.Name
                                id = $pe.Id
                                resourceGroup = $pe.ResourceGroupName
                                location = $pe.Location
                                vnet = $vnetName
                                subnet = $subnetName
                                privateIPs = $privateIPs
                                connections = $connections
                                connectedResource = $connectedResource
                                provisioningState = $pe.ProvisioningState
                                tags = $pe.Tag
                                subscription = $sub.Name
                            }
                        } catch {
                            Write-Host "      ⚠️  Error processing Private Endpoint: $($pe.Name)" -ForegroundColor Yellow
                        }
                    }
                    $inventory.summary.totalPrivateEndpoints += $privateEndpoints.Count
                } catch {
                    Write-Host "      ⚠️  Error collecting Private Endpoints" -ForegroundColor Yellow
                }
                
            } catch {
                Write-Host "      ⚠️  Error collecting network resources in sub: $($sub.Name)" -ForegroundColor Yellow
            }
        }
        
        # Get Virtual Machines
        Write-Host "    ○ Collecting Virtual Machines..." -ForegroundColor Gray
        foreach ($sub in $subs | Select-Object -First 10) {
            try {
                Set-AzContext -SubscriptionId $sub.Id | Out-Null
                
                $vms = Get-AzVM -Status -ErrorAction SilentlyContinue
                foreach ($vm in $vms) {
                    # Get network interfaces
                    $nics = @()
                    $vmVNet = $null
                    $vmSubnet = $null
                    $privateIPs = @()
                    $publicIPs = @()
                    
                    foreach ($nicRef in $vm.NetworkProfile.NetworkInterfaces) {
                        try {
                            $nicId = $nicRef.Id
                            $nicRG = ($nicId -split '/')[4]
                            $nicName = Split-Path $nicId -Leaf
                            $nic = Get-AzNetworkInterface -ResourceGroupName $nicRG -Name $nicName -ErrorAction SilentlyContinue
                            
                            if ($nic) {
                                $nics += $nic.Name
                                
                                foreach ($ipConfig in $nic.IpConfigurations) {
                                    if ($ipConfig.PrivateIpAddress) {
                                        $privateIPs += $ipConfig.PrivateIpAddress
                                    }
                                    
                                    if ($ipConfig.Subnet) {
                                        $subnetId = $ipConfig.Subnet.Id
                                        $vmVNet = ($subnetId -split '/subnets/')[0] | Split-Path -Leaf
                                        $vmSubnet = Split-Path $subnetId -Leaf
                                    }
                                    
                                    if ($ipConfig.PublicIpAddress) {
                                        $pipId = $ipConfig.PublicIpAddress.Id
                                        $pipRG = ($pipId -split '/')[4]
                                        $pipName = Split-Path $pipId -Leaf
                                        $pip = Get-AzPublicIpAddress -ResourceGroupName $pipRG -Name $pipName -ErrorAction SilentlyContinue
                                        if ($pip -and $pip.IpAddress) {
                                            $publicIPs += $pip.IpAddress
                                        }
                                    }
                                }
                            }
                        } catch {}
                    }
                    
                    # Get OS disk info
                    $osDiskSize = 0
                    if ($vm.StorageProfile.OsDisk.DiskSizeGB) {
                        $osDiskSize = $vm.StorageProfile.OsDisk.DiskSizeGB
                    }
                    
                    $powerState = ($vm.PowerState -replace 'PowerState/', '')
                    
                    $inventory.compute.virtualMachines += @{
                        name = $vm.Name
                        id = $vm.Id
                        resourceGroup = $vm.ResourceGroupName
                        location = $vm.Location
                        vmSize = $vm.HardwareProfile.VmSize
                        osType = $vm.StorageProfile.OsDisk.OsType
                        osDiskSizeGB = $osDiskSize
                        dataDisksCount = $vm.StorageProfile.DataDisks.Count
                        powerState = $powerState
                        provisioningState = $vm.ProvisioningState
                        networkInterfaces = $nics
                        vnet = $vmVNet
                        subnet = $vmSubnet
                        privateIPs = $privateIPs
                        publicIPs = $publicIPs
                        availabilitySet = if ($vm.AvailabilitySetReference) { Split-Path $vm.AvailabilitySetReference.Id -Leaf } else { $null }
                        tags = $vm.Tags
                        subscription = $sub.Name
                    }
                }
                $inventory.summary.totalVMs += $vms.Count
                
            } catch {
                Write-Host "      ⚠️  Error collecting VMs in sub: $($sub.Name)" -ForegroundColor Yellow
            }
        }
        
        # Get Governance Resources
        Write-Host "    ○ Collecting Governance Resources..." -ForegroundColor Gray
        foreach ($sub in $subs | Select-Object -First 10) {
            try {
                Set-AzContext -SubscriptionId $sub.Id | Out-Null
                
                # Budgets (requires Az.CostManagement module - skip if not available)
                try {
                    if (Get-Command Get-AzConsumptionBudget -ErrorAction SilentlyContinue) {
                        $budgets = Get-AzConsumptionBudget -ErrorAction SilentlyContinue
                        foreach ($budget in $budgets) {
                            $inventory.governance.budgets += @{
                                name = $budget.Name
                                amount = $budget.Amount
                                timeGrain = $budget.TimeGrain
                                timePeriod = @{
                                    startDate = $budget.TimePeriod.StartDate
                                    endDate = $budget.TimePeriod.EndDate
                                }
                                currentSpend = $budget.CurrentSpend.Amount
                                subscription = $sub.Name
                            }
                        }
                        $inventory.summary.totalBudgets += $budgets.Count
                    }
                } catch {}
                
                # Resource Locks
                $locks = Get-AzResourceLock -ErrorAction SilentlyContinue
                foreach ($lock in $locks) {
                    $inventory.governance.locks += @{
                        name = $lock.Name
                        resourceName = $lock.ResourceName
                        resourceType = $lock.ResourceType
                        level = $lock.Properties.Level
                        notes = $lock.Properties.Notes
                        subscription = $sub.Name
                    }
                }
                $inventory.summary.totalLocks += $locks.Count
                
                # Collect commonly used tags
                $resources = Get-AzResource -ErrorAction SilentlyContinue | Select-Object -First 50
                foreach ($resource in $resources) {
                    if ($resource.Tags) {
                        foreach ($tagKey in $resource.Tags.Keys) {
                            if (-not $inventory.governance.tags.ContainsKey($tagKey)) {
                                $inventory.governance.tags[$tagKey] = @()
                            }
                            $tagValue = $resource.Tags[$tagKey]
                            if ($tagValue -notin $inventory.governance.tags[$tagKey]) {
                                $inventory.governance.tags[$tagKey] += $tagValue
                            }
                        }
                    }
                }
                
            } catch {
                Write-Host "      ⚠️  Error collecting governance resources in sub: $($sub.Name)" -ForegroundColor Yellow
            }
        }
        
        Write-Host "    ✓ Inventory collection complete" -ForegroundColor Green
        
        # Evaluate Best Practices Compliance
        Write-Host "    ○ Evaluating Cloud Adoption Framework compliance..." -ForegroundColor Gray
        $inventory.bestPractices = Get-LandingZoneBestPracticesAssessment -Inventory $inventory
        Write-Host "    ✓ Best practices assessment complete" -ForegroundColor Green
        
    } catch {
        Write-Host "    ✗ Error during inventory collection: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
    
    return $inventory
}

function Get-LandingZoneBestPracticesAssessment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Inventory
    )
    
    $assessment = @{
        overallScore = 0
        maxScore = 0
        recommendations = @()
        categories = @{
            managementGroupHierarchy = @{
                score = 0
                maxScore = 15
                status = 'fail'
                findings = @()
            }
            policyDrivenGovernance = @{
                score = 0
                maxScore = 20
                status = 'fail'
                findings = @()
            }
            identityAndAccess = @{
                score = 0
                maxScore = 15
                status = 'fail'
                findings = @()
            }
            networkTopology = @{
                score = 0
                maxScore = 20
                status = 'fail'
                findings = @()
            }
            securityGovernance = @{
                score = 0
                maxScore = 10
                status = 'fail'
                findings = @()
            }
            costManagement = @{
                score = 0
                maxScore = 10
                status = 'fail'
                findings = @()
            }
            resourceOrganization = @{
                score = 0
                maxScore = 10
                status = 'fail'
                findings = @()
            }
        }
    }
    
    # 1. Management Group Hierarchy Assessment
    $mgCount = $Inventory.summary.totalManagementGroups
    $subCount = $Inventory.summary.totalSubscriptions
    
    if ($mgCount -ge 2) {
        $assessment.categories.managementGroupHierarchy.score += 5
        $assessment.categories.managementGroupHierarchy.findings += "✓ Management group hierarchy is implemented ($mgCount groups)"
    } else {
        $assessment.categories.managementGroupHierarchy.findings += "✗ Limited management group structure. Recommended: Use hierarchical management groups for organizational alignment"
        $assessment.recommendations += "Implement a management group hierarchy (e.g., Root > Platform/Landing Zones > Corp/Online)"
    }
    
    if ($mgCount -ge 3 -and $mgCount -le 6) {
        $assessment.categories.managementGroupHierarchy.score += 5
        $assessment.categories.managementGroupHierarchy.findings += "✓ Management group hierarchy follows CAF recommendations (3-6 levels)"
    } elseif ($mgCount -gt 6) {
        $assessment.categories.managementGroupHierarchy.findings += "⚠ Management group hierarchy may be too deep. Recommended: 3-6 levels maximum"
        $assessment.recommendations += "Simplify management group structure to 3-6 levels for better manageability"
    }
    
    if ($subCount -ge 3) {
        $assessment.categories.managementGroupHierarchy.score += 5
        $assessment.categories.managementGroupHierarchy.findings += "✓ Multiple subscriptions for workload isolation ($subCount subscriptions)"
    } elseif ($subCount -gt 0) {
        $assessment.categories.managementGroupHierarchy.findings += "⚠ Consider using multiple subscriptions for better workload isolation and scale"
        $assessment.recommendations += "Adopt subscription democratization: Use separate subscriptions for platform, landing zones, and workloads"
    }
    
    # 2. Policy-Driven Governance Assessment
    $policyDefs = $Inventory.summary.totalPolicyDefinitions
    $policyInits = $Inventory.summary.totalPolicyInitiatives
    $policyAssigns = $Inventory.summary.totalPolicyAssignments
    
    if ($policyDefs -gt 0 -or $policyInits -gt 0) {
        $assessment.categories.policyDrivenGovernance.score += 5
        $assessment.categories.policyDrivenGovernance.findings += "✓ Custom policies/initiatives defined ($policyDefs definitions, $policyInits initiatives)"
    } else {
        $assessment.categories.policyDrivenGovernance.findings += "⚠ No custom policies found. Consider implementing custom policies for organizational requirements"
        $assessment.recommendations += "Define custom Azure Policies for security, compliance, and governance requirements"
    }
    
    if ($policyAssigns -ge 5) {
        $assessment.categories.policyDrivenGovernance.score += 10
        $assessment.categories.policyDrivenGovernance.findings += "✓ Active policy assignments at scale ($policyAssigns assignments)"
    } elseif ($policyAssigns -gt 0) {
        $assessment.categories.policyDrivenGovernance.score += 5
        $assessment.categories.policyDrivenGovernance.findings += "⚠ Limited policy assignments. Recommended: Apply policies at management group level"
        $assessment.recommendations += "Increase policy coverage by assigning policies at management group scope"
    } else {
        $assessment.categories.policyDrivenGovernance.findings += "✗ No policy assignments found. Critical: Implement Azure Policy for governance"
        $assessment.recommendations += "Assign Azure Policy initiatives (e.g., Azure Security Benchmark, regulatory compliance)"
    }
    
    if ($policyInits -gt 0) {
        $assessment.categories.policyDrivenGovernance.score += 5
        $assessment.categories.policyDrivenGovernance.findings += "✓ Policy initiatives (grouped policies) are being used"
    }
    
    # 3. Identity and Access Management Assessment
    $roleAssigns = $Inventory.summary.totalRoleAssignments
    
    if ($roleAssigns -ge 10) {
        $assessment.categories.identityAndAccess.score += 10
        $assessment.categories.identityAndAccess.findings += "✓ RBAC actively implemented ($roleAssigns role assignments)"
    } elseif ($roleAssigns -gt 0) {
        $assessment.categories.identityAndAccess.score += 5
        $assessment.categories.identityAndAccess.findings += "⚠ Limited RBAC implementation. Recommended: Implement least-privilege access"
        $assessment.recommendations += "Expand RBAC implementation with custom roles and group-based assignments"
    } else {
        $assessment.categories.identityAndAccess.findings += "✗ No custom role assignments. Implement RBAC for identity-based access control"
        $assessment.recommendations += "Define and assign Azure RBAC roles at management group and subscription scopes"
    }
    
    # Check for privileged roles (Owner/Contributor)
    $hasPrivilegedRoles = $Inventory.roleAssignments | Where-Object { $_.roleDefinitionName -match 'Owner|Contributor' }
    if ($hasPrivilegedRoles) {
        $assessment.categories.identityAndAccess.score += 5
        $assessment.categories.identityAndAccess.findings += "✓ Privileged roles detected. Ensure these follow least-privilege principle"
    }
    
    # 4. Network Topology and Connectivity Assessment
    $vnetCount = $Inventory.summary.totalVNets
    $peeringCount = $Inventory.summary.totalPeerings
    $vpnCount = $Inventory.networking.vpnGateways.Count
    $fwCount = $Inventory.networking.firewalls.Count
    
    if ($vnetCount -ge 2) {
        $assessment.categories.networkTopology.score += 5
        $assessment.categories.networkTopology.findings += "✓ Multiple VNets for network segmentation ($vnetCount VNets)"
    } elseif ($vnetCount -eq 1) {
        $assessment.categories.networkTopology.findings += "⚠ Single VNet detected. Consider hub-spoke topology for scalable architecture"
        $assessment.recommendations += "Implement hub-spoke network topology or Azure Virtual WAN for enterprise-scale connectivity"
    } else {
        $assessment.categories.networkTopology.findings += "✗ No VNets found. Deploy networking infrastructure"
    }
    
    if ($peeringCount -gt 0 -and $vnetCount -ge 2) {
        $assessment.categories.networkTopology.score += 10
        $assessment.categories.networkTopology.findings += "✓ VNet peering implemented for connectivity ($peeringCount peerings)"
    } elseif ($vnetCount -ge 2) {
        $assessment.categories.networkTopology.findings += "⚠ Multiple VNets without peering. Recommended: Implement hub-spoke with VNet peering"
        $assessment.recommendations += "Connect VNets using peering or Virtual WAN for centralized connectivity"
    }
    
    if ($vpnCount -gt 0 -or $fwCount -gt 0) {
        $assessment.categories.networkTopology.score += 5
        $assessment.categories.networkTopology.findings += "✓ Network security appliances deployed (VPN: $vpnCount, Firewalls: $fwCount)"
    } else {
        $assessment.categories.networkTopology.findings += "⚠ No VPN gateways or firewalls detected. Consider Azure Firewall or NVA for hub connectivity"
        $assessment.recommendations += "Deploy Azure Firewall in hub VNet for centralized security and egress control"
    }
    
    # 5. Security and Governance Assessment
    $locks = $Inventory.summary.totalLocks
    $nsgCount = $Inventory.networking.networkSecurityGroups.Count
    
    if ($locks -gt 0) {
        $assessment.categories.securityGovernance.score += 5
        $assessment.categories.securityGovernance.findings += "✓ Resource locks implemented for protection ($locks locks)"
    } else {
        $assessment.categories.securityGovernance.findings += "⚠ No resource locks found. Recommended: Lock critical resources"
        $assessment.recommendations += "Apply CanNotDelete locks on critical resources (networking, shared services)"
    }
    
    if ($nsgCount -gt 0) {
        $assessment.categories.securityGovernance.score += 5
        $assessment.categories.securityGovernance.findings += "✓ Network Security Groups deployed ($nsgCount NSGs)"
    } else {
        $assessment.categories.securityGovernance.findings += "⚠ No NSGs detected. Implement network segmentation"
        $assessment.recommendations += "Deploy Network Security Groups for subnet-level security and micro-segmentation"
    }
    
    # 6. Cost Management Assessment
    $budgets = $Inventory.summary.totalBudgets
    
    if ($budgets -ge 3) {
        $assessment.categories.costManagement.score += 10
        $assessment.categories.costManagement.findings += "✓ Cost management with budgets ($budgets budgets)"
    } elseif ($budgets -gt 0) {
        $assessment.categories.costManagement.score += 5
        $assessment.categories.costManagement.findings += "⚠ Limited budget coverage. Recommended: Budget per subscription"
        $assessment.recommendations += "Create budgets for all subscriptions with alerting thresholds"
    } else {
        $assessment.categories.costManagement.findings += "✗ No budgets configured. Implement cost management and monitoring"
        $assessment.recommendations += "Configure Azure Budgets and Cost Management alerts for financial governance"
    }
    
    # 7. Resource Organization Assessment
    $tagCount = $Inventory.governance.tags.Keys.Count
    
    if ($tagCount -ge 5) {
        $assessment.categories.resourceOrganization.score += 10
        $assessment.categories.resourceOrganization.findings += "✓ Comprehensive tagging strategy ($tagCount tag keys)"
    } elseif ($tagCount -gt 0) {
        $assessment.categories.resourceOrganization.score += 5
        $assessment.categories.resourceOrganization.findings += "⚠ Basic tagging implemented. Recommended: Standardize tags (Environment, CostCenter, Owner, etc.)"
        $assessment.recommendations += "Define and enforce tagging policy with required tags: Environment, CostCenter, Owner, Application"
    } else {
        $assessment.categories.resourceOrganization.findings += "✗ No tags detected. Implement tagging strategy for resource organization"
        $assessment.recommendations += "Implement mandatory tagging policy using Azure Policy Modify effect"
    }
    
    # Calculate overall scores
    foreach ($category in $assessment.categories.Keys) {
        $cat = $assessment.categories[$category]
        $assessment.maxScore += $cat.maxScore
        $assessment.overallScore += $cat.score
        
        # Determine status
        $percentage = ($cat.score / $cat.maxScore) * 100
        if ($percentage -ge 80) {
            $cat.status = 'excellent'
        } elseif ($percentage -ge 60) {
            $cat.status = 'good'
        } elseif ($percentage -ge 40) {
            $cat.status = 'fair'
        } else {
            $cat.status = 'needs-improvement'
        }
    }
    
    # Overall assessment
    $overallPercentage = [math]::Round(($assessment.overallScore / $assessment.maxScore) * 100, 0)
    $assessment.overallPercentage = $overallPercentage
    
    if ($overallPercentage -ge 80) {
        $assessment.overallStatus = 'excellent'
        $assessment.overallMessage = "Your Azure Landing Zone demonstrates strong alignment with Cloud Adoption Framework best practices."
    } elseif ($overallPercentage -ge 60) {
        $assessment.overallStatus = 'good'
        $assessment.overallMessage = "Your Azure Landing Zone follows many CAF best practices with room for enhancement."
    } elseif ($overallPercentage -ge 40) {
        $assessment.overallStatus = 'fair'
        $assessment.overallMessage = "Your Azure Landing Zone has basic implementation but needs improvement in several areas."
    } else {
        $assessment.overallStatus = 'needs-improvement'
        $assessment.overallMessage = "Your Azure Landing Zone requires significant work to align with CAF best practices."
    }
    
    return $assessment
}
