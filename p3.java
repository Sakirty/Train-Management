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
        try{
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
            query = "select max(passanger_id) from passangers";
            statement = connection.createStatement();
            ResultSet res1 = statement.executeQuery(query);
            int maxid = 0;
            while(res1.next()){
                maxid = res1.getInt("max");
                //System.out.println(maxid);
            }
            maxid+=1;
            //System.out.println(maxid);
            query = "insert into passangers(passanger_id, f_name, l_name, street, town, zip) values ("+maxid+",'"+fname+"','"+lname+"','"+st+"','"+tw+"','"+zip+"')";
            ResultSet res2 = statement.executeQuery(query);
            System.out.println("ADDED!");
            res2.close();
            res1.close();
            statement.close();
        }catch(SQLException e){

        }
    }
    public static void editPassanger()throws SQLException{
        try{
            System.out.println("ID?");
            String id = inScan.nextLine();
            query = "select * from passangers where passanger_id = " + id;
            statement = connection.createStatement();
            ResultSet res1 = statement.executeQuery(query);
            String fname1, lname1, street1, town1, zip1;
            while(res1.next()){
                fname1 = res1.getString("f_name");
                lname1 = res1.getString("l_name");
                street1 = res1.getString("street");
                town1 = res1.getString("town");
                zip1 = res1.getString("zip");
                System.out.println("you selected:"+fname1+" "+lname1+" "+street1+" "+town1+" "+zip1);
            }
            System.out.println("Update? y/n");
            String ud = inScan.nextLine();
            if(ud.equals("y")){
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
                //System.out.println("get1");
                query = "update passangers set f_name = '"+fname+"', l_name = '"+lname+"', street = '"+st +"', town = '"+tw+"', zip = '"+zip+"' where passanger_id = "+ id;
                //System.out.println("get2");
                //System.out.println(query);
                int res2 = statement.executeUpdate(query);
                System.out.println("UPDATED!");
                //res2.close();
                //System.out.println(fname+"  "+lname+"  "+st+"  "+tw+"  "+zip);
            }    
            res1.close();
            statement.close();
        }catch(SQLException e){

        }
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
            res1.close();
            statement.close();
        }catch(SQLException e){

        }
    }
    public static void singleSearch()throws SQLException{
        try{
            System.out.println("What Day?");
            String day = inScan.nextLine();
            System.out.println("Start at?");
            String start = inScan.nextLine();
            System.out.println("End at?");
            String end = inScan.nextLine();
            query = "select * from single_search('" + day+"','"+start+"','"+end+"')";
            //System.out.println(query);
            statement = connection.createStatement();
            ResultSet res1 = statement.executeQuery(query);
            String routeid;
            System.out.println("Routes:");
            while(res1.next()){
                routeid = res1.getString("route_id");
                System.out.println(routeid);
            }
            res1.close();
            statement.close();
        }catch(SQLException e){

        }
    }
    public static void combineSearch()throws SQLException{
        try{
            System.out.println("What Day?");
            String day = inScan.nextLine();
            System.out.println("Start at?");
            String start = inScan.nextLine();
            System.out.println("End at?");
            String end = inScan.nextLine();
            query = "select * from combine_search('" + day+"','"+start+"','"+end+"')";
            statement = connection.createStatement();
            ResultSet res1 = statement.executeQuery(query);
            String routeid1,routeid2,stationtrans;
            System.out.println("Route1\tRoute2");
            while(res1.next()){
                routeid1 = res1.getString("route_1");
                routeid2 = res1.getString("route_2");
                stationtrans = res1.getString("trans_station");
                System.out.println(routeid1+"\t"+routeid2);
            }
            res1.close();
            statement.close();
        }catch(SQLException e){

        }
    }
    public static void allPass()throws SQLException{
        try{
            System.out.println("What station?");
            String sta = inScan.nextLine();
            System.out.println("What day?");
            String day = inScan.nextLine();
            System.out.println("What time(xx:xx)?");
            String tim = inScan.nextLine();
            query = "select * from all_pass('" + sta+"','"+day+"','"+tim+"')";
            statement = connection.createStatement();
            ResultSet res1 = statement.executeQuery(query);
            String want_train;
            System.out.println("Trains");
            while(res1.next()){
                want_train = res1.getString("want_train");
                System.out.println(want_train);
            }
            res1.close();
            statement.close();
        }catch(SQLException e){

        }
    }
    public static void allMultiRoute()throws SQLException{
        try{
            query = "select * from pass_multi();";
            statement = connection.createStatement();
            ResultSet res1 = statement.executeQuery(query);
            String mlt;
            //System.out.println("Trains");
            while(res1.next()){
                mlt = res1.getString("multi_route");
                System.out.println(mlt);
            }
            res1.close();
            statement.close();
        }catch(SQLException e){

        }
    }
    public static void similarRoute()throws SQLException{
        try{
            System.out.println("What route?");
            String sta = inScan.nextLine();
            query = "select * from same_stations('" + sta + "')";
            statement = connection.createStatement();
            ResultSet res1 = statement.executeQuery(query);
            String sr;
            System.out.println("Routes similar with "+sta);
            while(res1.next()){
                sr = res1.getString("rid");
                System.out.println(sr);
            }
            res1.close();
            statement.close();
        }catch(SQLException e){

        }
    }
    public static void allStation()throws SQLException{
        try{
            query = "select * from all_trian_pass_through();";
            statement = connection.createStatement();
            ResultSet res1 = statement.executeQuery(query);
            String mlt;
            System.out.println("Stations:");
            while(res1.next()){
                mlt = res1.getString("null_station");
                System.out.println(mlt);
            }
            res1.close();
            statement.close();
        }catch(SQLException e){

        }
    }
    public static void doesNotStop()throws SQLException{
        try{
            System.out.println("Which Stop?");
            String sta = inScan.nextLine();
            query = "select * from never_pass('" + sta + "')";
            statement = connection.createStatement();
            ResultSet res1 = statement.executeQuery(query);
            String np;
            System.out.println("Routes never pass "+sta);
            while(res1.next()){
                np = res1.getString("np_train");
                System.out.println(np);
            }
            res1.close();
            statement.close();
        }catch(SQLException e){

        }
    }
    public static void stopPercent()throws SQLException{
        try{
            System.out.println("Rate(xx.xx)?");
            String rate = inScan.nextLine();
            query = "select * from pass_rate('" + rate + "')";
            statement = connection.createStatement();
            ResultSet res1 = statement.executeQuery(query);
            String pr;
            System.out.println("Routes pass rate higher than "+ rate);
            while(res1.next()){
                pr = res1.getString("p_route");
                System.out.println(pr);
            }
            res1.close();
            statement.close();
        }catch(SQLException e){

        }
    }
    public static void displayRoute()throws SQLException{
        try{
            System.out.println("Route?");
            String route = inScan.nextLine();
            query = "select * from display_route('" + route + "')";
            statement = connection.createStatement();
            ResultSet res1 = statement.executeQuery(query);
            String day,time,train;
            System.out.println("Day\tTime\tTrain");
            while(res1.next()){
                day = res1.getString("day_get");
                time = res1.getString("time_get");
                train = res1.getString("train_get");
                System.out.println(day+"  "+time+"  "+train);
            }
            res1.close();
            statement.close();
        }catch(SQLException e){

        }
    }
    public static void seatsAvil()throws SQLException{
        
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
    public static void login() throws SQLException{
        try{
            System.out.println("Agent ID:");
            String id = inScan.nextLine();
            query = "select * from agents where agent_id = " + id;
            statement = connection.createStatement();
            ResultSet res1 = statement.executeQuery(query);
            String aid = ""; 
            String apw = "";
            while(res1.next()){
                aid = res1.getString("agent_id");
                apw = res1. getString("agent_pw");
                //System.out.print(aid+"  "+apw);
            }
            res1.close();
            statement.close();
            System.out.println("Agent PW:");
            String pw = inScan.nextLine();
            if(pw.equals(apw)){
                
            }else{
                System.out.println("WRONG PASSWORD or ID!");
                System.exit(0);
            }
        }catch(SQLException e){

        }
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
            //login();
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