<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Gerobok Prihatin - Create An Account</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #fcf8f9;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .auth-container {
            background: #ffffff;
            padding: 35px;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(128, 0, 32, 0.1);
            width: 100%;
            max-width: 400px;
            text-align: center;
            border-top: 5px solid #800020;
        }
        h2 {
            color: #800020;
            margin-bottom: 25px;
            margin-top: 0;
        }
        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #4A0012;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-sizing: border-box;
        }
        .form-group input:focus, .form-group select:focus {
            border-color: #800020;
            outline: none;
        }
        .btn-submit {
            width: 100%;
            padding: 12px;
            background-color: #800020;
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            cursor: pointer;
            font-weight: bold;
            margin-top: 10px;
        }
        .btn-submit:hover {
            background-color: #4A0012;
        }
        .auth-logo {
            width: 100px;
            height: auto;
            margin-bottom: 15px;
        }
        a {
            color: #800020;
            text-decoration: none;
            font-weight: bold;
        }
        a:hover {
            text-decoration: underline;
        }
        .notification-msg {
            margin-top: 20px;
            padding: 10px;
            font-weight: bold;
            border-radius: 4px;
            font-size: 14px;
            text-align: left;
        }
        .error {
            color: #cc0000;
            background-color: #fde8ec;
            border: 1px solid #ebccd1;
        }
        .login-link {
            margin-top: 25px;
            font-size: 14px;
            color: #555;
        }
    </style>
    
    <script>
        function toggleRoleFields() {
            var roleSelect = document.getElementById("roleSelect");
            
            // Student fields setup
            var studentFields = document.querySelectorAll(".student-only-field");
            var studentInputs = document.querySelectorAll(".student-only-input");

            // HEP Staff fields setup
            var hepFields = document.querySelectorAll(".hep-only-field");
            var hepInputs = document.querySelectorAll(".hep-only-input");

            // Handle Student logic
            if (roleSelect.value === "student") {
                studentFields.forEach(field => field.style.display = "block");
                studentInputs.forEach(input => input.required = true);
            } else {
                studentFields.forEach(field => field.style.display = "none");
                studentInputs.forEach(input => {
                    input.required = false;
                    input.value = "";
                });
            }

            // Handle HEP Staff logic
            if (roleSelect.value === "hep") {
                hepFields.forEach(field => field.style.display = "block");
                hepInputs.forEach(input => input.required = true);
            } else {
                hepFields.forEach(field => field.style.display = "none");
                hepInputs.forEach(input => {
                    input.required = false;
                    input.value = "";
                });
            }
        }
    </script>
</head>
<body>

    <div class="auth-container">
        <img src="${pageContext.request.contextPath}/images/gerobok.png" alt="Gerobok Prihatin Logo" class="auth-logo">
        
        <h2>Create An Account</h2>
        
        <form action="${pageContext.request.contextPath}/gerobokPrihatinController" method="POST">
            <input type="hidden" name="action" value="register">
            
            <div class="form-group">
                <label>Select Your Role:</label>
                <select name="role" id="roleSelect" onchange="toggleRoleFields()" required>
                    <option value="">-- Choose Role --</option>
                    <option value="hep">HEP Staff</option>
                    <option value="donor">Donor</option>
                    <option value="student">Student</option>
                </select>
            </div>

            <!-- Conditional Field for HEP Staff -->
            <div class="form-group hep-only-field" style="display: none;">
                <label>Staff ID:</label>
                <input type="text" name="staffId" class="hep-only-input" placeholder="e.g. HEP12345">
            </div>

            <!-- Conditional Fields for Student -->
            <div class="form-group student-only-field" style="display: none;">
                <label>Student ID:</label>
                <input type="text" name="studentId" class="student-only-input" placeholder="e.g. 2024463524">
            </div>
            
            <div class="form-group student-only-field" style="display: none;">
                <label>Program Name:</label>
                <input type="text" name="program" class="student-only-input" placeholder="e.g. Bachelor of Computer Science (Hons)">
            </div>
            
            <!-- General Fields -->
            <div class="form-group">
                <label>Full Name:</label>
                <input type="text" name="fullName" required>
            </div>
            
            <div class="form-group">
                <label>Email Address:</label>
                <input type="email" name="email" required>
            </div>
            
            <div class="form-group">
                <label>Password:</label>
                <input type="password" name="password" required>
            </div>
            
            <button type="submit" class="btn-submit">Register</button>
        </form>

        <% 
            String error = request.getParameter("error");
            if (error != null) { 
        %>
            <div class="notification-msg error">
                ❌ 
                <% if (error.equals("failed")) { %>
                    Registration failed. Please try again.
                <% } else { %>
                    A database error occurred during registration.
                <% } %>
            </div>
        <% } %>

        <div class="login-link">
            Already have an account? <a href="login.jsp">Back to Login</a>
        </div>
    </div>

</body>
</html>