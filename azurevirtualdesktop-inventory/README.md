# Azure Virtual Desktop Inventory Dashboard

A comprehensive, production-ready web-based dashboard for documenting and monitoring your Azure Virtual Desktop (AVD) infrastructure. Built with PowerShell and modern web technologies, this tool provides real-time insights, detailed reporting, and professional PDF exports for your AVD environment.

![Azure Virtual Desktop](https://img.shields.io/badge/Azure-Virtual_Desktop-0078D4?style=flat&logo=microsoft-azure)
![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?style=flat&logo=powershell)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Key Features

### 📊 Comprehensive Inventory Collection
- **Host Pools**: Configuration, load balancing, session limits, registration tokens
- **Session Hosts**: Status, sessions, network details, image source tracking, OS/agent versions
- **Workspaces**: Friendly names, application group associations
- **Application Groups**: Desktop and RemoteApp configurations with published applications
- **Scaling Plans**: Automated capacity management with schedule details and time zones
- **Virtual Networks**: Network connectivity and session host associations
- **Compute Galleries**: Custom image repositories with version tracking and usage analytics

### 🎨 Modern Web Interface
- **Dark themed dashboard** with intuitive navigation
- **Real-time status indicators** with color-coded badges
- **Progress bar** for long-running operations
- **Interactive controls** with manual refresh capability
- **Responsive design** that works on desktop and tablet devices
- **Category explanations** to help understand AVD components

### 📄 Professional PDF Export
- **Complete documentation** of your AVD infrastructure
- **Detailed tables** with:
  - Session hosts with IP addresses, image sources, OS versions, agent versions, and heartbeat status
  - Host pool configurations with load balancing and session limits
  - Scaling plan schedules with time zones and capacity thresholds
  - Compute galleries with image definitions and version details
  - Application groups with published applications
  - Virtual networks with subnet configurations
- **Color-coded status indicators** for availability and health
- **Attribution footer** on every page
- **Professional formatting** suitable for audits and documentation

### 🔐 Secure Azure Integration
- **Azure device authentication** flow
- **Multi-subscription support** - automatically discovers all enabled subscriptions
- **Read-only access** - no modifications to your environment
- **Session-based authentication** - credentials managed by Azure PowerShell SDK

### ⚙️ Automated Setup & Validation
- **PowerShell 7+ requirement check** - ensures compatibility on startup
- **Automatic module installation** - missing Azure modules are installed automatically
- **Module version validation** - checks for minimum required versions
- **Optional module updates** - use `-UpdateModules` to update all modules to latest versions
- **Comprehensive error reporting** - clear messages about any missing prerequisites

## 📋 Prerequisites

### Required Software
- **PowerShell 7+** ([Download](https://github.com/PowerShell/PowerShell))
  - Windows: Available via Microsoft Store or installer
  - macOS: `brew install --cask powershell`
  - Linux: Follow [official installation guide](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
  
> **Note**: The server will automatically check for PowerShell 7+ on startup and will not start with older versions.

### Azure PowerShell Modules
The following modules are required and will be checked/installed automatically on first run:
- `Az.Accounts` (v2.0.0+) - Azure authentication and context management
- `Az.DesktopVirtualization` (v4.0.0+) - AVD resource management
- `Az.Resources` (v6.0.0+) - Resource group and subscription queries
- `Az.Network` (v5.0.0+) - Virtual network information
- `Az.Compute` (v5.0.0+) - Compute gallery and image definitions

**Automatic Module Management:**
- Missing modules are automatically installed on first run
- Outdated modules are detected and reported
- Use `-UpdateModules` switch to automatically update to the latest versions

### Azure Requirements
- **Azure Subscription** with Azure Virtual Desktop resources
- **Permissions**: Reader role on AVD resources (minimum)
- **Supported AVD Components**:
  - Host Pools (Pooled and Personal)
  - Session Hosts (Windows 10/11 multi-session, Windows Server)
  - Application Groups (Desktop and RemoteApp)
  - Workspaces
  - Scaling Plans
  - Compute Galleries

## 🚀 Quick Start

### 1. Clone or Download
```bash
git clone <repository-url>
cd azurevirtualdesktop-inventory
```

### 2. Start the Server

**On Windows (PowerShell):**
```powershell
# Basic start - will install missing modules if needed
.\Start-AVDInventoryServer.ps1

# Update all modules to latest version
.\Start-AVDInventoryServer.ps1 -UpdateModules
```

**On macOS/Linux:**
```bash
chmod +x start.sh

# Basic start
./start.sh

# Update all modules to latest version
./start.sh -UpdateModules

# Custom port
./start.sh -Port 3000
```

**Custom Port:**
```powershell
.\Start-AVDInventoryServer.ps1 -Port 3000
```

**First Run:**
- The script will automatically check for PowerShell 7+
- Missing Azure modules will be installed automatically
- Outdated modules will be reported (use `-UpdateModules` to update them)

### 3. Access the Dashboard

Open your web browser to:
```
http://localhost:8080
```

### 4. Authenticate with Azure

On first access:
1. The server will detect you're not authenticated
2. Click **"Sign in to Azure"** button
3. Follow the device code authentication prompt in the server console
4. Complete authentication in your browser using the provided code
5. Return to the dashboard - inventory will load automatically

The authentication session persists until the server is stopped or you clear your Azure context.

## 📖 Using the Dashboard

### Navigation Sections

| Section | Description |
|---------|-------------|
| 📊 **Overview** | Summary statistics, total resources, health status |
| 🏊 **Host Pools** | Configuration details, load balancing, session limits |
| 💻 **Session Hosts** | VM status, sessions, network info, image sources |
| 📁 **Workspaces** | User-facing resources and application group associations |
| 📦 **Application Groups** | Desktop and RemoteApp configurations |
| ⚖️ **Scaling Plans** | Automated start/stop schedules and capacity thresholds |
| 🌐 **Virtual Networks** | Network connectivity and subnet details |
| 🖼️ **Compute Galleries** | Custom images, versions, and usage tracking |
| 🔗 **Connection Diagram** | Visual map of resource relationships (coming soon) |

### Refreshing Inventory

Click the **🔄 Refresh** button in the header to manually update data from Azure.

> **Note**: Auto-refresh is disabled to optimize performance. The inventory will remain static until you manually refresh.

### Exporting to PDF

1. Click the **📥 Export PDF** button
2. Wait for the export to complete (progress bar shown)
3. PDF will download automatically as `AVD-WAF-Assessment-YYYY-MM-DD.pdf`

**PDF Contents:**
- Complete inventory documentation
- Detailed tables with filtering and formatting
- Color-coded status indicators
- Professional layout suitable for documentation and audits
- Attribution footer with creation details

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────┐
│                   Web Browser (Client)                   │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Frontend Application (HTML/CSS/JavaScript)        │  │
│  │  • Dark-themed dashboard with navigation           │  │
│  │  • Real-time data visualization                    │  │
│  │  • PDF export with jsPDF + autoTable               │  │
│  │  • Progress tracking and error handling            │  │
│  │  • 10-minute timeout for large environments        │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────┬───────────────────────────────────┘
                       │ HTTP REST API (JSON)
┌──────────────────────▼───────────────────────────────────┐
│              PowerShell Web Server                       │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Start-AVDInventoryServer.ps1                      │  │
│  │  • HTTP listener on configurable port              │  │
│  │  • Route handling and error recovery               │  │
│  │  • Authentication session management               │  │
│  │  • Static file serving (HTML, CSS, JS)             │  │
│  └────────────────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Get-AVDInventory.ps1                              │  │
│  │  • Multi-subscription inventory collection         │  │
│  │  • Image source tracking and gallery enumeration   │  │
│  │  • Network topology discovery                      │  │
│  │  • Scaling plan schedule parsing with timezones    │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────┬───────────────────────────────────┘
                       │ Azure PowerShell SDK
┌──────────────────────▼───────────────────────────────────┐
│                    Azure Cloud                           │
│  • Azure Virtual Desktop Resources                       │
│  • Compute Galleries & Image Definitions                 │
│  • Virtual Networks & Subnets                            │
│  • Resource Groups & Subscriptions                       │
└──────────────────────────────────────────────────────────┘
```

## 🔧 Configuration

### Server Port

Change the default port (8080) when starting:
```powershell
.\Start-AVDInventoryServer.ps1 -Port 9000
```

### Timeout Settings

For very large environments (1000+ session hosts), the timeout is set to 10 minutes. To adjust:

Edit `app.js` line 99:
```javascript
const timeoutId = setTimeout(() => controller.abort(), 600000); // 10 minutes
```

### Theme Customization

Edit `styles.css` to customize colors:
```css
:root {
    --bg-primary: #1a1a2e;
    --bg-secondary: #16213e;
    --primary-color: #0078d4;
    --secondary-color: #00bcf2;
}
```

## 🛠️ Troubleshooting

### PowerShell Version Check Fails

**Problem**: "PowerShell 7 or higher is required"

**Solution**:
The script requires PowerShell 7 or newer. Check your version:
```powershell
$PSVersionTable.PSVersion
```

If you're running an older version:
- **Windows**: Install from Microsoft Store or [download installer](https://github.com/PowerShell/PowerShell/releases)
- **macOS**: `brew install --cask powershell`
- **Linux**: Follow the [official installation guide](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)

> **Note**: Windows PowerShell 5.1 is NOT supported. You must use PowerShell 7+.

### Module Installation Fails

**Problem**: Azure modules don't install automatically

**Solution**:
The script will automatically install missing modules. If this fails:
```powershell
# Install modules manually with elevated privileges
Install-Module Az.Accounts -Force -Scope CurrentUser -AllowClobber -MinimumVersion 2.0.0
Install-Module Az.DesktopVirtualization -Force -Scope CurrentUser -MinimumVersion 4.0.0
Install-Module Az.Resources -Force -Scope CurrentUser -MinimumVersion 6.0.0
Install-Module Az.Network -Force -Scope CurrentUser -MinimumVersion 5.0.0
Install-Module Az.Compute -Force -Scope CurrentUser -MinimumVersion 5.0.0
```

**To update all modules to the latest version:**
```powershell
.\Start-AVDInventoryServer.ps1 -UpdateModules
```

### Authentication Errors

**Problem**: "Failed to authenticate" or "Access denied"

**Solution**:
1. Verify you have Reader permissions on AVD resources
2. Check your Azure subscription is active and enabled
3. Clear existing authentication:
   ```powershell
   Disconnect-AzAccount
   Clear-AzContext -Force
   ```
4. Restart the server and authenticate again

### Port Already in Use

**Problem**: Error: "Address already in use" on port 8080

**Solution**:
```powershell
# Windows - Find and kill process on port 8080
Get-Process -Name pwsh | Where-Object {$_.Path -like "*Start-AVDInventoryServer*"} | Stop-Process

# macOS/Linux
pkill -f "Start-AVDInventoryServer.ps1"

# Or use a different port
.\Start-AVDInventoryServer.ps1 -Port 8081
```

### Inventory Collection Timeout

**Problem**: "Request timed out after 10 minutes"

**Cause**: Very large environment with 1000+ resources

**Solution**:
1. Check the PowerShell console to see which subscription is slow
2. Consider excluding certain subscriptions
3. Check Azure service health for performance issues
4. Contact support if specific resources are taking excessive time

### No Data Displayed

**Problem**: Dashboard loads but shows no resources

**Checklist**:
- ✅ Authenticated? Check the banner at top of page
- ✅ Permissions? Verify Reader role on resource groups
- ✅ AVD resources exist? Check Azure Portal
- ✅ Correct subscription? Verify subscription name in banner
- ✅ Browser console? Press F12 and check for JavaScript errors
- ✅ Server console? Check PowerShell window for collection errors

### Scaling Plan Times Show "N/A"

**Problem**: Scaling plan schedules don't display start times

**Solution**: This is a known issue with certain Azure PowerShell SDK versions. Update to latest:
```powershell
Update-Module Az.DesktopVirtualization -Force
```

## 📊 API Reference

The web server exposes the following REST endpoints:

| Method | Endpoint | Description | Response |
|--------|----------|-------------|----------|
| `GET` | `/` | Main dashboard HTML page | HTML document |
| `GET` | `/api/auth/status` | Check Azure authentication status | `{authenticated: boolean, context: object}` |
| `POST` | `/api/auth/login` | Initiate Azure device authentication | `{success: boolean, message: string}` |
| `GET` | `/api/inventory/data` | Retrieve complete AVD inventory | JSON inventory data (see schema) |
| `POST` | `/api/inventory/refresh` | Force refresh inventory from Azure | `{success: boolean, lastUpdate: string}` |
| `GET` | `/app.js` | Client JavaScript application | JavaScript code |
| `GET` | `/styles.css` | Dashboard stylesheet | CSS styles |

### Inventory Data Schema

```json
{
  "collectionTime": "2026-03-03T10:30:00Z",
  "summary": {
    "totalSubscriptions": 2,
    "totalHostPools": 5,
    "totalSessionHosts": 25,
    "totalWorkspaces": 3,
    "totalApplicationGroups": 8,
    "totalScalingPlans": 2,
    "totalVNets": 4,
    "totalComputeGalleries": 1
  },
  "explanation": {
    "overview": "...",
    "hostPools": "...",
    "sessionHosts": "..."
  },
  "subscriptions": [
    {
      "name": "Production",
      "id": "sub-id",
      "hostPools": [...],
      "sessionHosts": [...],
      "workspaces": [...],
      "applicationGroups": [...],
      "scalingPlans": [...],
      "virtualNetworks": [...],
      "computeGalleries": [...]
    }
  ]
}
```

## 🔒 Security & Best Practices

### Security Considerations
- ✅ **Localhost only**: Server binds to `localhost` by default (not exposed to network)
- ✅ **No credential storage**: Azure credentials managed entirely by Azure PowerShell SDK
- ✅ **Device code auth**: Secure OAuth flow with Azure AD
- ✅ **Read-only access**: No modification capabilities - inventory only
- ✅ **Session-based**: Authentication tied to PowerShell session lifetime
- ✅ **HTTPS compatible**: Can be proxied through HTTPS reverse proxy if needed

### Recommended Access Roles
- **Minimum**: `Reader` on target resource groups
- **Recommended**: `Reader` at subscription level for complete inventory
- **Not required**: Contributor, Owner, or any write permissions

### Production Deployment
For production use beyond localhost:

1. **Use HTTPS**: Place behind reverse proxy (nginx, IIS, Azure App Gateway)
2. **Add authentication**: Integrate with Azure AD, SAML, or other IdP
3. **Enable logging**: Add application insights or log analytics
4. **Set up monitoring**: Health checks and availability monitoring
5. **Restrict access**: Limit IP ranges via firewall rules

## 📝 File Structure

```
azurevirtualdesktop-inventory/
├── Start-AVDInventoryServer.ps1  # Main web server (HTTP listener, routing)
├── Get-AVDInventory.ps1          # Inventory collection module (Azure queries)
├── index.html                    # Dashboard UI (structure)
├── styles.css                    # Dark theme styling (colors, layouts)
├── app.js                        # Client application (logic, PDF export)
├── test.html                     # Diagnostic test page
├── start.sh                      # Linux/macOS launcher script
└── README.md                     # This documentation
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

**Areas for contribution:**
- Multi-language support
- Additional PDF export options
- Custom filters and search
- Performance optimizations for 1000+ session hosts
- Additional data visualizations
- Export to Excel/CSV formats
- Connection diagram implementation

## 📄 License

This project is provided as-is under the MIT License for monitoring and documenting Azure Virtual Desktop environments.

## 👨‍💻 Author

**Alex ter Neuzen**  
Cloud Solutions Architect | Azure Virtual Desktop Specialist

🌐 Website: [www.gettothe.cloud](https://www.gettothe.cloud)  
💼 LinkedIn: Connect for more Azure content  
📝 Blog: AVD best practices, tips, and tutorials

## ✨ Credits & Acknowledgments

Built with:
- **PowerShell 7+** - Cross-platform automation framework
- **Azure PowerShell SDK** - Azure resource management
- **vis-network** ([visjs.org](https://visjs.org/)) - Network diagrams
- **jsPDF** ([github.com/parallax/jsPDF](https://github.com/parallax/jsPDF)) - PDF generation
- **jsPDF-AutoTable** - Table formatting in PDFs

Special thanks to the Azure Virtual Desktop community for feedback and feature requests.

---

**Need help?** Check the troubleshooting section or visit [www.gettothe.cloud](https://www.gettothe.cloud) for more resources.

**Found a bug?** Please report it with details about your environment and steps to reproduce.
