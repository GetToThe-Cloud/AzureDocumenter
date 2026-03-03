# Azure Virtual Desktop Inventory Dashboard

A comprehensive web-based dashboard for monitoring and managing your Azure Virtual Desktop (AVD) infrastructure in real-time.

## 🌟 Features

- **Live Inventory View**: Real-time monitoring of your AVD environment
- **Azure Authentication**: Automatic Azure connection check with device authentication support
- **Interactive Navigation**: Category-based navigation for easy access to different resource types
- **Visual Connection Diagram**: Interactive diagram showing relationships between AVD resources
- **PDF Export**: Export complete inventory setup to PDF format
- **Detailed Reporting**: Comprehensive information about:
  - Host Pools
  - Session Hosts
  - Workspaces
  - Application Groups
  - Published Applications
  - Session status and health

## 📋 Prerequisites

- **PowerShell 7+** ([Download](https://github.com/PowerShell/PowerShell))
- **Azure PowerShell Modules**:
  - Az.Accounts
  - Az.DesktopVirtualization
  - Az.Resources
  - Az.Network
  - Az.Compute
- **Azure Subscription** with AVD resources
- **Permissions**: Read access to AVD resources in your Azure subscription(s)

## 🚀 Quick Start

### 1. Installation

The required Azure PowerShell modules will be installed automatically on first run if not present.

### 2. Starting the Server

#### On macOS/Linux:
```bash
chmod +x start.sh
./start.sh
```

#### On Windows (PowerShell):
```powershell
.\Start-AVDInventoryServer.ps1 -Port 8080
```

### 3. Access the Dashboard

Open your web browser and navigate to:
```
http://localhost:8080
```

### 4. Authentication

If not already authenticated:
1. Click "Sign in to Azure" button
2. Follow the device authentication prompts in the server console
3. Complete authentication in your browser
4. Return to the dashboard - it will automatically refresh

## 📖 Usage

### Navigation

The dashboard includes the following sections:

- **📊 Overview**: Summary statistics and quick insights
- **🏊 Host Pools**: Detailed information about AVD host pools
- **💻 Session Hosts**: Status and health of individual session hosts
- **📁 Workspaces**: Workspace configurations
- **📦 Application Groups**: Application group details and published apps
- **🔗 Connection Diagram**: Visual representation of resource relationships

### Refreshing Data

Click the **Refresh** button in the header to update the inventory data from Azure.

### Exporting to PDF

Click the **Export PDF** button to generate a comprehensive PDF report of your AVD infrastructure.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│         Web Browser (Client)                │
│  ┌────────────────────────────────────────┐ │
│  │  HTML + CSS + JavaScript (app.js)     │ │
│  │  • Navigation                          │ │
│  │  • Data visualization                  │ │
│  │  • PDF export                          │ │
│  │  • Network diagram (vis.js)            │ │
│  └────────────────────────────────────────┘ │
└─────────────────┬───────────────────────────┘
                  │ HTTP REST API
┌─────────────────▼───────────────────────────┐
│   PowerShell Web Server                     │
│  ┌────────────────────────────────────────┐ │
│  │  Start-AVDInventoryServer.ps1          │ │
│  │  • HTTP listener                       │ │
│  │  • Route handling                      │ │
│  │  • Authentication management           │ │
│  └────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────┐ │
│  │  Get-AVDInventory.ps1                  │ │
│  │  • Inventory collection                │ │
│  │  • Diagram generation                  │ │
│  └────────────────────────────────────────┘ │
└─────────────────┬───────────────────────────┘
                  │ Azure PowerShell SDK
┌─────────────────▼───────────────────────────┐
│           Azure Cloud                       │
│  • AVD Host Pools                           │
│  • Session Hosts                            │
│  • Workspaces                               │
│  • Application Groups                       │
└─────────────────────────────────────────────┘
```

## 🔧 Configuration

### Changing the Port

To use a different port:

```bash
./start.sh
# Edit the script to change port, or:
pwsh -File Start-AVDInventoryServer.ps1 -Port 3000
```

### Auto-Refresh Interval

The dashboard automatically checks authentication status and can be configured to auto-refresh. Edit `app.js`:

```javascript
// Auto-refresh every 5 minutes (300000 ms)
setInterval(checkAuthStatus, 300000);
```

## 📊 API Endpoints

The server exposes the following REST API endpoints:

- `GET /` - Main dashboard page
- `GET /api/auth/status` - Check Azure authentication status
- `POST /api/auth/login` - Initiate Azure login
- `GET /api/inventory/data` - Retrieve AVD inventory data
- `POST /api/inventory/refresh` - Force refresh inventory data
- `GET /api/diagram/connections` - Get connection diagram data

## 🛠️ Troubleshooting

### Module Installation Errors

If Azure modules fail to install automatically:

```powershell
Install-Module -Name Az.Accounts -Force -Scope CurrentUser
Install-Module -Name Az.DesktopVirtualization -Force -Scope CurrentUser
Install-Module -Name Az.Resources -Force -Scope CurrentUser
```

### Authentication Issues

If authentication fails:
1. Ensure you have appropriate permissions in Azure
2. Check that your subscription is enabled
3. Try clearing your Azure context:
   ```powershell
   Clear-AzContext -Force
   ```

### Port Already in Use

If port 8080 is already in use:
```bash
# Kill existing process
pkill -f "Start-AVDInventoryServer.ps1"

# Or use a different port
pwsh -File Start-AVDInventoryServer.ps1 -Port 8081
```

### No Data Showing

1. Verify you are authenticated (check the banner at top of page)
2. Ensure your account has read permissions for AVD resources
3. Check browser console for errors (F12 → Console)
4. Check server console for error messages

## 🔒 Security Considerations

- The server runs on localhost by default (not exposed to network)
- Azure credentials are managed through Azure PowerShell SDK
- No credentials are stored in the application
- Authentication uses Azure device code flow
- All API calls require active Azure authentication

## 📝 File Structure

```
azurevirtualdesktop-inventory/
├── Start-AVDInventoryServer.ps1  # Main web server
├── Get-AVDInventory.ps1          # Inventory collection module
├── index.html                    # Main HTML page
├── styles.css                    # Styling
├── app.js                        # Client-side JavaScript
├── start.sh                      # Linux/macOS startup script
└── README.md                     # This file
```

## 🤝 Contributing

Feel free to submit issues or pull requests to improve this dashboard.

## 📄 License

This project is provided as-is for monitoring Azure Virtual Desktop environments.

## ✨ Credits

- Built with PowerShell 7+
- Visualization using [vis.js](https://visjs.org/)
- PDF generation using [jsPDF](https://github.com/parallax/jsPDF)
- Uses Azure PowerShell SDK

---

**Note**: This tool is designed for monitoring and reporting purposes. It does not make changes to your Azure environment.
