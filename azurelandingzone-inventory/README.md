# 🏢 Azure Landing Zone Inventory & Assessment Tool

A comprehensive web-based inventory and assessment dashboard for Azure Landing Zone environments. This tool provides real-time visibility into your Azure infrastructure and evaluates compliance against Microsoft Cloud Adoption Framework (CAF) and Well-Architected Framework (WAF) best practices.

![Azure Landing Zone](https://img.shields.io/badge/Azure-Landing%20Zone-0078D4?style=for-the-badge&logo=microsoft-azure)
![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?style=for-the-badge&logo=powershell)
![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## 🌟 Overview

The Azure Landing Zone Inventory Tool automatically collects and analyzes your Azure environment to provide:
- **Complete Infrastructure Inventory**: All resources across management groups and subscriptions
- **CAF Compliance Assessment**: Automated evaluation against Cloud Adoption Framework principles
- **WAF Alignment Scoring**: Assessment across 5 pillars (Reliability, Security, Cost, Operations, Performance)
- **Professional PDF Reports**: Comprehensive documentation with tables, charts, and recommendations
- **Real-Time Dashboard**: Interactive web interface with detailed resource information
- **Automatic Module Management**: Auto-installs and updates required PowerShell modules

**Version:** 1.0.0  
**Created by:** Alex ter Neuzen for [GetToTheCloud](https://www.gettothe.cloud)

## ✨ Key Features

### 📊 Comprehensive Inventory
- **Management Groups**: Full hierarchy with parent-child relationships
- **Subscriptions**: State, tags, and placement tracking
- **Azure Policy**: Definitions (custom + built-in), initiatives, and assignments
- **RBAC**: Complete role assignment mapping with principal details
- **Networking**: 
  - Virtual Networks with subnets and address spaces
  - VNet Peerings with connectivity status and traffic settings
  - Virtual WANs with hub configurations
  - VPN Gateways with SKUs, BGP, and active-active settings
  - ExpressRoute Circuits with bandwidth and provider details
  - Azure Firewalls with tier and threat intelligence modes
  - Firewall Policies with rule collection statistics and IDS/IPS
  - Network Security Groups with rule counts
  - Private DNS Zones with VNet links and record sets
  - Private Endpoints with connected PaaS resources
- **Compute**: Virtual Machines with power states and network details
- **Governance**: 
  - Cost Management Budgets with thresholds and alerts
  - Resource Locks at subscription, resource group, and resource levels
  - Tags collected from subscriptions, resource groups, and resources
  - Diagnostic Settings configuration

### 🎯 Assessment & Scoring
- **Cloud Adoption Framework (CAF)**: Evaluates 7 design areas
  - Management Group Hierarchy
  - Policy-Driven Governance
  - Identity and Access Management (RBAC)
  - Network Topology and Connectivity
  - Security Governance
  - Cost Management
  - Resource Organization
  
- **Well-Architected Framework (WAF)**: Scores 5 pillars
  - Reliability (network redundancy, resource locks)
  - Security (policies, RBAC, NSGs, firewalls)
  - Cost Optimization (budgets, tagging strategies)
  - Operational Excellence (management hierarchy, automation)
  - Performance Efficiency (network topology, connectivity)

### 📄 Advanced Reporting
- **Professional PDF Export**: Multi-page reports with:
  - Executive summary with key metrics and scores
  - CAF compliance assessment with detailed findings
  - WAF pillar analysis with individual scores
  - Management Groups hierarchy table
  - Subscriptions with state and tags
  - Virtual Networks and peering relationships
  - Virtual WANs, VPN Gateways, and ExpressRoute circuits
  - Azure Firewalls and Firewall Policies with rule statistics
  - Policy definitions and assignments
  - Role assignments distribution
  - Governance resources (budgets, locks, tags)
  - Actionable recommendations
  - Custom watermark on every page
- **Live Dashboard**: Real-time view with:
  - Progress bar during data collection
  - Interactive navigation between categories
  - Sortable data tables
  - Summary cards with key statistics

## 📋 Prerequisites

### Required Software
- **PowerShell 7.0 or higher** (pwsh)
  - Download: [https://aka.ms/powershell](https://aka.ms/powershell)
  - Verify: `pwsh --version`

### Required Azure PowerShell Modules

The tool **automatically checks and installs/updates** these modules on startup:

- **Az.Accounts** - Azure authentication and context management
- **Az.Resources** - Resource, policy, and management group operations
- **Az.Network** - Virtual networks, VPN gateways, firewalls, DNS
- **Az.PolicyInsights** - Policy compliance and remediation data

**Note:** All modules are automatically installed and updated to the latest version when you start the server. No manual installation needed!

### Manual Installation (Optional)

If you prefer to install modules manually before running:

```powershell
# Install required modules
Install-Module -Name Az.Accounts -Scope CurrentUser -Force
Install-Module -Name Az.Resources -Scope CurrentUser -Force
Install-Module -Name Az.Network -Scope CurrentUser -Force
Install-Module -Name Az.PolicyInsights -Scope CurrentUser -Force

# Update to latest versions
Update-Module -Name Az.Accounts -Force
Update-Module -Name Az.Resources -Force
Update-Module -Name Az.Network -Force
Update-Module -Name Az.PolicyInsights -Force
```

## 🔐 Azure Permissions Requirements

### Minimum Required Permissions

For **complete inventory** including management groups:

1. **Management Group Reader** role:
   - Scope: Tenant Root Management Group
   - Purpose: Read management group hierarchy
   - **Critical**: Without this, management groups will not be collected

2. **Reader** role:
   - Scope: Subscriptions or Management Groups you want to inventory
   - Purpose: Read all resources, policies, and configurations

### Permission Details

| Resource Type | Required Permission | Scope | Notes |
|--------------|-------------------|-------|-------|
| Management Groups | Management Group Reader | Tenant Root | Tenant-level permission required |
| Subscriptions | Reader | Subscription(s) | Or inherited from Management Group |
| Policies | Reader or Policy Reader | Subscription/MG | Built into Reader role |
| RBAC Roles | Reader | Subscription/MG | View role assignments |
| Networking | Reader | Subscription(s) | VNets, Firewalls, VPN, etc. |
| VMs & Compute | Reader | Subscription(s) | Virtual machines |
| Governance | Reader | Subscription(s) | Budgets, locks, tags |

### Checking Your Permissions

```powershell
# Check your current Azure context
Get-AzContext

# List role assignments for your account
Get-AzRoleAssignment -SignInName your.email@domain.com

# Check management group access
Get-AzManagementGroup
```

### Common Permission Issues

**Problem:** "Management Groups: 0" displayed even though they exist

**Cause:** Missing "Management Group Reader" role at tenant level

**Solution:**
1. Contact your Azure Global Administrator or Privileged Role Administrator
2. Request "Management Group Reader" role assignment at "/" (tenant root) scope
3. PowerShell command for admin to grant access:
   ```powershell
   New-AzRoleAssignment -SignInName user@domain.com `
       -RoleDefinitionName "Management Group Reader" `
       -Scope "/"
   ```

**Problem:** "Limited access to Management Groups" warning

**Cause:** Subscription-level resource provider registration check (misleading error)

**Solution:** The tool automatically handles this - uses tenant-level API calls to bypass subscription checks

## 🚀 Quick Start

### Step 1: Download or Clone

```bash
git clone https://github.com/GetToTheCloud/AzureDocumenter.git
cd AzureDocumenter/azurelandingzone-inventory
```

### Step 2: Start the Server

#### macOS/Linux
```bash
chmod +x start.sh
./start.sh
```

#### Windows
```cmd
start.cmd
```

#### PowerShell (Any Platform)
```powershell
pwsh -File Start-AzureLandingZoneServer.ps1
```

### Step 3: Use the Tool

1. **Server Startup**: 
   - PowerShell 7 version check
   - Automatic module installation/update (2-5 minutes first time)
   - Azure authentication status check
   - Server starts on http://localhost:8080

2. **Web Interface**:
   - Open browser to `http://localhost:8080`
   - Click "Sign in to Azure" button
   - Follow device code authentication flow
   - Wait for data collection (2-10 minutes depending on tenant size)
   - Navigate through categories in sidebar

3. **Export Report**:
   - Click "Export to PDF" button
   - Professional multi-page report generated
   - Includes all tables, assessments, and recommendations

## 🗂️ Project Structure

```
azurelandingzone-inventory/
├── Start-AzureLandingZoneServer.ps1    # HTTP server with auto module management
├── Get-AzureLandingZoneInventory.ps1   # Data collection engine (v1.0.0)
├── index.html                           # Dashboard interface with progress bar
├── styles.css                           # UI styling
├── app.js                               # Frontend logic & PDF generation
├── start.sh                            # Unix startup script
├── start.cmd                           # Windows startup script
└── README.md                           # This file
```

### File Details

**Start-AzureLandingZoneServer.ps1**
- PowerShell 7+ requirement check
- Automatic module installation and updates
- Management group access validation
- HTTP listener on localhost:8080
- Device authentication support
- RESTful API endpoints

**Get-AzureLandingZoneInventory.ps1**
- Module dependency validation
- Comprehensive resource collection
- CAF/WAF assessment logic
- Smart error handling for tenant-level resources
- Progress logging with colored output

**index.html**
- Responsive single-page application
- Category navigation sidebar
- Progress overlay during collection
- Data tables for all resource types
- PDF export button

**app.js**
- Frontend application logic (v1.0.0)
- REST API integration
- Dynamic table rendering
- Multi-stage progress simulation
- jsPDF-based report generation

## 📊 Dashboard Categories

### 📈 Overview
- Summary cards with key metrics
- CAF compliance score with percentage
- WAF pillar scores (5 pillars)
- Resource count statistics
- Quick access to all categories

### 🗂️ Management Groups
- Hierarchical structure table
- Parent management group references
- Child object counts (MGs + subscriptions)
- Tenant ID display

### 💳 Subscriptions
- Complete subscription inventory
- State tracking (Enabled/Disabled/ProvisioningState)
- Tag collections
- Management group placement
- Tenant association

### 📋 Policies
Three-tier policy governance:
- **Definitions**: Custom and built-in policy rules with descriptions
- **Initiatives**: Policy sets (bundles) with member policies
- **Assignments**: Active policy enforcement at all scopes (MG/Sub/RG)

### 👥 Role Assignments
- RBAC role mappings
- Principal identification (User/Group/ServicePrincipal)
- Role definition names
- Scope hierarchy display
- Role distribution analytics

### 🌐 Networking
Complete network infrastructure visibility:
- **Virtual Networks**: Address spaces, subnet counts, locations
- **VNet Peerings**: Source/remote VNets, states, traffic settings
- **Virtual WANs**: Hub counts, branch-to-branch, VNet-to-VNet traffic
- **VPN Gateways**: Gateway types, SKUs, VPN types, Active-Active, BGP
- **ExpressRoute Circuits**: Providers, peering locations, bandwidth, states
- **Azure Firewalls**: Tiers, threat intel modes, rule counts, policy references
- **Firewall Policies**: Total rules, collection breakdowns, IDS/IPS status
- **Network Security Groups**: Security rule counts by resource group
- **Private DNS Zones**: Record set counts, VNet link details
- **Private Endpoints**: Connected resources, private IPs, connection states

### 💻 Virtual Machines
- VM inventory with computer names
- Power states (Running/Deallocated/Stopped)
- VM sizes and OS types
- Network connectivity (VNet/Subnet)
- Private IP addresses
- Availability sets

### ⚖️ Governance
- **Budgets**: Cost thresholds, time periods, alert configurations
- **Resource Locks**: 
  - Subscription-level locks
  - Resource group-level locks
  - Resource-level locks
  - Lock types (CanNotDelete/ReadOnly)
- **Tags**: 
  - Unique tag keys discovered
  - Tag values collected from subscriptions
  - Tag values from resource groups
  - Sample tag values from resources (first 100)
- **Diagnostic Settings**: Monitoring configuration tracking

## 📄 PDF Export Features

Generated reports include:

### 📑 Cover Page
- Tool name and version (v1.0.0)
- Generation timestamp
- Tenant ID
- Azure Landing Zone branding

### 📊 Executive Summary
- Management groups, subscriptions, policies overview
- Networking resource counts
- Governance resource counts
- VM inventory summary

### 🏆 CAF Assessment (7 Categories)
Detailed evaluation with scores and findings:
1. **Management Group Hierarchy**: Structure depth and organization
2. **Policy Governance**: Built-in vs custom policies, coverage
3. **Identity & Access (RBAC)**: Role assignment distribution
4. **Network Topology**: Hub-spoke patterns, connectivity
5. **Security**: NSGs, firewalls, policies, private endpoints
6. **Cost Management**: Budget coverage, tagging strategies
7. **Resource Organization**: Tagging maturity, structure

Each category includes:
- Score percentage
- Status indicators (✓ / ✗ / ⚠)
- Detailed findings
- Specific recommendations

### 🎯 WAF Alignment (5 Pillars)
Individual pillar scoring:
- **Reliability**: Network redundancy, locks, hybrid connectivity
- **Security**: Policies, RBAC, firewalls, NSGs  
- **Cost Optimization**: Budgets, tagging, resource organization
- **Operational Excellence**: Management hierarchy, automation potential
- **Performance Efficiency**: Network topology, connectivity options

### 📋 Detailed Resource Tables
Structured data tables for:
- Management Groups (name, parent, children, type)
- Subscriptions (name, state, tags, MG)
- Virtual Networks (name, location, address space, subnets)
- VNet Peerings (source, remote, state, traffic settings)
- Virtual WANs (name, location, hubs, traffic policies)
- VPN Gateways (name, SKU, type, BGP, Active-Active)
- ExpressRoute Circuits (name, provider, bandwidth, state)
- Azure Firewalls (name, tier, threat intel, rules/policy)
- Firewall Policies (name, tier, rules, collections, IDS)
- Role Assignments (principal, role, scope)
- Policy Assignments (name, scope, enforcement)

### 📚 References & Resources
- Microsoft CAF documentation links
- WAF guidance
- Best practice references

### 🔖 Custom Watermark
Every page footer: "Created by Alex ter Neuzen for https://www.gettothe.cloud"

## 🔧 Configuration

### Custom Port
```powershell
./Start-AzureLandingZoneServer.ps1 -Port 3000
```

### Module Updates
Modules are automatically checked and updated on every server start. To force update manually:
```powershell
Update-Module -Name Az.Accounts -Force
Update-Module -Name Az.Resources -Force  
Update-Module -Name Az.Network -Force
Update-Module -Name Az.PolicyInsights -Force
```

### Collection Scope
By default, collects from ALL subscriptions. To limit scope, edit `Get-AzureLandingZoneInventory.ps1`:

```powershell
# Line ~310: Limit subscriptions for detailed resource collection
$subs = Get-AzSubscription | Where-Object { $_.Name -like "Prod*" }

# Or use specific subscription IDs
$subs = Get-AzSubscription -SubscriptionId "sub-id-1", "sub-id-2"
```

### UI Customization
- **Styling**: Modify `styles.css` for colors, fonts, layouts
- **Tables**: Edit column definitions in `index.html`
- **Data Display**: Update render functions in `app.js`
- **PDF Content**: Customize `exportToPDF()` function in `app.js`

## 🛠️ Troubleshooting

### PowerShell Version Issues
```powershell
# Check version
pwsh --version

# Should be 7.0 or higher
# If not, download from: https://aka.ms/powershell
```

**Error Message:**
```
❌ ERROR: PowerShell 7 or higher is required.
   Current version: 5.1.xxxxx
   Download PowerShell 7+: https://aka.ms/powershell
```

**Solution:** Install PowerShell 7+ and run with `pwsh` command instead of `powershell`

### Module Installation Failures
```powershell
# Clear module cache
Remove-Module Az.* -Force -ErrorAction SilentlyContinue

# Reinstall manually
Install-Module -Name Az.Accounts -Force -Scope CurrentUser -AllowClobber
Install-Module -Name Az.Resources -Force -Scope CurrentUser -AllowClobber
Install-Module -Name Az.Network -Force -Scope CurrentUser -AllowClobber
Install-Module -Name Az.PolicyInsights -Force -Scope CurrentUser -AllowClobber
```

### Authentication Issues
```powershell
# Clear and reconnect
Disconnect-AzAccount
Clear-AzContext -Force  
Connect-AzAccount -UseDeviceAuthentication

# Verify connection
Get-AzContext
Get-AzSubscription
```

**Symptoms:**
- "Not authenticated" message
- Empty inventory data
- Connection timeout errors

**Solution:**
1. Ensure device code authentication completes
2. Check network proxy settings
3. Verify Azure AD sign-in works in browser

### Management Group Permission Errors

**Error Message:**
```
⚠️  Error accessing Management Groups: ...does not have authorization 
     to perform action 'Microsoft.Management/register/action'...
```

**This is a MISLEADING error!** The cmdlet checks subscription-level permissions first, but management groups are tenant-level resources.

**Solution:**
- The tool automatically handles this error
- Uses `-ErrorAction SilentlyContinue` to bypass false permission check
- Ensure you have "Management Group Reader" role at **tenant root** level
- Contact Azure Global Admin if management groups still show 0

**Verification:**
```powershell
# Should return management groups (not error)
Get-AzManagementGroup

# Check your role assignments
Get-AzRoleAssignment -SignInName your.email@domain.com | 
    Where-Object { $_.RoleDefinitionName -like "*Management Group*" }
```

### Port Already in Use

```bash
# macOS/Linux: Find and kill process
lsof -ti:8080 | xargs kill -9

# Windows: Kill PowerShell processes
taskkill /F /IM pwsh.exe

# Use alternate port
./Start-AzureLandingZoneServer.ps1 -Port 8081
```

### Slow Collection Performance

**Causes:**
- Large tenant (50+ subscriptions)
- Many resources (1000+ VNets, policies, etc.)
- Network latency to Azure APIs

**Solutions:**
1. **Be Patient**: 5-15 minutes is normal for large tenants
2. **Limit Scope**: Edit collection script to target specific MGs/subscriptions
3. **Watch Progress**: Console shows real-time collection status
4. **Check Output**: Look for errors in PowerShell console

### Firewall Policy Collection Errors

If you see input prompts during collection:

```powershell
# Update Az.Network to latest version
Update-Module -Name Az.Network -Force

# Restart server
```

The tool properly handles firewall policy rule collections without user input.

### Missing Data in Tables

**Problem:** Tables show "No X found" but you know they exist

**Causes & Solutions:**
- **Permissions**: Verify Reader access to subscription/MG
- **Scope**: Check if resources are in subscriptions being scanned
- **Errors**: Review PowerShell console for API errors
- **Filters**: Remove any resource filters in collection script

### PDF Export Not Working

**Symptoms:**
- Button doesn't respond
- JavaScript console errors
- Blank/incomplete PDF

**Solutions:**
1. **Check jsPDF Library**: Ensure CDN loads correctly
2. **Browser Console**: Check for JavaScript errors (F12)
3. **Large Data**: Reduce data size if browser memory exhausted
4. **Try Another Browser**: Chrome/Edge recommended

## 🔐 Security

- **localhost Only**: Server binds to 127.0.0.1 (no network exposure)
- **Device Code Auth**: Secure Azure authentication flow
- **No Storage**: No credentials or tokens stored locally
- **Read-Only**: Only queries resources, never modifies
- **Session-Based**: Authentication per browser session
- **Automatic Cleanup**: Context cleared on server stop
- **No External APIs**: All data stays on your local machine

## 📊 Performance Characteristics

### Collection Time
- **Small Tenant** (1-5 subscriptions): 1-2 minutes
- **Medium Tenant** (5-20 subscriptions): 2-5 minutes  
- **Large Tenant** (20-50 subscriptions): 5-15 minutes
- **Enterprise Tenant** (50+ subscriptions): 15-30 minutes

*Factors affecting speed:*
- Number of subscriptions
- Resources per subscription (especially policies, role assignments)
- Network latency to Azure APIs
- Management group hierarchy depth

### Resource Collection Scope
**Version 1.0.0 removes all artificial limits:**
- ✅ **All** Management Groups
- ✅ **All** Subscriptions  
- ✅ **All** Policy Definitions (custom & built-in)
- ✅ **All** Policy Initiatives (custom & built-in)
- ✅ **All** Policy Assignments
- ✅ **All** Role Assignments
- ✅ **All** VNets, Peerings, Firewalls
- ✅ **All** Virtual WANs, VPN Gateways, ExpressRoute Circuits
- ✅ **All** Virtual Machines
- ✅ **All** Locks (subscription/RG/resource levels)
- ✅ **All** Tags (from subscriptions, resource groups, sample from resources)

### Browser Requirements
- Modern browser (Chrome, Edge, Firefox, Safari)
- JavaScript enabled
- Recommended: Chrome or Edge for best PDF export performance
- Memory: 4GB+ RAM recommended for large tenants (10,000+ resources)

### Progress Tracking
9-stage progress indicator shows:
1. Management Groups
2. Subscriptions
3. Policy Definitions
4. Policy Initiatives & Assignments
5. Role Assignments
6. Networking (VNets, Peerings, Virtual WAN, VPN, ExpressRoute, Firewalls)
7. Virtual Machines
8. Governance (Budgets, Locks, Tags)
9. Assessment (CAF/WAF scoring)

## 🤝 Contributing

### Adding New Azure Resources
1. **Collection**: Update `Get-AzureLandingZoneInventory.ps1`
   ```powershell
   # Example: Add Azure SQL Databases
   Write-Host "Collecting SQL Databases..." -ForegroundColor Cyan
   $sqlDatabases = @()
   foreach ($sub in $allSubscriptions) {
       Set-AzContext -SubscriptionId $sub.Id -ErrorAction SilentlyContinue
       $sqlDatabases += Get-AzSqlDatabase -ErrorAction SilentlyContinue
   }
   
   # Add to inventory object
   $inventory.databases = @{
       sqlDatabases = $sqlDatabases
   }
   ```

2. **UI**: Add table in `index.html`
   ```html
   <div class="subsection">
       <h3>SQL Databases</h3>
       <table class="data-table" id="sqlDatabasesTable">
           <thead>
               <tr>
                   <th>Name</th>
                   <th>Subscription</th>
                   <th>Location</th>
                   <th>Tier</th>
               </tr>
           </thead>
           <tbody></tbody>
       </table>
   </div>
   ```

3. **Display**: Update `app.js`
   ```javascript
   function populateSqlDatabases() {
       const table = document.querySelector('#sqlDatabasesTable tbody');
       table.innerHTML = '';
       
       if (!inventoryData.databases?.sqlDatabases?.length) {
           table.innerHTML = '<tr><td colspan="4">No SQL databases found</td></tr>';
           return;
       }
       
       inventoryData.databases.sqlDatabases.forEach(db => {
           const row = table.insertRow();
           row.insertCell(0).textContent = db.DatabaseName;
           row.insertCell(1).textContent = db.ResourceGroupName;
           row.insertCell(2).textContent = db.Location;
           row.insertCell(3).textContent = db.SkuName;
       });
   }
   
   // Call in populateData()
   populateSqlDatabases();
   ```

4. **PDF Export**: Add section in `app.js` `exportToPDF()`
   ```javascript
   // Add after networking section
   if (inventoryData.databases?.sqlDatabases?.length > 0) {
       doc.addPage();
       doc.setFontSize(16);
       doc.text('SQL Databases', 105, yPos, { align: 'center' });
       yPos += 10;
       
       // Create table...
   }
   ```

### Adding Assessment Criteria

Update CAF/WAF scoring in `Get-AzureLandingZoneInventory.ps1`:

```powershell
# Example: Add new CAF category for Data Management
$dataManagementScore = 0
$dataManagementFindings = @()
$dataManagementRecs = @()

# Check for SQL TDE encryption
$sqlServers = Get-AzSqlServer
if ($sqlServers | Where-Object { $_.MinimalTlsVersion -eq '1.2' }) {
    $dataManagementScore += 15
    $dataManagementFindings += "✓ SQL Servers enforce TLS 1.2"
} else {
    $dataManagementFindings += "✗ SQL Servers not enforcing TLS 1.2"
    $dataManagementRecs += "Enable TLS 1.2 on all SQL Servers"
}

# Add to assessment
$assessment.caf.categories += @{
    name = "Data Management"
    score = [math]::Min($dataManagementScore, 100)
    findings = $dataManagementFindings
    recommendations = $dataManagementRecs
}
```

### Code Style Guidelines
- **PowerShell**: Use `PascalCase` for functions, `$camelCase` for variables
- **JavaScript**: Use `camelCase` for functions/variables
- **Comments**: Add inline explanations for complex logic
- **Error Handling**: Always include `-ErrorAction SilentlyContinue` for Azure cmdlets
- **Output**: Use `Write-Host` with colors (Cyan for info, Yellow for warnings, Red for errors)

## 📝 License

MIT License - Free to use, modify, and distribute.

See [LICENSE](LICENSE) file for full terms.

## 🙏 Acknowledgments

### Technologies & Libraries
- **Microsoft Azure PowerShell SDK**: Core data collection
- **jsPDF Library**: PDF generation functionality
- **vis-network**: Network visualization support (available in codebase)

### Inspiration & Standards
- Microsoft Azure Cloud Adoption Framework (CAF)
- Microsoft Azure Well-Architected Framework (WAF)
- Azure Landing Zone reference implementations
- Azure community best practices

### Special Thanks
- Azure PowerShell SDK maintainers
- Microsoft Cloud Adoption Framework team
- Azure architecture and governance community

## 🔗 Related Resources

### Microsoft Official Documentation
- [Azure Landing Zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/) - Foundational landing zone concepts
- [Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/) - Complete adoption methodology
- [Well-Architected Framework](https://learn.microsoft.com/azure/architecture/framework/) - Five-pillar architecture guidance
- [Azure Policy](https://learn.microsoft.com/azure/governance/policy/) - Policy-driven governance
- [Management Groups](https://learn.microsoft.com/azure/governance/management-groups/) - Hierarchical organization
- [Azure RBAC](https://learn.microsoft.com/azure/role-based-access-control/) - Identity and access management

### Network Architecture Patterns
- [Hub-Spoke Network Topology](https://learn.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) - Core networking pattern
- [Azure Firewall Architecture](https://learn.microsoft.com/azure/architecture/example-scenario/firewalls/) - Central firewall design
- [Private Link and DNS Integration](https://learn.microsoft.com/azure/private-link/private-endpoint-dns) - Private connectivity
- [Virtual WAN Documentation](https://learn.microsoft.com/azure/virtual-wan/) - Global transit network
- [VPN Gateway Planning](https://learn.microsoft.com/azure/vpn-gateway/vpn-gateway-about-vpngateways) - Hybrid connectivity

### Governance & Best Practices
- [Azure Policy Samples](https://github.com/Azure/azure-policy) - Community policy definitions
- [Azure Enterprise Scaffold](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/) - Enterprise-scale architecture
- [Tagging Strategy](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging) - Resource organization
- [Cost Management Best Practices](https://learn.microsoft.com/azure/cost-management-billing/costs/cost-mgt-best-practices) - Budget and optimization

### Tools & Automation
- [Azure PowerShell Documentation](https://learn.microsoft.com/powershell/azure/) - Complete cmdlet reference
- [Azure Resource Graph](https://learn.microsoft.com/azure/governance/resource-graph/) - Advanced querying at scale
- [Azure CLI](https://learn.microsoft.com/cli/azure/) - Alternative command-line tool
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) - Infrastructure as Code

## 👨‍💻 Author

**Alex ter Neuzen**  
IT Consultant with experience in Azure Local, Azure Landing Zones and Azure Virtual Desktop

🌐 Website: [GetToTheCloud](https://www.gettothe.cloud)  
📧 Contact: Through website  
💼 Specialties: Azure Landing Zones, Cloud Adoption, Infrastructure as Code

---

<div align="center">

**Version 1.0.0** | Built with PowerShell 7+ | Last Updated: 2024

*Empowering Azure Landing Zone visibility and governance through automated inventory and assessment*

⭐ If this tool helps your Azure journey, consider sharing it with your team!

</div>
