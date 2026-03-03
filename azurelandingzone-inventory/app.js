// Global state
let inventoryData = null;
let isAuthenticated = false;

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    checkAuthStatus();
});

// Check authentication status
async function checkAuthStatus() {
    try {
        const response = await fetch('/api/auth/status');
        const data = await response.json();
        
        isAuthenticated = data.authenticated;
        updateAuthUI(data);
        
        if (isAuthenticated) {
            loadInventory();
        } else {
            showAuthRequired();
        }
    } catch (error) {
        console.error('Error checking auth status:', error);
        showAuthRequired();
    }
}

// Update authentication UI
function updateAuthUI(data) {
    const authStatus = document.getElementById('authStatus');
    
    if (data.authenticated && data.context) {
        authStatus.className = 'auth-status authenticated';
        authStatus.innerHTML = `
            ✓ Authenticated as <strong>${data.context.account}</strong><br>
            Tenant: ${data.context.tenant}
        `;
    } else {
        authStatus.className = 'auth-status not-authenticated';
        authStatus.innerHTML = '⚠️ Not authenticated with Azure';
    }
}

// Show authentication required screen
function showAuthRequired() {
    document.getElementById('authRequired').style.display = 'flex';
    document.querySelectorAll('.content-section').forEach(section => {
        if (section.id !== 'authRequired') {
            section.style.display = 'none';
        }
    });
}

// Authenticate with Azure
async function authenticateAzure() {
    const btn = event.target;
    btn.disabled = true;
    btn.innerHTML = '<span class="icon">⏳</span> Authenticating...';
    
    try {
        const response = await fetch('/api/auth/login', { method: 'POST' });
        const data = await response.json();
        
        if (data.success) {
            alert('Authentication successful! Please wait while we load your inventory...');
            location.reload();
        } else {
            alert('Authentication failed: ' + data.message);
            btn.disabled = false;
            btn.innerHTML = 'Sign in to Azure';
        }
    } catch (error) {
        alert('Authentication error: ' + error.message);
        btn.disabled = false;
        btn.innerHTML = 'Sign in to Azure';
    }
}

// Load inventory data
async function loadInventory() {
    try {
        showLoading();
        const response = await fetch('/api/inventory/data');
        
        if (response.status === 401) {
            showAuthRequired();
            return;
        }
        
        inventoryData = await response.json();
        
        if (inventoryData.error) {
            alert('Error loading inventory: ' + inventoryData.error);
            return;
        }
        
        updateLastUpdate();
        populateUI();
        hideAuthRequired();
    } catch (error) {
        console.error('Error loading inventory:', error);
        alert('Failed to load inventory: ' + error.message);
    }
}

// Refresh inventory
async function refreshInventory() {
    const btn = document.getElementById('refreshBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="icon">⏳</span> Refreshing...';
    
    try {
        await loadInventory();
        btn.innerHTML = '<span class="icon">✓</span> Refreshed!';
        setTimeout(() => {
            btn.innerHTML = '<span class="icon">🔄</span> Refresh';
            btn.disabled = false;
        }, 2000);
    } catch (error) {
        btn.innerHTML = '<span class="icon">🔄</span> Refresh';
        btn.disabled = false;
    }
}

// Update last update timestamp
function updateLastUpdate() {
    if (inventoryData && inventoryData.collectionTime) {
        const date = new Date(inventoryData.collectionTime);
        document.getElementById('lastUpdate').textContent = 
            `Last updated: ${date.toLocaleString()}`;
    }
}

// Show loading state
function showLoading() {
    document.querySelectorAll('.content-section tbody').forEach(tbody => {
        tbody.innerHTML = '<tr><td colspan="10" class="loading">Loading</td></tr>';
    });
}

// Hide authentication required screen
function hideAuthRequired() {
    document.getElementById('authRequired').style.display = 'none';
}

// Populate UI with inventory data
function populateUI() {
    if (!inventoryData) return;
    
    // Update explanations
    if (inventoryData.explanations) {
        document.getElementById('overviewExplanation').textContent = 
            inventoryData.explanations.overview || 'No description available';
        document.getElementById('managementGroupsExplanation').textContent = 
            inventoryData.explanations.managementGroups || 'No description available';
        document.getElementById('subscriptionsExplanation').textContent = 
            inventoryData.explanations.subscriptions || 'No description available';
        document.getElementById('policiesExplanation').textContent = 
            inventoryData.explanations.policies || 'No description available';
        document.getElementById('roleAssignmentsExplanation').textContent = 
            inventoryData.explanations.roleAssignments || 'No description available';
        document.getElementById('networkingExplanation').textContent = 
            inventoryData.explanations.networking || 'No description available';
        document.getElementById('governanceExplanation').textContent = 
            inventoryData.explanations.governance || 'No description available';
    }
    
    // Update summary cards
    const summary = inventoryData.summary || {};
    document.getElementById('totalManagementGroups').textContent = summary.totalManagementGroups || 0;
    document.getElementById('totalSubscriptions').textContent = summary.totalSubscriptions || 0;
    document.getElementById('totalPolicyDefinitions').textContent = summary.totalPolicyDefinitions || 0;
    document.getElementById('totalPolicyInitiatives').textContent = summary.totalPolicyInitiatives || 0;
    document.getElementById('totalPolicyAssignments').textContent = summary.totalPolicyAssignments || 0;
    document.getElementById('totalRoleAssignments').textContent = summary.totalRoleAssignments || 0;
    document.getElementById('totalVNets').textContent = summary.totalVNets || 0;
    document.getElementById('totalPeerings').textContent = summary.totalPeerings || 0;
    document.getElementById('totalVMs').textContent = summary.totalVMs || 0;
    document.getElementById('totalBudgets').textContent = summary.totalBudgets || 0;
    document.getElementById('totalLocks').textContent = summary.totalLocks || 0;
    
    // Populate best practices assessment
    populateBestPractices();
    
    // Populate tables
    populateManagementGroups();
    populateSubscriptions();
    populatePolicies();
    populateRoleAssignments();
    populateNetworking();
    populateVirtualMachines();
    populateGovernance();
    createNetworkDiagram();
}

// Populate Management Groups table
function populateManagementGroups() {
    const tbody = document.getElementById('managementgroupsTableBody');
    const mgs = inventoryData.managementGroups || [];
    
    if (mgs.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5">No management groups found</td></tr>';
        return;
    }
    
    tbody.innerHTML = mgs.map(mg => `
        <tr>
            <td><strong>${mg.displayName || 'N/A'}</strong></td>
            <td><code>${mg.name || 'N/A'}</code></td>
            <td>${mg.parentName || 'N/A'}</td>
            <td>${mg.children ? mg.children.length : 0}</td>
            <td>${mg.type || 'N/A'}</td>
        </tr>
    `).join('');
}

// Populate Subscriptions table
function populateSubscriptions() {
    const tbody = document.getElementById('subscriptionsTableBody');
    const subs = inventoryData.subscriptions || [];
    
    if (subs.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4">No subscriptions found</td></tr>';
        return;
    }
    
    tbody.innerHTML = subs.map(sub => `
        <tr>
            <td><strong>${sub.name || 'N/A'}</strong></td>
            <td><code>${sub.subscriptionId || 'N/A'}</code></td>
            <td><span class="badge ${sub.state === 'Enabled' ? 'badge-success' : 'badge-warning'}">${sub.state || 'Unknown'}</span></td>
            <td>${formatTags(sub.tags)}</td>
        </tr>
    `).join('');
}

// Populate Policies tables
function populatePolicies() {
    const policies = inventoryData.policies || {};
    
    // Policy Definitions
    const defTbody = document.getElementById('policyDefinitionsTableBody');
    const defs = policies.definitions || [];
    
    if (defs.length === 0) {
        defTbody.innerHTML = '<tr><td colspan="4">No policy definitions found</td></tr>';
    } else {
        defTbody.innerHTML = defs.map(policy => {
            const displayName = policy.displayName || policy.name || 'Unnamed Policy';
            const policyType = policy.policyType || 'Unknown';
            const mode = policy.mode || 'All';
            const description = policy.description || 'No description available';
            
            return `
                <tr>
                    <td><strong>${displayName}</strong></td>
                    <td><span class="badge ${policyType === 'Custom' ? 'badge-primary' : 'badge-secondary'}">${policyType}</span></td>
                    <td>${mode}</td>
                    <td>${truncate(description, 100)}</td>
                </tr>
            `;
        }).join('');
    }
    
    // Policy Initiatives
    const initTbody = document.getElementById('policyInitiativesTableBody');
    const inits = policies.initiatives || [];
    
    if (inits.length === 0) {
        initTbody.innerHTML = '<tr><td colspan="4">No policy initiatives found</td></tr>';
    } else {
        initTbody.innerHTML = inits.map(initiative => {
            const displayName = initiative.displayName || initiative.name || 'Unnamed Initiative';
            const policyType = initiative.policyType || 'Unknown';
            const policyCount = initiative.policyDefinitions ? initiative.policyDefinitions.length : 0;
            const description = initiative.description || 'No description available';
            
            return `
                <tr>
                    <td><strong>${displayName}</strong></td>
                    <td><span class="badge ${policyType === 'Custom' ? 'badge-primary' : 'badge-secondary'}">${policyType}</span></td>
                    <td>${policyCount}</td>
                    <td>${truncate(description, 100)}</td>
                </tr>
            `;
        }).join('');
    }
    
    // Policy Assignments
    const assignTbody = document.getElementById('policyAssignmentsTableBody');
    const assigns = policies.assignments || [];
    
    if (assigns.length === 0) {
        assignTbody.innerHTML = '<tr><td colspan="4">No policy assignments found</td></tr>';
    } else {
        assignTbody.innerHTML = assigns.map(assignment => {
            const displayName = assignment.displayName || assignment.name || 'Unnamed Assignment';
            const enforcementMode = assignment.enforcementMode || 'Default';
            const scope = assignment.scope || 'Unknown scope';
            const description = assignment.description || `Policy assignment: ${assignment.policyName || 'Unknown'}`;
            
            return `
                <tr>
                    <td><strong>${displayName}</strong></td>
                    <td><span class="badge ${enforcementMode === 'Default' ? 'badge-success' : 'badge-warning'}">${enforcementMode}</span></td>
                    <td><small>${truncate(scope, 60)}</small></td>
                    <td>${truncate(description, 80)}</td>
                </tr>
            `;
        }).join('');
    }
}

// Populate Role Assignments table
function populateRoleAssignments() {
    const tbody = document.getElementById('roleassignmentsTableBody');
    const roles = inventoryData.roleAssignments || [];
    
    if (roles.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4">No role assignments found</td></tr>';
        return;
    }
    
    tbody.innerHTML = roles.map(role => `
        <tr>
            <td><strong>${role.displayName || role.signInName || 'N/A'}</strong></td>
            <td>${role.roleDefinitionName || 'N/A'}</td>
            <td><small>${truncate(role.scope, 60) || 'N/A'}</small></td>
            <td>${role.objectType || 'N/A'}</td>
        </tr>
    `).join('');
}

// Populate Networking tables
function populateNetworking() {
    const networking = inventoryData.networking || {};
    
    // Virtual Networks
    const vnetsTbody = document.getElementById('vnetsTableBody');
    const vnets = networking.vnets || [];
    
    if (vnets.length === 0) {
        vnetsTbody.innerHTML = '<tr><td colspan="6">No virtual networks found</td></tr>';
    } else {
        vnetsTbody.innerHTML = vnets.map(vnet => `
            <tr>
                <td><strong>${vnet.name || 'N/A'}</strong></td>
                <td>${vnet.resourceGroup || 'N/A'}</td>
                <td>${vnet.location || 'N/A'}</td>
                <td><code>${vnet.addressSpace ? vnet.addressSpace.join(', ') : 'N/A'}</code></td>
                <td>${vnet.subnets ? vnet.subnets.length : 0} subnets</td>
                <td><small>${vnet.subscription || 'N/A'}</small></td>
            </tr>
        `).join('');
    }
    
    // VNet Peerings
    const peerTbody = document.getElementById('peeringsTableBody');
    const peerings = networking.peerings || [];
    
    if (peerings.length === 0) {
        peerTbody.innerHTML = '<tr><td colspan="9">No VNet peerings found</td></tr>';
    } else {
        peerTbody.innerHTML = peerings.map((peer, idx) => `
            <tr onclick="showResourceDetails('peering', ${idx})" data-type="peering" data-index="${idx}">
                <td><strong>${peer.name || 'N/A'}</strong></td>
                <td>${peer.sourceVNet || 'N/A'}</td>
                <td>${peer.remoteVNet || 'N/A'}</td>
                <td><span class="status-badge ${peer.peeringState === 'Connected' ? 'status-connected' : 'status-disconnected'}">${peer.peeringState || 'Unknown'}</span></td>
                <td>${peer.allowVirtualNetworkAccess ? '✓' : '✗'}</td>
                <td>${peer.allowForwardedTraffic ? '✓' : '✗'}</td>
                <td>${peer.allowGatewayTransit ? '✓' : '✗'}</td>
                <td>${peer.useRemoteGateways ? '✓' : '✗'}</td>
                <td>${peer.provisioningState || 'N/A'}</td>
            </tr>
        `).join('');
    }
    
    // VPN Gateways
    const vpnTbody = document.getElementById('vpnGatewaysTableBody');
    const vpns = networking.vpnGateways || [];
    
    if (vpns.length === 0) {
        vpnTbody.innerHTML = '<tr><td colspan="6">No VPN gateways found</td></tr>';
    } else {
        vpnTbody.innerHTML = vpns.map(vpn => `
            <tr>
                <td><strong>${vpn.name || 'N/A'}</strong></td>
                <td>${vpn.resourceGroup || 'N/A'}</td>
                <td>${vpn.location || 'N/A'}</td>
                <td>${vpn.gatewayType || 'N/A'}</td>
                <td>${vpn.sku || 'N/A'}</td>
                <td><small>${vpn.subscription || 'N/A'}</small></td>
            </tr>
        `).join('');
    }
    
    // Firewalls
    const fwTbody = document.getElementById('firewallsTableBody');
    const firewalls = networking.firewalls || [];
    
    if (firewalls.length === 0) {
        fwTbody.innerHTML = '<tr><td colspan="6">No Azure Firewalls found</td></tr>';
    } else {
        fwTbody.innerHTML = firewalls.map(fw => `
            <tr>
                <td><strong>${fw.name || 'N/A'}</strong></td>
                <td>${fw.resourceGroup || 'N/A'}</td>
                <td>${fw.location || 'N/A'}</td>
                <td>${fw.tier || 'N/A'}</td>
                <td>${fw.threatIntelMode || 'N/A'}</td>
                <td><small>${fw.subscription || 'N/A'}</small></td>
            </tr>
        `).join('');
    }
    
    // NSGs
    const nsgTbody = document.getElementById('nsgsTableBody');
    const nsgs = networking.networkSecurityGroups || [];
    
    if (nsgs.length === 0) {
        nsgTbody.innerHTML = '<tr><td colspan="5">No network security groups found</td></tr>';
    } else {
        nsgTbody.innerHTML = nsgs.map(nsg => `
            <tr>
                <td><strong>${nsg.name || 'N/A'}</strong></td>
                <td>${nsg.resourceGroup || 'N/A'}</td>
                <td>${nsg.location || 'N/A'}</td>
                <td>${nsg.securityRulesCount || 0} rules</td>
                <td><small>${nsg.subscription || 'N/A'}</small></td>
            </tr>
        `).join('');
    }
}

// Populate Governance tables
function populateGovernance() {
    const governance = inventoryData.governance || {};
    
    // Budgets
    const budgetTbody = document.getElementById('budgetsTableBody');
    const budgets = governance.budgets || [];
    
    if (budgets.length === 0) {
        budgetTbody.innerHTML = '<tr><td colspan="5">No budgets found</td></tr>';
    } else {
        budgetTbody.innerHTML = budgets.map(budget => `
            <tr>
                <td><strong>${budget.name || 'N/A'}</strong></td>
                <td>$${budget.amount || 0}</td>
                <td>${budget.timeGrain || 'N/A'}</td>
                <td>$${budget.currentSpend || 0}</td>
                <td><small>${budget.subscription || 'N/A'}</small></td>
            </tr>
        `).join('');
    }
    
    // Locks
    const lockTbody = document.getElementById('locksTableBody');
    const locks = governance.locks || [];
    
    if (locks.length === 0) {
        lockTbody.innerHTML = '<tr><td colspan="5">No resource locks found</td></tr>';
    } else {
        lockTbody.innerHTML = locks.map(lock => `
            <tr>
                <td><strong>${lock.name || 'N/A'}</strong></td>
                <td>${lock.resourceName || 'N/A'}</td>
                <td><span class="badge ${lock.level === 'CanNotDelete' ? 'badge-danger' : 'badge-warning'}">${lock.level || 'N/A'}</span></td>
                <td>${lock.notes || 'No notes'}</td>
                <td><small>${lock.subscription || 'N/A'}</small></td>
            </tr>
        `).join('');
    }
    
    // Tags
    const tagsContainer = document.getElementById('tagsContent');
    const tags = governance.tags || {};
    
    if (Object.keys(tags).length === 0) {
        tagsContainer.innerHTML = '<p>No common tags found</p>';
    } else {
        tagsContainer.innerHTML = Object.keys(tags).map(key => `
            <div class="tag-group">
                <div class="tag-key">${key}</div>
                <div class="tag-values">
                    ${tags[key].map(value => `<span class="tag-value">${value}</span>`).join('')}
                </div>
            </div>
        `).join('');
    }
}

// Populate Best Practices Assessment
function populateBestPractices() {
    const bp = inventoryData.bestPractices;
    
    if (!bp) {
        return;
    }
    
    // Show the section
    document.getElementById('bestPracticesSection').style.display = 'block';
    
    // Overall score
    document.getElementById('overallScore').textContent = bp.overallPercentage + '%';
    document.getElementById('overallMessage').textContent = bp.overallMessage || '';
    
    // Category scores
    const categories = [
        'managementGroupHierarchy',
        'policyDrivenGovernance',
        'identityAndAccess',
        'networkTopology',
        'securityGovernance',
        'costManagement',
        'resourceOrganization'
    ];
    
    categories.forEach(categoryKey => {
        const cat = bp.categories[categoryKey];
        if (!cat) return;
        
        const cardElement = document.getElementById('bp-' + categoryKey);
        if (!cardElement) return;
        
        const percentage = Math.round((cat.score / cat.maxScore) * 100);
        const h3 = cardElement.querySelector('h3');
        const statusElement = cardElement.querySelector('.bp-status');
        
        if (h3) {
            h3.textContent = percentage + '%';
        }
        
        if (statusElement) {
            let statusText = '';
            let statusClass = '';
            
            switch(cat.status) {
                case 'excellent':
                    statusText = '✓ Excellent';
                    statusClass = 'bp-status-excellent';
                    break;
                case 'good':
                    statusText = '✓ Good';
                    statusClass = 'bp-status-good';
                    break;
                case 'fair':
                    statusText = '⚠ Fair';
                    statusClass = 'bp-status-fair';
                    break;
                case 'needs-improvement':
                    statusText = '✗ Needs Work';
                    statusClass = 'bp-status-needs-improvement';
                    break;
            }
            
            statusElement.textContent = statusText;
            statusElement.className = 'bp-status ' + statusClass;
        }
    });
    
    // Recommendations
    if (bp.recommendations && bp.recommendations.length > 0) {
        document.getElementById('bpRecommendations').style.display = 'block';
        const list = document.getElementById('recommendationsList');
        list.innerHTML = bp.recommendations.map(rec => `<li>${rec}</li>`).join('');
    } else {
        document.getElementById('bpRecommendations').style.display = 'none';
    }
}

// Show specific section
function showSection(sectionId) {
    // Update active nav link
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('data-section') === sectionId) {
            link.classList.add('active');
        }
    });
    
    // Show selected section
    document.querySelectorAll('.content-section').forEach(section => {
        section.classList.remove('active');
        if (section.id === sectionId) {
            section.classList.add('active');
        }
    });
}

// Export to PDF with detailed descriptions
async function exportToPDF() {
    const btn = document.getElementById('exportBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="icon">⏳</span> Generating PDF...';
    
    try {
        const { jsPDF } = window.jspdf;
        const pdf = new jsPDF('p', 'mm', 'a4');
        
        let yPos = 20;
        const lineHeight = 7;
        const pageHeight = 280;
        const margin = 20;
        const maxWidth = 170;
        
        // Helper function to add text with word wrap
        function addText(text, fontSize = 10, isBold = false) {
            pdf.setFontSize(fontSize);
            pdf.setFont(undefined, isBold ? 'bold' : 'normal');
            
            const lines = pdf.splitTextToSize(text, maxWidth);
            lines.forEach(line => {
                if (yPos > pageHeight) {
                    pdf.addPage();
                    yPos = 20;
                }
                pdf.text(line, margin, yPos);
                yPos += lineHeight;
            });
        }
        
        function addSection(title, text) {
            yPos += 5;
            addText(title, 14, true);
            yPos += 2;
            addText(text, 10, false);
            yPos += 5;
        }
        
        // Title
        pdf.setFontSize(20);
        pdf.setFont(undefined, 'bold');
        pdf.text('Azure Landing Zone Inventory', margin, yPos);
        yPos += 10;
        
        pdf.setFontSize(10);
        pdf.setFont(undefined, 'normal');
        pdf.text(`Generated: ${new Date().toLocaleString()}`, margin, yPos);
        yPos += 15;
        
        // Overview
        if (inventoryData.explanations) {
            addSection('Overview', inventoryData.explanations.overview);
            
            // Summary
            addText('Summary Statistics:', 12, true);
            yPos += 2;
            const summary = inventoryData.summary || {};
            addText(`• Management Groups: ${summary.totalManagementGroups || 0}`);
            addText(`• Subscriptions: ${summary.totalSubscriptions || 0}`);
            addText(`• Policy Definitions: ${summary.totalPolicyDefinitions || 0}`);
            addText(`• Policy Initiatives: ${summary.totalPolicyInitiatives || 0}`);
            addText(`• Policy Assignments: ${summary.totalPolicyAssignments || 0}`);
            addText(`• Role Assignments: ${summary.totalRoleAssignments || 0}`);
            addText(`• Virtual Networks: ${summary.totalVNets || 0}`);
            addText(`• VNet Peerings: ${summary.totalPeerings || 0}`);
            addText(`• Budgets: ${summary.totalBudgets || 0}`);
            addText(`• Resource Locks: ${summary.totalLocks || 0}`);
            yPos += 10;
            
            // Cloud Adoption Framework Best Practices Assessment
            if (inventoryData.bestPractices) {
                pdf.addPage();
                yPos = 20;
                
                pdf.setFontSize(16);
                pdf.setFont(undefined, 'bold');
                pdf.text('Cloud Adoption Framework Compliance Assessment', margin, yPos);
                yPos += 10;
                
                const bp = inventoryData.bestPractices;
                
                // Overall Score
                pdf.setFontSize(12);
                pdf.setFont(undefined, 'bold');
                pdf.text(`Overall Compliance Score: ${bp.overallPercentage}% (${bp.overallScore}/${bp.maxScore} points)`, margin, yPos);
                yPos += 7;
                
                pdf.setFontSize(10);
                pdf.setFont(undefined, 'normal');
                addText(bp.overallMessage);
                yPos += 5;
                
                addText('This assessment evaluates your Azure Landing Zone against Microsoft Cloud Adoption Framework design principles, including management group hierarchy, policy-driven governance, identity and access management, network topology, security, cost management, and resource organization.');
                yPos += 10;
                
                // Category Assessments
                pdf.setFontSize(12);
                pdf.setFont(undefined, 'bold');
                pdf.text('Assessment Categories', margin, yPos);
                yPos += 7;
                
                const categories = {
                    'managementGroupHierarchy': 'Management Group Hierarchy',
                    'policyDrivenGovernance': 'Policy-Driven Governance',
                    'identityAndAccess': 'Identity and Access Management',
                    'networkTopology': 'Network Topology and Connectivity',
                    'securityGovernance': 'Security and Governance',
                    'costManagement': 'Cost Management',
                    'resourceOrganization': 'Resource Organization'
                };
                
                for (const [key, title] of Object.entries(categories)) {
                    const cat = bp.categories[key];
                    if (!cat) continue;
                    
                    const catPercentage = Math.round((cat.score / cat.maxScore) * 100);
                    
                    // Category header
                    pdf.setFontSize(11);
                    pdf.setFont(undefined, 'bold');
                    const statusIcon = cat.status === 'excellent' ? '🟢' : 
                                      cat.status === 'good' ? '🟡' : 
                                      cat.status === 'fair' ? '🟠' : '🔴';
                    
                    if (yPos > pageHeight - 30) {
                        pdf.addPage();
                        yPos = 20;
                    }
                    
                    pdf.text(`${title}: ${catPercentage}% (${cat.score}/${cat.maxScore})`, margin, yPos);
                    yPos += 6;
                    
                    // Findings
                    pdf.setFontSize(9);
                    pdf.setFont(undefined, 'normal');
                    cat.findings.forEach(finding => {
                        if (yPos > pageHeight - 10) {
                            pdf.addPage();
                            yPos = 20;
                        }
                        const lines = pdf.splitTextToSize(finding, maxWidth - 5);
                        lines.forEach(line => {
                            pdf.text(`  ${line}`, margin, yPos);
                            yPos += 5;
                        });
                    });
                    
                    yPos += 3;
                }
                
                // Recommendations
                if (bp.recommendations && bp.recommendations.length > 0) {
                    if (yPos > pageHeight - 40) {
                        pdf.addPage();
                        yPos = 20;
                    }
                    
                    yPos += 5;
                    pdf.setFontSize(12);
                    pdf.setFont(undefined, 'bold');
                    pdf.text('Recommended Actions', margin, yPos);
                    yPos += 7;
                    
                    pdf.setFontSize(10);
                    pdf.setFont(undefined, 'normal');
                    addText('Based on the assessment, consider implementing the following improvements:');
                    yPos += 2;
                    
                    bp.recommendations.forEach((rec, idx) => {
                        if (yPos > pageHeight - 10) {
                            pdf.addPage();
                            yPos = 20;
                        }
                        const lines = pdf.splitTextToSize(`${idx + 1}. ${rec}`, maxWidth - 5);
                        lines.forEach(line => {
                            pdf.text(line, margin, yPos);
                            yPos += 6;
                        });
                    });
                    
                    yPos += 10;
                }
                
                // Reference
                yPos += 5;
                pdf.setFontSize(9);
                pdf.setFont(undefined, 'italic');
                addText('Reference: Microsoft Cloud Adoption Framework for Azure - Azure Landing Zone Design Principles');
                addText('https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/');
                yPos += 5;
            }
            
            // Management Groups
            pdf.addPage();
            yPos = 20;
            addSection('Management Groups', inventoryData.explanations.managementGroups);
            
            // Policies
            pdf.addPage();
            yPos = 20;
            addSection('Azure Policy', inventoryData.explanations.policies);
            
            // Role Assignments
            pdf.addPage();
            yPos = 20;
            addSection('Role-Based Access Control (RBAC)', inventoryData.explanations.roleAssignments);
            
            // Networking
            pdf.addPage();
            yPos = 20;
            addSection('Networking Architecture', inventoryData.explanations.networking);
            
            // Governance
            pdf.addPage();
            yPos = 20;
            addSection('Governance and Compliance', inventoryData.explanations.governance);
            
            // Subscriptions
            pdf.addPage();
            yPos = 20;
            addSection('Subscription Strategy', inventoryData.explanations.subscriptions);
        }
        
        // Save PDF
        pdf.save(`Azure-Landing-Zone-Inventory-${new Date().toISOString().split('T')[0]}.pdf`);
        
        btn.innerHTML = '<span class="icon">✓</span> PDF Downloaded!';
        setTimeout(() => {
            btn.innerHTML = '<span class="icon">📄</span> Export PDF';
            btn.disabled = false;
        }, 2000);
    } catch (error) {
        console.error('Error generating PDF:', error);
        alert('Failed to generate PDF: ' + error.message);
        btn.innerHTML = '<span class="icon">📄</span> Export PDF';
        btn.disabled = false;
    }
}

// Utility functions
function formatTags(tags) {
    if (!tags || Object.keys(tags).length === 0) {
        return '<em>No tags</em>';
    }
    return Object.entries(tags)
        .map(([key, value]) => `<span class="tag-value">${key}: ${value}</span>`)
        .join(' ');
}

function truncate(str, length) {
    if (!str) return '';
    return str.length > length ? str.substring(0, length) + '...' : str;
}

// Populate Virtual Machines table
function populateVirtualMachines() {
    const tbody = document.getElementById('virtualmachinesTableBody');
    const vms = (inventoryData.compute && inventoryData.compute.virtualMachines) || [];
    
    if (vms.length === 0) {
        tbody.innerHTML = '<tr><td colspan="10">No virtual machines found</td></tr>';
        return;
    }
    
    tbody.innerHTML = vms.map((vm, idx) => {
        const powerStateClass = vm.powerState === 'running' ? 'status-running' : 
                               vm.powerState === 'deallocated' ? 'status-deallocated' : 'status-stopped';
        return `
            <tr onclick="showResourceDetails('vm', ${idx})" data-type="vm" data-index="${idx}">
                <td><strong>${vm.name || 'N/A'}</strong></td>
                <td>${vm.vmSize || 'N/A'}</td>
                <td>${vm.osType || 'N/A'}</td>
                <td><span class="status-badge ${powerStateClass}">${vm.powerState || 'Unknown'}</span></td>
                <td>${vm.vnet || '<em>None</em>'}</td>
                <td>${vm.subnet || '<em>None</em>'}</td>
                <td><code>${vm.privateIPs && vm.privateIPs.length > 0 ? vm.privateIPs.join(', ') : 'None'}</code></td>
                <td>${vm.publicIPs && vm.publicIPs.length > 0 ? vm.publicIPs.join(', ') : '<em>None</em>'}</td>
                <td>${vm.location || 'N/A'}</td>
                <td><small>${vm.subscription || 'N/A'}</small></td>
            </tr>
        `;
    }).join('');
}

// Create network diagram
let networkDiagramInstance = null;

function createNetworkDiagram() {
    if (!inventoryData) return;
    
    const container = document.getElementById('networkDiagram');
    if (!container) return;
    
    const nodes = [];
    const edges = [];
    let nodeId = 1;
    
    // Create node map for lookups
    const vnetNodeMap = {};
    const vmNodeMap = {};
    
    // Add VNets
    const vnets = (inventoryData.networking && inventoryData.networking.vnets) || [];
    vnets.forEach((vnet, idx) => {
        const id = nodeId++;
        vnetNodeMap[vnet.name] = id;
        nodes.push({
            id: id,
            label: vnet.name,
            shape: 'box',
            color: {
                background: '#667eea',
                border: '#5568d3'
            },
            font: { color: '#ffffff', size: 14, face: 'Arial' },
            title: `VNet: ${vnet.name}\\nAddress Space: ${vnet.addressSpace ? vnet.addressSpace.join(', ') : 'N/A'}\\nLocation: ${vnet.location}`,
            dataType: 'vnet',
            dataIndex: idx
        });
    });
    
    // Add VMs
    const vms = (inventoryData.compute && inventoryData.compute.virtualMachines) || [];
    vms.forEach((vm, idx) => {
        const id = nodeId++;
        vmNodeMap[vm.name] = id;
        nodes.push({
            id: id,
            label: vm.name,
            shape: 'image',
            image: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0OCIgaGVpZ2h0PSI0OCIgdmlld0JveD0iMCAwIDQ4IDQ4Ij48cmVjdCB3aWR0aD0iNDgiIGhlaWdodD0iNDgiIGZpbGw9IiM0Mjg1RjQiLz48dGV4dCB4PSI1MCUiIHk9IjUwJSIgZm9udC1mYW1pbHk9IkFyaWFsIiBmb250LXNpemU9IjI0IiBmaWxsPSJ3aGl0ZSIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPvCfkrs8L3RleHQ+PC9zdmc+',
            size: 30,
            title: `VM: ${vm.name}\\nSize: ${vm.vmSize}\\nOS: ${vm.osType}\\nState: ${vm.powerState}`,
            dataType: 'vm',
            dataIndex: idx
        });
        
        // Connect VM to VNet
        if (vm.vnet && vnetNodeMap[vm.vnet]) {
            edges.push({
                from: id,
                to: vnetNodeMap[vm.vnet],
                color: { color: '#95a5a6' },
                dashes: true,
                arrows: { to: false },
                title: `Connected via ${vm.subnet || 'subnet'}`
            });
        }
    });
    
    // Add VNet Peerings
    const peerings = (inventoryData.networking && inventoryData.networking.peerings) || [];
    peerings.forEach(peer => {
        const sourceId = vnetNodeMap[peer.sourceVNet];
        const remoteId = vnetNodeMap[peer.remoteVNet];
        
        if (sourceId && remoteId) {
            edges.push({
                from: sourceId,
                to: remoteId,
                color: { 
                    color: peer.peeringState === 'Connected' ? '#27ae60' : '#e74c3c',
                    highlight: '#f39c12'
                },
                width: 3,
                arrows: { to: { enabled: true, type: 'arrow' } },
                title: `Peering: ${peer.name}\\nState: ${peer.peeringState}`,
                smooth: { type: 'curvedCW', roundness: 0.2 }
            });
        }
    });
    
    // Create network
    const data = { nodes: new vis.DataSet(nodes), edges: new vis.DataSet(edges) };
    const options = {
        physics: {
            enabled: true,
            stabilization: { iterations: 200 },
            barnesHut: {
                gravitationalConstant: -8000,
                centralGravity: 0.3,
                springLength: 200,
                springConstant: 0.04
            }
        },
        interaction: {
            hover: true,
            tooltipDelay: 200,
            navigationButtons: true,
            keyboard: true
        },
        nodes: {
            font: { size: 14 }
        },
        edges: {
            font: { size: 12, align: 'middle' },
            smooth: { type: 'continuous' }
        }
    };
    
    networkDiagramInstance = new vis.Network(container, data, options);
    
    // Add click event to nodes
    networkDiagramInstance.on('click', function(params) {
        if (params.nodes.length > 0) {
            const nodeId = params.nodes[0];
            const node = nodes.find(n => n.id === nodeId);
            if (node) {
                showResourceDetails(node.dataType, node.dataIndex);
            }
        }
    });
}

// Reset diagram view
function resetDiagram() {
    if (networkDiagramInstance) {
        networkDiagramInstance.fit();
    }
}

// Fit diagram to screen
function fitDiagram() {
    if (networkDiagramInstance) {
        networkDiagramInstance.fit({
            animation: {
                duration: 1000,
                easingFunction: 'easeInOutQuad'
            }
        });
    }
}

// Show resource details panel
function showResourceDetails(type, index) {
    const panel = document.getElementById('resourceDetails');
    const title = document.getElementById('detailsTitle');
    const content = document.getElementById('detailsContent');
    
    let resource = null;
    let html = '';
    
    if (type === 'vnet') {
        const vnets = (inventoryData.networking && inventoryData.networking.vnets) || [];
        resource = vnets[index];
        if (resource) {
            title.textContent = `VNet: ${resource.name}`;
            html = `
                <div class="detail-section">
                    <div class="detail-label">Resource Group</div>
                    <div class="detail-value">${resource.resourceGroup || 'N/A'}</div>
                    
                    <div class="detail-label">Location</div>
                    <div class="detail-value">${resource.location || 'N/A'}</div>
                    
                    <div class="detail-label">Address Space</div>
                    <div class="detail-value"><code>${resource.addressSpace ? resource.addressSpace.join(', ') : 'N/A'}</code></div>
                    
                    <div class="detail-label">Subnets</div>
                    <div class="detail-value">
                        ${resource.subnets && resource.subnets.length > 0 ? 
                            resource.subnets.map(s => `• ${s.name}: <code>${s.addressPrefix}</code>`).join('<br>') : 
                            'No subnets'}
                    </div>
                    
                    <div class="detail-label">DNS Servers</div>
                    <div class="detail-value">${resource.dnsServers && resource.dnsServers.length > 0 ? resource.dnsServers.join(', ') : 'Default (Azure provided)'}</div>
                    
                    <div class="detail-label">Subscription</div>
                    <div class="detail-value">${resource.subscription || 'N/A'}</div>
                </div>
                
                <div class="detail-section">
                    <div class="detail-label">Connected Resources</div>
                    <ul class="connections-list">
            `;
            
            // Find connected VMs
            const vms = (inventoryData.compute && inventoryData.compute.virtualMachines) || [];
            const connectedVMs = vms.filter(vm => vm.vnet === resource.name);
            connectedVMs.forEach(vm => {
                html += `<li onclick="showResourceDetails('vm', ${vms.indexOf(vm)})">💻 ${vm.name} (${vm.subnet || 'unknown subnet'})</li>`;
            });
            
            // Find peerings
            const peerings = (inventoryData.networking && inventoryData.networking.peerings) || [];
            const connectedPeerings = peerings.filter(p => p.sourceVNet === resource.name || p.remoteVNet === resource.name);
            connectedPeerings.forEach(peer => {
                html += `<li onclick="showResourceDetails('peering', ${peerings.indexOf(peer)})">🔗 Peering to ${peer.sourceVNet === resource.name ? peer.remoteVNet : peer.sourceVNet}</li>`;
            });
            
            if (connectedVMs.length === 0 && connectedPeerings.length === 0) {
                html += '<li>No connections found</li>';
            }
            
            html += '</ul></div>';
        }
    } else if (type === 'vm') {
        // Use modal for VM details
        showVMDetailsModal(index);
        return;
    } else if (type === 'peering') {
        const peerings = (inventoryData.networking && inventoryData.networking.peerings) || [];
        resource = peerings[index];
        if (resource) {
            title.textContent = `Peering: ${resource.name}`;
            html = `
                <div class="detail-section">
                    <div class="detail-label">Source VNet</div>
                    <div class="detail-value">${resource.sourceVNet || 'N/A'}</div>
                    
                    <div class="detail-label">Remote VNet</div>
                    <div class="detail-value">${resource.remoteVNet || 'N/A'}</div>
                    
                    <div class="detail-label">Peering State</div>
                    <div class="detail-value"><span class="status-badge status-${resource.peeringState === 'Connected' ? 'connected' : 'disconnected'}">${resource.peeringState || 'Unknown'}</span></div>
                    
                    <div class="detail-label">Provisioning State</div>
                    <div class="detail-value">${resource.provisioningState || 'N/A'}</div>
                    
                    <div class="detail-label">Allow Virtual Network Access</div>
                    <div class="detail-value">${resource.allowVirtualNetworkAccess ? '✓ Yes' : '✗ No'}</div>
                    
                    <div class="detail-label">Allow Forwarded Traffic</div>
                    <div class="detail-value">${resource.allowForwardedTraffic ? '✓ Yes' : '✗ No'}</div>
                    
                    <div class="detail-label">Allow Gateway Transit</div>
                    <div class="detail-value">${resource.allowGatewayTransit ? '✓ Yes' : '✗ No'}</div>
                    
                    <div class="detail-label">Use Remote Gateways</div>
                    <div class="detail-value">${resource.useRemoteGateways ? '✓ Yes' : '✗ No'}</div>
                    
                    <div class="detail-label">Remote Address Space</div>
                    <div class="detail-value"><code>${resource.remoteAddressSpace ? resource.remoteAddressSpace.join(', ') : 'N/A'}</code></div>
                    
                    <div class="detail-label">Resource Group</div>
                    <div class="detail-value">${resource.sourceResourceGroup || 'N/A'}</div>
                    
                    <div class="detail-label">Subscription</div>
                    <div class="detail-value">${resource.subscription || 'N/A'}</div>
                </div>
                
                <div class="detail-section">
                    <div class="detail-label">Connected VNets</div>
                    <ul class="connections-list">
            `;
            
            const vnets = (inventoryData.networking && inventoryData.networking.vnets) || [];
            const sourceIdx = vnets.findIndex(v => v.name === resource.sourceVNet);
            const remoteIdx = vnets.findIndex(v => v.name === resource.remoteVNet);
            
            if (sourceIdx >= 0) {
                html += `<li onclick="showResourceDetails('vnet', ${sourceIdx})">🌐 ${resource.sourceVNet} (Source)</li>`;
            }
            if (remoteIdx >= 0) {
                html += `<li onclick="showResourceDetails('vnet', ${remoteIdx})">🌐 ${resource.remoteVNet} (Remote)</li>`;
            }
            
            html += '</ul></div>';
        }
    }
    
    content.innerHTML = html;
    panel.style.display = 'block';
}

// Close resource details panel
function closeDetails() {
    document.getElementById('resourceDetails').style.display = 'none';
}

// Show VM details in modal
function showVMDetailsModal(index) {
    const vms = (inventoryData.compute && inventoryData.compute.virtualMachines) || [];
    const vm = vms[index];
    
    if (!vm) return;
    
    const modal = document.getElementById('vmDetailsModal');
    const title = document.getElementById('vmModalTitle');
    const body = document.getElementById('vmModalBody');
    
    title.textContent = `Virtual Machine: ${vm.name || 'Unknown'}`;
    
    let html = `
        <div class="vm-details-grid">
            <div class="detail-card">
                <h3>💻 Basic Information</h3>
                <div class="detail-row">
                    <span class="detail-label">Name:</span>
                    <span class="detail-value"><strong>${vm.name || 'N/A'}</strong></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Resource Group:</span>
                    <span class="detail-value">${vm.resourceGroup || 'N/A'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">VM Size:</span>
                    <span class="detail-value"><code>${vm.vmSize || 'N/A'}</code></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Operating System:</span>
                    <span class="detail-value">${vm.osType || 'N/A'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Power State:</span>
                    <span class="detail-value">
                        <span class="status-badge status-${vm.powerState || 'unknown'}">${vm.powerState || 'Unknown'}</span>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Location:</span>
                    <span class="detail-value">${vm.location || 'N/A'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Subscription:</span>
                    <span class="detail-value"><small>${vm.subscription || 'N/A'}</small></span>
                </div>
            </div>
            
            <div class="detail-card">
                <h3>💾 Storage</h3>
                <div class="detail-row">
                    <span class="detail-label">OS Disk Size:</span>
                    <span class="detail-value">${vm.osDiskSizeGB || 0} GB</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Data Disks:</span>
                    <span class="detail-value">${vm.dataDisksCount || 0} disk(s)</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Availability Set:</span>
                    <span class="detail-value">${vm.availabilitySet || '<em>None</em>'}</span>
                </div>
            </div>
            
            <div class="detail-card">
                <h3>🌐 Networking</h3>
                <div class="detail-row">
                    <span class="detail-label">Virtual Network:</span>
                    <span class="detail-value">${vm.vnet || '<em>None</em>'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Subnet:</span>
                    <span class="detail-value">${vm.subnet || '<em>None</em>'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Private IP(s):</span>
                    <span class="detail-value"><code>${vm.privateIPs && vm.privateIPs.length > 0 ? vm.privateIPs.join(', ') : 'None'}</code></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Public IP(s):</span>
                    <span class="detail-value">${vm.publicIPs && vm.publicIPs.length > 0 ? vm.publicIPs.join(', ') : '<em>None</em>'}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Network Interfaces:</span>
                    <span class="detail-value"><small>${vm.networkInterfaces && vm.networkInterfaces.length > 0 ? vm.networkInterfaces.join(', ') : 'None'}</small></span>
                </div>
            </div>
    `;
    
    // Tags section
    if (vm.tags && Object.keys(vm.tags).length > 0) {
        html += `
            <div class="detail-card detail-card-full">
                <h3>🏷️ Tags</h3>
                <div class="tags-grid">
        `;
        
        for (const [key, value] of Object.entries(vm.tags)) {
            html += `
                <div class="tag-item">
                    <span class="tag-key">${key}:</span>
                    <span class="tag-value">${value || '<em>empty</em>'}</span>
                </div>
            `;
        }
        
        html += `
                </div>
            </div>
        `;
    } else {
        html += `
            <div class="detail-card detail-card-full">
                <h3>🏷️ Tags</h3>
                <p style="color: #999; font-style: italic;">No tags assigned to this virtual machine</p>
            </div>
        `;
    }
    
    html += `</div>`;
    
    body.innerHTML = html;
    modal.style.display = 'block';
    
    // Close modal when clicking outside
    modal.onclick = function(event) {
        if (event.target === modal) {
            closeVMModal();
        }
    };
}

// Close VM details modal
function closeVMModal() {
    const modal = document.getElementById('vmDetailsModal');
    modal.style.display = 'none';
}
