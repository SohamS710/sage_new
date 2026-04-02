package models;

public class Report {
    private int reportId;
    private int userId;
    private String description;

    public Report() {}

    public Report(int userId, String description) {
        this.userId = userId;
        this.description = description;
    }

    public int getReportId() { return reportId; }
    public int getUserId() { return userId; }
    public String getDescription() { return description; }

    public void setReportId(int reportId) { this.reportId = reportId; }
    public void setUserId(int userId) { this.userId = userId; }
    public void setDescription(String description) { this.description = description; }
}