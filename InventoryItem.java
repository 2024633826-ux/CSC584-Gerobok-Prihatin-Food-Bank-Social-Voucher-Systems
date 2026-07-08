package model;

import java.io.Serializable;

public class InventoryItem implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // Entity Attributes
    private int id;
    private String itemName;
    private String category; // WAJIB TAMBAH UNTUK CARTA DASHBOARD
    private int quantity;
    private String expiryDate;

    public InventoryItem() {}

    public InventoryItem(int id, String itemName, String category, int quantity, String expiryDate) {
        this.id = id;
        this.itemName = itemName;
        this.category = category;
        this.quantity = quantity;
        this.expiryDate = expiryDate;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    
    public String getExpiryDate() { return expiryDate; }
    public void setExpiryDate(String expiryDate) { this.expiryDate = expiryDate; }
}