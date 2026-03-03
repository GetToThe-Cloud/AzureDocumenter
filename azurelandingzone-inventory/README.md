# 🏢 Azure Landing Zone Inventory

A comprehensive web-based inventory dashboard for Azure Landing Zone environments. This tool provides a live view of your Azure Landing Zone configuration, including management groups, subscriptions, policies, role assignments, networking, and governance settings.

## ✨ Features

- **Live Inventory Collection**: Automatically gathers current state from Azure
- **Comprehensive Coverage**: 
  - Management Groups hierarchy
  - Subscriptions and placement
  - Azure Policy (definitions, initiatives, assignments)
  - Role-Based Access Control (RBAC)
  - Networking (VNets, peerings, VPN gateways, firewalls, NSGs)
  - Governance (budgets, locks, tags, diagnostic settings)
- **Category Navigation**: Organized sidebar with intuitive navigation
- **Detailed Descriptions**: Educational content explaining each service and setting
- **PDF Export**: Generate detailed reports with explanations
- **Azure Authentication**: Secure integration with Azure via device authentication

## 📋 Prerequisites

- **PowerShell 7+** (pwsh): [Download](https://aka.ms/powershell)
- **Azure PowerShell Modules** (automatically installed if missing):
  - Az.Accounts
  - Az.Resources (includes Management Groups)
  - Az.Network
  - Az.PolicyInsights
  - Az.CostManagement (optional, for budget data)
- **Azure Permissions**: 
  - Reader access at tenant root or management group level
  - Or Reader access to specific subscriptions

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

### Manual Start

```powershell
pwsh -File Start-AzureLandingZoneServer.ps1 -Port 8080
```

## 📖 Usage

1. **Start the Server**: Run the startup script for your platform
2. **Open Browser**: Navigate to http://localhost:8080
3. **Authenticate**: Click "Sign in to Azure" and follow device authentication flow
4. **Explore**: Use the sidebar navigation to browse different categories
5. **Export**: Click "Export PDF" to generate a comprehensive report with explanations
6. **Refresh**: Click "Refresh" to update the inventory data

## 🗂️ File Structure

```
azurelandingzone-inventory/
├── Start-AzureLandingZoneServer.ps1    # Web server (PowerShell HTTP listener)
├── Get-AzureLandingZoneInventory.ps1   # Inventory collection module
├── index.html                           # Frontend UI
├── styles.css                           # Styling
├── app.js                               # Frontend logic & PDF export
├── start.sh                            # macOS/Linux startup script
├── start.cmd                           # Windows startup script
└── README.md                           # This file
```

## 🎯 Categories

### 📊 Overview
Summary dashboard with key metrics and introduction to Azure Landing Zone concepts.

### 🗂️ Management Groups
Hierarchical organization structure for subscriptions with parent-child relationships.

### 💳 Subscriptions
List of all Azure subscriptions with their state, tags, and placement in the management group hierarchy.

### 📋 Policies
- **Policy Definitions**: Individual governance rules
- **Policy Initiatives**: Grouped policy sets (e.g., CIS Benchmark)
- **Policy Assignments**: Applied policies at various scopes

### 👥 Role Assignments
Role-Based Access Control (RBAC) assignments showing who has access to what resources and with which permissions.

### 🌐 Networking
- **Virtual Networks**: VNets with address spaces and subnets
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
