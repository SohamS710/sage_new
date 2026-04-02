package models;

public class Contact {
    private int contactId;
    private int userId;
    private String name;
    private String phone;
    private String relation;

    public Contact() {}

    public Contact(int userId, String name, String phone, String relation) {
        this.userId = userId;
        this.name = name;
        this.phone = phone;
        this.relation = relation;
    }

    public int getContactId() { return contactId; }
    public int getUserId() { return userId; }
    public String getName() { return name; }
    public String getPhone() { return phone; }
    public String getRelation() { return relation; }

    public void setContactId(int contactId) { this.contactId = contactId; }
    public void setUserId(int userId) { this.userId = userId; }
    public void setName(String name) { this.name = name; }
    public void setPhone(String phone) { this.phone = phone; }
    public void setRelation(String relation) { this.relation = relation; }
}