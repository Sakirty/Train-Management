//package edu.pitt.cs;
import java.sql.*;
import java.util.*;
import java.io.*;
import java.text.*;
import java.lang.*;

public class p3{
    private static Connection connection;
    private static Statement statement;
    private static PreparedStatement prepStatement;
    private static ResultSet resultSet;
    private static String query; 
    private static Scanner inScan = new Scanner(System.in);

    public static void data() throws SQLException{
        try{
            String choice = "";
            promote_choice(); 
            choice = inScan.nextLine();
            if(choice.equals("1")){
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
            }
        }catch(SQLException e){

        }
    }
    public static void addPassanger(){
        System.out.println("First Name?");
        String fname = inScan.nextLine();
        System.out.println("Last Name?");
        String lname = inScan.nextLine();
        System.out.println("street?");
        String st = inScan.nextLine();
        System.out.println("town?");
        String tw = inScan.nextLine();
        System.out.println("zip?");
        String zip = inScan.nextLine();
    }
    public static void editPassanger(){

    }
    public static void viewPassanger() throws SQLException{
        try{
            System.out.println("ID?");
            String id = inScan.nextLine();
            query = "select * from passangers where passanger_id = " + id;
            statement = connection.createStatement();
            ResultSet res1 = statement.executeQuery(query);
            String fname, lname, street, town, zip;
            while(res1.next()){
                fname = res1.getString("f_name");
                lname = res1.getString("l_name");
                street = res1.getString("street");
                town = res1.getString("town");
                zip = res1.getString("zip");
                System.out.println(fname+" "+lname+" "+street+" "+town+" "+zip);
            }
        }catch(SQLException e){

        }
    }
    public static void singleSearch(){

    }
    public static void combineSearch(){

    }
    public static void allPass(){

    }
    public static void doesNotStop(){

    }
    public static void allMultiRoute(){

    }
    public static void similarRoute(){

    }
    public static void allStation(){

    }
    public static void stopPercent(){

    }
    public static void displayRoute(){

    }
    public static void seatsAvil(){
        
    }
    public static void promote_choice(){
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
    }
    public static void main(String args[]) throws
            SQLException, ClassNotFoundException {
    //jdbc:postgresql://localhost:5432/
        String username, password;
        username = "postgres";
        password = "postgres";
        try{
            Class.forName("org.postgresql.Driver");
            String url = "jdbc:postgresql://localhost:5433/postgres";
            connection = DriverManager.getConnection(url, username, password);
            //System.out.println("connected!");
            //promote_choice();
            while(true){
                data();
            }
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