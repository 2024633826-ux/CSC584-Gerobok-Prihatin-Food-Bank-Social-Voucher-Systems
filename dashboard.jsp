<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="model.user"%>
<%
    // Kawalan Keselamatan - Pengguna wajib log masuk
    if (session == null || session.getAttribute("loggedUser") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    user loggedUser = (user) session.getAttribute("loggedUser");
    String staffName = (loggedUser != null) ? loggedUser.getFullName() : "Staff Member";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HEP Staff View - Dashboard Overview</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #fcf8f9; color: #333; display: flex; min-height: 100vh; }
        
        .sidebar { width: 260px; background: linear-gradient(180deg, #4A0012 0%, #2A000A 100%); color: white; padding: 30px 20px; }
        .sidebar h3 { color: #D4AF37; margin-bottom: 25px; font-size: 20px; text-transform: uppercase; letter-spacing: 1px; border-bottom: 2px solid rgba(212, 175, 55, 0.2); padding-bottom: 10px; }
        .sidebar ul { list-style: none; }
        .sidebar ul li { margin-bottom: 15px; }
        .sidebar ul li a, .sidebar ul li strong { display: block; padding: 12px 15px; text-decoration: none; border-radius: 5px; color: #f5f5f5; font-weight: 500; transition: all 0.3s; }
        .sidebar ul li strong.active { background-color: #800020; color: #D4AF37; border-left: 4px solid #D4AF37; }
        .sidebar ul li a:hover { background-color: rgba(255, 255, 255, 0.1); color: #D4AF37; padding-left: 20px; }
        
        .main-content { flex: 1; padding: 40px; }
        .header-title { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #800020; padding-bottom: 15px; margin-bottom: 20px; }
        .header-title h1 { color: #800020; font-size: 28px; }

        .welcome-banner { background-color: #fff; border: 1px solid rgba(128,0,32,0.1); padding: 15px 20px; border-radius: 6px; margin-bottom: 25px; box-shadow: 0 2px 8px rgba(0,0,0,0.01); }
        .welcome-banner p { font-size: 15px; color: #555; }
        .welcome-banner strong { color: #800020; font-weight: 600; }

        .metrics-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }
        .metric-card { background-color: #fff; border: 1px solid #f0d5da; border-left: 5px solid #800020; padding: 20px; border-radius: 6px; box-shadow: 0 4px 10px rgba(0,0,0,0.02); display: flex; flex-direction: column; justify-content: space-between; }
        .metric-card h4 { font-size: 13px; color: #777; text-transform: uppercase; margin-bottom: 10px; font-weight: 600; }
        .metric-card h1 { font-size: 36px; color: #800020; font-weight: 700; margin-bottom: 5px; }
        .metric-card p { font-size: 13px; color: #999; }

        .charts-container { display: grid; grid-template-columns: 1fr 1fr; gap: 25px; margin-bottom: 40px; }
        .chart-box { background-color: #fff; border: 1px solid rgba(128,0,32,0.1); border-radius: 8px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); }
        .chart-box h4 { font-size: 16px; color: #4A0012; margin-bottom: 20px; text-align: center; font-weight: 600; }
        .canvas-wrapper { position: relative; width: 100%; height: 320px; }

        .data-table-section { margin-top: 20px; }
        .data-table-section h2 { color: #800020; font-size: 22px; margin-bottom: 15px; }
        .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.04); border: 1px solid rgba(128,0,32,0.1); }
        .data-table th { background-color: #4A0012; color: white; padding: 15px; text-align: left; font-size: 14px; }
        .data-table td { padding: 15px; border-bottom: 1px solid #eee; font-size: 14px; vertical-align: middle; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h3>GEROBOK PRIHATIN - HEP Management</h3>
        <ul>
            <li><a href="${pageContext.request.contextPath}/DashboardServlet" style="background-color: #800020; color: #D4AF37; border-left: 4px solid #D4AF37; font-weight: bold;">Dashboard</a></li>
            <li><a href="gerobokPrihatinController?action=manageInventory">Manage Inventory</a></li>
            <li><a href="HepDistribution.jsp">Manage Distribution</a></li>
            <li><a href="gerobokPrihatinController?action=logout" style="color: #ff6b6b;">Logout</a></li>
        </ul>
    </div>

    <div class="main-content">
        <div class="header-title">
            <h1>Dashboard Overview</h1>
        </div>

        <div class="welcome-banner">
            <p>Welcome back, <strong><%= staffName %></strong></p>
        </div>

        <div class="metrics-grid">
            <div class="metric-card">
                <h4>Total SKU Categories</h4>
                <h1>${totalCategories != null ? totalCategories : '0'}</h1>
                <p>registered categories</p>
            </div>
            <div class="metric-card">
                <h4>Total Stock Volume</h4>
                <h1>${totalStockVolume != null ? totalStockVolume : '0'}</h1>
                <p>units in central depot</p>
            </div>
            <div class="metric-card">
                <h4>Total Donors</h4>
                <h1>${totalDonors != null ? totalDonors : '0'}</h1>
                <p>registered people</p>
            </div>
            <div class="metric-card">
                <h4>Pending Donations</h4>
                <h1>${pendingDonations != null ? pendingDonations : '0'}</h1>
                <p>awaiting verification</p>
            </div>
        </div>

        <div class="charts-container">
            <div class="chart-box">
                <h4>Total Food Items (Bar Chart)</h4>
                <div class="canvas-wrapper">
                    <canvas id="realBarChart"></canvas>
                </div>
            </div>

            <div class="chart-box">
                <h4>Total Food Items (Pie Chart Distribution)</h4>
                <div class="canvas-wrapper">
                    <canvas id="realPieChart"></canvas>
                </div>
            </div>
        </div>

        <div class="data-table-section">
            <h2>Current Inventory Stock Summary</h2>
            <table class="data-table">
                <thead>
                    <tr>
                        <th width="45%">Item Name</th>
                        <th width="30%">Category</th>
                        <th width="25%">Current Quantity</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty inventoryList}">
                            <tr>
                                <td colspan="3" align="center" style="color: #777; padding: 30px;">No inventory records found in the system.</td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="item" items="${inventoryList}">
                                <tr>
                                    <td><strong><c:out value="${item.itemName}"/></strong></td>
                                    <td><c:out value="${item.category}"/></td>
                                    <td><c:out value="${item.quantity}"/> units</td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <script>

        const riceCount = ${riceQty != null ? riceQty : 0};
        const noodleCount = ${noodleQty != null ? noodleQty : 0};
        const flourBakingCount = ${flourBakingQty != null ? flourBakingQty : 0};
        const cannedCount = ${cannedQty != null ? cannedQty : 0};
        const saucesCondimentsCount = ${saucesCondimentsQty != null ? saucesCondimentsQty : 0};
        const beveragesCount = ${beveragesQty != null ? beveragesQty : 0};
        const cerealsBiscuitsCount = ${cerealsBiscuitsQty != null ? cerealsBiscuitsQty : 0};
        const bodyHygieneCount = ${bodyHygieneQty != null ? bodyHygieneQty : 0};
        const sanitaryCount = ${sanitaryQty != null ? sanitaryQty : 0};
        const othersCount = ${othersQty != null ? othersQty : 0};

        const categoryLabels = [
            'Rice', 'Noodle', 'Flour & Baking', 'Canned Food', 
            'Sauces & Condiments', 'Beverages', 'Cereals & Biscuits', 
            'Body Hygiene', 'Sanitary Products', 'Others'
        ];
        
        const chartDataValues = [
            riceCount, noodleCount, flourBakingCount, cannedCount, 
            black=saucesCondimentsCount, beveragesCount, cerealsBiscuitsCount, 
            bodyHygieneCount, sanitaryCount, othersCount
        ];

        const chartColors = [
            '#4A0012', '#630018', '#800020', '#9c1a36', '#b33c56', 
            '#c95d73', '#d9899a', '#e6b3bd', '#f2d5da', '#2A000A'
        ];
        
        const borderColors = [
            '#2A000A', '#4A0012', '#630018', '#800020', '#9c1a36', 
            '#b33c56', '#c95d73', '#d9899a', '#e6b3bd', '#000000'
        ];

        // Render Bar Chart
        const ctxBar = document.getElementById('realBarChart').getContext('2d');
        new Chart(ctxBar, {
            type: 'bar',
            data: {
                labels: categoryLabels,
                datasets: [{
                    label: 'Stock Quantity',
                    data: chartDataValues,
                    backgroundColor: chartColors,
                    borderColor: borderColors,
                    borderWidth: 1,
                    barThickness: 24
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: { beginAtZero: true, grid: { color: '#f3e6e8' } },
                    x: { grid: { display: false }, ticks: { font: { size: 10 } } }
                }
            }
        });

        // Render Pie Chart
        const ctxPie = document.getElementById('realPieChart').getContext('2d');
        new Chart(ctxPie, {
            type: 'pie',
            data: {
                labels: categoryLabels,
                datasets: [{
                    data: chartDataValues,
                    backgroundColor: chartColors,
                    borderWidth: 2,
                    borderColor: '#fff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { 
                        position: 'right', 
                        labels: { boxWidth: 12, font: { size: 11 } } 
                    }
                }
            }
        });
    </script>
</body>
</html>