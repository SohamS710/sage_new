package services;

import database.ReportDAO;
import models.Report;
import java.util.*;

public class ReportService {

    private ReportDAO dao = new ReportDAO();

    public void addReport(int userId, String desc) {
        Report r = new Report(userId, desc);
        dao.addReport(r);
    }

    public void viewReports(int userId) {
        List<Report> list = dao.getReports(userId);

        for (Report r : list) {
            System.out.println(
                r.getReportId() + " | " +
                r.getDescription()
            );
        }
    }
}