package database;

import models.Contact;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ContactDAO {

    public void addContact(Contact contact) {
        String sql = "INSERT INTO Emergency_Contact(user_id, name, phone, relation) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, contact.getUserId());
            ps.setString(2, contact.getName());
            ps.setString(3, contact.getPhone());
            ps.setString(4, contact.getRelation());

            ps.executeUpdate();
            System.out.println("Contact Added!");

        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public List<Contact> getContactsByUser(int userId) {
        List<Contact> list = new ArrayList<>();
        String sql = "SELECT * FROM Emergency_Contact WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Contact c = new Contact();
                c.setContactId(rs.getInt("contact_id"));
                c.setUserId(rs.getInt("user_id"));
                c.setName(rs.getString("name"));
                c.setPhone(rs.getString("phone"));
                c.setRelation(rs.getString("relation"));
                list.add(c);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public void updateContact(Contact contact) {
        String sql = "UPDATE Emergency_Contact SET name=?, phone=?, relation=? WHERE contact_id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, contact.getName());
            ps.setString(2, contact.getPhone());
            ps.setString(3, contact.getRelation());
            ps.setInt(4, contact.getContactId());

            ps.executeUpdate();
            System.out.println("Contact Updated!");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteContact(int contactId) {
        String sql = "DELETE FROM Emergency_Contact WHERE contact_id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, contactId);
            ps.executeUpdate();

            System.out.println("Contact Deleted!");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}