# 🏢 Azure Landing Zone Inventory & Assessment Tool

A comprehensive web-based inventory and assessment dashboard for Azure Landing Zone environments. This tool provides real-time visibility into your Azure infrastructure and evaluates compliance against Microsoft Cloud Adoption Framework (CAF) and Well-Architected Framework (WAF) best practices.

![Azure Landing Zone](https://img.shields.io/badge/Azure-Landing%20Zone-0078D4?style=for-the-badge&logo=microsoft-azure)
![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?style=for-the-badge&logo=powershell)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## 🌟 Overview

The Azure Landing Zone Inventory Tool automatically collects and analyzes your Azure environment to provide:
- **Complete Infrastructure Inventory**: All resources across management groups and subscriptions
- **CAF Compliance Assessment**: Automated evaluation against Cloud Adoption Framework principles
- **WAF Alignment Scoring**: Assessment across 5 pillars (Reliability, Security, Cost, Operations, Performance)
- **Professional PDF Reports**: Comprehensive documentation with tables, charts, and recommendations
- **Real-Time Dashboard**: Interactive web interface with detailed resource information

Created by **Alex ter Neuzen** for [GetToTheCloud](https://www.gettothe.cloud)

## ✨ Key Features

### 📊 Comprehensive Inventory
- **Management Groups**: Full hierarchy with parent-child relationships
- **Subscriptions**: State, tags, and placement tracking
- **Azure Policy**: Definitions, initiatives, and assignments
- **RBAC**: Complete role assignment mapping
- **Networking**: 
  - Virtual Networks with subnets and address spaces
  - VNet Peerings with connectivity status
  - Virtual WANs and hub configurations
  - VPN Gateways for hybrid connectivity
  - Azure Firewalls with policy details
  - Firewall Policies with active rule counts
  - Network Security Groups
  - Private DNS Zones with VNet links
  - Private Endpoints with connected resources
- **Compute**: Virtual Machines with network details
- **Governance**: Budgets, resource locks, tags, and diagnostic settings

### 🎯 Assessment & Scoring
- **Cloud Adoption Framework**: Evaluates 7 design areas
  - Management Group Hierarchy
  - Policy-Driven Governance
  - Identity and Access Management
  - Network Topology
  - Security Governance
  - Cost Management
  - Resource Organization
  
- **Well-Architected Framework**: Scores 5 pillars
  - Reliability
  - Security
  - Cost Optimization
  - Operational Excellence
  - Performance Efficiency

### 📄 Advanced Reporting
- **Professional PDF Export**: Multi-page reports with:
  - Executive summary with key metrics
  - CAF compliance assessment with scoring
  - WAF pillar analysis
  - Structured data tables for VNets, peerings, firewalls
  - Detailed resource inventories
  - Actionable recommendations
  - Watermarked on every page
- **Custom Watermark**: "Created by Alex ter Neuzen for https://www.gettothe.cloud"

## 📋 Prerequisites

### Required Software
- **PowerShell 7+** (pwsh): [Download](https://aka.ms/powershell)
- **Azure PowerShell Modules**:
  ```powershell
  Install-Module -Name Az.Accounts -Scope CurrentUser
  Install-Module -Name Az.Resources -Scope CurrentUser
  Install-Module -Name Az.Network -Scope CurrentUser
  Install-Module -Name Az.PolicyInsights -Scope CurrentUser
  ```

### Optional Modules
- **Az.CostManagement**: For budget data collection
- **Az.PrivateDns**: Enhanced private DNS zone details

### Azure Permissions
Minimum required permissions:
- **Reader** role at:
  - Tenant Root Management Group (recommended), OR
  - Specific Management Groups/Subscriptions

For complete inventory:
- Reader access across all subscriptions
- Management Group Reader for hierarchy
- Policy Reader for policy insights

## 🚀 Quick Start

### macOS/Linux
```bash
cd azurelandingzone-inventory
chmod +x start.sh
./start.sh
```

### Windows
```cmd
cd azurelandingzone-inventory
start.cmd
```

### PowerShell (Any Platform)
```powershell
pwsh -File Start-AzureLandingZoneServer.ps1 -Port 8080
```

### First Use
1. **Launch**: Start the server using one of the methods above
2. **Browse**: Navigate to `http://localhost:8080`
3. **Authenticate**: Click "Sign in to Azure" - follow device code flow
4. **Wait**: Initial collection takes 2-5 minutes
5. **Explore**: Navigate through categories in the sidebar
6. **Assess**: Review CAF/WAF scores and recommendations
7. **Export**: Generate professional PDF report

## 🗂️ Project Structure

```
azurelandingzone-inventory/
├── Start-AzureLandingZoneServer.ps1    # HTTP server (PowerShell listener)
├── Get-AzureLandingZoneInventory.ps1   # Data collection engine
├── index.html                           # Dashboard interface
├── styles.css                           # UI styling
├── app.js                               # Frontend logic & PDF generation
├── start.sh                            # Unix startup script
├── start.cmd                           # Windows startup script
└── README.md                           # Documentation
```

## 📊 Dashboard Categories

### 📈 Overview
- Summary cards with key metrics
- CAF compliance score and status
- WAF pillar scores
- Quick statistics dashboard

### 🗂️ Management Groups
- Hierarchical structure visualization
- Parent-child relationships
- Child subscription counts
- Management group details

### 💳 Subscriptions
- Complete subscription inventory
- State tracking (Enabled/Disabled)
- Tag management
- Management group placement

### 📋 Policies
Comprehensive policy governance tracking:
- **Definitions**: Custom and built-in policy rules
- **Initiatives**: Policy sets (CIS, NIST, etc.)
- **Assignments**: Active policy enforcement at all scopes

### 👥 Role Assignments
- RBAC role mappings
- Principal identification (users, groups, service principals)
- Scope hierarchy
- Role distribution analytics

### 🌐 Networking
Complete network infrastructure visibility:
- **Virtual Networks**: Address spaces, subnets, service endpoints
- **VNet Peerings**: Hub-spoke topology, connectivity status
- **Virtual WANs**: Hub configurations, branch-to-branch settings
- **VPN Gateways**: Hybrid connectivity, SKUs, BGP settings
- **Azure Firewalls**: Tier, threat intelligence, rule statistics
- **Firewall Policies**: Active rule counts, IDS/IPS status, rule collections
- **Network Security Groups**: Security rule counts
- **Private DNS Zones**: Record sets, VNet links
- **Private Endpoints**: Connected PaaS resources, private IPs

### 💻 Virtual Machines
- VM inventory with sizes and OS types
- Power states (running, deallocated, stopped)
- Network connectivity (VNet, subnet, IPs)
- Availability sets

### ⚖️ Governance
- **Budgets**: Cost management thresholds and alerts
- **Resource Locks**: Deletion/modification protection
- **Tags**: Organization and chargeback tracking
- **Diagnostic Settings**: Monitoring configuration

## 📄 PDF Export Features

Generated reports include:

### 📑 Cover Page
- Title and generation timestamp
- Tenant ID
- Summary statistics

### 📊 Executive Summary
- Tenant overview
- Resource inventory counts
- High-level metrics

### 🏆 CAF Assessment
- Overall compliance percentage
- Category-by-category scoring:
  - Management Groups (hierarchical structure)
  - Policy Governance (enforcement coverage)
  - Identity & Access (RBAC implementation)
  - Network Topology (hub-spoke, connectivity)
  - Security (NSGs, firewalls, policies)
  - Cost Management (budgets, tags)
  - Resource Organization (structure, naming)
- Detailed findings with status indicators
- Actionable recommendations

### 🎯 WAF Alignment
- Five-pillar assessment:
  - **Reliability**: Network redundancy, locks, hybrid connectivity
  - **Security**: Policies, RBAC, NSGs, firewalls
  - **Cost Optimization**: Budgets, tagging, SKU policies
  - **Operational Excellence**: Management hierarchy, automation
  - **Performance Efficiency**: Network topology, connectivity, automation
- Individual pillar scores
- Overall WAF alignment percentage

### 📋 Resource Details
Structured tables for all resources:
- **Management Groups**: Hierarchy with children counts
- **Subscriptions**: State, tags, placement
- **Virtual Networks**: Address spaces, subnet counts
- **VNet Peerings**: Source/remote VNets, state, configuration
- **Virtual WANs**: Hub counts, traffic settings
- **Azure Firewalls**: Policy/classic rules, threat intel
- **Firewall Policies**: Total rules, collection breakdown, IDS status
- **Private DNS Zones**: Record counts, VNet links
- **Private Endpoints**: Connected resources, private IPs

### 📚 References
- Microsoft documentation links
- CAF resources
- WAF resources
- Best practice guides

### 🔍 Watermark
Every page includes: "Created by Alex ter Neuzen for https://www.gettothe.cloud"

## 🔧 Configuration

### Custom Port
```powershell
./Start-AzureLandingZoneServer.ps1 -Port 3000
```

### Data Collection Limits
Edit `Get-AzureLandingZoneInventory.ps1` to adjust:
```powershell
# Line ~435: Subscription processing limit
$subs | Select-Object -First 10  # Change 10 to desired number

# Line ~285: Policy definitions limit
Select-Object -First 20  # Change 20 for more policies
```

### UI Customization
- **Styling**: Modify `styles.css`
- **Layout**: Edit section structure in `index.html`
- **Data Display**: Update table rendering in `app.js`
- **PDF Content**: Customize `exportToPDF()` function in `app.js`

## 🛠️ Troubleshooting

### Authentication Issues
```powershell
# Clear and reconnect
Disconnect-AzAccount
Clear-AzContext -Force
Connect-AzAccount -UseDeviceAuthentication
```

### Missing Modules
```powershell
# Install all required modules
$modules = @(
    'Az.Accounts',
    'Az.Resources', 
    'Az.Network',
    'Az.PolicyInsights',
    'Az.CostManagement'
)
foreach ($module in $modules) {
    Install-Module -Name $module -Force -Scope CurrentUser -AllowClobber
}
```

### Permission Errors
If you see "Limited access" warnings:
- Request **Reader** role at Management Group level
- Verify subscription access
- Check Azure AD role assignments

### Port Conflicts
```bash
# macOS/Linux
pkill -f "Start-AzureLandingZoneServer"
./start.sh

# Windows
taskkill /F /IM pwsh.exe
start.cmd

# Use alternate port
./Start-AzureLandingZoneServer.ps1 -Port 8081
```

### Slow Collection
Performance tips:
- Reduce subscription limit in script (default: 10)
- Skip optional modules (e.g., CostManagement for budgets)
- Focus on specific management groups
- Use filtering in collection script

### Firewall Policy Errors
If firewall policy collection prompts for input:
- Ensure Az.Network module is up to date:
  ```powershell
  Update-Module -Name Az.Network -Force
  ```
- The script now handles rule collection groups properly

## 🔐 Security

- **localhost Only**: Server binds to 127.0.0.1 (no network exposure)
- **Device Code Auth**: Secure Azure authentication flow
- **No Storage**: No credentials or tokens stored locally
- **Read-Only**: Only queries resources, never modifies
- **Session-Based**: Authentication per browser session
- **Automatic Cleanup**: Context cleared on server stop

## 📊 Performance Characteristics

### Collection Time
- **Small Tenant** (1-5 subs): 1-2 minutes
- **Medium Tenant** (5-20 subs): 2-5 minutes  
- **Large Tenant** (20+ subs): 5-15 minutes

### Resource Limits (Default)
- Policy Definitions: First 20 custom + 20 built-in
- Policy Initiatives: First 20 custom + 20 built-in
- Policy Assignments: First 100
- Role Assignments: First 100
- Subscriptions for detailed resources: First 10
- Virtual Machines: All in first 10 subscriptions

### Browser Requirements
- Modern browser (Chrome, Edge, Firefox, Safari)
- JavaScript enabled
- jsPDF library loaded from CDN

## 🤝 Contributing

### Adding New Resources
1. **Collection**: Update `Get-AzureLandingZoneInventory.ps1`
   ```powershell
   # Add new resource type
   $inventory.newCategory = @{
       newResources = @()
   }
   ```

2. **UI**: Add table in `index.html`
   ```html
   <div class="subsection">
       <h3>New Resource Type</h3>
       <table class="data-table">
           <!-- Define columns -->
       </table>
   </div>
   ```

3. **Display**: Update `app.js`
   ```javascript
   function populateNewResources() {
       // Render data in table
   }
   ```

4. **Export**: Add to PDF in `app.js` `exportToPDF()`

### Adding Assessment Criteria
Update best practices logic in `Get-AzureLandingZoneInventory.ps1`:
```powershell
# Add new check
if ($condition) {
    $categoryScore += 10
    $findings += "✓ Positive finding"
} else {
    $findings += "✗ Improvement needed"
    $recommendations += "Recommendation text"
}
```

## 📝 License

MIT License - Free to use, modify, and distribute.

## 🙏 Acknowledgments

- Microsoft Azure Cloud Adoption Framework team
- Azure PowerShell SDK maintainers
- jsPDF library contributors
- Azure community

## 🔗 Related Resources

### Microsoft Documentation
- [Azure Landing Zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Cloud Adoption Framework](https://learn.microsoft.com/azure/cloud-adoption-framework/)
- [Well-Architected Framework](https://learn.microsoft.com/azure/architecture/framework/)
- [Azure Policy](https://learn.microsoft.com/azure/governance/policy/)
- [Management Groups](https://learn.microsoft.com/azure/governance/management-groups/)

### Best Practices
- [Hub-Spoke Network Topology](https://learn.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Azure Firewall Architecture](https://learn.microsoft.com/azure/architecture/example-scenario/firewalls/)
- [Private Link and DNS Integration](https://learn.microsoft.com/azure/private-link/private-endpoint-dns)

## 👨‍💻 Author

**Alex ter Neuzen**  
[GetToTheCloud](https://www.gettothe.cloud)

---

*Last Updated: 2024*
- **VNet Peerings**: Hub-spoke connectivity relationships
- **VPN Gateways**: On-premises connectivity
- **Azure Firewalls**: Network security appliances
- **Network Security Groups**: Subnet/NIC-level firewall rules

### ⚖️ Governance
- **Budgets**: Spending thresholds and alerts
- **Resource Locks**: Protection against accidental deletion/modification
- **Tags**: Resource organization and cost allocation

## 📄 PDF Export

The PDF export feature generates a comprehensive document that includes:

- **Detailed Explanations**: Multi-page descriptions of each Landing Zone component
- **Summary Statistics**: Key metrics and counts
- **Service Descriptions**: What each Azure service does and why it matters
- **Best Practices**: Guidance on Landing Zone patterns and configurations

Perfect for documentation, compliance reporting, or stakeholder presentations.

## 🔧 Configuration

### Change Port

```powershell
./Start-AzureLandingZoneServer.ps1 -Port 3000
```

### Customize Data Collection

Edit `Get-AzureLandingZoneInventory.ps1` to:
- Adjust resource limits (default: first 10 subscriptions for detailed resources)
- Add additional Azure resources
- Modify filtering logic

### Customize UI

- **Styling**: Edit `styles.css`
- **Categories**: Modify navigation in `index.html`
- **Data Display**: Update table structures in `app.js`

## 🛠️ Troubleshooting

### Authentication Issues

```powershell
# Clear Azure context
Disconnect-AzAccount
Clear-AzContext -Force

# Reconnect
Connect-AzAccount -UseDeviceAuthentication
```

### Module Installation Errors

```powershell
# Install modules manually
Install-Module -Name Az.Accounts -Force -Scope CurrentUser
Install-Module -Name Az.Resources -Force -Scope CurrentUser
Install-Module -Name Az.Network -Force -Scope CurrentUser
Install-Module -Name Az.PolicyInsights -Force -Scope CurrentUser
# Optional for budget data:
# Install-Module -Name Az.CostManagement -Force -Scope CurrentUser
```

### Port Already in Use

```bash
# macOS/Linux: Stop existing instance
pkill -f "Start-AzureLandingZoneServer.ps1"

# Windows: Find and kill the process
taskkill /F /IM pwsh.exe /FI "WINDOWTITLE eq Start-AzureLandingZoneServer*"

# Or use a different port
./Start-AzureLandingZoneServer.ps1 -Port 8081
```

### Limited Access Warning

If you see warnings about limited access to certain resources (e.g., Management Groups), you need elevated permissions. Contact your Azure administrator for:
- Reader access at the tenant root management group
- Or specific permissions for the resources you want to inventory

## 🔐 Security Considerations

- **Local Only**: Server binds to localhost only (not accessible from network)
- **Device Authentication**: Uses secure Azure device authentication flow
- **No Credentials Stored**: Authentication tokens managed by Azure PowerShell
- **Read-Only**: Only performs read operations, never modifies resources

## 📊 Performance

- **Initial Load**: 2-5 minutes depending on tenant size
- **Refresh**: Same as initial load (full re-collection)
- **Limits**: Default limits applied to prevent timeouts:
  - Policy Definitions: First 50 custom
  - Policy Initiatives: First 50 custom
  - Policy Assignments: First 100
  - Role Assignments: First 100
  - Subscriptions for detailed resources: First 10

Adjust these limits in `Get-AzureLandingZoneInventory.ps1` as needed.

## 🤝 Contributing

To extend this tool:

1. **Add New Azure Resources**: 
   - Update `Get-AzureLandingZoneInventory.ps1` to collect new data
   - Add corresponding table/section in `index.html`
   - Update `app.js` to display the data

2. **Add New Categories**:
   - Add navigation link in `index.html` sidebar
   - Create content section
   - Update `showSection()` in `app.js`

3. **Enhance PDF Export**:
   - Add sections in `exportToPDF()` function in `app.js`
   - Include more detailed explanations

## 📝 License

This tool is provided as-is for Azure Landing Zone inventory and documentation purposes.

## 🆘 Support

For issues or questions:
1. Check the Troubleshooting section
2. Review Azure permissions requirements
3. Verify PowerShell and module versions

## 🔗 Related Resources

- [Azure Landing Zone Documentation](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/)
- [Azure Policy Documentation](https://docs.microsoft.com/azure/governance/policy/)
- [Azure Management Groups](https://docs.microsoft.com/azure/governance/management-groups/)

---

**Built with:** PowerShell, HTML5, CSS3, JavaScript, Azure PowerShell SDK, jsPDF
