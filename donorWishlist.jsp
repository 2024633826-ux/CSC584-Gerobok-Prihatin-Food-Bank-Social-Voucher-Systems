<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Live Wishlist - Gerobok Prihatin</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #fcf8f9; color: #333; display: flex; min-height: 100vh; }
        
        .sidebar { width: 260px; background: linear-gradient(180deg, #4A0012 0%, #2A000A 100%); color: white; padding: 30px 20px; }
        .sidebar h3 { color: #D4AF37; margin-bottom: 25px; font-size: 18px; text-transform: uppercase; letter-spacing: 1px; border-bottom: 2px solid rgba(212, 175, 55, 0.2); padding-bottom: 10px; }
        .sidebar ul { list-style: none; }
        .sidebar ul li { margin-bottom: 15px; }
        .sidebar ul li a, .sidebar ul li strong { display: block; padding: 12px 15px; text-decoration: none; border-radius: 5px; color: #f5f5f5; font-weight: 500; transition: all 0.3s; }
        .sidebar ul li strong.active { background-color: #800020; color: #D4AF37; border-left: 4px solid #D4AF37; }
        .sidebar ul li a:hover { background-color: rgba(255, 255, 255, 0.1); color: #D4AF37; padding-left: 20px; }
        
        .main-content { flex: 1; padding: 40px; }
        .header-title { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #800020; padding-bottom: 15px; margin-bottom: 30px; }
        .header-title h1 { color: #800020; font-size: 28px; }
        
        .info-text { font-size: 14px; color: #666; margin-bottom: 25px; line-height: 1.5; }
        
        .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.04); margin-top: 15px; }
        .data-table th { background-color: #4A0012; color: white; padding: 15px; text-align: left; font-size: 14px; }
        .data-table td { padding: 15px; border-bottom: 1px solid #eee; font-size: 14px; vertical-align: middle; }
        
        .badge { padding: 5px 10px; border-radius: 4px; font-weight: bold; font-size: 12px; display: inline-block; }
        .badge-high { background-color: #fde8e8; color: #e74c3c; border: 1px solid #fbc4c4; }
        .badge-medium { background-color: #fef3c7; color: #d97706; border: 1px solid #fde68a; }
        .badge-low { background-color: #e0f2fe; color: #0284c7; border: 1px solid #bae6fd; }
        
        .btn-quick-donate { background-color: #2ecc71; color: white; border: none; padding: 8px 14px; border-radius: 4px; font-weight: bold; cursor: pointer; text-decoration: none; display: inline-block; font-size: 12px; }
        .btn-quick-donate:hover { background-color: #27ae60; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h3>Gerobok Prihatin - Donor Page</h3>
        <ul>
            <li><a href="Dashboard.jsp">Dashboard</a></li>
            <li><a href="donationDetail.jsp">Donation Detail</a></li>
            <li><strong class="active">Live Wishlist</strong></li>
            <li><a href="donationHistory.jsp">Donation History</a></li>
            <li><a href="gerobokPrihatinController?action=logout" style="color: #ff6b6b;">Logout</a></li>
        </ul>
    </div>

    <div class="main-content">
        <div class="header-title">
            <h1>Live Food Bank Wishlist (Suggested Priority Items)</h1>
        </div>

        <p class="info-text">
            The critical items listed below are urgently required by the HEP administration team for prompt distribution to underprivileged student segments.
        </p>

        <table class="data-table">
            <thead>
                <tr>
                    <th width="25%">Target Item Needed</th>
                    <th width="20%">Urgency Category</th>
                    <th width="20%">Target Goal Level</th>
                    <th width="20%">Still Short Of</th>
                    <th width="15%">Quick Action</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty wishlist}">
                        <tr>
                            <td colspan="5" align="center" style="color: #777; padding: 30px;">
                                No active inventory target manifests currently recorded by administration.
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="wItem" items="${wishlist}">
                            <tr>
                                <td><strong><c:out value="${wItem.itemName}"/></strong></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${wItem.urgencyLevel eq 'High'}">
                                            <span class="badge badge-high">High Urgency</span>
                                        </c:when>
                                        <c:when test="${wItem.urgencyLevel eq 'Medium'}">
                                            <span class="badge badge-medium">Medium Urgency</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-low">Low Urgency</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td><c:out value="${wItem.targetQuantity}"/> units</td>
                                <td>
                                    <c:set var="shortage" value="${wItem.targetQuantity - wItem.currentQuantity}"/>
                                    <span style="color: ${shortage > 0 ? '#e74c3c' : '#2ecc71'}; font-weight: bold;">
                                        <c:out value="${shortage > 0 ? shortage : 0}"/> units
                                    </span>
                                </td>
                                <td>
                                    <a href="donationDetail.jsp?preFillItem=${wItem.itemName}" class="btn-quick-donate">Donate Now</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

</body>
</html>