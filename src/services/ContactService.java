package services;

import database.ContactDAO;
import models.Contact;
import java.util.List;

public class ContactService {

    private ContactDAO dao = new ContactDAO();

    public void addContact(int userId, String name, String phone, String relation) {
        Contact contact = new Contact(userId, name, phone, relation);
        dao.addContact(contact);
    }

    public void viewContacts(int userId) {
        List<Contact> contacts = dao.getContactsByUser(userId);

        for (Contact c : contacts) {
            System.out.println(
                c.getContactId() + " | " +
                c.getName() + " | " +
                c.getPhone() + " | " +
                c.getRelation()
            );
        }
    }

    public void updateContact(int id, String name, String phone, String relation) {
        Contact contact = new Contact();
        contact.setContactId(id);
        contact.setName(name);
        contact.setPhone(phone);
        contact.setRelation(relation);

        dao.updateContact(contact);
    }

    public void deleteContact(int id) {
        dao.deleteContact(id);
    }
}