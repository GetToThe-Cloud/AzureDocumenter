# 📘 AzureDocumenter

> Professional documentation and inventory tools for Azure environments

[![Website](https://img.shields.io/badge/Website-azuredocumenter.com-0078D4?style=for-the-badge&logo=microsoft-azure)](https://www.azuredocumenter.com)
[![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?style=for-the-badge&logo=powershell)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

## 🌐 Visit Our Website

For complete documentation, examples, and live demos, visit:
**[https://www.azuredocumenter.com](https://www.azuredocumenter.com)**

## 📖 Overview

AzureDocumenter is a collection of professional-grade documentation and inventory tools designed to help organizations maintain comprehensive visibility and documentation of their Azure environments. Built with PowerShell and modern web technologies, these tools provide real-time dashboards, automated assessments, and professional PDF reports.

**Created by Alex ter Neuzen** for [GetToTheCloud](https://www.gettothe.cloud)

## 🗂️ Repository Structure

### 📁 Root Files
- **`index.html`** - Main landing page for AzureDocumenter
- **`styles.css`** - Global stylesheet for the landing page
- **`LICENSE`** - MIT License information
- **`README.md`** - This file

### 📁 azurelandingzone-inventory/

Complete inventory and assessment tool for Azure Landing Zone environments.

**Key Features:**
- 🏗️ Comprehensive infrastructure inventory (Management Groups, Subscriptions, Policies, RBAC)
- 📊 Networking components (VNets, Peerings, Firewalls, NSGs, Private Endpoints)
- 🎯 CAF (Cloud Adoption Framework) compliance assessment
- 📈 WAF (Well-Architected Framework) scoring across 5 pillars
- 📄 Professional PDF reports with charts and recommendations
- 🌐 Real-time web dashboard

**Files:**
- `Get-AzureLandingZoneInventory.ps1` - PowerShell script to collect inventory data
- `Start-AzureLandingZoneServer.ps1` - Local web server launcher
- `index.html` - Web-based dashboard
- `app.js` - Frontend logic and data processing
- `styles.css` - Dashboard styling
- `start.cmd` / `start.sh` - Quick start scripts for Windows/Unix
- `README.md` - Detailed documentation

**Quick Start:**
```bash
cd azurelandingzone-inventory
./start.sh          # macOS/Linux
# or
start.cmd           # Windows
```

### 📁 azurevirtualdesktop-inventory/

Production-ready dashboard for Azure Virtual Desktop (AVD) infrastructure documentation.

**Key Features:**
- 🖥️ Complete AVD inventory (Host Pools, Session Hosts, Workspaces, Application Groups)
- 📊 Real-time status monitoring with color-coded indicators
- 🔄 Scaling plans and automated capacity management tracking
- 🎨 Modern dark-themed web interface
- 📄 Professional PDF exports for audits and documentation
- 🔐 Secure Azure authentication with multi-subscription support

**Files:**
- `Get-AVDInventory.ps1` - PowerShell script to collect AVD data
- `Start-AVDInventoryServer.ps1` - Local web server launcher
- `index.html` - AVD dashboard interface
- `app.js` - Frontend logic and visualization
- `styles.css` - Dashboard styling
- `start.sh` - Quick start script
- `test.html` - Testing and development page
- `README.md` - Detailed documentation

**Quick Start:**
```bash
cd azurevirtualdesktop-inventory
./start.sh          # macOS/Linux
```

## 🚀 Getting Started

### Prerequisites

- **PowerShell 7+** ([Download](https://github.com/PowerShell/PowerShell))
- **Azure PowerShell Module** (`Az` module)
- **Azure Account** with appropriate read permissions
- **Modern web browser** (Chrome, Edge, Firefox, Safari)

### Installation

1. **Clone or download this repository:**
   ```bash
   git clone <repository-url>
   cd AzureDocumenter
   ```

2. **Install Azure PowerShell (if not already installed):**
   ```powershell
   Install-Module -Name Az -Repository PSGallery -Force -AllowClobber
   ```

3. **Choose your tool:**
   - Navigate to `azurelandingzone-inventory/` for Landing Zone documentation
   - Navigate to `azurevirtualdesktop-inventory/` for AVD documentation

4. **Run the launcher:**
   - Execute `start.sh` (macOS/Linux) or `start.cmd` (Windows)
   - Your browser will open automatically to the dashboard
   - Follow the authentication prompts to connect to Azure

## 📚 Documentation

Each tool includes comprehensive documentation in its respective README.md file:

- **[Azure Landing Zone Inventory Documentation](azurelandingzone-inventory/README.md)**
  - Complete feature list
  - Assessment methodology
  - PDF report generation
  - Troubleshooting guide

- **[Azure Virtual Desktop Inventory Documentation](azurevirtualdesktop-inventory/README.md)**
  - Dashboard features
  - Component tracking
  - Export capabilities
  - Best practices

## 🌟 Use Cases

### Azure Landing Zone Inventory
- **Cloud Governance Teams**: Monitor CAF compliance and policy adherence
- **Security Teams**: Audit RBAC, NSGs, and network security configurations
- **Network Teams**: Document VNet topology, peerings, and connectivity
- **Compliance Officers**: Generate comprehensive infrastructure reports
- **Cloud Architects**: Assess Well-Architected Framework alignment

### Azure Virtual Desktop Inventory
- **AVD Administrators**: Monitor session host health and availability
- **IT Operations**: Track scaling plans and capacity management
- **Compliance Teams**: Document AVD infrastructure for audits
- **Service Desk**: Quick reference for troubleshooting sessions
- **Management**: Executive reporting on AVD estate

## 🔐 Security & Permissions

Both tools use **read-only access** to Azure resources:

- Secure Azure device authentication flow
- No credentials stored locally
- No modifications made to your environment
- Session-based authentication managed by Azure SDK
- Multi-subscription support with automatic discovery

**Required Azure RBAC Permissions:**
- `Reader` role at subscription or management group level
- Additional `Reader and Data Access` for storage accounts (if applicable)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Alex ter Neuzen**
- Website: [GetToTheCloud](https://www.gettothe.cloud)
- Project Site: [AzureDocumenter.com](https://www.azuredocumenter.com)

## 🙏 Acknowledgments

- Built with PowerShell and modern web technologies
- Inspired by Microsoft Cloud Adoption Framework (CAF)
- Aligned with Azure Well-Architected Framework (WAF)
- Designed for Azure Landing Zone and AVD best practices

---

**For more information, visit [https://www.azuredocumenter.com](https://www.azuredocumenter.com)**
