<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.user"%>
<%@page import="java.sql.*"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
    if (session == null || session.getAttribute("loggedUser") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    user activeUser = (user) session.getAttribute("loggedUser");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Inventory - Gerobok Prihatin</title>
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
        .header-title { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #800020; padding-bottom: 15px; margin-bottom: 30px; }
        .header-title h1 { color: #800020; font-size: 28px; }
        
        .summary-box-table { width: 100%; border-collapse: collapse; background-color: white; border-radius: 6px; overflow: hidden; box-shadow: 0 4px 10px rgba(0,0,0,0.02); border: 1px solid rgba(128,0,32,0.1); margin-bottom: 30px; }
        .summary-box-table td { padding: 25px; }
        
        fieldset { border: 1px solid rgba(128, 0, 32, 0.2); background: white; padding: 25px; border-radius: 8px; margin-bottom: 40px; }
        fieldset legend h3 { color: #800020; padding: 0 10px; }
        
        table.form-layout td { padding: 8px; font-weight: 600; font-size: 14px; }
        input[type="text"], input[type="number"], input[type="date"], select { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; margin-top: 5px; font-weight: normal; }
        
        .btn-submit { background-color: #000000; color: white; border: none; padding: 12px 24px; font-weight: bold; border-radius: 4px; cursor: pointer; font-size: 14px; }
        .btn-submit:hover { background-color: #222; }
        .btn-clear { background-color: #ffffff; color: #333; border: 1px solid #ccc; padding: 12px 24px; font-weight: bold; border-radius: 4px; cursor: pointer; font-size: 14px; margin-left: 10px; }
        .btn-clear:hover { background-color: #f5f5f5; }
        
        .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.04); margin-top: 15px; }
        .data-table th { background-color: #4A0012; color: white; padding: 15px; text-align: left; font-size: 14px; }
        .data-table td { padding: 15px; border-bottom: 1px solid #eee; font-size: 14px; vertical-align: middle; }
        
        .btn-action-update { background-color: #000000; color: white; border: none; padding: 8px 14px; border-radius: 4px; font-weight: bold; cursor: pointer; text-decoration: none; display: inline-block; font-size: 12px; }
        .btn-action-update:hover { background-color: #222222; }
        .btn-action-delete { background-color: #e74c3c; color: white; border: none; padding: 8px 14px; border-radius: 4px; font-weight: bold; cursor: pointer; text-decoration: none; display: inline-block; font-size: 12px; }
        .btn-action-delete:hover { background-color: #c0392b; }
        
        .alert { padding: 15px; margin-bottom: 20px; border-radius: 4px; font-weight: bold; font-size: 14px; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-danger { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h3>GEROBOK PRIHATIN - HEP Management</h3>
        <ul>
            <li><a href="gerobokPrihatinController?action=dashboard">Dashboard Overview</a></li>
            <li><strong class="active">Manage Inventory</strong></li>
            <li><a href="HepDistribution.jsp">Manage Distribution</a></li>
            <li><a href="gerobokPrihatinController?action=logout" style="color: #ff6b6b;">Logout</a></li>
        </ul>
    </div>

    <div class="main-content">
        <div class="header-title">
            <h1>Facility & Stock Control Ledger</h1>
        </div>

        <c:if test="${not empty param.status}">
            <c:choose>
                <c:when test="${param.status eq 'AddSuccess'}">
                    <div class="alert alert-success">✅ New inventory item recorded successfully!</div>
                </c:when>
                <c:when test="${param.status eq 'UpdateSuccess'}">
                    <div class="alert alert-success">✅ Stock quantity updated successfully!</div>
                </c:when>
                <c:when test="${param.status eq 'DeleteSuccess'}">
                    <div class="alert alert-success">✅ Stock record deleted permanently!</div>
                </c:when>
                <c:when test="${param.status eq 'Error'}">
                    <div class="alert alert-danger">❌ An error occurred processing the data transaction. Please check your system logs.</div>
                </c:when>
            </c:choose>
        </c:if>

        <table class="summary-box-table">
            <tr>
                <td>
                    <strong>Division of Student's Affairs Facility:</strong> Budisiswa Building, 40450 Shah Alam, Selangor<br>
                    <small style="color: #666;">Stock Audited: Live Tracking Database</small>
                </td>
                <td align="center" width="25%" style="background-color: #f5f5f5; border-left: 1px solid #eee;">
                    <small style="font-weight: bold; color: #555;">Total Registered Categories</small>
                    <h2 style="margin-top:5px;"><c:out value="${totalCategories != null ? totalCategories : 0}"/> Categories</h2>
                </td>
                <td align="center" width="25%" style="background-color: #e2e8f0; color: #1a202c;">
                    <small style="font-weight: bold;">Total Stock Volume</small>
                    <h2 style="margin-top:5px;"><c:out value="${totalStockVolume != null ? totalStockVolume : 0}"/> Units</h2>
                </td>
                <td align="center" width="25%" style="background-color: #2d3748; color: #f7fafc;">
                    <small style="color: #cbd5e0;">Alert Thresholds</small>
                    <h2 style="margin-top:5px; color: #fc8181;">0 Deficits</h2>
                </td>
            </tr>
        </table>

        <fieldset>
            <legend><h3>Add New Stock Item Entry</h3></legend>
            <p style="font-size: 13px; color: #666; margin-bottom: 15px;">Declare incoming bulk supply drop-offs to add inventory counts to student voucher distribution registers.</p>
            
            <form action="InventoryController" method="POST">
                <input type="hidden" name="action" value="addStock">
                <table border="0" class="form-layout" width="100%">
                    <tr>
                        <td width="20%">Assigned:</td>
                        <td>
                            <select name="donorId" required style="width: 50%;">
                                <option value="ALL">📢 BROADCAST TO ALL DONORS</option>
                                <%
                                    Connection conn = null;
                                    Statement stmt = null;
                                    ResultSet rs = null;
                                    try {
                                        Class.forName("org.apache.derby.jdbc.ClientDriver");
                                        conn = DriverManager.getConnection("jdbc:derby://localhost:1527/gerobok_prihatin", "app", "app");
                                        stmt = conn.createStatement();
                                        rs = stmt.executeQuery("SELECT DONORID, USERNAME FROM APP.DONOR");
                                        while (rs.next()) {
                                %>
                                                <option value="<%= rs.getInt("DONORID") %>">ID: <%= rs.getInt("DONORID") %> - <%= rs.getString("USERNAME") %></option>
                                <%
                                        }
                                    } catch (Exception e) {
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (Exception e) {}
                                        if (stmt != null) try { stmt.close(); } catch (Exception e) {}
                                        if (conn != null) try { conn.close(); } catch (Exception e) {}
                                    }
                                %>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td>Urgency:</td>
                        <td>
                            <select name="category" required style="width: 50%;">
                                <option value="">-- Select Urgency Level --</option>
                                <option value="High">High Urgency</option>
                                <option value="Medium">Medium Urgency</option>
                                <option value="Low">Low Urgency</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td>Item Brand Name:</td>
                        <td><input type="text" name="itemName" placeholder="e.g., Premium White Rice (5kg)" required style="width: 50%;"></td>
                    </tr>
                    <tr>
                        <td>Batch Quantity:</td>
                        <td><input type="number" name="quantity" min="1" value="1" required style="width: 25%;"> <span style="font-weight: normal; margin-left: 5px;">units</span></td>
                    </tr>
                    <tr>
                        <td>Batch Expiry Date:</td>
                        <td><input type="date" name="expiryDate" style="width: 25%;"> <span style="font-size: 12px; color: #777; margin-left:5px;">(Optional)</span></td>
                    </tr>
                    <tr>
                        <td></td>
                        <td style="padding-top: 15px;">
                            <input type="submit" value="Add to Live Inventory Ledger" class="btn-submit">
                            <input type="reset" value="Clear Form" class="btn-clear">
                        </td>
                    </tr>
                </table>
            </form>
        </fieldset>

        <h2>Current Stock Inventory Records</h2>
        <p style="font-size: 13px; color: #666; margin-bottom: 15px;">Perform regular audits. Adjust active batch balances inline or wipe decommissioned stock allocations permanently.</p>

        <table class="data-table">
            <thead>
                <tr>
                    <th width="35%">Item Asset Details</th>
                    <th width="25%">Quantity Available</th>
                    <th width="20%">Expiry Timeline Date</th>
                    <th width="20%">Administrative Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty inventoryList}">
                        <tr>
                            <td colspan="4" align="center" style="color: #777; padding: 30px;">No items found in inventory storage.</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="item" items="${inventoryList}">
                            <tr>
                                <form action="InventoryController" method="POST">
                                    <input type="hidden" name="action" value="updateStockQty">
                                    <input type="hidden" name="donationId" value="${item.donationId}">
                                    
                                    <td>
                                        <strong><c:out value="${item.itemName}"/></strong><br>
                                        <small style="color: #777;">Urgency: <c:out value="${item.category}"/></small>
                                    </td>
                                    <td>
                                        <div style="display: flex; align-items: center;">
                                            <input type="number" name="quantity" value="${item.quantity}" style="width: 70px; padding: 6px; text-align: center; margin-top:0;" min="0">
                                            <span style="margin-left: 8px; color: #555;">units</span>
                                        </div>
                                    </td>
                                    <td><c:out value="${item.expiryDate}"/></td>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 8px;">
                                            <input type="submit" value="Update Stock" class="btn-action-update">
                                            <a href="InventoryController?action=deleteStock&donationId=${item.donationId}" class="btn-action-delete" onclick="return confirm('Are you sure you want to permanently delete this item?')">Delete</a>
                                        </div>
                                    </td>
                                </form>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
        
        <p style="font-size: 12px; color: #666; margin-top: 20px;">* Note: Any alterations submitted across these inventory matrices directly influence distribution request options on the HepDistribution portal window.</p>
    </div>

</body>
</html>