import java.util.*;
import java.io.*;
import java.text.*;
import java.lang.*;
public class foo4{
    static String[] allinput = new String[1000];
    static int allindex = 0;
    public static void main(String args[]) throws FileNotFoundException{
        File file = new File("./Trains.txt");
        Scanner sc = new Scanner(file);
        String s;
        while(sc.hasNextLine()){
            s = sc.nextLine();
            String[] parts = s.split(";");
            String tempStr = "";
            tempStr = parts[0] +";"+parts[3]+";"+0+";"+"true";
            allinput[allindex]=tempStr;
            allindex++;
        }
        sc.close();
        try {
                    PrintStream out = new PrintStream(new FileOutputStream("TrainSeats.txt"));
                    for (int i = 0; i < allindex; i++)
                        out.println(allinput[i]);
                    out.close();
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                }
        System.exit(0);
    }
}