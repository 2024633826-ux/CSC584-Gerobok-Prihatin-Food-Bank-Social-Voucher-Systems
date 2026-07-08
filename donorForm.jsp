<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.user" %>
<%
    String prefillItem = request.getParameter("prefillItem");
    if(prefillItem == null) {
        prefillItem = "";
    }
    
    user activeUser = (user) session.getAttribute("loggedUser");
    if (activeUser == null || !activeUser.getRole().equalsIgnoreCase("donor")) {
        response.sendRedirect("login.jsp?error=Unauthorized");
        return;
    }
    String donorName = activeUser.getFullName(); 
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Log New Donation Package - Gerobok Prihatin</title>
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
        .header-title { border-bottom: 2px solid #800020; padding-bottom: 15px; margin-bottom: 30px; }
        .header-title h1 { color: #800020; font-size: 28px; }
        
        .session-card { background: white; border: 1px solid #e2d6d9; padding: 15px 20px; border-radius: 6px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
        .session-info span { color: #800020; font-weight: bold; }
        .manifest-mode { text-align: right; }
        .manifest-mode div { color: #800020; font-weight: bold; font-size: 14px; }
        
        .form-container { background: white; border: 1px solid #eee; border-radius: 8px; padding: 30px; box-shadow: 0 4px 12px rgba(0,0,0,0.02); }
        .form-legend { color: #800020; font-weight: bold; border-bottom: 1px solid #eee; padding-bottom: 10px; margin-bottom: 25px; font-size: 16px; }
        
        .form-group { display: flex; align-items: center; margin-bottom: 20px; }
        .form-group label { width: 250px; font-weight: bold; color: #4A0012; font-size: 15px; }
        .form-field { flex: 1; }
        
        .form-field input[type="text"], 
        .form-field input[type="number"], 
        .form-field input[type="date"], 
        .form-field select, 
        .form-field textarea {
            width: 100%;
            max-width: 500px;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 14px;
        }
        .form-field input:focus, .form-field select:focus, .form-field textarea:focus { border-color: #800020; outline: none; }
        
        .radio-group { display: flex; gap: 20px; }
        .radio-option { display: flex; align-items: center; gap: 6px; cursor: pointer; }
        
        .btn-submit { background-color: #800020; color: white; border: none; padding: 12px 30px; border-radius: 4px; font-size: 15px; font-weight: bold; cursor: pointer; transition: background 0.2s; margin-left: 250px; }
        .btn-submit:hover { background-color: #4A0012; }

        .alert-error { background-color: #f8d7da; color: #721c24; padding: 12px; border-radius: 4px; margin-bottom: 20px; border: 1px solid #f5c6cb; max-width: 760px; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h3>Gerobok Prihatin-<br>Donor Page</h3>
        <ul>
            <li><a href="${pageContext.request.contextPath}/donor.jsp">Dashboard</a></li>
            <li><strong class="active">Donation Detail</strong></li>
            <li><a href="${pageContext.request.contextPath}/donorWishlist.jsp">Live Wishlist</a></li>
            <li><a href="${pageContext.request.contextPath}/gerobokPrihatinController?action=donationHistory">Donation History</a></li>
            <li><a href="${pageContext.request.contextPath}/gerobokPrihatinController?action=logout" style="color: #ff6b6b;">Logout</a></li>
        </ul>
    </div>

    <div class="main-content">
        <div class="header-title">
            <h1>Log New Donation Package</h1>
        </div>

        <%
            String donationStatus = request.getParameter("donationStatus");
            if ("error".equals(donationStatus)) {
        %>
            <div class="alert-error"><strong>Error!</strong> Failed to record the donation package. Please verify your data and try again.</div>
        <%
            }
        %>
        
        <div class="session-card">
            <div class="session-info">
                Current Session: <span><%= donorName %></span><br>
                <small style="color: #777;">Thank you for supporting low-income student distribution tracks.</small>
            </div>
            <div class="manifest-mode">
                <small style="color: #555;">Form Manifest Mode:</small>
                <div>New Stock Intake Registry</div>
            </div>
        </div>
        
        <div class="form-container">
            <div class="form-legend">Log New Donation Package</div>
            <p style="color: #666; font-size: 14px; margin-bottom: 25px;">Please fill out the precise specifications of your food bank contribution below.</p>
            
            <form id="donationForm" action="${pageContext.request.contextPath}/gerobokPrihatinController" method="POST" onsubmit="return handleFormSubmit(event)">
                <input type="hidden" name="action" value="addDonation">
                
                <div class="form-group">
                    <label>Item Category:</label>
                    <div class="form-field">
                        <select name="category" required>
                            <option value="">-- Select Category --</option>
                            <option value="Rice" <%= prefillItem.equalsIgnoreCase("Rice") || prefillItem.toLowerCase().contains("rice") ? "selected" : "" %>>Rice / Grains</option>
                            <option value="Noodle" <%= prefillItem.equalsIgnoreCase("Noodle") || prefillItem.toLowerCase().contains("noodle") ? "selected" : "" %>>Instant Noodles / Pasta</option>
                            <option value="Flour & Baking" <%= prefillItem.toLowerCase().contains("flour") || prefillItem.toLowerCase().contains("baking") ? "selected" : "" %>>Flour / Sugar / Cooking Oil</option>
                            <option value="Canned Food" <%= prefillItem.equalsIgnoreCase("Canned Food") || prefillItem.toLowerCase().contains("canned") || prefillItem.toLowerCase().contains("sardine") ? "selected" : "" %>>Canned Fish / Meat / Vegetables</option>
                            <option value="Sauces & Condiments" <%= prefillItem.toLowerCase().contains("sauce") || prefillItem.toLowerCase().contains("ketchup") || prefillItem.toLowerCase().contains("soy") ? "selected" : "" %>>Sauces / Condiments / Spices</option>
                            <option value="Beverages" <%= prefillItem.toLowerCase().contains("milo") || prefillItem.toLowerCase().contains("coffee") || prefillItem.toLowerCase().contains("tea") || prefillItem.toLowerCase().contains("drink") ? "selected" : "" %>>Milo / Coffee / Tea / Powdered Milk</option>
                            <option value="Cereals & Biscuits" <%= prefillItem.toLowerCase().contains("biscuit") || prefillItem.toLowerCase().contains("cracker") || prefillItem.toLowerCase().contains("cereal") || prefillItem.toLowerCase().contains("oat") ? "selected" : "" %>>Biscuits / Crackers / Oats</option>
                            <option value="Body Hygiene" <%= prefillItem.toLowerCase().contains("soap") || prefillItem.toLowerCase().contains("shampoo") || prefillItem.toLowerCase().contains("toothbrush") || prefillItem.toLowerCase().contains("paste") ? "selected" : "" %>>Soap / Shampoo / Toothpaste</option>
                            <option value="Sanitary Products" <%= prefillItem.toLowerCase().contains("pad") || prefillItem.toLowerCase().contains("sanitary") || prefillItem.toLowerCase().contains("tissue") ? "selected" : "" %>>Sanitary Pads / Tissues</option>
                            <option value="Others" <%= prefillItem.equalsIgnoreCase("Others") || (!prefillItem.equals("") && !prefillItem.toLowerCase().contains("rice") && !prefillItem.toLowerCase().contains("noodle") && !prefillItem.toLowerCase().contains("canned")) ? "selected" : "" %>>Others</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label>Item Name / Description:</label>
                    <div class="form-field">
                        <input type="text" name="itemName" value="<%= prefillItem %>" placeholder="e.g. Premium White Rice (5kg)" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Batch Quantity Amount:</label>
                    <div class="form-field">
                        <input type="number" name="quantity" min="1" placeholder="Enter quantity items" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Package Expiry Date:</label>
                    <div class="form-field">
                        <input type="date" name="expiryDate" required>
                        <span style="font-size: 12px; color: #777; margin-left: 10px;">(Must be valid for at least 6 months)</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Storage Requirements:</label>
                    <div class="form-field">
                        <div class="radio-group">
                            <label class="radio-option">
                                <input type="radio" name="storageType" value="Dry Pantry" checked> Dry Pantry (Room Temperature)
                            </label>
                            <label class="radio-option">
                                <input type="radio" name="storageType" value="Chilled"> Chilled / Refrigeration Required
                            </label>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Drop-off Delivery Mode:</label>
                    <div class="form-field">
                        <select name="deliveryMode" required>
                            <option value="Personal Walk-In">Personal Walk-In (HEP Counter Facility)</option>
                            <option value="Courier Service">Courier Service / Mail Delivery</option>
                            <option value="Bulk Drop-off">Bulk Drop-off Arrangement</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Additional Remarks:</label>
                    <div class="form-field">
                        <textarea name="remarks" rows="3" placeholder="Optional: Note down item brand designations, packaging states, or split shipping arrivals..."></textarea>
                    </div>
                </div>
                
                <button type="submit" class="btn-submit">Submit Donation</button>
            </form>
        </div>
    </div>

    <script>
        function handleFormSubmit(event) {
            event.preventDefault();
            alert("Success! Your donation package has been registered. Thank you for your kindness!");
            document.getElementById("donationForm").submit();
        }
    </script>
</body>
</html>