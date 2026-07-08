package model;

import java.io.Serializable;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class user implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int id;          
    private String fullName; 
    private String email;    
    private String password; 
    private String role;     
    private String studentId; 
    private String program; 

    public static final List<user> userDatabase = new CopyOnWriteArrayList<>();

    static {
        user admin = new user("System Admin", "admin@hep.edu", "12345", "HEP Staff");
        admin.setId(1); 
        userDatabase.add(admin);

        user student1 = new user("aqilah izzati", "aqilah@student.com", "12345", "student", "2024463524", "Bachelor of Computer Science (Hons)");
        student1.setId(2);
        userDatabase.add(student1);
    }

    public user() {}

    public user(String fullName, String email, String password, String role) {
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.role = role;
    }

    public user(String fullName, String email, String password, String role, String studentId, String program) {
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.role = role;
        this.studentId = studentId;
        this.program = program;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getProgram() { return program; }
    public void setProgram(String program) { this.program = program; }
}