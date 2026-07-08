package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {
    
    private final String dbUrl = "jdbc:derby://localhost:1527/gerobok_prihatin";
    private final String dbUser = "app";
    private final String dbPassword = "app";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int totalItems = 0;
        int totalCategories = 0;
        int totalDonors = 0;
        int pendingDonations = 0;
        
        int riceQty = 0;
        int noodleQty = 0;
        int flourBakingQty = 0;
        int cannedQty = 0;
        int saucesCondimentsQty = 0;
        int beveragesQty = 0;
        int cerealsBiscuitsQty = 0; 
        int bodyHygieneQty = 0;
        int sanitaryQty = 0;
        int othersQty = 0;

        List<model.InventoryItem> inventoryList = new ArrayList<>();

        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
                
                // 1. Kira Jumlah Keseluruhan Stok Unit
                String sqlTotalItems = "SELECT SUM(QUANTITY) FROM INVENTORY";
                try (PreparedStatement ps1 = conn.prepareStatement(sqlTotalItems);
                     ResultSet rs1 = ps1.executeQuery()) {
                    if(rs1.next()) totalItems = rs1.getInt(1);
                }

                // 2. Kira Jumlah Kategori Unik yang mempunyai stok
                String sqlCat = "SELECT COUNT(DISTINCT CATEGORY) FROM INVENTORY";
                try (PreparedStatement psCat = conn.prepareStatement(sqlCat);
                     ResultSet rsCat = psCat.executeQuery()) {
                    if(rsCat.next()) totalCategories = rsCat.getInt(1);
                }

                // 3. Kira Jumlah Penderma Berdaftar
                String sqlDonors = "SELECT COUNT(DONORID) FROM DONOR";
                try (PreparedStatement ps2 = conn.prepareStatement(sqlDonors);
                     ResultSet rs2 = ps2.executeQuery()) {
                    if(rs2.next()) totalDonors = rs2.getInt(1);
                }

                // 4. Kira Pendermaan Baru yang Berstatus 'Pending'
                String sqlPending = "SELECT COUNT(DONATIONID) FROM DONATION WHERE STATUS = 'Pending'";
                try (PreparedStatement ps3 = conn.prepareStatement(sqlPending);
                     ResultSet rs3 = ps3.executeQuery()) {
                    if(rs3.next()) pendingDonations = rs3.getInt(1);
                }

                // 5. Ambil Kuantiti Spesifik bagi Setiap Kategori untuk Carta Graf
                riceQty = getCategoryQuantity(conn, "Rice");
                noodleQty = getCategoryQuantity(conn, "Noodle");
                flourBakingQty = getCategoryQuantity(conn, "Flour & Baking");
                cannedQty = getCategoryQuantity(conn, "Canned Food");
                saucesCondimentsQty = getCategoryQuantity(conn, "Sauces & Condiments");
                beveragesQty = getCategoryQuantity(conn, "Beverages");
                cerealsBiscuitsQty = getCategoryQuantity(conn, "Cereals & Biscuits");
                bodyHygieneQty = getCategoryQuantity(conn, "Body Hygiene");
                sanitaryQty = getCategoryQuantity(conn, "Sanitary Products");
                othersQty = getCategoryQuantity(conn, "Others");

                // 6. Ambil Senarai Item untuk Jadual Ringkasan (Summary Table)
                String sqlList = "SELECT ITEMNAME, CATEGORY, QUANTITY FROM INVENTORY";
                try (PreparedStatement psList = conn.prepareStatement(sqlList);
                     ResultSet rsList = psList.executeQuery()) {
                    while(rsList.next()) {
                        model.InventoryItem item = new model.InventoryItem();
                        item.setItemName(rsList.getString("ITEMNAME"));
                        item.setCategory(rsList.getString("CATEGORY"));
                        item.setQuantity(rsList.getInt("QUANTITY"));
                        inventoryList.add(item);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Hantar semua data ke Request Attribute supaya boleh dibaca oleh JSP
        request.setAttribute("totalStockVolume", totalItems);
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

        // Forward ke fail JSP yang telah dikemaskini
        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }

    private int getCategoryQuantity(Connection conn, String categoryName) throws java.sql.SQLException {
        int quantity = 0;
        String query = "SELECT SUM(QUANTITY) FROM INVENTORY WHERE CATEGORY = ?";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, categoryName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    quantity = rs.getInt(1);
                }
            }
        }
        return quantity;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}