<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="model.user"%>
<%
    user activeUser = (user) session.getAttribute("loggedUser");
    if (activeUser == null || !activeUser.getRole().equalsIgnoreCase("student")) {
        response.sendRedirect("login.jsp?error=Unauthorized");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Profile & History - Gerobok Prihatin</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #fcf8f9; color: #333; display: flex; min-height: 100vh; }
        .sidebar { width: 260px; background: linear-gradient(180deg, #4A0012 0%, #2A000A 100%); color: white; padding: 30px 20px; }
        .sidebar h3 { color: #D4AF37; margin-bottom: 25px; font-size: 20px; text-transform: uppercase; border-bottom: 2px solid rgba(212, 175, 55, 0.2); padding-bottom: 10px; }
        .sidebar ul { list-style: none; }
        .sidebar ul li { margin-bottom: 15px; }
        .sidebar ul li a { display: block; padding: 12px 15px; color: #eee; text-decoration: none; border-radius: 4px; transition: 0.2s; }
        .sidebar ul li a:hover, .sidebar ul li a.active { background: rgba(212, 175, 55, 0.2); color: #D4AF37; font-weight: bold; }
        
        .main-content { flex: 1; padding: 40px; overflow-y: auto; }
        .header-title { border-bottom: 2px solid #800020; padding-bottom: 15px; margin-bottom: 30px; }
        .header-title h1 { color: #800020; font-size: 28px; }
        
        .profile-container { display: flex; gap: 20px; margin-bottom: 40px; }
        .profile-card { flex: 2; background: white; padding: 25px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); border-left: 5px solid #800020; }
        .profile-card h2 { color: #800020; margin-bottom: 15px; font-size: 22px; }
        .profile-card p { font-size: 15px; margin-bottom: 10px; color: #555; }
        .profile-card p strong { color: #333; }
        
        .metrics-card { flex: 1; background: white; padding: 25px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); border-top: 5px solid #D4AF37; }
        .metrics-card h4 { color: #2A000A; margin-bottom: 15px; font-size: 16px; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid #eee; padding-bottom: 5px; }
        .metrics-card ul { list-style: none; }
        .metrics-card ul li { font-size: 14px; margin-bottom: 10px; color: #555; display: flex; justify-content: space-between; }
        .metrics-card ul li strong { color: #800020; }
        
        .section-title { color: #800020; font-size: 20px; margin-bottom: 15px; margin-top: 20px; }
        .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 10px rgba(0,0,0,0.05); margin-bottom: 35px; }
        .data-table th { background-color: #800020; color: white; text-align: left; padding: 15px; font-size: 14px; text-transform: uppercase; }
        .data-table td { padding: 15px; border-bottom: 1px solid #eee; font-size: 14px; color: #444; }
        .status-collected { color: #2ecc71; font-weight: bold; }
        .status-expired { color: #95a5a6; font-style: italic; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h3>Gerobok Prihatin - Student</h3>
        <ul>
            <li><a href="gerobokPrihatinController?action=viewMarketplace">Dashboard</a></li>
            <li><a href="studentVoucher.jsp">My Voucher</a></li>
            <li><a href="studentProfile.jsp" class="active">My Profile</a></li>
            <li><a href="gerobokPrihatinController?action=logout" style="color: #ff7675;">Logout</a></li>
        </ul>
    </div>

    <div class="main-content">
        <div class="profile-container">
            <div class="profile-card">
                <h2><%= activeUser.getFullName() %></h2>
                <p><strong>Student ID:</strong> <%= activeUser.getStudentId() %></p>
                <p><strong>Program:</strong> <%= activeUser.getProgram() %></p>
                <p><strong>Account Status:</strong> <span style="color: #2ecc71; font-weight: bold;">ACTIVE</span></p>
            </div>
            
            <div class="metrics-card">
                <h4>Voucher Summary Metrics</h4>
                <ul>
                    <li>Total Claimed: <strong>5 items</strong></li>
                    <li>Total Expired: <strong>2 tokens</strong></li>
                    <li>Active Balance: <strong>3 tokens</strong></li>
                </ul>
            </div>
        </div>

        <h3 class="section-title">Food Bank Claim & Collection History</h3>
        <p style="color: #666; margin-bottom: 15px; font-size: 14px;">Below is the complete record of items you have successfully claimed and collected from the food bank facility.</p>
        
        <table class="data-table">
            <thead>
                <tr>
                    <th>Voucher ID</th>
                    <th>Food Item Name</th>
                    <th>Collection Date</th>
                    <th>Handled By (HEP)</th>
                    <th>Status Log</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>VCH-4110</strong></td>
                    <td>Premium White Rice (5kg)</td>
                    <td>2026-05-10</td>
                    <td>Staff Ahmad</td>
                    <td><span class="status-collected">COLLECTED</span></td>
                </tr>
                <tr>
                    <td><strong>VCH-3982</strong></td>
                    <td>Canned Sardines (150g)</td>
                    <td>2026-04-28</td>
                    <td>Staff Aminah</td>
                    <td><span class="status-collected">COLLECTED</span></td>
                </tr>
                <tr>
                    <td><strong>VCH-3811</strong></td>
                    <td>Instant Noodles (Pack of 5)</td>
                    <td>2026-04-15</td>
                    <td>Staff Ahmad</td>
                    <td><span class="status-collected">COLLECTED</span></td>
                </tr>
            </tbody>
        </table>

        <h3 class="section-title">Expired Voucher Tokens</h3>
        <p style="color: #666; margin-bottom: 15px; font-size: 14px;">The following digital voucher tokens were not utilized within their validity period and have expired.</p>
        
        <table class="data-table">
            <thead>
                <tr>
                    <th>Token ID</th>
                    <th>Issue Date</th>
                    <th>Expiry Date</th>
                    <th>Reason / Status</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>TKN-9921-EXP</strong></td>
                    <td>2026-03-01</td>
                    <td>2026-03-31</td>
                    <td><span class="status-expired">Expired (Unused Token)</span></td>
                </tr>
                <tr>
                    <td><strong>TKN-9540-EXP</strong></td>
                    <td>2026-02-01</td>
                    <td>2026-02-28</td>
                    <td><span class="status-expired">Expired (Unused Token)</span></td>
                </tr>
            </tbody>
        </table>
    </div>

</body>
</html>