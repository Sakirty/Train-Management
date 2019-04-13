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
        else if(choice.equals("1")){
            addPassanger();
        }
        else if(choice.equals("2")){
            editPassanger();
        }
        else if(choice.equals("3")){
            viewPassanger();
        }
        else if(choice.equals("4")){
            singleSearch();  
        } 
        else if(choice.equals("5")){
            combineSearch();
        }
        else if(choice.equals("6")){
            allPass();
        }
        else if(choice.equals("7")){
            allMultiRoute();
        }
        else if(choice.equals("8")){
            similarRoute();
        }
        else if(choice.equals("9")){
            allStation();
        }
        else if(choice.equals("10")){
            doesNotStop();
        }
        else if(choice.equals("11")){
            stopPercent();
        }
        else if(choice.equals("12")){
            displayRoute();
        }
        else if(choice.equals("13")){
            seatsAvil();
        }
        else if(choice.equals("14")){
            System.out.println("EXITING");
            System.exit(0);
        }
        else{
            System.out.println("INVALID CHOICE");
            data();
        }
        choice = inScan.nextLine();
        
    }
    public void addPassanger(){

    }
    public void editPassanger(){

    }
    public void viewPassanger(){

    }
    public void singleSearch(){

    }
    public void combineSearch(){

    }
    public void allPass(){

    }
    public void doesNotStop(){

    }
    public void stopPercent(){

    }
    public void displayRoute(){

    }
    public void seatsAvil(){
        
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