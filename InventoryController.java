package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "InventoryController", urlPatterns = {"/InventoryController"})
public class InventoryController extends HttpServlet {

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

        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }

        if (action == null || action.equals("manageInventory")) {
            List<Map<String, Object>> inventoryList = new ArrayList<>();
            int totalCategories = 0;
            int totalStockVolume = 0;

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                
                String catQuery = "SELECT COUNT(DISTINCT CATEGORY) FROM APP.DONATION";
                try (PreparedStatement psCat = conn.prepareStatement(catQuery);
                     ResultSet rsCat = psCat.executeQuery()) {
                    if (rsCat.next()) totalCategories = rsCat.getInt(1);
                }

                String volQuery = "SELECT SUM(QUANTITY) FROM APP.DONATION";
                try (PreparedStatement psVol = conn.prepareStatement(volQuery);
                     ResultSet rsVol = psVol.executeQuery()) {
                    if (rsVol.next()) totalStockVolume = rsVol.getInt(1);
                }

                String listQuery = "SELECT DONATIONID, ITEMNAME, CATEGORY, QUANTITY, EXPIRYDATE FROM APP.DONATION";
                try (PreparedStatement psList = conn.prepareStatement(listQuery);
                     ResultSet rsList = psList.executeQuery()) {
                    while (rsList.next()) {
                        Map<String, Object> item = new HashMap<>();
                        item.put("donationId", rsList.getInt("DONATIONID"));
                        item.put("itemName", rsList.getString("ITEMNAME"));
                        item.put("category", rsList.getString("CATEGORY"));
                        item.put("quantity", rsList.getInt("QUANTITY"));
                        item.put("expiryDate", rsList.getDate("EXPIRYDATE") != null ? rsList.getDate("EXPIRYDATE").toString() : "N/A");
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

        else if (action.equals("addStock")) {
            String category = request.getParameter("category");
            String itemName = request.getParameter("itemName");
            String quantityStr = request.getParameter("quantity");
            String expiryDate = request.getParameter("expiryDate");

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                
                int nextDonationId = 1;
                String maxQuery = "SELECT MAX(DONATIONID) FROM APP.DONATION";
                try (PreparedStatement psMax = conn.prepareStatement(maxQuery);
                     ResultSet rsMax = psMax.executeQuery()) {
                    if (rsMax.next() && rsMax.getObject(1) != null) {
                        nextDonationId = rsMax.getInt(1) + 1;
                    }
                }

                String insertDonation = "INSERT INTO APP.DONATION (DONATIONID, ITEMNAME, CATEGORY, QUANTITY, EXPIRYDATE) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertDonation)) {
                    ps.setInt(1, nextDonationId);
                    ps.setString(2, itemName);
                    ps.setString(3, category);
                    ps.setInt(4, Integer.parseInt(quantityStr));
                    
                    if (expiryDate != null && !expiryDate.trim().isEmpty()) {
                        ps.setDate(5, java.sql.Date.valueOf(expiryDate));
                    } else {
                        ps.setNull(5, java.sql.Types.DATE);
                    }
                    ps.executeUpdate();
                }

                int nextWishlistId = 1;
                String maxWishQuery = "SELECT MAX(WISHLISTID) FROM APP.WISHLIST";
                try (PreparedStatement psMaxW = conn.prepareStatement(maxWishQuery);
                     ResultSet rsMaxW = psMaxW.executeQuery()) {
                    if (rsMaxW.next() && rsMaxW.getObject(1) != null) {
                        nextWishlistId = rsMaxW.getInt(1) + 1;
                    }
                }

                String insertWishlist = "INSERT INTO APP.WISHLIST (WISHLISTID, ITEMNAME, TARGETQUANTITY, CURRENTQUANTITY, URGENCYLEVEL) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement psIn = conn.prepareStatement(insertWishlist)) {
                    psIn.setInt(1, nextWishlistId);
                    psIn.setString(2, itemName);
                    psIn.setInt(3, 500);
                    psIn.setInt(4, Integer.parseInt(quantityStr));
                    psIn.setString(5, category);
                    psIn.executeUpdate();
                }
                
                response.sendRedirect("InventoryController?action=manageInventory&status=AddSuccess");
                return;
                
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("InventoryController?action=manageInventory&status=Error");
                return;
            }
        }

        else if (action.equals("updateStockQty")) {
            String donationIdStr = request.getParameter("donationId");
            String newQtyStr = request.getParameter("quantity");

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement("UPDATE APP.DONATION SET QUANTITY = ? WHERE DONATIONID = ?")) {
                
                ps.setInt(1, Integer.parseInt(newQtyStr));
                ps.setInt(2, Integer.parseInt(donationIdStr));
                ps.executeUpdate();
                
                response.sendRedirect("InventoryController?action=manageInventory&status=UpdateSuccess");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("InventoryController?action=manageInventory&status=Error");
                return;
            }
        }

        else if (action.equals("deleteStock")) {
            String donationIdStr = request.getParameter("donationId");

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement("DELETE FROM APP.DONATION WHERE DONATIONID = ?")) {
                
                ps.setInt(1, Integer.parseInt(donationIdStr));
                ps.executeUpdate();
                
                response.sendRedirect("InventoryController?action=manageInventory&status=DeleteSuccess");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("InventoryController?action=manageInventory&status=Error");
                return;
            }
        }
    }
}