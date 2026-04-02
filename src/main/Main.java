package main;

import java.util.*;
import java.io.*;
import java.net.*;

import services.ContactService;
import services.ReportService;

public class Main {

    static Scanner sc = new Scanner(System.in);
    static ContactService contactService = new ContactService();
    static ReportService reportService = new ReportService();

    public static void main(String[] args) {
        while (true) {
            System.out.println("\n1. Login");
            System.out.println("2. Sign Up");
            System.out.println("3. Exit");

            int choice = sc.nextInt();

            switch (choice) {
                case 1:
                    dashboard();
                    break;
                case 2:
                    System.out.println("Sign Up Successful");
                    break;
                case 3:
                    System.exit(0);
                default:
                    System.out.println("Invalid Choice");
            }
        }
    }

    static void dashboard() {
        while (true) {
            System.out.println("\n--- MAIN MENU ---");
            System.out.println("1. SOS");
            System.out.println("2. Tips & Products");
            System.out.println("3. Safe Zones");
            System.out.println("4. Services");
            System.out.println("5. Emergency Contacts");
            System.out.println("6. Feedback");
            System.out.println("7. Reports");
            System.out.println("8. Logout");

            int choice = sc.nextInt();

            switch (choice) {
                case 1: sosMenu(); break;
                case 5: contactMenu(); break;
                case 7: reportMenu(); break;
                case 8: return;
                default: System.out.println("Option selected");
            }
        }
    }

    // CONTACT
    static void contactMenu() {
        int choice;
        do {
            System.out.println("\n1.Add 2.View 3.Update 4.Delete 5.Back");
            choice = sc.nextInt(); sc.nextLine();

            switch (choice) {
                case 1:
                    System.out.print("UserId: ");
                    int uid = sc.nextInt(); sc.nextLine();
                    System.out.print("Name: ");
                    String name = sc.nextLine();
                    System.out.print("Phone: ");
                    String ph = sc.nextLine();
                    System.out.print("Relation: ");
                    String rel = sc.nextLine();
                    contactService.addContact(uid, name, ph, rel);
                    break;

                case 2:
                    System.out.print("UserId: ");
                    contactService.viewContacts(sc.nextInt());
                    break;

                case 3:
                    System.out.print("ID: ");
                    int id = sc.nextInt(); sc.nextLine();
                    System.out.print("Name: ");
                    String n = sc.nextLine();
                    System.out.print("Phone: ");
                    String p = sc.nextLine();
                    System.out.print("Relation: ");
                    String r = sc.nextLine();
                    contactService.updateContact(id, n, p, r);
                    break;

                case 4:
                    System.out.print("ID: ");
                    contactService.deleteContact(sc.nextInt());
                    break;

                case 5:
                    return;
            }
        } while (choice != 5);
    }

    // REPORT
    static void reportMenu() {
        int choice;
        do {
            System.out.println("\n1.Add Report 2.View Reports 3.Back");
            choice = sc.nextInt(); sc.nextLine();

            switch (choice) {
                case 1:
                    System.out.print("UserId: ");
                    int uid = sc.nextInt(); sc.nextLine();
                    System.out.print("Description: ");
                    String d = sc.nextLine();
                    reportService.addReport(uid, d);
                    break;

                case 2:
                    System.out.print("UserId: ");
                    reportService.viewReports(sc.nextInt());
                    break;

                case 3:
                    return;
            }
        } while (choice != 3);
    }

    // SOS
    static void sosMenu() {
        System.out.println("\n1. Send Location");
        int ch = sc.nextInt();
        if (ch == 1) getLocation();
    }

    static void getLocation() {
        try {
            URL url = new URL("https://ipinfo.io/json");
            BufferedReader br = new BufferedReader(
                    new InputStreamReader(url.openStream()));

            String data = "", line;
            while ((line = br.readLine()) != null) data += line;

            System.out.println("Location: " + get(data, "\"loc\": \""));

        } catch (Exception e) {
            System.out.println("Error fetching location");
        }
    }

    static String get(String data, String key) {
        int start = data.indexOf(key);
        if (start == -1) return "Not Found";
        start += key.length();
        int end = data.indexOf("\"", start);
        return data.substring(start, end);
 git remote add origin https://github.com/SohamS710/sage_new.git   }
}