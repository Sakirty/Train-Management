import java.sql.*;
import java.util.*;
import java.io.*;
import java.text.*;
import java.lang.*;

public class data{
    private static Connection connection;
    private Statement statement;
    private PreparedStatement prepStatement;
    private ResultSet resultSet;
    private String query; 
    private Scanner inScan = new Scanner(System.in);

    public data(){
        String choice = "";
        System.out.println("Please Select What you would like to do: ");
        System.out.println("\t1.Add passanger");
        System.out.println("\t2.Edit passanger");
        System.out.println("\t3.View passanger");
        System.out.println("\t4.Single route trip search");
        System.out.println("\t5.Combination route trip search");
        System.out.println("\t6.Find all trains that pass through a specific station(given station, day and time)");
        System.out.println("\t7.Find routes that cross multi rails");
        System.out.println("\t8.Find similar routes(given a route)");
        System.out.println("\t9.Find stations that all trains pass through");
        System.out.println("\t10.Find all trains that does not stop at a specific station(given a station)");
        System.out.println("\t11.Find all routes taht stop at leat at x% of the station they visit(given a x)");
        System.out.println("\t12.Display a route");
        System.out.println("\t13.Find seats availability");
        System.out.println("\t14.Quit");

        //System.out.println("\t");
        choice = inScan.nextLine();
    }
    public static void main(String args[]) throws SQLException{
        String username, password;
        username = "postgres";
        password = "postgres";
        try{
            Class.forName("org.postgresql.Driver");
            String url = "jdbc:postgresql://localhost:5432/";
            connection = DriverManager.getConnection(url, username, password);
            data thing = new data();
        }
        catch(Exception Ex){
            System.out.println("Error connecting to database.  Machine Error: " +
			       Ex.toString());
        }
        finally{
            connection.close();
        }
    }
}