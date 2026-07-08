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
    <title>Food Bank Marketplace - Gerobok Prihatin</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #fcf8f9; color: #333; display: flex; min-height: 100vh; }
        
        .sidebar { width: 260px; background: linear-gradient(180deg, #4A0012 0%, #2A000A 100%); color: white; padding: 30px 20px; }
        .sidebar h3 { color: #D4AF37; margin-bottom: 25px; font-size: 20px; text-transform: uppercase; border-bottom: 2px solid rgba(212, 175, 55, 0.2); padding-bottom: 10px; }
        .sidebar ul { list-style: none; }
        .sidebar ul li { margin-bottom: 15px; }
        .sidebar ul li a { display: block; padding: 12px 15px; color: #eee; text-decoration: none; border-radius: 4px; transition: all 0.3s; }
        .sidebar ul li a:hover, .sidebar ul li a.active { background: rgba(212, 175, 55, 0.2); color: #D4AF37; font-weight: bold; }
        
        .main-content { flex: 1; padding: 40px; }
        .header-title { border-bottom: 2px solid #800020; padding-bottom: 15px; margin-bottom: 30px; }
        .header-title h1 { color: #800020; font-size: 28px; }
        
        .user-status-bar { display: flex; justify-content: space-between; align-items: center; background: white; padding: 15px 25px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); margin-bottom: 30px; gap: 20px; }
        .user-info { line-height: 1.6; }
        .user-info small { color: #2ecc71; font-weight: bold; }
        .token-balance { text-align: right; line-height: 1.6; }
        .token-count { font-size: 16px; font-weight: bold; color: #800020; background: #fdf2f4; padding: 6px 14px; border-radius: 20px; border: 1px solid #f5d6dc; display: inline-block; margin-top: 5px; white-space: nowrap; }

        .filter-section { background: white; border: 1px solid #eee; border-radius: 8px; padding: 20px; margin-bottom: 30px; box-shadow: 0 2px 5px rgba(0,0,0,0.02); }
        .filter-section legend { font-weight: bold; color: #800020; padding: 0 10px; font-size: 14px; text-transform: uppercase; }
        .filter-grid { display: flex; justify-content: space-between; gap: 20px; align-items: center; }
        .filter-input-group { display: flex; gap: 10px; align-items: center; flex: 1; }
        .filter-input-group input[type="text"], .filter-select select { padding: 8px 12px; border: 1px solid #ccc; border-radius: 4px; width: 100%; max-width: 300px; background-color: #ffffff; }
        .btn-search { background-color: #800020; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; }
        .btn-search:hover { background-color: #4A0012; }

        .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 10px rgba(0,0,0,0.05); margin-bottom: 30px; }
        .data-table th { background-color: #800020; color: white; text-align: left; padding: 15px; font-size: 14px; text-transform: uppercase; }
        .data-table td { padding: 15px; border-bottom: 1px solid #eee; font-size: 14px; vertical-align: middle; }
        
        .input-qty { width: 70px; padding: 6px; border: 1px solid #ccc; border-radius: 4px; text-align: center; }
        .btn-claim { background-color: #800020; color: white; border: none; padding: 10px 18px; border-radius: 4px; font-weight: bold; cursor: pointer; transition: background 0.2s; }
        .btn-claim:hover { background-color: #4A0012; }
        
        .rules-card { background: #fffdf5; border: 1px dashed #D4AF37; border-radius: 8px; padding: 20px; color: #555; margin-bottom: 15px; }
        .rules-card strong { color: #2A000A; display: block; margin-bottom: 10px; }
        .rules-card ul { list-style-position: inside; }
        .rules-card ul li { margin-bottom: 8px; font-size: 14px; }
        .note-text { color: #777; font-size: 12px; font-style: italic; }
        
        .alert-msg { padding: 15px; margin-bottom: 20px; border-radius: 4px; font-weight: bold; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h3>Gerobok Prihatin - STUDENT</h3>
        <ul>
            <li><a href="gerobokPrihatinController?action=viewMarketplace" class="active">Dashboard</a></li>
            <li><a href="studentVoucher.jsp">My Voucher</a></li>
            <li><a href="studentProfile.jsp">My Profile</a></li>
            <li><a href="gerobokPrihatinController?action=logout" style="color: #ff7675;">Logout</a></li>
        </ul>
    </div>

    <div class="main-content">
        
        <div class="header-title">
            <h1>Available Food Items Marketplace</h1>
        </div>

        <c:if test="${param.status == 'RequestSubmitted'}">
            <div class="alert-msg alert-success">Item successfully requested! Your request has been sent for HEP approval.</div>
        </c:if>
        <c:if test="${param.status == 'Error'}">
            <div class="alert-msg alert-error">An error occurred while processing your request. Please try again.</div>
        </c:if>

        <div class="user-status-bar">
            <div class="user-info">
                <strong>Welcome,</strong> <%= activeUser.getFullName() %><br>
                <strong>Student ID:</strong> <%= activeUser.getStudentId() != null ? activeUser.getStudentId() : "Not Updated" %><br>
                <strong>Program:</strong> <%= activeUser.getProgram() != null ? activeUser.getProgram() : "Not Updated" %><br>
                <small>Portal Status: Verified</small>
            </div>
            <div class="token-balance">
                <strong>Voucher Token Balance:</strong> <br>
                <span class="token-count">3 Tokens Available</span>
            </div>
        </div>

        <p style="color: #555; margin-bottom: 20px;">Select an item below to claim. Each claim will deduct 1 voucher from your balance and requires HEP approval to generate your Voucher Number and PIN.</p>
        
        <fieldset class="filter-section">
            <legend>Filter Items</legend>
            <div class="filter-grid">
                <div class="filter-input-group">
                    <label for="searchItem">Search Item:</label>
                    <input type="text" id="searchItem" placeholder="e.g., Rice, Sardines...">
                    <button type="button" class="btn-search">Search</button>
                </div>
                <div class="filter-select">
                    <label for="categorySelect">Category: </label>
                    <select id="categorySelect">
                        <option>All Segments</option>
                        <option>Dry Food</option>
                        <option>Canned Food</option>
                        <option>Essential Staples</option>
                    </select>
                </div>
            </div>
        </fieldset>

        <table class="data-table">
            <thead>
                <tr>
                    <th>Category</th>
                    <th>Food Item Name</th>
                    <th>Estimated Expiry</th>
                    <th>Available Quantity</th>
                    <th>Request Quantity</th>
                    <th style="text-align: center;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="item" items="${inventoryList}">
                    <tr>
                        <td><c:out value="${item.category}"/></td>
                        <td><strong><c:out value="${item.itemName}"/></strong></td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty item.expiryDate}">
                                    <c:out value="${item.expiryDate}"/>
                                </c:when>
                                <c:otherwise>Non-perishable / No Expiry</c:otherwise>
                            </c:choose>
                        </td>
                        <td><c:out value="${item.quantity}"/> remaining</td>
                        
                        <form action="gerobokPrihatinController" method="POST">
                            <input type="hidden" name="action" value="requestItem">
                            <input type="hidden" name="wishlistId" value="${item.donationId}">
                            
                            <td>
                                <input type="number" name="quantity" class="input-qty" min="1" max="${item.quantity}" value="1" required>
                            </td>
                            <td align="center">
                                <c:choose>
                                    <c:when test="${item.quantity > 0}">
                                        <input type="submit" class="btn-claim" value="Claim / Request Item">
                                    </c:when>
                                    <c:otherwise>
                                        <button type="button" class="btn-claim" style="background-color: #ccc; cursor: not-allowed;" disabled>Out of Stock</button>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </form>
                    </tr>
                </c:forEach>
                
                <c:if test="${empty inventoryList}">
                    <tr>
                        <td colspan="6" align="center" style="color: #999; padding: 30px;">No food items are available in the inventory database right now.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>

        <div class="rules-card">
            <strong>Food Bank Fair-Usage & Distribution Rules:</strong>
            <ul>
                <li>Students are strictly limited to item limits allowed by active wallet balances.</li>
                <li>All requested goods must be collected from the HEP central warehouse within 7 working days post-approval.</li>
                <li>Uncollected approvals will automatically cycle back into community distribution assets.</li>
            </ul>
        </div>

        <p class="note-text">* Note: Submitting a request triggers the system backend to verify eligibility before creating the active Voucher No & PIN numbers.</p>

    </div>

</body>
</html>