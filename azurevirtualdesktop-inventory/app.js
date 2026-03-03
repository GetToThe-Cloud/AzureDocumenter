// Azure Virtual Desktop Inventory - Client Application

let inventoryData = null;
let diagramData = null;
let network = null;

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    checkAuthStatus();
    // Auto-refresh every 5 minutes
    setInterval(checkAuthStatus, 300000);
});

// Check authentication status
async function checkAuthStatus() {
    try {
        const response = await fetch('/api/auth/status');
        const data = await response.json();
        
        const authStatusDiv = document.getElementById('authStatus');
        
        if (data.authenticated) {
            authStatusDiv.className = 'auth-status authenticated';
            authStatusDiv.innerHTML = `✓ Connected to Azure as <strong>${data.context.account}</strong> | Subscription: <strong>${data.context.subscription}</strong>`;
            
            document.getElementById('authRequired').style.display = 'none';
            await loadInventoryData();
        } else {
            authStatusDiv.className = 'auth-status not-authenticated';
            authStatusDiv.innerHTML = '⚠ Not authenticated with Azure. Please sign in to view inventory data.';
            
            document.getElementById('authRequired').style.display = 'flex';
        }
    } catch (error) {
        console.error('Error checking auth status:', error);
    }
}

// Authenticate with Azure
async function authenticateAzure() {
    try {
        showLoading();
        const response = await fetch('/api/auth/login', { method: 'POST' });
        const data = await response.json();
        
        if (data.success) {
            await checkAuthStatus();
        } else {
            alert('Authentication failed: ' + data.message);
        }
    } catch (error) {
        console.error('Error authenticating:', error);
        alert('Authentication failed. Please check the server console for device code.');
    } finally {
        hideLoading();
    }
}

// Load inventory data
async function loadInventoryData() {
    try {
        showLoading();
        const response = await fetch('/api/inventory/data');
        
        if (response.status === 401) {
            await checkAuthStatus();
            return;
        }
        
        inventoryData = await response.json();
        
        if (inventoryData.error) {
            console.error('Error loading inventory:', inventoryData.error);
            alert('Error loading inventory: ' + inventoryData.error);
            return;
        }
        
        updateLastUpdateTime();
        
        // Render explanations
        if (inventoryData.explanation) {
            document.getElementById('overviewExplanation').textContent = inventoryData.explanation.overview || '';
            document.getElementById('hostPoolsExplanation').textContent = inventoryData.explanation.hostPools || '';
            document.getElementById('sessionHostsExplanation').textContent = inventoryData.explanation.sessionHosts || '';
            document.getElementById('scalingPlansExplanation').textContent = inventoryData.explanation.scalingPlans || '';
            document.getElementById('vnetsExplanation').textContent = inventoryData.explanation.virtualNetworks || '';
            document.getElementById('galleriesExplanation').textContent = inventoryData.explanation.computeGalleries || '';
        }
        
        renderOverview();
        renderHostPools();
        renderSessionHosts();
        renderWorkspaces();
        renderApplicationGroups();
        renderScalingPlans();
        renderVNets();
        renderComputeGalleries();
        
    } catch (error) {
        console.error('Error loading inventory data:', error);
    } finally {
        hideLoading();
    }
}

// Refresh inventory
async function refreshInventory() {
    try {
        showLoading();
        const response = await fetch('/api/inventory/refresh', { method: 'POST' });
        const data = await response.json();
        
        if (data.success) {
            await loadInventoryData();
        }
    } catch (error) {
        console.error('Error refreshing inventory:', error);
    } finally {
        hideLoading();
    }
}

// Update last update time
function updateLastUpdateTime() {
    if (inventoryData && inventoryData.collectionTime) {
        const date = new Date(inventoryData.collectionTime);
        const formatted = date.toLocaleString('en-US', { 
            month: 'short', 
            day: 'numeric', 
            year: 'numeric',
            hour: '2-digit', 
            minute: '2-digit' 
        });
        document.getElementById('lastUpdate').textContent = `Last updated: ${formatted}`;
    }
}

// Render overview section
function renderOverview() {
    if (!inventoryData) return;
    
    const summary = inventoryData.summary;
    
    document.getElementById('totalHostPools').textContent = summary.totalHostPools;
    document.getElementById('totalSessionHosts').textContent = summary.totalSessionHosts;
    document.getElementById('availableHosts').textContent = summary.availableSessionHosts;
    document.getElementById('unavailableHosts').textContent = summary.unavailableSessionHosts;
    document.getElementById('totalWorkspaces').textContent = summary.totalWorkspaces;
    document.getElementById('totalAppGroups').textContent = summary.totalApplicationGroups;
    document.getElementById('totalScalingPlans').textContent = summary.totalScalingPlans || 0;
    document.getElementById('totalVNets').textContent = summary.totalVNets || 0;
    document.getElementById('totalGalleries').textContent = summary.totalComputeGalleries || 0;
    
    // Render subscriptions
    const subsList = document.getElementById('subscriptionsList');
    subsList.innerHTML = '<h3 style="margin-bottom: 1rem;">Subscriptions</h3>';
    
    inventoryData.subscriptions.forEach(sub => {
        const subDiv = document.createElement('div');
        subDiv.className = 'subscription-section';
        subDiv.innerHTML = `
            <div class="subscription-header">
                <h3>${sub.name}</h3>
                <div style="font-size: 0.9rem; margin-top: 0.5rem; opacity: 0.9;">
                    ID: ${sub.id}
                </div>
            </div>
            <div class="subscription-content">
                <div class="data-item-details">
                    <div class="data-field">
                        <div class="data-field-label">Host Pools</div>
                        <div class="data-field-value">${sub.hostPools.length}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Workspaces</div>
                        <div class="data-field-value">${sub.workspaces.length}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Application Groups</div>
                        <div class="data-field-value">${sub.applicationGroups.length}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Scaling Plans</div>
                        <div class="data-field-value">${sub.scalingPlans ? sub.scalingPlans.length : 0}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Virtual Networks</div>
                        <div class="data-field-value">${sub.virtualNetworks ? sub.virtualNetworks.length : 0}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Compute Galleries</div>
                        <div class="data-field-value">${sub.computeGalleries ? sub.computeGalleries.length : 0}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Tenant ID</div>
                        <div class="data-field-value" style="font-size: 0.85rem;">${sub.tenantId}</div>
                    </div>
                </div>
            </div>
        `;
        subsList.appendChild(subDiv);
    });
}

// Render host pools
function renderHostPools() {
    if (!inventoryData) return;
    
    const container = document.getElementById('hostPoolsList');
    container.innerHTML = '';
    
    let hpCount = 0;
    inventoryData.subscriptions.forEach(sub => {
        sub.hostPools.forEach(hp => {
            hpCount++;
            const hpDiv = document.createElement('div');
            hpDiv.className = 'data-item';
            
            const tokenStatus = hp.registrationToken.exists 
                ? (hp.registrationToken.expired ? '🔴 Expired' : '🟢 Valid')
                : '⚫ Not Available';
            
            hpDiv.innerHTML = `
                <div class="data-item-header">
                    <h3>${hp.name}</h3>
                    <span class="badge badge-info">${hp.hostPoolType}</span>
                </div>
                <div class="data-item-details">
                    <div class="data-field">
                        <div class="data-field-label">Resource Group</div>
                        <div class="data-field-value">${hp.resourceGroup}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Location</div>
                        <div class="data-field-value">${hp.location}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Load Balancer</div>
                        <div class="data-field-value">${hp.loadBalancerType}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Max Session Limit</div>
                        <div class="data-field-value">${hp.maxSessionLimit}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Session Hosts</div>
                        <div class="data-field-value">${hp.sessionHostCount} total (${hp.availableHosts} available)</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Registration Token</div>
                        <div class="data-field-value">${tokenStatus}</div>
                    </div>
                    ${hp.scalingPlanReference ? `
                    <div class="data-field">
                        <div class="data-field-label">Scaling Plan</div>
                        <div class="data-field-value"><span class="badge badge-success">✓ ${hp.scalingPlanReference}</span></div>
                    </div>
                    ` : ''}
                </div>
            `;
            container.appendChild(hpDiv);
        });
    });
    
    if (hpCount === 0) {
        container.innerHTML = '<p style="color: var(--text-secondary);">No host pools found.</p>';
    }
}

// Render session hosts
function renderSessionHosts() {
    if (!inventoryData) return;
    
    const container = document.getElementById('sessionHostsList');
    container.innerHTML = '';
    
    let shCount = 0;
    inventoryData.subscriptions.forEach(sub => {
        sub.hostPools.forEach(hp => {
            if (hp.sessionHosts.length > 0) {
                const hpSection = document.createElement('div');
                hpSection.style.marginBottom = '2rem';
                hpSection.innerHTML = `<h3 style="margin-bottom: 1rem; color: var(--secondary-color);">${hp.name}</h3>`;
                
                const table = document.createElement('div');
                table.className = 'table-container';
                table.innerHTML = `
                    <table>
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Status</th>
                                <th>Sessions</th>
                                <th>Allow New Session</th>
                                <th>VNet</th>
                                <th>Private IP</th>
                                <th>Image Source</th>
                                <th>OS Version</th>
                                <th>Agent Version</th>
                                <th>Last Heartbeat</th>
                            </tr>
                        </thead>
                        <tbody id="sh-${hp.name.replace(/[^a-zA-Z0-9]/g, '')}"></tbody>
                    </table>
                `;
                hpSection.appendChild(table);
                container.appendChild(hpSection);
                
                const tbody = hpSection.querySelector('tbody');
                hp.sessionHosts.forEach(sh => {
                    shCount++;
                    const statusBadge = sh.status === 'Available' ? 'badge-success' : 'badge-danger';
                    const lastHB = sh.lastHeartBeat ? new Date(sh.lastHeartBeat).toLocaleString() : 'N/A';
                    const vnetInfo = sh.network ? `${sh.network.vnetName}/${sh.network.subnetName}` : 'N/A';
                    const privateIP = sh.network ? sh.network.privateIP : 'N/A';
                    
                    let imageSource = 'N/A';
                    if (sh.image) {
                        if (sh.image.type === 'Gallery') {
                            imageSource = `🖼️ ${sh.image.imageName} (v${sh.image.version})`;
                        } else if (sh.image.type === 'Marketplace') {
                            imageSource = `🏪 ${sh.image.publisher}/${sh.image.offer}`;
                        }
                    }
                    
                    const row = document.createElement('tr');
                    row.innerHTML = `
                        <td>${sh.name}</td>
                        <td><span class="badge ${statusBadge}">${sh.status}</span></td>
                        <td>${sh.sessions}</td>
                        <td>${sh.allowNewSession ? '✓' : '✗'}</td>
                        <td style="font-size: 0.85rem;">${vnetInfo}</td>
                        <td style="font-size: 0.85rem;">${privateIP}</td>
                        <td style="font-size: 0.85rem;">${imageSource}</td>
                        <td>${sh.osVersion || 'N/A'}</td>
                        <td>${sh.agentVersion || 'N/A'}</td>
                        <td style="font-size: 0.85rem;">${lastHB}</td>
                    `;
                    tbody.appendChild(row);
                });
            }
        });
    });
    
    if (shCount === 0) {
        container.innerHTML = '<p style="color: var(--text-secondary);">No session hosts found.</p>';
    }
}

// Render workspaces
function renderWorkspaces() {
    if (!inventoryData) return;
    
    const container = document.getElementById('workspacesList');
    container.innerHTML = '';
    
    let wsCount = 0;
    inventoryData.subscriptions.forEach(sub => {
        sub.workspaces.forEach(ws => {
            wsCount++;
            const wsDiv = document.createElement('div');
            wsDiv.className = 'data-item';
            wsDiv.innerHTML = `
                <h3>${ws.name}</h3>
                <div class="data-item-details">
                    <div class="data-field">
                        <div class="data-field-label">Friendly Name</div>
                        <div class="data-field-value">${ws.friendlyName || 'N/A'}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Resource Group</div>
                        <div class="data-field-value">${ws.resourceGroup}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Location</div>
                        <div class="data-field-value">${ws.location}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Application Groups</div>
                        <div class="data-field-value">${ws.applicationGroupReferences ? ws.applicationGroupReferences.length : 0}</div>
                    </div>
                </div>
                ${ws.description ? `<p style="margin-top: 1rem; color: var(--text-secondary);">${ws.description}</p>` : ''}
            `;
            container.appendChild(wsDiv);
        });
    });
    
    if (wsCount === 0) {
        container.innerHTML = '<p style="color: var(--text-secondary);">No workspaces found.</p>';
    }
}

// Render application groups
function renderApplicationGroups() {
    if (!inventoryData) return;
    
    const container = document.getElementById('appGroupsList');
    container.innerHTML = '';
    
    let agCount = 0;
    inventoryData.subscriptions.forEach(sub => {
        sub.applicationGroups.forEach(ag => {
            agCount++;
            const agDiv = document.createElement('div');
            agDiv.className = 'data-item';
            
            let appsHTML = '';
            if (ag.applications && ag.applications.length > 0) {
                appsHTML = `
                    <div style="margin-top: 1rem;">
                        <div class="data-field-label">Published Applications</div>
                        <div class="table-container" style="margin-top: 0.5rem;">
                            <table style="font-size: 0.85rem;">
                                <thead>
                                    <tr>
                                        <th>Name</th>
                                        <th>Friendly Name</th>
                                        <th>File Path</th>
                                        <th>Show in Portal</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    ${ag.applications.map(app => `
                                        <tr>
                                            <td>${app.name}</td>
                                            <td>${app.friendlyName || 'N/A'}</td>
                                            <td style="font-size: 0.8rem;">${app.filePath || 'N/A'}</td>
                                            <td>${app.showInPortal ? '✓' : '✗'}</td>
                                        </tr>
                                    `).join('')}
                                </tbody>
                            </table>
                        </div>
                    </div>
                `;
            }
            
            agDiv.innerHTML = `
                <div class="data-item-header">
                    <h3>${ag.name}</h3>
                    <span class="badge badge-info">${ag.applicationGroupType}</span>
                </div>
                <div class="data-item-details">
                    <div class="data-field">
                        <div class="data-field-label">Friendly Name</div>
                        <div class="data-field-value">${ag.friendlyName || 'N/A'}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Resource Group</div>
                        <div class="data-field-value">${ag.resourceGroup}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Location</div>
                        <div class="data-field-value">${ag.location}</div>
                    </div>
                    <div class="data-field">
                        <div class="data-field-label">Applications</div>
                        <div class="data-field-value">${ag.applications.length}</div>
                    </div>
                </div>
                ${appsHTML}
            `;
            container.appendChild(agDiv);
        });
    });
    
    if (agCount === 0) {
        container.innerHTML = '<p style="color: var(--text-secondary);">No application groups found.</p>';
    }
}

// Render scaling plans
function renderScalingPlans() {
    if (!inventoryData) return;
    
    const container = document.getElementById('scalingPlansList');
    container.innerHTML = '';
    
    let spCount = 0;
    inventoryData.subscriptions.forEach(sub => {
        if (sub.scalingPlans) {
            sub.scalingPlans.forEach(sp => {
                spCount++;
                const spDiv = document.createElement('div');
                spDiv.className = 'data-item';
                
                let schedulesHTML = '';
                if (sp.schedules && sp.schedules.length > 0) {
                    schedulesHTML = `
                        <div style="margin-top: 1rem;">
                            <div class="data-field-label">Schedules</div>
                            <div class="table-container" style="margin-top: 0.5rem;">
                                <table style="font-size: 0.85rem;">
                                    <thead>
                                        <tr>
                                            <th>Name</th>
                                            <th>Days</th>
                                            <th>Ramp Up</th>
                                            <th>Peak</th>
                                            <th>Ramp Down</th>
                                            <th>Off Peak</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${sp.schedules.map(schedule => `
                                            <tr>
                                                <td>${schedule.name || 'N/A'}</td>
                                                <td>${schedule.daysOfWeek || 'N/A'}</td>
                                                <td>${schedule.rampUpStartTime || 'N/A'}</td>
                                                <td>${schedule.peakStartTime || 'N/A'}</td>
                                                <td>${schedule.rampDownStartTime || 'N/A'}</td>
                                                <td>${schedule.offPeakStartTime || 'N/A'}</td>
                                            </tr>
                                        `).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    `;
                }
                
                let hostPoolRefsHTML = '';
                if (sp.hostPoolReferences && sp.hostPoolReferences.length > 0) {
                    hostPoolRefsHTML = `
                        <div style="margin-top: 1rem;">
                            <div class="data-field-label">Assigned Host Pools</div>
                            <div style="margin-top: 0.5rem;">
                                ${sp.hostPoolReferences.map(hpRef => {
                                    const hpName = hpRef.hostPoolArmPath.split('/').pop();
                                    const enabledBadge = hpRef.scalingPlanEnabled ? 'badge-success' : 'badge-warning';
                                    const enabledText = hpRef.scalingPlanEnabled ? 'Enabled' : 'Disabled';
                                    return `<span class="badge ${enabledBadge}" style="margin-right: 0.5rem; margin-bottom: 0.5rem;">${hpName}: ${enabledText}</span>`;
                                }).join('')}
                            </div>
                        </div>
                    `;
                }
                
                spDiv.innerHTML = `
                    <div class="data-item-header">
                        <h3>${sp.name}</h3>
                        <span class="badge badge-info">${sp.hostPoolType || 'N/A'}</span>
                    </div>
                    <div class="data-item-details">
                        <div class="data-field">
                            <div class="data-field-label">Friendly Name</div>
                            <div class="data-field-value">${sp.friendlyName || 'N/A'}</div>
                        </div>
                        <div class="data-field">
                            <div class="data-field-label">Resource Group</div>
                            <div class="data-field-value">${sp.resourceGroup}</div>
                        </div>
                        <div class="data-field">
                            <div class="data-field-label">Location</div>
                            <div class="data-field-value">${sp.location}</div>
                        </div>
                        <div class="data-field">
                            <div class="data-field-label">Time Zone</div>
                            <div class="data-field-value">${sp.timeZone || 'N/A'}</div>
                        </div>
                        <div class="data-field">
                            <div class="data-field-label">Exclusion Tag</div>
                            <div class="data-field-value">${sp.exclusionTag || 'None'}</div>
                        </div>
                        <div class="data-field">
                            <div class="data-field-label">Schedules</div>
                            <div class="data-field-value">${sp.schedules ? sp.schedules.length : 0}</div>
                        </div>
                    </div>
                    ${schedulesHTML}
                    ${hostPoolRefsHTML}
                `;
                container.appendChild(spDiv);
            });
        }
    });
    
    if (spCount === 0) {
        container.innerHTML = '<p style="color: var(--text-secondary);">No scaling plans found.</p>';
    }
}

// Render virtual networks
function renderVNets() {
    if (!inventoryData) return;
    
    const container = document.getElementById('vnetsList');
    container.innerHTML = '';
    
    let vnetCount = 0;
    inventoryData.subscriptions.forEach(sub => {
        if (sub.virtualNetworks) {
            sub.virtualNetworks.forEach(vnet => {
                vnetCount++;
                const vnetDiv = document.createElement('div');
                vnetDiv.className = 'data-item';
                
                let subnetsHTML = '';
                if (vnet.subnets && vnet.subnets.length > 0) {
                    subnetsHTML = `
                        <div style="margin-top: 1rem;">
                            <div class="data-field-label">Subnets</div>
                            <div class="table-container" style="margin-top: 0.5rem;">
                                <table style="font-size: 0.85rem;">
                                    <thead>
                                        <tr>
                                            <th>Name</th>
                                            <th>Address Prefix</th>
                                            <th>Connected Devices</th>
                                            <th>AVD Session Hosts</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${vnet.subnets.map(subnet => `
                                            <tr>
                                                <td>${subnet.name}</td>
                                                <td>${subnet.addressPrefix}</td>
                                                <td>${subnet.connectedDevices || 0}</td>
                                                <td>${subnet.connectedSessionHosts || 0}</td>
                                            </tr>
                                        `).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    `;
                }
                
                let peeringsHTML = '';
                if (vnet.peerings && vnet.peerings.length > 0) {
                    peeringsHTML = `
                        <div style="margin-top: 1rem;">
                            <div class="data-field-label">VNet Peerings</div>
                            <div class="table-container" style="margin-top: 0.5rem;">
                                <table style="font-size: 0.85rem;">
                                    <thead>
                                        <tr>
                                            <th>Name</th>
                                            <th>Remote VNet</th>
                                            <th>Peering State</th>
                                            <th>Allow Forwarded Traffic</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${vnet.peerings.map(peer => `
                                            <tr>
                                                <td>${peer.name}</td>
                                                <td style="font-size: 0.8rem;">${peer.remoteVNet}</td>
                                                <td><span class="badge ${peer.peeringState === 'Connected' ? 'badge-success' : 'badge-warning'}">${peer.peeringState}</span></td>
                                                <td>${peer.allowForwardedTraffic ? '✓' : '✗'}</td>
                                            </tr>
                                        `).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    `;
                }
                
                vnetDiv.innerHTML = `
                    <div class="data-item-header">
                        <h3>${vnet.name}</h3>
                        <span class="badge badge-success">AVD Network</span>
                        ${vnet.connectedSessionHosts ? `<span class="badge badge-info">${vnet.connectedSessionHosts} Session Hosts</span>` : ''}
                    </div>
                    <div class="data-item-details">
                        <div class="data-field">
                            <div class="data-field-label">Resource Group</div>
                            <div class="data-field-value">${vnet.resourceGroup}</div>
                        </div>
                        <div class="data-field">
                            <div class="data-field-label">Location</div>
                            <div class="data-field-value">${vnet.location}</div>
                        </div>
                        <div class="data-field">
                            <div class="data-field-label">Address Space</div>
                            <div class="data-field-value">${vnet.addressSpace}</div>
                        </div>
                        <div class="data-field">
                            <div class="data-field-label">DNS Servers</div>
                            <div class="data-field-value">${vnet.dnsServers || 'Default (Azure-provided)'}</div>
                        </div>
                        <div class="data-field">
                            <div class="data-field-label">Subnets</div>
                            <div class="data-field-value">${vnet.subnets ? vnet.subnets.length : 0}</div>
                        </div>
                        <div class="data-field">
                            <div class="data-field-label">Peerings</div>
                            <div class="data-field-value">${vnet.peerings ? vnet.peerings.length : 0}</div>
                        </div>
                    </div>
                    ${subnetsHTML}
                    ${peeringsHTML}
                `;
                container.appendChild(vnetDiv);
            });
        }
    });
    
    if (vnetCount === 0) {
        container.innerHTML = '<p style="color: var(--text-secondary);">No AVD-connected virtual networks found.</p>';
    }
}

// Render compute galleries
function renderComputeGalleries() {
    if (!inventoryData) return;
    
    const container = document.getElementById('galleriesList');
    container.innerHTML = '';
    
    let galleryCount = 0;
    inventoryData.subscriptions.forEach(sub => {
        if (sub.computeGalleries) {
            sub.computeGalleries.forEach(gallery => {
                galleryCount++;
                const galleryDiv = document.createElement('div');
                galleryDiv.className = 'data-item';
                
                let imagesHTML = '';
                if (gallery.images && gallery.images.length > 0) {
                    imagesHTML = `
                        <div style="margin-top: 1rem;">
                            <div class="data-field-label">Images</div>
                            ${gallery.images.map(image => {
                                let versionsHTML = '';
                                if (image.versions && image.versions.length > 0) {
                                    versionsHTML = `
                                        <div class="table-container" style="margin-top: 0.5rem;">
                                            <table style="font-size: 0.85rem;">
                                                <thead>
                                                    <tr>
                                                        <th>Version</th>
                                                        <th>Location</th>
                                                        <th>Provisioning State</th>
                                                        <th>Used By</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    ${image.versions.map(version => `
                                                        <tr>
                                                            <td><strong>${version.name}</strong></td>
                                                            <td>${version.location}</td>
                                                            <td><span class="badge ${version.provisioningState === 'Succeeded' ? 'badge-success' : 'badge-warning'}">${version.provisioningState}</span></td>
                                                            <td>${version.usedBy ? version.usedBy.join(', ') : 'Not in use'}</td>
                                                        </tr>
                                                    `).join('')}
                                                </tbody>
                                            </table>
                                        </div>
                                    `;
                                }
                                
                                return `
                                    <div style="margin-bottom: 1.5rem; padding: 1rem; background: rgba(255,255,255,0.02); border-radius: 8px; border: 1px solid rgba(255,255,255,0.05);">
                                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                                            <h4 style="margin: 0; color: var(--secondary-color);">🖼️ ${image.name}</h4>
                                            <span class="badge badge-info">${image.osType || 'N/A'}</span>
                                        </div>
                                        <div class="data-item-details">
                                            <div class="data-field">
                                                <div class="data-field-label">OS State</div>
                                                <div class="data-field-value">${image.osState || 'N/A'}</div>
                                            </div>
                                            <div class="data-field">
                                                <div class="data-field-label">Hyper-V Generation</div>
                                                <div class="data-field-value">${image.hyperVGeneration || 'N/A'}</div>
                                            </div>
                                            <div class="data-field">
                                                <div class="data-field-label">Versions</div>
                                                <div class="data-field-value">${image.versions ? image.versions.length : 0}</div>
                                            </div>
                                            <div class="data-field">
                                                <div class="data-field-label">Description</div>
                                                <div class="data-field-value">${image.description || 'No description'}</div>
                                            </div>
                                        </div>
                                        ${versionsHTML}
                                    </div>
                                `;
                            }).join('')}
                        </div>
                    `;
                }
                
                galleryDiv.innerHTML = `
                    <div class="data-item-header">
                        <h3>${gallery.name}</h3>
                        <span class="badge badge-success">${gallery.provisioningState || 'N/A'}</span>
                    </div>
                    <div class="data-item-details">
                        <div class="data-field">
                            <div class="data-field-label">Resource Group</div>
                            <div class="data-field-value">${gallery.resourceGroup}</div>
                        </div>
                        <div class="data-field">
                            <div class="data-field-label">Location</div>
                            <div class="data-field-value">${gallery.location}</div>
                        </div>
                        <div class="data-field">
                            <div class="data-field-label">Images</div>
                            <div class="data-field-value">${gallery.images ? gallery.images.length : 0}</div>
                        </div>
                        <div class="data-field">
                            <div class="data-field-label">Description</div>
                            <div class="data-field-value">${gallery.description || 'No description'}</div>
                        </div>
                    </div>
                    ${imagesHTML}
                `;
                container.appendChild(galleryDiv);
            });
        }
    });
    
    if (galleryCount === 0) {
        container.innerHTML = '<p style="color: var(--text-secondary);">No Azure Compute Galleries found.</p>';
    }
}

// Show section
function showSection(sectionId) {
    // Update navigation
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
    });
    document.querySelector(`[data-section="${sectionId}"]`).classList.add('active');
    
    // Update content
    document.querySelectorAll('.content-section').forEach(section => {
        section.classList.remove('active');
    });
    document.getElementById(sectionId).classList.add('active');
    
    // Load diagram if needed
    if (sectionId === 'diagram' && !diagramData) {
        loadDiagram();
    }
}

// Load and render diagram
async function loadDiagram() {
    try {
        showLoading();
        const response = await fetch('/api/diagram/connections');
        
        if (response.status === 401) {
            return;
        }
        
        diagramData = await response.json();
        
        if (diagramData.error) {
            console.error('Error loading diagram:', diagramData.error);
            return;
        }
        
        renderDiagram();
    } catch (error) {
        console.error('Error loading diagram:', error);
    } finally {
        hideLoading();
    }
}

// Render diagram with vis.js
function renderDiagram() {
    if (!diagramData) return;
    
    const container = document.getElementById('networkDiagram');
    
    // Define colors for different node types
    const colorMap = {
        subscription: { background: '#0078d4', border: '#005a9e' },
        hostpool: { background: '#50e6ff', border: '#00b7c3' },
        sessionhost: { background: '#107c10', border: '#0b5a08' },
        workspace: { background: '#ffaa44', border: '#dd8800' },
        applicationgroup: { background: '#8764b8', border: '#674ea7' },
        scalingplan: { background: '#f7630c', border: '#c04d0a' },
        vnet: { background: '#0078d4', border: '#004578' }
    };
    
    // Prepare nodes and edges
    const nodes = diagramData.nodes.map(node => ({
        id: node.id,
        label: node.label,
        color: colorMap[node.type] || { background: '#666', border: '#333' },
        font: { color: '#ffffff' },
        shape: 'box',
        margin: 10
    }));
    
    const edges = diagramData.edges.map(edge => ({
        from: edge.from,
        to: edge.to,
        label: edge.label,
        arrows: 'to',
        font: { size: 10, color: '#999999' }
    }));
    
    const data = { nodes, edges };
    
    const options = {
        physics: {
            enabled: true,
            barnesHut: {
                gravitationalConstant: -2000,
                springLength: 200,
                springConstant: 0.04
            },
            stabilization: {
                iterations: 200
            }
        },
        layout: {
            hierarchical: {
                enabled: true,
                direction: 'UD',
                sortMethod: 'directed',
                levelSeparation: 150,
                nodeSpacing: 200
            }
        },
        nodes: {
            font: {
                size: 14
            }
        },
        edges: {
            smooth: {
                type: 'cubicBezier',
                forceDirection: 'vertical'
            }
        }
    };
    
    network = new vis.Network(container, data, options);
}

// Export to PDF
async function exportToPDF() {
    try {
        showLoading();
        
        const { jsPDF } = window.jspdf;
        const pdf = new jsPDF('p', 'mm', 'a4');
        
        let yOffset = 20;
        
        // Title
        pdf.setFontSize(20);
        pdf.text('Azure Virtual Desktop Inventory Report', 20, yOffset);
        yOffset += 10;
        
        // Date
        pdf.setFontSize(10);
        pdf.text(`Generated: ${new Date().toLocaleString()}`, 20, yOffset);
        yOffset += 15;
        
        if (!inventoryData) {
            pdf.text('No inventory data available', 20, yOffset);
        } else {
            // Summary
            pdf.setFontSize(14);
            pdf.text('Summary', 20, yOffset);
            yOffset += 8;
            
            pdf.setFontSize(10);
            const summary = inventoryData.summary;
            pdf.text(`Host Pools: ${summary.totalHostPools}`, 20, yOffset);
            yOffset += 6;
            pdf.text(`Session Hosts: ${summary.totalSessionHosts} (${summary.availableSessionHosts} available, ${summary.unavailableSessionHosts} unavailable)`, 20, yOffset);
            yOffset += 6;
            pdf.text(`Workspaces: ${summary.totalWorkspaces}`, 20, yOffset);
            yOffset += 6;
            pdf.text(`Application Groups: ${summary.totalApplicationGroups}`, 20, yOffset);
            yOffset += 6;
            pdf.text(`Scaling Plans: ${summary.totalScalingPlans || 0}`, 20, yOffset);
            yOffset += 6;
            pdf.text(`Virtual Networks: ${summary.totalVNets || 0}`, 20, yOffset);
            yOffset += 6;
            pdf.text(`Compute Galleries: ${summary.totalComputeGalleries || 0}`, 20, yOffset);
            yOffset += 15;
            
            // Subscriptions
            inventoryData.subscriptions.forEach((sub, subIndex) => {
                if (yOffset > 250) {
                    pdf.addPage();
                    yOffset = 20;
                }
                
                pdf.setFontSize(14);
                pdf.text(`Subscription: ${sub.name}`, 20, yOffset);
                yOffset += 8;
                
                pdf.setFontSize(10);
                
                // Host Pools
                if (sub.hostPools.length > 0) {
                    pdf.text('Host Pools:', 25, yOffset);
                    yOffset += 6;
                    
                    sub.hostPools.forEach(hp => {
                        if (yOffset > 270) {
                            pdf.addPage();
                            yOffset = 20;
                        }
                        pdf.text(`  • ${hp.name} (${hp.hostPoolType}, ${hp.sessionHostCount} hosts)`, 30, yOffset);
                        yOffset += 6;
                    });
                    yOffset += 4;
                }
                
                // Workspaces
                if (sub.workspaces.length > 0) {
                    pdf.text('Workspaces:', 25, yOffset);
                    yOffset += 6;
                    
                    sub.workspaces.forEach(ws => {
                        if (yOffset > 270) {
                            pdf.addPage();
                            yOffset = 20;
                        }
                        pdf.text(`  • ${ws.name}`, 30, yOffset);
                        yOffset += 6;
                    });
                    yOffset += 4;
                }
                
                // Application Groups
                if (sub.applicationGroups.length > 0) {
                    pdf.text('Application Groups:', 25, yOffset);
                    yOffset += 6;
                    
                    sub.applicationGroups.forEach(ag => {
                        if (yOffset > 270) {
                            pdf.addPage();
                            yOffset = 20;
                        }
                        pdf.text(`  • ${ag.name} (${ag.applicationGroupType})`, 30, yOffset);
                        yOffset += 6;
                    });
                    yOffset += 4;
                }
                
                // Scaling Plans
                if (sub.scalingPlans && sub.scalingPlans.length > 0) {
                    pdf.text('Scaling Plans:', 25, yOffset);
                    yOffset += 6;
                    
                    sub.scalingPlans.forEach(sp => {
                        if (yOffset > 270) {
                            pdf.addPage();
                            yOffset = 20;
                        }
                        pdf.text(`  • ${sp.name} (${sp.hostPoolType || 'N/A'})`, 30, yOffset);
                        yOffset += 6;
                    });
                    yOffset += 4;
                }
                
                // Virtual Networks
                if (sub.virtualNetworks && sub.virtualNetworks.length > 0) {
                    pdf.text('Virtual Networks (AVD-connected):', 25, yOffset);
                    yOffset += 6;
                    
                    sub.virtualNetworks.forEach(vnet => {
                        if (yOffset > 270) {
                            pdf.addPage();
                            yOffset = 20;
                        }
                        const hostCount = vnet.connectedSessionHosts ? ` - ${vnet.connectedSessionHosts} session hosts` : '';
                        pdf.text(`  • ${vnet.name} (${vnet.addressSpace})${hostCount}`, 30, yOffset);
                        yOffset += 6;
                    });
                    yOffset += 4;
                }
                
                // Compute Galleries
                if (sub.computeGalleries && sub.computeGalleries.length > 0) {
                    pdf.text('Azure Compute Galleries:', 25, yOffset);
                    yOffset += 6;
                    
                    sub.computeGalleries.forEach(gallery => {
                        if (yOffset > 270) {
                            pdf.addPage();
                            yOffset = 20;
                        }
                        const imageCount = gallery.images ? gallery.images.length : 0;
                        pdf.text(`  • ${gallery.name} (${imageCount} images)`, 30, yOffset);
                        yOffset += 6;
                    });
                    yOffset += 4;
                }
                
                yOffset += 8;
            });
        }
        
        // Save PDF
        pdf.save(`AVD-Inventory-${new Date().toISOString().split('T')[0]}.pdf`);
        
    } catch (error) {
        console.error('Error exporting to PDF:', error);
        alert('Error exporting to PDF: ' + error.message);
    } finally {
        hideLoading();
    }
}

// Show/hide loading overlay
function showLoading() {
    document.getElementById('loadingOverlay').style.display = 'flex';
}

function hideLoading() {
    document.getElementById('loadingOverlay').style.display = 'none';
}
