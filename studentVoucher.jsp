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
    <title>My Vouchers - Gerobok Prihatin</title>
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

        .voucher-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 25px; margin-bottom: 40px; }
        .voucher-card { background: white; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); overflow: hidden; border: 1px solid #eee; display: flex; flex-direction: column; }
        .voucher-header { background: #800020; color: white; padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; }
        .voucher-header h3 { font-size: 16px; text-transform: uppercase; letter-spacing: 0.5px; }
        .status-badge { background: #fffdf5; color: #D4AF37; font-size: 11px; font-weight: bold; padding: 4px 10px; border-radius: 20px; border: 1px solid #D4AF37; }
        .status-pending { background: #e67e22; color: white; border: none; }
        
        .voucher-body { padding: 20px; flex: 1; }
        .item-name { color: #2A000A; font-size: 18px; font-weight: bold; margin-bottom: 15px; }
        .voucher-details { margin-bottom: 15px; font-size: 14px; color: #555; }
        .voucher-details p { margin-bottom: 8px; }
        
        .secure-box { background: #fdf2f4; border: 1px dashed #800020; padding: 12px; border-radius: 6px; text-align: center; margin-top: 10px; }
        .secure-box p { font-size: 12px; color: #800020; font-weight: bold; margin-bottom: 5px; }
        .voucher-code { font-family: 'Courier New', Courier, monospace; font-size: 18px; font-weight: bold; color: #333; letter-spacing: 1px; margin-bottom: 8px; }
        
        .barcode-container { display: flex; justify-content: center; margin-top: 10px; background: white; padding: 5px; border-radius: 4px; }
        .barcode-container img { max-width: 100%; height: auto; }
        
        .info-card { background: #fffdf5; border: 1px dashed #D4AF37; border-radius: 8px; padding: 20px; color: #555; }
        .info-card strong { color: #2A000A; display: block; margin-bottom: 8px; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h3>Gerobok Prihatin - Student</h3>
        <ul>
            <li><a href="gerobokPrihatinController?action=viewMarketplace">Dashboard</a></li>
            <li><a href="studentVoucher.jsp" class="active">My Voucher</a></li>
            <li><a href="studentProfile.jsp">My Profile</a></li>
            <li><a href="gerobokPrihatinController?action=logout" style="color: #ff7675;">Logout</a></li>
        </ul>
    </div>

    <div class="main-content">
        <div class="header-title">
            <h1>My Active Voucher Tokens</h1>
        </div>

        <div class="voucher-grid">
            
            <div class="voucher-card">
                <div class="voucher-header">
                    <h3>Voucher Token</h3>
                    <span class="status-badge">READY FOR PICKUP</span>
                </div>
                <div class="voucher-body">
                    <div class="item-name">Premium White Rice (5kg)</div>
                    <div class="voucher-details">
                        <p><strong>Qty Requested:</strong> 1 unit</p>
                        <p><strong>Approved Date:</strong> 2026-07-05</p>
                        <p style="color: #c0392b;"><strong>Expiry Date:</strong> 2026-07-12 (7 days left)</p>
                    </div>
                    <div class="secure-box">
                        <p>SHOW THIS TO HEP WAREHOUSE STAFF</p>
                        <div class="voucher-code">VCH-4552 | PIN: 8819</div>
                        <div class="barcode-container">
                            <img src="https://bwipjs-api.metafloor.com/?bcid=code128&text=VCH4552&scale=2&rotate=N&includeText=false" alt="Barcode">
                        </div>
                    </div>
                </div>
            </div>

            <div class="voucher-card">
                <div class="voucher-header" style="background: #e67e22;">
                    <h3>Voucher Token</h3>
                    <span class="status-badge status-pending">PENDING HEP</span>
                </div>
                <div class="voucher-body">
                    <div class="item-name">Canned Sardines (150g)</div>
                    <div class="voucher-details">
                        <p><strong>Qty Requested:</strong> 2 units</p>
                        <p><strong>Requested Date:</strong> 2026-07-08</p>
                        <p><strong>Expiry Date:</strong> Pending approval</p>
                    </div>
                    <div class="secure-box" style="background: #fdfaf4; border-color: #e67e22;">
                        <p style="color: #d35400;">WAITING FOR HEP VERIFICATION</p>
                        <div class="voucher-code" style="color: #999; font-size: 15px;">Gen-No & PIN Pending</div>
                    </div>
                </div>
            </div>

        </div>

        <div class="info-card">
            <strong>How to redeem your food items:</strong>
            <p>1. Ensure your voucher status has changed to READY FOR PICKUP.</p>
            <p>2. Present the generated Voucher Number, PIN, or scan the Barcode to the HEP officer at the Central Food Bank counter.</p>
            <p>3. Make sure to collect your items before the stated Expiry Date to avoid token cancellation.</p>
        </div>
    </div>

</body>
</html>