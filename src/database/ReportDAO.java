package database;

import models.Report;
import java.sql.*;
import java.util.*;

public class ReportDAO {

    public void addReport(Report report) {
        String sql = "INSERT INTO Reports(user_id, description) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, report.getUserId());
            ps.setString(2, report.getDescription());

            ps.executeUpdate();
            System.out.println("Report Added!");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Report> getReports(int userId) {
        List<Report> list = new ArrayList<>();
        String sql = "SELECT * FROM Reports WHERE user_id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Report r = new Report();
                r.setReportId(rs.getInt("report_id"));
                r.setUserId(rs.getInt("user_id"));
                r.setDescription(rs.getString("description"));
                list.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}