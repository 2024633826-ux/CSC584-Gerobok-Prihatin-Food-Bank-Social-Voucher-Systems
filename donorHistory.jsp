<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.user"%>
<%@page import="java.util.List"%>
<%@page import="java.util.HashMap"%>
<%
    user activeUser = (user) session.getAttribute("loggedUser");
    if (activeUser == null || !activeUser.getRole().equalsIgnoreCase("donor")) {
        response.sendRedirect("login.jsp?error=Unauthorized");
        return;
    }
    
    List<HashMap<String, Object>> historyList = (List<HashMap<String, Object>>) request.getAttribute("historyList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Donation History - Gerobok Prihatin</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #fcf8f9; color: #333; display: flex; min-height: 100vh; }
        
        .sidebar { width: 260px; background: linear-gradient(180deg, #4A0012 0%, #2A000A 100%); color: white; padding: 30px 20px; }
        .sidebar h3 { color: #D4AF37; margin-bottom: 25px; font-size: 16px; text-transform: uppercase; letter-spacing: 1px; border-bottom: 2px solid rgba(212, 175, 55, 0.2); padding-bottom: 10px; }
        .sidebar ul { list-style: none; }
        .sidebar ul li { margin-bottom: 15px; }
        .sidebar ul li a, .sidebar ul li strong { display: block; padding: 12px 15px; text-decoration: none; border-radius: 5px; color: #f5f5f5; font-weight: 500; transition: all 0.3s; }
        .sidebar ul li strong.active { background-color: #800020; color: #D4AF37; border-left: 4px solid #D4AF37; }
        .sidebar ul li a:hover { background-color: rgba(255, 255, 255, 0.1); color: #D4AF37; padding-left: 20px; }
        
        .main-content { flex: 1; padding: 40px; }
        .header-title { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #800020; padding-bottom: 15px; margin-bottom: 30px; }
        .header-title h1 { color: #800020; font-size: 28px; }
        
        .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.04); margin-top: 15px; margin-bottom: 30px; }
        .data-table th { background-color: #4A0012; color: white; padding: 15px; text-align: left; font-size: 14px; }
        .data-table td { padding: 15px; border-bottom: 1px solid #eee; font-size: 15px; }
        
        .badge-verified { background-color: #2ecc71; color: white; padding: 4px 10px; border-radius: 12px; font-weight: bold; font-size: 11px; }
        .badge-pending { background-color: #f1c40f; color: #333; padding: 4px 10px; border-radius: 12px; font-weight: bold; font-size: 11px; }
        .badge-rejected { background-color: #e74c3c; color: white; padding: 4px 10px; border-radius: 12px; font-weight: bold; font-size: 11px; }
        
        .btn-pdf { background-color: #800020; color: white; border: none; padding: 12px 22px; font-weight: bold; border-radius: 4px; cursor: pointer; transition: background 0.2s; }
        .btn-pdf:hover { background-color: #4A0012; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h3>Gerobok Prihatin-<br>Donor Page</h3>
        <ul>
            <li><a href="donor.jsp">Dashboard</a></li>
            <li><a href="donorForm.jsp">Donation Detail</a></li>
            <li><a href="donorWishlist.jsp">Live Wishlist</a></li>
            <li><a href="gerobokPrihatinController?action=donationHistory" style="background-color: #800020; color: #D4AF37; border-left: 4px solid #D4AF37; font-weight: bold;">Donation History</a></li>
            <li><a href="gerobokPrihatinController?action=logout" style="color: #ff6b6b;">Logout</a></li>
        </ul>
    </div>

    <div class="main-content">
        <div class="header-title">
            <h1>History Donation</h1>
        </div>
        
        <p style="color: #555; margin-bottom: 20px;"></p>

        <table class="data-table">
            <thead>
                <tr>
                    <th>Donation ID</th>
                    <th>Item Description Name</th>
                    <th>Quantity Logged</th>
                    <th>Status State</th>
                </tr>
            </thead>
            <tbody>
                <%
                    if (historyList != null && !historyList.isEmpty()) {
                        for (HashMap<String, Object> row : historyList) {
                            String status = (String) row.get("status");
                            String badgeClass = "badge-pending";
                            
                            if ("Verified".equalsIgnoreCase(status) || "Approved".equalsIgnoreCase(status)) {
                                badgeClass = "badge-verified";
                            } else if ("Rejected".equalsIgnoreCase(status)) {
                                badgeClass = "badge-rejected";
                            }
                %>
                <tr>
                    <td><strong>DON-<%= row.get("donationId") %></strong></td>
                    <td><%= row.get("itemName") %></td>
                    <td><%= row.get("quantity") %> Units</td>
                    <td><span class="<%= badgeClass %>"><%= status %></span></td>
                </tr>
                <%
                        }
                    } else {
                %>
                <tr>
                    <td colspan="4" style="text-align: center; color: #999;">No donation history found. Start donating using the 'Donation Detail' form!</td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>

        <button type="button" class="btn-pdf" onclick="alert('Downloading compiled historic audit report data ledger into print-ready layout PDF format...')">📥 Download Audit Report (PDF)</button>
    </div>

</body>
</html>