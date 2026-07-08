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
    <title>Manage Distribution - Gerobok Prihatin</title>
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
        
        .summary-box-table { width: 100%; border-collapse: collapse; background-color: white; border-radius: 6px; overflow: hidden; box-shadow: 0 4px 10px rgba(0,0,0,0.02); border: 1px solid rgba(128,0,32,0.1); margin-bottom: 30px; }
        .summary-box-table td { padding: 25px; }
        
        fieldset { border: 1px solid rgba(128, 0, 32, 0.2); background: white; padding: 25px; border-radius: 8px; margin-bottom: 40px; }
        fieldset legend h3 { color: #800020; padding: 0 10px; }
        
        input[type="text"], input[type="number"], select { padding: 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; margin-top: 5px; }
        .btn-request { background-color: #800020; color: white; border: none; padding: 12px 20px; font-weight: bold; border-radius: 4px; cursor: pointer; }
        
        .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.04); margin-top: 15px; }
        .data-table th { background-color: #4A0012; color: white; padding: 15px; text-align: left; font-size: 14px; }
        .data-table td { padding: 15px; border-bottom: 1px solid #eee; font-size: 14px; vertical-align: middle; }
        
        .badge-pending { background-color: #f39c12; color: white; padding: 4px 10px; border-radius: 12px; font-weight: bold; font-size: 11px; }
        
        .btn-approve { background-color: #2ecc71; color: white; border: none; padding: 6px 12px; border-radius: 4px; font-weight: bold; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-approve:hover { background-color: #27ae60; }
        .btn-update { background-color: #3498db; color: white; border: none; padding: 6px 12px; border-radius: 4px; font-weight: bold; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-update:hover { background-color: #2980b9; }
        .btn-delete { background-color: #e74c3c; color: white; border: none; padding: 6px 12px; border-radius: 4px; font-weight: bold; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-delete:hover { background-color: #c0392b; }
        
        .alert { padding: 15px; margin-bottom: 20px; border-radius: 4px; font-weight: bold; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-danger { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h3>GEROBOK PRIHATIN - HEP Management</h3>
        <ul>
            <li><a href="gerobokPrihatinController?action=dashboard">Dashboard Overview</a></li>
            <li><a href="gerobokPrihatinController?action=manageInventory">Manage Inventory</a></li>
            <li><strong class="active">Manage Distribution</strong></li>
            <li><a href="gerobokPrihatinController?action=logout" style="color: #ff6b6b;">Logout</a></li>
        </ul>
    </div>

    <div class="main-content">
        <c:if test="${not empty param.status}">
            <c:choose>
                <c:when test="${param.status eq 'ApprovedSuccess'}">
                    <div class="alert alert-success">✅ Application successfully approved and stock inventory balance has been deducted!</div>
                </c:when>
                <c:when test="${param.status eq 'UpdateSuccess'}">
                    <div class="alert alert-success">✅ Allowed quantity successfully updated!</div>
                </c:when>
                <c:when test="${param.status eq 'MergedSuccess'}">
                    <div class="alert alert-success">✅ Manual request processed and structural records updated!</div>
                </c:when>
                <c:when test="${param.status eq 'RejectedSuccess'}">
                    <div class="alert alert-success">✅ Request successfully rejected!</div>
                </c:when>
                <c:when test="${param.status eq 'Error'}">
                    <div class="alert alert-danger">❌ Operation Failed: Check database connection or stock balance limit!</div>
                </c:when>
            </c:choose>
        </c:if>

        <table class="summary-box-table">
            <tr>
                <td>
                    <strong>Active Window Phase:</strong> Semester April-July 2026<br>
                    <small style="color: #666;">Counter Authority Profile Level: Higher Education Welfare Officer</small>
                </td>
                <td align="center" width="25%" style="background-color: #fff9ea; color: #b7791f; border-left: 1px solid #eee;">
                    <small>PENDING APPROVALS</small>
                    <h2 style="margin-top:5px;"><c:out value="${requestList != null ? requestList.size() : 0}"/> Requests</h2>
                </td>
            </tr>
        </table>

        <fieldset>
            <legend><h3>Log Manual Emergency Request</h3></legend>
            <p style="font-size: 13px; color: #666; margin-bottom: 10px;">Manually authorize instant food ration voucher overrides if a high-risk student registers on-site at the headquarters desk layout counter.</p>
            
            <form action="gerobokPrihatinController?action=createManualRequest" method="POST">
                <table border="0" cellpadding="5" width="100%">
                    <tr>
                        <td>Student Name:<br><input type="text" name="studentName" placeholder="e.g., Hamzah Bin Ahmad" required style="width: 90%;"></td>
                        <td>Student Matrix ID:<br><input type="text" name="studentId" placeholder="20264412" required style="width: 90%;"></td>
                        <td>
                            Select Item From Inventory Sourcing:<br>
                            <select name="wishlistId" required style="width: 90%;">
                                <option value="">-- Select Available Item Target --</option>
                                <%
                                    Connection connHep = null;
                                    Statement stmtHep = null;
                                    ResultSet rsHep = null;

                                    try {
                                        Class.forName("org.apache.derby.jdbc.ClientDriver");
                                        connHep = DriverManager.getConnection("jdbc:derby://localhost:1527/gerobok_prihatin", "app", "app");
                                        
                                        // Synced query to fetch active target rows matching marketplace inventory structure
                                        String sqlHep = "SELECT DONATIONID, ITEMNAME, QUANTITY FROM APP.INVENTORY WHERE QUANTITY > 0";
                                        stmtHep = connHep.createStatement();
                                        rsHep = stmtHep.executeQuery(sqlHep);

                                        while(rsHep.next()) {
                                            int id = rsHep.getInt("DONATIONID");
                                            String name = rsHep.getString("ITEMNAME");
                                            int qty = rsHep.getInt("QUANTITY");
                                %>
                                            <option value="<%= id %>">
                                                <%= name %> (Available Stock: <%= qty %> units)
                                            </option>
                                <%
                                        }
                                    } catch (Exception e) {
                                %>
                                        <option value="">Error loading items: <%= e.getMessage() %></option>
                                <%
                                    } finally {
                                        if (rsHep != null) try { rsHep.close(); } catch (Exception e) {}
                                        if (stmtHep != null) try { stmtHep.close(); } catch (Exception e) {}
                                        if (connHep != null) try { connHep.close(); } catch (Exception e) {}
                                    }
                                %>
                            </select>
                        </td>
                        <td>Qty:<br><input type="number" name="quantity" min="1" value="1" style="width: 60px;"></td>
                        <td valign="bottom">
                            <input type="submit" value="+ Create Request" class="btn-request">
                        </td>
                    </tr>
                </table>
            </form>
        </fieldset>

        <h2>Active Requests & Voucher Issuance</h2>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Req ID</th>
                    <th>Student Details</th>
                    <th>Item Requested</th>
                    <th width="22%">Quantity Allowed</th>
                    <th>Submission Date</th>
                    <th>Status State</th>
                    <th width="20%">Administrative Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty requestList}">
                        <c:forEach var="req" items="${requestList}">
                            <tr>
                                <td><c:out value="${req.requestId}"/></td>
                                <td>
                                    <strong><c:out value="${req.studentName}"/></strong><br>
                                    <small style="color: #777;">ID: <c:out value="${req.studentId}"/></small>
                                </td>
                                <td><c:out value="${req.itemName}"/></td>
                                <td>
                                    <form action="gerobokPrihatinController" method="POST" style="display:inline-flex; align-items: center; margin: 0;">
                                        <input type="hidden" name="action" value="updateDistributionQty">
                                        <input type="hidden" name="requestId" value="${req.requestId}">
                                        <input type="number" name="allowedQuantity" value="${req.quantity}" style="width: 60px; padding: 4px; margin: 0 4px 0 0;" min="1">
                                        <button type="submit" class="btn-update" style="padding: 4px 8px; font-size: 12px;">Update</button>
                                    </form>
                                </td>
                                <td><c:out value="${req.date}"/></td> 
                                <td align="center">
                                    <span class="badge-pending">Pending</span>
                                </td>
                                <td align="center">
                                    <div style="display: flex; gap: 8px; justify-content: center;">
                                        <a href="gerobokPrihatinController?action=approveRequest&requestId=${req.requestId}" 
                                           class="btn-approve" 
                                           onclick="return confirm('Confirm approval for this student\'s voucher?')">Approve</a>
                                        <a href="gerobokPrihatinController?action=rejectRequest&requestId=${req.requestId}" 
                                           class="btn-delete" 
                                           onclick="return confirm('Reject this request?')">Reject</a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="7" align="center" style="color: #999; padding: 30px;">No active distribution requests found in queue.</td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

</body>
</html>