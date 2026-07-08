package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.user; 

@WebServlet(name = "gerobokPrihatinController", urlPatterns = {"/gerobokPrihatinController"})
public class gerobokPrihatinController extends HttpServlet {

    private static final String DB_URL = "jdbc:derby://localhost:1527/gerobok_prihatin";
    private static final String DB_USER = "app";
    private static final String DB_PASSWORD = "app";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }

        if (action == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // ==========================================
        // 1. LOGIN ACTION
        // ==========================================
        if (action.equals("login")) {
            String userParam = request.getParameter("username"); 
            String passParam = request.getParameter("password");
            String roleParam = request.getParameter("role");

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                String query = "SELECT * FROM APP_USER WHERE EMAIL = ? AND PASSWORD = ?";
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setString(1, userParam);
                    ps.setString(2, passParam);
                    
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            user loggedUser = new user();
                            
                            loggedUser.setId(rs.getInt("USERID")); 
                            loggedUser.setEmail(rs.getString("EMAIL")); 
                            loggedUser.setFullName(rs.getString("FULLNAME"));
                            loggedUser.setRole(rs.getString("ROLE"));

                            String dbRole = loggedUser.getRole();
                            boolean roleMatch = false;
                            
                            if (roleParam.equalsIgnoreCase("hep") && (dbRole.equalsIgnoreCase("hep") || dbRole.equalsIgnoreCase("STAFF"))) {
                                roleMatch = true;
                            } else if (roleParam.equalsIgnoreCase("student") && dbRole.equalsIgnoreCase("student")) {
                                roleMatch = true;
                            } else if (roleParam.equalsIgnoreCase("donor") && dbRole.equalsIgnoreCase("donor")) {
                                roleMatch = true;
                            }

                            if (!roleMatch) {
                                response.sendRedirect("login.jsp?error=InvalidRole");
                                return;
                            }

                            if (roleParam.equalsIgnoreCase("student")) {
                                String queryStudent = "SELECT STUDENTID, PROGRAM FROM STUDENT WHERE USERID = ?";
                                try (PreparedStatement psStud = conn.prepareStatement(queryStudent)) {
                                    psStud.setInt(1, loggedUser.getId());
                                    try (ResultSet rsStud = psStud.executeQuery()) {
                                        if (rsStud.next()) {
                                            loggedUser.setStudentId(rsStud.getString("STUDENTID"));
                                            loggedUser.setProgram(rsStud.getString("PROGRAM")); 
                                        }
                                    }
                                }
                            }

                            session.setAttribute("loggedUser", loggedUser);

                            if (roleParam.equalsIgnoreCase("hep")) {
                                response.sendRedirect("gerobokPrihatinController?action=dashboard");
                                return;
                            } else if (roleParam.equalsIgnoreCase("donor")) {
                                response.sendRedirect("donor.jsp");
                                return;
                            } else if (roleParam.equalsIgnoreCase("student")) {
                                response.sendRedirect("gerobokPrihatinController?action=viewMarketplace");
                                return;
                            } else {
                                response.sendRedirect("login.jsp?error=InvalidRole");
                                return;
                            }
                        } else {
                            response.sendRedirect("login.jsp?error=InvalidCredentials");
                            return;
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                if (!response.isCommitted()) {
                    response.getWriter().println("<h3>Database Connection Error:</h3> " + e.getMessage());
                }
            }
        }

        // ==========================================
        // 2. REGISTER ACTION
        // ==========================================
        else if (action.equals("register")) {
            String emailParam = request.getParameter("email"); 
            String passParam = request.getParameter("password");
            String nameParam = request.getParameter("fullName");
            String roleParam = request.getParameter("role");
            String studentIdParam = request.getParameter("studentId"); 
            String programParam = request.getParameter("program"); 
            String staffIdParam = request.getParameter("staffId");

            Connection conn = null;
            PreparedStatement psUser = null;
            PreparedStatement psSpecific = null; 
            ResultSet generatedKeys = null;

            try {
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                conn.setAutoCommit(false); 

                String queryUser = "INSERT INTO APP_USER (FULLNAME, EMAIL, PASSWORD, ROLE) VALUES (?, ?, ?, ?)";
                
                psUser = conn.prepareStatement(queryUser, java.sql.Statement.RETURN_GENERATED_KEYS);
                psUser.setString(1, nameParam);
                psUser.setString(2, emailParam);
                psUser.setString(3, passParam);
                psUser.setString(4, roleParam);

                int userInserted = psUser.executeUpdate();

                if (userInserted > 0) {
                    generatedKeys = psUser.getGeneratedKeys();
                    
                    if (generatedKeys.next()) {
                        int newUserId = generatedKeys.getInt(1); 

                        if (roleParam.equalsIgnoreCase("student")) {
                            String queryStudent = "INSERT INTO STUDENT (STUDENTID, USERID, PROGRAM) VALUES (?, ?, ?)";
                            psSpecific = conn.prepareStatement(queryStudent);
                            psSpecific.setString(1, studentIdParam);
                            psSpecific.setInt(2, newUserId);
                            psSpecific.setString(3, programParam);
                            psSpecific.executeUpdate();
                        } 
                        else if (roleParam.equalsIgnoreCase("donor")) {
                            String queryDonor = "INSERT INTO DONOR (USERID) VALUES (?)";
                            psSpecific = conn.prepareStatement(queryDonor);
                            psSpecific.setInt(1, newUserId);
                            psSpecific.executeUpdate();
                        } 
                        else if (roleParam.equalsIgnoreCase("hep")) {
                            String queryHep = "INSERT INTO HEP_STAFF (STAFFID, USERID) VALUES (?, ?)";
                            psSpecific = conn.prepareStatement(queryHep);
                            psSpecific.setString(1, staffIdParam);
                            psSpecific.setInt(2, newUserId);
                            psSpecific.executeUpdate();
                        }
                        
                    } else {
                        throw new Exception("Failed to retrieve auto-generated User ID reference.");
                    }

                    conn.commit();
                    response.sendRedirect("login.jsp?register=success");
                    return;
                } else {
                    conn.rollback();
                    response.sendRedirect("register.jsp?error=failed");
                    return;
                }

            } catch (Exception e) {
                if (conn != null) {
                    try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
                }
                e.printStackTrace();
                if (!response.isCommitted()) {
                    response.getWriter().println("<h3>Registration Database Error:</h3> " + e.getMessage());
                }
            } finally {
                try { if (generatedKeys != null) generatedKeys.close(); } catch (Exception e) {}
                try { if (psUser != null) psUser.close(); } catch (Exception e) {}
                try { if (psSpecific != null) psSpecific.close(); } catch (Exception e) {}
                try { if (conn != null) conn.close(); } catch (Exception e) {}
            }
        }

        // ==========================================
        // 3. ADD DONATION ACTION (DONOR)
        // ==========================================
        else if (action.equals("addDonation")) {
            user activeUser = (user) session.getAttribute("loggedUser");
            if (activeUser == null || !activeUser.getRole().equalsIgnoreCase("donor")) {
                response.sendRedirect("login.jsp?error=Unauthorized");
                return;
            }

            String category = request.getParameter("category");
            String itemName = request.getParameter("itemName");
            String quantityStr = request.getParameter("quantity");
            String expiryDate = request.getParameter("expiryDate");
            String storageType = request.getParameter("storageType");
            String deliveryMode = request.getParameter("deliveryMode");
            String remarks = request.getParameter("remarks");
            String status = "Pending"; 

            Connection conn = null;
            PreparedStatement psGetDonor = null;
            PreparedStatement psDonation = null;
            PreparedStatement psInventory = null;
            PreparedStatement psMaxInvId = null;
            ResultSet rsDonor = null;
            ResultSet genDonationKeys = null;
            ResultSet rsMaxId = null;

            try {
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                conn.setAutoCommit(false); 
                
                int userId = activeUser.getId();
                int donorId = -1;
                
                String queryGetDonor = "SELECT DONORID FROM DONOR WHERE USERID = ?";
                psGetDonor = conn.prepareStatement(queryGetDonor);
                psGetDonor.setInt(1, userId);
                rsDonor = psGetDonor.executeQuery();
                
                if (rsDonor.next()) {
                    donorId = rsDonor.getInt("DONORID");
                } else {
                    throw new Exception("Donor record not found.");
                }

                String queryDonation = "INSERT INTO DONATION (ITEMNAME, CATEGORY, QUANTITY, EXPIRYDATE, STORAGETYPE, DELIVERYMODE, REMARKS, STATUS, DONORID) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                psDonation = conn.prepareStatement(queryDonation, java.sql.Statement.RETURN_GENERATED_KEYS);
                
                psDonation.setString(1, itemName);
                psDonation.setString(2, category);
                
                int qty = (quantityStr != null && !quantityStr.trim().isEmpty()) ? Integer.parseInt(quantityStr.trim()) : 0;
                psDonation.setInt(3, qty);
                
                if (expiryDate != null && !expiryDate.trim().isEmpty()) {
                    try {
                        psDonation.setDate(4, java.sql.Date.valueOf(expiryDate.trim()));
                    } catch (Exception e) {
                        psDonation.setNull(4, java.sql.Types.DATE);
                    }
                } else {
                    psDonation.setNull(4, java.sql.Types.DATE);
                }
                
                psDonation.setString(5, storageType);
                psDonation.setString(6, deliveryMode);
                psDonation.setString(7, remarks);
                psDonation.setString(8, status);
                psDonation.setInt(9, donorId);

                int donationInserted = psDonation.executeUpdate();
                int newDonationId = -1;

                if (donationInserted > 0) {
                    genDonationKeys = psDonation.getGeneratedKeys();
                    if (genDonationKeys.next()) {
                        newDonationId = genDonationKeys.getInt(1); 
                    }
                }

                if (newDonationId != -1) {
                    int nextInventoryId = 1;
                    psMaxInvId = conn.prepareStatement("SELECT MAX(DONATIONID) FROM INVENTORY");
                    rsMaxId = psMaxInvId.executeQuery();
                    if (rsMaxId.next()) {
                        nextInventoryId = rsMaxId.getInt(1) + 1;
                    }
                    if (nextInventoryId <= 0) {
                        nextInventoryId = 1;
                    }

                    String queryInventory = "INSERT INTO INVENTORY (DONATIONID, ITEMNAME, CATEGORY, QUANTITY, EXPIRYDATE, DONATIONID_FK) VALUES (?, ?, ?, ?, ?, ?)";
                    psInventory = conn.prepareStatement(queryInventory);
                    
                    psInventory.setInt(1, nextInventoryId); 
                    psInventory.setString(2, itemName);
                    psInventory.setString(3, category);
                    psInventory.setInt(4, qty);
                    
                    if (expiryDate != null && !expiryDate.trim().isEmpty()) {
                        try {
                            psInventory.setDate(5, java.sql.Date.valueOf(expiryDate.trim()));
                        } catch (Exception e) {
                            psInventory.setNull(5, java.sql.Types.DATE);
                        }
                    } else {
                        psInventory.setNull(5, java.sql.Types.DATE);
                    }
                    
                    psInventory.setInt(6, newDonationId); 

                    psInventory.executeUpdate();
                    
                    conn.commit(); 
                    
                    response.sendRedirect("gerobokPrihatinController?action=donationHistory&status=success");
                    return;
                } else {
                    conn.rollback();
                    response.sendRedirect("donorForm.jsp?donationStatus=error");
                    return;
                }

            } catch (Exception e) {
                e.printStackTrace();
                if (conn != null) {
                    try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
                }
                response.sendRedirect("donorForm.jsp?donationStatus=error");
                return;
            } finally {
                try { if (rsMaxId != null) rsMaxId.close(); } catch (Exception e) {}
                try { if (psMaxInvId != null) psMaxInvId.close(); } catch (Exception e) {}
                try { if (rsDonor != null) rsDonor.close(); } catch (Exception e) {}
                try { if (genDonationKeys != null) genDonationKeys.close(); } catch (Exception e) {}
                try { if (psGetDonor != null) psGetDonor.close(); } catch (Exception e) {}
                try { if (psDonation != null) psDonation.close(); } catch (Exception e) {}
                try { if (psInventory != null) psInventory.close(); } catch (Exception e) {}
                try { if (conn != null) conn.close(); } catch (Exception e) {}
            }
        }

        // ==========================================
        // 4. DASHBOARD ACTION (HEP / STAFF)
        // ==========================================
        else if (action.equals("dashboard")) {
            int totalStockVolume = 0;
            int totalCategories = 0;
            int totalDonors = 0;
            int pendingDonations = 0;
            
            int riceQty = 0, noodleQty = 0, flourBakingQty = 0, cannedQty = 0, saucesCondimentsQty = 0;
            int beveragesQty = 0, cerealsBiscuitsQty = 0, bodyHygieneQty = 0, sanitaryQty = 0, othersQty = 0;

            List<HashMap<String, Object>> inventoryList = new ArrayList<>();

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                
                try (ResultSet rs1 = conn.createStatement().executeQuery("SELECT SUM(QUANTITY) FROM INVENTORY")) {
                    if (rs1.next()) totalStockVolume = rs1.getInt(1);
                }

                try (ResultSet rsCat = conn.createStatement().executeQuery("SELECT COUNT(DISTINCT CATEGORY) FROM INVENTORY")) {
                    if (rsCat.next()) totalCategories = rsCat.getInt(1);
                }

                try (ResultSet rs2 = conn.createStatement().executeQuery("SELECT COUNT(*) FROM DONOR")) {
                    if (rs2.next()) totalDonors = rs2.getInt(1);
                }

                try (ResultSet rs3 = conn.createStatement().executeQuery("SELECT COUNT(*) FROM DONATION WHERE STATUS = 'Pending'")) {
                    if (rs3.next()) pendingDonations = rs3.getInt(1);
                }

                try (ResultSet rsC = conn.createStatement().executeQuery("SELECT CATEGORY, SUM(QUANTITY) FROM INVENTORY GROUP BY CATEGORY")) {
                    while (rsC.next()) {
                        String cat = rsC.getString(1);
                        int qty = rsC.getInt(2);
                        
                        if (cat == null) { othersQty += qty; continue; }
                        
                        switch (cat.trim()) {
                            case "Rice":
                            case "Essential Staples":
                                riceQty += qty; break;
                            case "Noodle":
                            case "Dry Provisions":
                                noodleQty += qty; break;
                            case "Flour & Baking":
                                flourBakingQty += qty; break;
                            case "Canned Food":
                            case "Canned":
                                cannedQty += qty; break;
                            case "Sauces & Condiments":
                                saucesCondimentsQty += qty; break;
                            case "Beverages":
                                beveragesQty += qty; break;
                            case "Cereals & Biscuits":
                                cerealsBiscuitsQty += qty; break;
                            case "Body Hygiene":
                                bodyHygieneQty += qty; break;
                            case "Sanitary Products":
                                sanitaryQty += qty; break;
                            default:
                                othersQty += qty; break;
                        }
                    }
                }

                String queryList = "SELECT ITEMNAME, CATEGORY, QUANTITY FROM INVENTORY";
                try (PreparedStatement psList = conn.prepareStatement(queryList);
                     ResultSet rsList = psList.executeQuery()) {
                    while (rsList.next()) {
                        HashMap<String, Object> item = new HashMap<>();
                        item.put("itemName", rsList.getString("ITEMNAME"));
                        item.put("category", rsList.getString("CATEGORY"));
                        item.put("quantity", rsList.getInt("QUANTITY"));
                        inventoryList.add(item);
                    }
                }

            } catch (Exception e) { 
                e.printStackTrace(); 
            }

            request.setAttribute("totalStockVolume", totalStockVolume);
            request.setAttribute("totalCategories", totalCategories);
            request.setAttribute("totalDonors", totalDonors);
            request.setAttribute("pendingDonations", pendingDonations);
            
            request.setAttribute("riceQty", riceQty);
            request.setAttribute("noodleQty", noodleQty);
            request.setAttribute("flourBakingQty", flourBakingQty);
            request.setAttribute("cannedQty", cannedQty);
            request.setAttribute("saucesCondimentsQty", saucesCondimentsQty);
            request.setAttribute("beveragesQty", beveragesQty);
            request.setAttribute("cerealsBiscuitsQty", cerealsBiscuitsQty);
            request.setAttribute("bodyHygieneQty", bodyHygieneQty);
            request.setAttribute("sanitaryQty", sanitaryQty);
            request.setAttribute("othersQty", othersQty);
            
            request.setAttribute("inventoryList", inventoryList);

            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            return;
        }

        // ==========================================
        // 5. MANAGE INVENTORY (HEP)
        // ==========================================
        else if (action.equals("manageInventory")) {
            List<HashMap<String, Object>> inventoryList = new ArrayList<>();
            int totalCategories = 0;
            int totalStockVolume = 0;

            String queryFetch = "SELECT DONATIONID, ITEMNAME, CATEGORY, QUANTITY, EXPIRYDATE FROM INVENTORY";
            String queryStats = "SELECT COUNT(DISTINCT CATEGORY), SUM(QUANTITY) FROM INVENTORY";

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                try (PreparedStatement psStats = conn.prepareStatement(queryStats);
                     ResultSet rsStats = psStats.executeQuery()) {
                    if (rsStats.next()) {
                        totalCategories = rsStats.getInt(1);
                        totalStockVolume = rsStats.getInt(2);
                    }
                }

                try (PreparedStatement psFetch = conn.prepareStatement(queryFetch);
                     ResultSet rsFetch = psFetch.executeQuery()) {
                    while (rsFetch.next()) {
                        HashMap<String, Object> item = new HashMap<>();
                        item.put("donationId", rsFetch.getInt("DONATIONID"));
                        item.put("itemName", rsFetch.getString("ITEMNAME"));
                        item.put("category", rsFetch.getString("CATEGORY"));
                        item.put("quantity", rsFetch.getInt("QUANTITY"));
                        item.put("expiryDate", rsFetch.getDate("EXPIRYDATE"));
                        inventoryList.add(item);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            request.setAttribute("inventoryList", inventoryList);
            request.setAttribute("totalCategories", totalCategories);
            request.setAttribute("totalStockVolume", totalStockVolume);
            
            request.getRequestDispatcher("HepInventory.jsp").forward(request, response);
            return;
        }

        // ==========================================
        // 6. ADD STOCK ACTION (HEP)
        // ==========================================
        else if (action.equals("addStock")) {
            String category = request.getParameter("category");
            String itemName = request.getParameter("itemName");
            String quantityStr = request.getParameter("quantity");
            String expiryDate = request.getParameter("expiryDate");
            int qty = (quantityStr != null) ? Integer.parseInt(quantityStr) : 0;

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                int nextInventoryId = 1;
                try (PreparedStatement psMax = conn.prepareStatement("SELECT MAX(DONATIONID) FROM INVENTORY");
                     ResultSet rsMax = psMax.executeQuery()) {
                    if (rsMax.next()) {
                        nextInventoryId = rsMax.getInt(1) + 1;
                    }
                }

                String sql = "INSERT INTO INVENTORY (DONATIONID, ITEMNAME, CATEGORY, QUANTITY, EXPIRYDATE, DONATIONID_FK) VALUES (?, ?, ?, ?, ?, NULL)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, nextInventoryId);
                    ps.setString(2, itemName);
                    ps.setString(3, category);
                    ps.setInt(4, qty);
                    if (expiryDate != null && !expiryDate.trim().isEmpty()) {
                        ps.setDate(5, java.sql.Date.valueOf(expiryDate.trim()));
                    } else {
                        ps.setNull(5, java.sql.Types.DATE);
                    }
                    ps.executeUpdate();
                }
                response.sendRedirect("gerobokPrihatinController?action=manageInventory&status=AddSuccess");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("gerobokPrihatinController?action=manageInventory&status=Error");
                return;
            }
        }

        // ==========================================
        // 7. UPDATE STOCK QTY ACTION (HEP)
        // ==========================================
        else if (action.equals("updateStockQty")) {
            int donationId = Integer.parseInt(request.getParameter("donationId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            String sql = "UPDATE INVENTORY SET QUANTITY = ? WHERE DONATIONID = ?";
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, quantity);
                ps.setInt(2, donationId);
                ps.executeUpdate();
                
                response.sendRedirect("gerobokPrihatinController?action=manageInventory&status=UpdateSuccess");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("gerobokPrihatinController?action=manageInventory&status=Error");
                return;
            }
        }

        // ==========================================
        // 8. DELETE STOCK ACTION (HEP)
        // ==========================================
        else if (action.equals("deleteStock")) {
            int donationId = Integer.parseInt(request.getParameter("donationId"));

            String sql = "DELETE FROM INVENTORY WHERE DONATIONID = ?";
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, donationId);
                ps.executeUpdate();
                
                response.sendRedirect("gerobokPrihatinController?action=manageInventory&status=DeleteSuccess");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("gerobokPrihatinController?action=manageInventory&status=Error");
                return;
            }
        }
        

        // ==========================================
        // 9. DONATION HISTORY (DONOR)
        // ==========================================
        else if (action.equals("donationHistory")) {
            user activeUser = (user) session.getAttribute("loggedUser");
            if (activeUser == null || !activeUser.getRole().equalsIgnoreCase("donor")) {
                response.sendRedirect("login.jsp?error=Unauthorized");
                return;
            }

            List<HashMap<String, Object>> historyList = new ArrayList<>();

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                int userId = activeUser.getId();
                int donorId = -1;
                
                String queryGetDonor = "SELECT DONORID FROM DONOR WHERE USERID = ?";
                try (PreparedStatement psDonor = conn.prepareStatement(queryGetDonor)) {
                    psDonor.setInt(1, userId);
                    try (ResultSet rsDonor = psDonor.executeQuery()) {
                        if (rsDonor.next()) {
                            donorId = rsDonor.getInt("DONORID");
                        }
                    }
                }

                if (donorId != -1) {
                    String queryHistory = "SELECT DONATIONID, ITEMNAME, QUANTITY, STATUS FROM DONATION WHERE DONORID = ? ORDER BY DONATIONID DESC";
                    try (PreparedStatement psHist = conn.prepareStatement(queryHistory)) {
                        psHist.setInt(1, donorId);
                        try (ResultSet rsHist = psHist.executeQuery()) {
                            while (rsHist.next()) {
                                HashMap<String, Object> record = new HashMap<>();
                                record.put("donationId", rsHist.getInt("DONATIONID"));
                                record.put("itemName", rsHist.getString("ITEMNAME"));
                                record.put("quantity", rsHist.getInt("QUANTITY"));
                                record.put("status", rsHist.getString("STATUS"));
                                
                                historyList.add(record);
                            }
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            request.setAttribute("historyList", historyList);
            request.getRequestDispatcher("donorHistory.jsp").forward(request, response);
            return;
        }

       // ==========================================
        // 10. VIEW MARKETPLACE (STUDENT)
        // ==========================================
        else if (action.equals("viewMarketplace")) {
            user activeUser = (user) session.getAttribute("loggedUser");
            if (activeUser == null || !activeUser.getRole().equalsIgnoreCase("student")) {
                response.sendRedirect("login.jsp?error=Unauthorized");
                return;
            }

            List<HashMap<String, Object>> inventoryList = new ArrayList<>();
            String queryFetch = "SELECT DONATIONID, ITEMNAME, CATEGORY, QUANTITY, EXPIRYDATE FROM INVENTORY WHERE QUANTITY > 0";

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement psFetch = conn.prepareStatement(queryFetch);
                 ResultSet rsFetch = psFetch.executeQuery()) {
                while (rsFetch.next()) {
                    HashMap<String, Object> item = new HashMap<>();
                    item.put("donationId", rsFetch.getInt("DONATIONID"));
                    item.put("itemName", rsFetch.getString("ITEMNAME"));
                    item.put("category", rsFetch.getString("CATEGORY"));
                    item.put("quantity", rsFetch.getInt("QUANTITY"));
                    item.put("expiryDate", rsFetch.getDate("EXPIRYDATE"));
                    inventoryList.add(item);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            request.setAttribute("inventoryList", inventoryList);
            request.getRequestDispatcher("studentMarketplace.jsp").forward(request, response);
            return;
        }

        // ==========================================
        // 11. REQUEST ITEM ACTION (STUDENT) - MATCHES 'DISTRIBUTION'
        // ==========================================
        else if (action.equals("requestItem")) {
            user activeUser = (user) session.getAttribute("loggedUser");
            if (activeUser == null || !activeUser.getRole().equalsIgnoreCase("student")) {
                response.sendRedirect("login.jsp?error=Unauthorized");
                return;
            }

            int wishlistId = Integer.parseInt(request.getParameter("wishlistId"));
            int reqQty = Integer.parseInt(request.getParameter("quantity"));
            String studentName = activeUser.getFullName();
            String studentId = activeUser.getStudentId();

            // Menyelaraskan query mengikut jadual APP.DISTRIBUTION sebenar
            String queryRequest = "INSERT INTO DISTRIBUTION (STUDENTNAME, STUDENTID, WISHLISTID, ALLOWEDQUANTITY, SUBMISSIONDATE, STATUSSTATE) VALUES (?, ?, ?, ?, CURRENT_DATE, 'Pending')";

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(queryRequest)) {
                ps.setString(1, studentName);
                ps.setString(2, studentId);
                ps.setInt(3, wishlistId);
                ps.setInt(4, reqQty);
                ps.executeUpdate();

                response.sendRedirect("gerobokPrihatinController?action=viewMarketplace&status=RequestSubmitted");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("gerobokPrihatinController?action=viewMarketplace&status=Error");
                return;
            }
        }

        // ==========================================
        // 12. VIEW REQUESTS PENDING (HEP) - MATCHES 'DISTRIBUTION'
        // ==========================================
        else if (action.equals("viewRequests")) {
            user activeUser = (user) session.getAttribute("loggedUser");
            if (activeUser == null || (!activeUser.getRole().equalsIgnoreCase("hep") && !activeUser.getRole().equalsIgnoreCase("staff"))) {
                response.sendRedirect("login.jsp?error=Unauthorized");
                return;
            }

            List<HashMap<String, Object>> requestList = new ArrayList<>();
            // Menyelaraskan query bagi jadual DISTRIBUTION untuk paparan HEP
            String query = "SELECT d.REQUESTID, d.STUDENTNAME, d.STUDENTID, i.ITEMNAME, d.ALLOWEDQUANTITY, d.SUBMISSIONDATE " +
                           "FROM DISTRIBUTION d " +
                           "JOIN INVENTORY i ON d.WISHLISTID = i.DONATIONID " +
                           "WHERE d.STATUSSTATE = 'Pending'";

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(query);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HashMap<String, Object> reqMap = new HashMap<>();
                    reqMap.put("requestId", rs.getInt("REQUESTID"));
                    reqMap.put("studentName", rs.getString("STUDENTNAME"));
                    reqMap.put("studentId", rs.getString("STUDENTID"));
                    reqMap.put("itemName", rs.getString("ITEMNAME"));
                    reqMap.put("quantity", rs.getInt("ALLOWEDQUANTITY"));
                    reqMap.put("date", rs.getDate("SUBMISSIONDATE"));
                    requestList.add(reqMap);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            request.setAttribute("requestList", requestList);
request.getRequestDispatcher("HepDistribution.jsp").forward(request, response);
            return;
        }

        // ==========================================
        // 13. APPROVE ATOMIC REQUEST (HEP) - MATCHES 'DISTRIBUTION'
        // ==========================================
        else if (action.equals("approveRequest")) {
            user activeUser = (user) session.getAttribute("loggedUser");
            if (activeUser == null || (!activeUser.getRole().equalsIgnoreCase("hep") && !activeUser.getRole().equalsIgnoreCase("staff"))) {
                response.sendRedirect("login.jsp?error=Unauthorized");
                return;
            }

            int requestId = Integer.parseInt(request.getParameter("requestId"));
            Connection conn = null;

            try {
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                conn.setAutoCommit(false); 

                int wishlistId = -1;
                int reqQty = 0;
                String selectReq = "SELECT WISHLISTID, ALLOWEDQUANTITY FROM DISTRIBUTION WHERE REQUESTID = ?";
                try (PreparedStatement psSelect = conn.prepareStatement(selectReq)) {
                    psSelect.setInt(1, requestId);
                    try (ResultSet rs = psSelect.executeQuery()) {
                        if (rs.next()) {
                            wishlistId = rs.getInt("WISHLISTID");
                            reqQty = rs.getInt("ALLOWEDQUANTITY");
                        }
                    }
                }

                // Potong kuantiti daripada inventori sedia ada
                String updateInv = "UPDATE INVENTORY SET QUANTITY = QUANTITY - ? WHERE DONATIONID = ? AND QUANTITY >= ?";
                try (PreparedStatement psInv = conn.prepareStatement(updateInv)) {
                    psInv.setInt(1, reqQty);
                    psInv.setInt(2, wishlistId);
                    psInv.setInt(3, reqQty);
                    int updatedRows = psInv.executeUpdate();
                    
                    if (updatedRows == 0) {
                        throw new Exception("Stok tidak mencukupi untuk diluluskan!");
                    }
                }

                // Kemaskini status kelulusan dalam jadual DISTRIBUTION
                String updateReqStatus = "UPDATE DISTRIBUTION SET STATUSSTATE = 'Approved' WHERE REQUESTID = ?";
                try (PreparedStatement psStatus = conn.prepareStatement(updateReqStatus)) {
                    psStatus.setInt(1, requestId);
                    psStatus.executeUpdate();
                }

                conn.commit(); 
                response.sendRedirect("gerobokPrihatinController?action=viewRequests&status=ApprovedSuccess");
                return;
            } catch (Exception e) {
                if (conn != null) {
                    try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
                }
                e.printStackTrace();
                response.sendRedirect("gerobokPrihatinController?action=viewRequests&status=Error");
                return;
            } finally {
                try { if (conn != null) conn.close(); } catch (Exception e) {}
            }
        }

        // ==========================================
        // 14. REJECT REQUEST ACTION (HEP) - MATCHES 'DISTRIBUTION'
        // ==========================================
        else if (action.equals("rejectRequest")) {
            user activeUser = (user) session.getAttribute("loggedUser");
            if (activeUser == null || (!activeUser.getRole().equalsIgnoreCase("hep") && !activeUser.getRole().equalsIgnoreCase("staff"))) {
                response.sendRedirect("login.jsp?error=Unauthorized");
                return;
            }

            int requestId = Integer.parseInt(request.getParameter("requestId"));
            String sqlReject = "UPDATE DISTRIBUTION SET STATUSSTATE = 'Rejected' WHERE REQUESTID = ?";

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(sqlReject)) {
                ps.setInt(1, requestId);
                ps.executeUpdate();

                response.sendRedirect("gerobokPrihatinController?action=viewRequests&status=RejectedSuccess");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("gerobokPrihatinController?action=viewRequests&status=Error");
                return;
            }
        }

        // ==========================================
        // 15. UPDATE ALLOWED QUANTITY (HEP) - MATCHES 'DISTRIBUTION'
        // ==========================================
        else if (action.equals("updateDistributionQty")) {
            user activeUser = (user) session.getAttribute("loggedUser");
            if (activeUser == null || (!activeUser.getRole().equalsIgnoreCase("hep") && !activeUser.getRole().equalsIgnoreCase("staff"))) {
                response.sendRedirect("login.jsp?error=Unauthorized");
                return;
            }

            int requestId = Integer.parseInt(request.getParameter("requestId"));
            int updatedQty = Integer.parseInt(request.getParameter("allowedQuantity"));

            String sqlUpdate = "UPDATE DISTRIBUTION SET ALLOWEDQUANTITY = ? WHERE REQUESTID = ? AND STATUSSTATE = 'Pending'";

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                ps.setInt(1, updatedQty);
                ps.setInt(2, requestId);
                ps.executeUpdate();

                response.sendRedirect("gerobokPrihatinController?action=viewRequests&status=UpdateSuccess");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("gerobokPrihatinController?action=viewRequests&status=Error");
                return;
            }
        }

        // ==========================================
        // 16. VIEW PROFILE & REQUEST HISTORY (STUDENT)
        // ==========================================
        else if (action.equals("viewProfile")) {
            user activeUser = (user) session.getAttribute("loggedUser");
            if (activeUser == null || !activeUser.getRole().equalsIgnoreCase("student")) {
                response.sendRedirect("login.jsp?error=Unauthorized");
                return;
            }

            List<HashMap<String, Object>> historyList = new ArrayList<>();
            // Mengambil sejarah permohonan barangan berdasarkan STUDENTID milik sesi aktif
            String queryHistory = "SELECT d.REQUESTID, i.ITEMNAME, i.CATEGORY, d.ALLOWEDQUANTITY, d.SUBMISSIONDATE, d.STATUSSTATE " +
                                 "FROM DISTRIBUTION d " +
                                 "JOIN INVENTORY i ON d.WISHLISTID = i.DONATIONID " +
                                 "WHERE d.STUDENTID = ? ORDER BY d.SUBMISSIONDATE DESC";

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(queryHistory)) {
                ps.setString(1, activeUser.getStudentId());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        HashMap<String, Object> record = new HashMap<>();
                        record.put("requestId", rs.getInt("REQUESTID"));
                        record.put("itemName", rs.getString("ITEMNAME"));
                        record.put("category", rs.getString("CATEGORY"));
                        record.put("quantity", rs.getInt("ALLOWEDQUANTITY"));
                        record.put("date", rs.getDate("SUBMISSIONDATE"));
                        record.put("status", rs.getString("STATUSSTATE"));
                        historyList.add(record);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            request.setAttribute("historyList", historyList);
            request.getRequestDispatcher("studentProfile.jsp").forward(request, response);
            return;
        }

        // ==========================================
        // 17. LOGOUT ACTION
        // ==========================================
        else if (action.equals("logout")) {
            session.removeAttribute("loggedUser");
            session.invalidate();
            
            response.sendRedirect("index.jsp?status=loggedout");
            return;
        }
    }
}