# Azure Local Inventory Dashboard

A web-based inventory dashboard for Azure Local (Azure Stack HCI) environments. This tool provides a comprehensive view of your Azure Local infrastructure including clusters, nodes, networks, images, and virtual machines.

## Features

- 🔷 **Clusters**: View all Azure Local clusters with status, versions, and node counts
- 🖥️ **Nodes**: Monitor individual nodes with hardware and software details
- 📦 **Agent & Software Versions**: Track Azure Arc agent and OS versions across infrastructure
- 🌐 **Logical Networks**: View network configurations and subnets
- 💿 **Images**: List available VM images and templates
- 💻 **Virtual Machines**: View all VMs with their cluster/node placement and resource allocation
- 📊 **Visual Analytics**: Charts showing status distributions and VM placement
- 🔍 **Search & Filter**: Quick search across all resource types
- 📄 **PDF Export**: Generate reports for documentation

## Prerequisites

- **PowerShell 7.0 or higher** (Required - the script will check and exit if not met)
  - Download from: https://aka.ms/powershell
- Azure PowerShell modules (auto-installed if missing):
  - Az.Accounts
  - Az.Resources
  - Az.StackHCI
  - Az.ConnectedMachine
  - Az.ArcGateway
- Azure subscription with Azure Local (Azure Stack HCI) resources
- Appropriate Azure RBAC permissions to read Azure Local resources

## Installation

1. Install PowerShell 7+ if not already installed:
   ```bash
   # macOS
   brew install --cask powershell
   
   # Windows
   winget install Microsoft.PowerShell
   ```

2. Install required Azure modules (these will be auto-installed on first run):
   ```powershell
   Install-Module -Name Az.Accounts, Az.Resources, Az.StackHCI, Az.ConnectedMachine -Force
   ```

## Usage

### Starting the Server

**Option 1: Using the shell script (macOS/Linux)**
```bash
./start.sh
```

**Option 2: Using PowerShell directly**
```powershell
pwsh Start-AzureLocalServer.ps1
```

**Option 3: Custom port**
```powershell
pwsh Start-AzureLocalServer.ps1 -Port 8082
```

### Accessing the Dashboard

1. The server will start on `http://localhost:8081` (default port)
2. Open your web browser and navigate to the URL
3. You'll be prompted to authenticate with Azure using device code authentication
4. Follow the prompts in your terminal or browser
5. Once authenticated, the dashboard will automatically load your Azure Local inventory

### Navigation

- **Overview**: Summary statistics and distribution charts
- **Clusters**: Detailed cluster information
- **Nodes**: Individual node details with status and versions
- **Versions**: Agent and software version tracking
- **Networks**: Logical network configurations
- **Images**: Available VM images and templates
- **Virtual Machines**: Complete VM inventory with placement details

### Features

- **Refresh**: Click the refresh button to reload inventory data
- **Search**: Use the search boxes to filter resources
- **Filter VMs by Cluster**: Select a specific cluster to view its VMs
- **Export PDF**: Generate a PDF report of the inventory

## Architecture

The solution consists of three main components:

1. **Get-AzureLocalInventory.ps1**: PowerShell module that collects inventory data from Azure
   - Queries Azure Local clusters and their properties
   - Retrieves Arc-enabled servers (nodes) information
   - Collects logical networks, images, and VM data
   - Aggregates statistics and relationships

2. **Start-AzureLocalServer.ps1**: Web server that serves the dashboard
   - HTTP listener on localhost
   - API endpoints for authentication and data retrieval
   - Automatic authentication handling
   - JSON API for inventory data

3. **Frontend (index.html, app.js, styles.css)**: Web interface
   - Responsive single-page application
   - Dynamic data rendering
   - Search and filter capabilities
   - PDF export functionality

## API Endpoints

- `GET /` - Main dashboard page
- `GET /api/auth/status` - Check authentication status
- `POST /api/auth/login` - Initiate Azure login
- `GET /api/inventory/data` - Retrieve inventory data
- `POST /api/inventory/refresh` - Refresh inventory data

## Troubleshooting

**Authentication Issues**
- Ensure you have the required Azure permissions
- Try clearing your Azure context: `Clear-AzContext -Force`
- Re-authenticate using: `Connect-AzAccount`

**No Data Showing**
- Verify you have Azure Local resources in your subscription
- Check that you're connected to the correct subscription
- Ensure your account has Reader role or higher on the resources

**Module Installation Errors**
- Run PowerShell as administrator/sudo
- Manually install modules: `Install-Module Az.StackHCI -Force`

**Port Already in Use**
- Stop any other services using port 8081
- Or start the server on a different port: `-Port 8082`

## Security Notes

- The server runs on localhost only and is not accessible from external networks
- Azure credentials are handled through the Az PowerShell module
- No credentials are stored or transmitted by the application
- All data is retrieved in real-time from your Azure subscription

## Version

Current Version: 1.0.0

## License

See parent repository LICENSE file.

## Support

For issues or questions related to:
- Azure Local: [Azure Stack HCI Documentation](https://learn.microsoft.com/azure-stack/hci/)
- Azure PowerShell: [Az PowerShell Documentation](https://learn.microsoft.com/powershell/azure/)

## Related Tools

- [Azure Landing Zone Inventory](../azurelandingzone-inventory/)
- [Azure Virtual Desktop Inventory](../azurevirtualdesktop-inventory/)
